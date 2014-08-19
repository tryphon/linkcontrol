require 'ipaddr'
require 'socket'
require 'facter'

class Network < ActiveForm::Base
  unloadable

  attr_accessor :id

  def to_param
    id
  end

  attr_accessor :method
  attr_accessor :static_address, :static_netmask, :static_gateway, :static_dns1

  attr_accessor :mac_address

  validates_inclusion_of :method, :in => %w{dhcp static}

  with_options :if => :manual? do |static|
    static.validates_presence_of :static_address, :static_netmask, :static_gateway, :static_dns1
    static.validate :must_use_valid_ip_addresses
    static.validate :must_use_valid_gateway_in_network
  end

  def after_initialize
    self.method ||= "dhcp"

    self.static_address ||= "192.168.1.100"
    self.static_netmask ||= "255.255.255.0"
    self.static_gateway ||= "192.168.1.1"
    self.static_dns1 ||= "192.168.1.1"
  end

  def manual?
    self.method == "static"
  end

  def new_record?
    false
  end

  def presenter
    @presenter ||= NetworkPresenter.new(self)
  end

  def facter_value(name)
    facter_interface = (id == "eth0" ? "" : "_#{id}")
    Facter.value("#{name}#{facter_interface}")
  rescue => e
    Rails.logger.error "Facter failed with #{name} : #{e}"
    nil
  end

  def address
    @address ||= facter_value "ipaddress"
  end

  def netmask
    @netmask ||= facter_value "netmask"
  end

  def mac_address
    @mac_address ||= facter_value "macaddress"
  end

  def name
    @name ||= I18n.translate(id, :scope => "networks.name", :default => "#{Network.human_name} #{id}")
  end

  @@interface_ids = %w{eth0}
  cattr_accessor :interface_ids

  def self.blank_configurations
    interface_ids.inject({}) { |map, id| map[id] = { "id" => id }; map }
  end

  def self.saved_configurations
    (PuppetConfiguration.load[:network_interfaces] or []).inject({}) do |configurations, configuration| 
      interface_id = configuration["id"]
      configurations[interface_id] = configuration if interface_ids.include?(interface_id)
      configurations 
    end
  end

  def self.configurations
    blank_configurations.merge(saved_configurations)
  end

  def self.all
    configurations.values.map do |attributes|
      Network.new attributes
    end.sort_by(&:id)
  end

  def self.find(id)
    if configuration = configurations[id.to_s]
      Network.new configuration
    end
  end

  def save(dont_valid = false)
    return false if not valid? and not dont_valid

    self.class.configurations.tap do |current_configurations|
      current_configurations[id] = attributes
      PuppetConfiguration.load.update_attributes(:network_interfaces => current_configurations.values).save
    end

    true
  end

  def update_attributes_with_save(attributes)
    update_attributes_without_save attributes
    save
  end
  alias_method_chain :update_attributes, :save

  private

  def must_use_valid_ip_addresses
    [:static_address, :static_gateway, :static_dns1].each do |attribute|
      begin
        IPAddr.new(send(attribute), Socket::AF_INET) if errors.on(attribute).blank?
      rescue
        errors.add(attribute, :not_a_valid_ip_address)
      end
    end

    if errors.on(:static_address).blank? and errors.on(:static_netmask).blank?
      begin
        IPAddr.new("#{static_address}/#{static_netmask}", Socket::AF_INET)
      rescue
        errors.add(:static_netmask, :not_a_valid_netmask)
      end
    end
  end

  def must_use_valid_gateway_in_network
    if errors.on(:static_address).blank? and errors.on(:static_netmask).blank? and errors.on(:static_gateway).blank?
      if static_address == static_gateway
        errors.add(:static_gateway, :can_be_the_static_address)
      end

      static_gateway_ip = 
        begin
          IPAddr.new(static_gateway)
        rescue 
          errors.add(:static_gateway, :not_a_valid_ip_address)
        end

      unless IPAddr.new("#{static_address}/#{static_netmask}", Socket::AF_INET).include?(static_gateway_ip)
        errors.add(:static_gateway, :not_in_local_network)
      end
    end
  end

  def must_use_valid_dns
    if errors.on(:static_address).blank? and errors.on(:static_dns1).blank?
      if static_address == static_dns1
        errors.add(:static_dns1, :can_be_the_static_address)
      end
    end
  end

end

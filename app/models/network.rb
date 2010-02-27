require 'ipaddr'
require 'socket'

class Network < ActiveForm::Base

  @@configuration_file = "tmp/config.pp"
  cattr_accessor :configuration_file

  @@system_update_command = nil
  cattr_accessor :system_update_command

  @@default_udp_port = 14100
  cattr_accessor :default_udp_port

  @@default_http_port = 8000
  cattr_accessor :default_http_port

  attr_accessor :method
  attr_accessor :static_address, :static_netmask, :static_gateway, :static_dns1

  attr_accessor :linkstream_target_host

  def self.acts_as_ip_port(*names)
    names.each do |name|
      attr_accessor name
      define_method("#{name}=") do |value|
        value = value.blank? ? nil : value.to_i
        instance_variable_set "@#{name}", value
      end
      validates_numericality_of name, :only_integer => true, :greater_than => 1024, :less_than => 65536, :message => :not_a_user_port
    end
  end

  acts_as_ip_port :linkstream_target_port, :linkstream_udp_port, :linkstream_http_port

  validates_inclusion_of :method, :in => %w{dhcp static}

  with_options :if => :manual? do |static|
    static.validates_presence_of :static_address, :static_netmask, :static_gateway, :static_dns1
    static.validate :must_use_valid_ip_addresses
    static.validate :must_use_valid_gateway_in_network
  end

  validate :must_found_linkstream_target_host

  def after_initialize
    self.method ||= "dhcp"
    self.static_address ||= "192.168.1.100"
    self.static_netmask ||= "255.255.255.0"
    self.static_gateway ||= "192.168.1.1"
    self.static_dns1 ||= "192.168.1.1"

    self.linkstream_target_host ||= "localhost"

    use_default_ports
  end

  before_validation :use_default_ports

  def use_default_ports
    self.linkstream_target_port ||= default_udp_port
    self.linkstream_udp_port ||= default_udp_port
    self.linkstream_http_port ||= default_http_port
  end

  def manual?
    self.method == "static"
  end

  def save
    return false unless valid?

    File.open(configuration_file, "w") do |f|
      Network.attribute_names.each do |attribute|
        value = send(attribute)
        configuration_key = attribute.start_with?("linkstream") ? attribute : "network_#{attribute}" 
        
        f.puts "$#{configuration_key}=\"#{value}\""
      end
    end

    if system_update_command
      system system_update_command
    else
      true
    end
  rescue
    false
  end

  def new_record?
    false
  end

  def load
    File.readlines(configuration_file).collect(&:strip).each do |line|
      if line =~ /^\$([^=]+)="(.*)"$/
        configuration_key, value = $1, $2

        attribute = configuration_key.gsub(/^network_/, '')
        send("#{attribute}=", value)
      end
    end
  end

  def self.load
    Network.new.tap do |network|
      network.load
    end
  end

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

      unless IPAddr.new("#{static_address}/#{static_netmask}", Socket::AF_INET).include?(IPAddr.new(static_gateway))
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

  def must_found_linkstream_target_host
    return unless errors.on(linkstream_target_host).blank?

    begin
      if linkstream_target_host =~ /[0-9.]+/
        IPAddr.new(linkstream_target_host, Socket::AF_INET)
      else
        Socket.gethostbyname(linkstream_target_host)
      end
    rescue
      errors.add(:linkstream_target_host, :not_valid_hostname)
    end
  end

end

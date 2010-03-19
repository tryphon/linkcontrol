require 'ipaddr'

class LinkStream < ActiveForm::Base
  include PuppetConfigurable

  def puppet_configuration_prefix
    "linkstream"
  end

  @@default_udp_port = 14100
  cattr_accessor :default_udp_port

  @@default_http_port = 8000
  cattr_accessor :default_http_port

  attr_accessor :target_host

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

  acts_as_ip_port :target_port, :udp_port, :http_port

  def after_initialize
    self.target_host ||= "localhost"
    use_default_ports
  end

  before_validation :use_default_ports
  validate :must_found_target_host

  def use_default_ports
    self.target_port ||= default_udp_port
    self.udp_port ||= default_udp_port
    self.http_port ||= default_http_port
  end

  def new_record?
    false
  end

  def self.load
    self.new.tap(&:load)
  end

  def must_found_target_host
    return unless errors.on(target_host).blank?

    begin
      if target_host =~ /^[0-9\.]+$/
        IPAddr.new(target_host, Socket::AF_INET)
      else
        Socket.gethostbyname(target_host)
      end
    rescue
      errors.add(:target_host, :not_valid_hostname)
    end
  end

end

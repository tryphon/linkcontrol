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

  include ActsAsIpPort
  acts_as_ip_port :target_port, :udp_port, :http_port, :user_port => true

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

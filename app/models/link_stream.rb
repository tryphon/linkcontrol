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
  include HostValidation
  validates_host :target_host

  include ActsAsIpPort
  acts_as_ip_port :target_port, :udp_port, :user_port => true
  acts_as_ip_port :http_port, :user_port => true, :allow_blank => true

  def after_initialize
    self.target_host ||= "localhost"
    self.http_port ||= default_http_port
    use_default_ports
  end

  before_validation :use_default_ports

  def use_default_ports
    self.target_port ||= default_udp_port
    self.udp_port ||= default_udp_port
  end

  def new_record?
    false
  end

  def http_enabled?
    not http_port.blank?
  end

end

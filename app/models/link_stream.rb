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

  attr_accessor :packetizer_interleaving, :packetizer_repeat, :packetizer_packet_size

  with_options(:only_integer => true, :allow_blank => true) do |stream|
    stream.validates_numericality_of :packetizer_interleaving, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 10
    stream.validates_numericality_of :packetizer_repeat, :greater_than_or_equal_to => 1, :less_than_or_equal_to => 11
    stream.validates_numericality_of :packetizer_packet_size, :greater_than_or_equal_to => 100, :less_than_or_equal_to => 10.kilobytes
  end

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

  def with_packetizer_properties?
    not [packetizer_interleaving, packetizer_repeat, packetizer_packet_size].all?(&:blank?)
  end

end

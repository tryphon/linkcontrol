require 'ipaddr'
require 'open-uri'
require 'facter'

class LinkStream < ActiveForm::Base
  include PuppetConfigurable

  @@default_port = 8000
  cattr_accessor :default_port

  attr_accessor :host
  include HostValidation
  validates_host :host, :allow_blank => true

  include ActsAsIpPort
  acts_as_ip_port :port, :user_port => true

  attr_accessor :password
  validates_format_of :password, :with => /^[A-Za-z0-9]*$/
  validates_length_of :password, :minimum => 6, :allow_blank => true
  validates_presence_of :password, :if => :push?

  attr_accessor :mode
  validates_inclusion_of :mode, :in => %{push pull}

  def push?
    mode == "push"
  end

  def pull?
    mode == "pull"
  end

  def after_initialize
    use_default_ports
    self.mode ||= (self.host.present? ? "pull" : "push")
  end

  before_validation :use_default_ports

  def use_default_ports
    self.port ||= default_port
  end

  def new_record?
    false
  end

  UNKNOWN_PUBLIC_IP = "unknown"

  def raw_public_ip
    @raw_public_ip ||= Rails.cache.fetch("LinkStream#public_ip", :expires_in => 5.minutes) do
      begin
        Timeout::timeout(5) do
          open('http://www.freecast.org/reference.php',&:read)
        end
      rescue Exception => e
        Rails.logger.error "Failed to retrieve public ip : #{e}"
        UNKNOWN_PUBLIC_IP
      end
    end
  end

  def public_ip
    raw_public_ip unless raw_public_ip == UNKNOWN_PUBLIC_IP
  end

  def local_ip
    @local_ip ||= Network.find("eth0").address
  end

end

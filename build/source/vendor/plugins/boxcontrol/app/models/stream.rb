require 'metalive'

class Stream < ActiveForm::Base
  include ActsAsIpPort
  include HostValidation
  extend StripAttributes

  strip_attributes!

  attr_accessor :name, :id, :description, :genre, :related_url, :enabled
  validates_presence_of :name

  attr_accessor :server, :server_type, :password, :mount_point
  acts_as_ip_port :port, :allow_blank => true

  validates_presence_of :server_type

  def self.validates_presence_when_server_supports_of(*attributes)
    attributes.each do |attribute|
      supported_attribute = Proc.new do |stream| 
        stream.server_type.nil? or stream.server_type.supports?(attribute)
      end

      validates_presence_of attribute, :if => supported_attribute
    end
  end

  validates_presence_when_server_supports_of :server, :port, :password, :mount_point

  validates_format_of :mount_point, :with => %r{^[^/]}, :allow_blank => true

  @@available_formats = [ :vorbis, :mp3, :aac, :aacp ]
  @@available_modes = [ :vbr, :cbr ]
  cattr_reader :available_formats

  attr_accessor :format
  validates_presence_of :format
  validates_inclusion_of :format, :in => available_formats

  attr_accessor :mode
  validates_presence_of :mode
  validate :validate_mode

  attr_accessor :quality
  validates_numericality_of :quality, :only_integer => true, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10
  with_options :if => Proc.new { |s| s.allows_vbr? and s.mode == :vbr } do |when_requires_quality|
    when_requires_quality.validates_presence_of :quality
  end

  attr_accessor :bitrate
  validate :bitrate_is_available

  def bitrate_is_available
    errors.add(:bitrate, :inclusion) unless allowed_bitrates.include?(bitrate)
  end

  with_options :if => Proc.new { |s| s.allows_cbr? and s.mode == :cbr } do |when_requires_bitrate|
    when_requires_bitrate.validates_presence_of :bitrate
  end

  validates_host :server, :allow_blank => true

  def after_initialize
    self.format ||= :vorbis
    self.mode ||= :vbr
    self.quality ||= 4
    self.server_type ||= :icecast2
    self.enabled = true if self.enabled.nil?

    if new_record?
      self.attributes = Stream.default_attributes.update(self.attributes)
    end
  end

  def self.requires_cbr?(format)
    format == :aacp
  end
  
  def self.allows_cbr?(format)
    [:vorbis, :mp3, :aac, :aacp].include? format
  end

  def self.requires_quality?(format)
    false
  end

  def self.allows_vbr?(format)
    [:vorbis, :mp3, :aac].include? format
  end

  def self.requires_bitrate?(format)
    requires_cbr? format
  end

  def requires_quality?
    self.class.requires_quality?(self.format)
  end

  def requires_bitrate?
    self.class.requires_bitrate?(self.format)
  end

  def allows_cbr?
    self.class.allows_cbr?(self.format)
  end

  def allows_vbr?
    self.class.allows_vbr?(self.format)
  end

  def allowed_bitrates
    self.class.allowed_bitrates(format)
  end

  def self.allowed_bitrates(format = nil)
    case format
    when :mp3
      [32, 40, 48, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320]
    when :vorbis
      [48, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320]
    when :aac
      [8, 16, 24, 32, 40, 48, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320 ]
    when :aacp
      [16, 22, 24, 32, 44, 48, 64, 72, 96]
    when nil
      [:mp3, :vorbis, :aac, :aacp].inject({}) do |map,format|
        map[format] = allowed_bitrates(format)
        map
      end
    else
      []
    end
  end

  def self.default_attributes
    if reference_stream = Stream.last
      { 
        :server => reference_stream.server,
        :port => reference_stream.port,
        :description => reference_stream.description,
        :genre => reference_stream.genre,
        :related_url => reference_stream.related_url
      }.with_indifferent_access
    else
      { 
        :port => 8000
      }.with_indifferent_access
    end
  end

  def url
    "#{server}:#{port}#{path}"
  end

  def path
    mount_point and mount_point.start_with?('/') ? mount_point : "/#{mount_point}"
  end

  class ServerType

    attr_accessor :id, :disabled_attributes

    def initialize(id, options = {})
      self.id = id
      self.disabled_attributes = Array(options[:disable])
    end

    def name
      I18n.translate(id, :scope => "streams.server_types")
    end

    delegate :to_s, :to => :id

    @@icecast2 = new :icecast2
    cattr_reader :icecast2

    @@shoutcast = new :shoutcast, :disable => :mount_point
    cattr_reader :shoutcast

    @@local = new :local, :disable => [:server, :port, :password]
    cattr_reader :local

    @@tryphon = new :tryphon, :disable => [:server, :port, :password]
    cattr_reader :tryphon

    @@all = [icecast2, shoutcast, local] # tryphon
    cattr_reader :all

    all.each do |type|
      define_method("#{type.id}?") do
        id == type.id
      end
    end

    def self.find(id)
      return id if ServerType === id

      id = id.to_sym
      all.find { |t| t.id == id }
    end

    def supports?(attribute)
      not disabled_attributes.include? attribute.to_sym
    end
    
  end

  validates_inclusion_of :server_type, :in => ServerType.all

  def server_type=(server_type)
    @server_type = server_type ? ServerType.find(server_type) : nil
  end

  def icecast_server?
    server_type == :icecast2
  end

  def format=(format)
    @format = format ? format.to_sym : nil
  end

  def mode=(mode)
    @mode = mode ? mode.to_sym : nil
  end

  def quality=(quality)
    @quality = quality ? quality.to_i : nil
  end

  def bitrate=(bitrate)
    @bitrate = bitrate ? bitrate.to_i : nil
  end

  def mount_point=(mount_point)
    @mount_point = mount_point ? mount_point.gsub(%r{^/}, '') : nil
  end

  alias_method :enabled?, :enabled
  def disabled?
    not enabled?
  end

  def enabled=(enabled)
    @enabled = [true, 1, "true", "1"].include?(enabled)
  end

  def toggle(attribute)
    self[attribute] = !send("#{attribute}?")
    self
  end

  def presenter
    @presenter ||= StreamPresenter.new self
  end

  @@maximum_count = 4
  cattr_accessor :maximum_count

  def self.can_create?
    count < maximum_count
  end

  def new_record?
    self.id.nil?
  end

  def to_param
    self.id.to_s
  end

  def ==(other)
    other and self.id == other.id
  end

  def update_attributes_with_save(attributes)
    update_attributes_without_save attributes
    save
  end
  alias_method_chain :update_attributes, :save

  def save(dont_valid = false)
    return false if not valid? and not dont_valid

    self.id ||= (Stream.all.collect(&:id).max or 0) + 1
    PuppetConfiguration.load.update_attributes(self.attributes, "stream_#{self.id}").save
  end

  def destroy
    unless new_record?
      streams = Stream.all
      PuppetConfiguration.transaction do
        PuppetConfiguration.load.clear("stream_")
        streams.delete self

        streams.each_with_index do |stream, index|
          stream.id = index + 1
          stream.save(true)
        end
      end
    end
  end

  def self.all
    config = PuppetConfiguration.load
    (1..4).collect do |n|
      attributes = config.attributes("stream_#{n}")
      unless attributes.blank?
        Stream.new attributes.update(:id => n) 
      end
    end.compact
  end

  def self.count
    all.size
  end

  def self.find(id)
    id = id.to_i
    all.find { |stream| stream.id == id }
  end

  def self.first
    all.first
  end

  def self.last
    all.last
  end

  def metadata_updater
    attributes = { :server => server, :port => port, :password => password }
    unless server_type.shoutcast?
      Metalive::Icecast.new attributes.update(:mount => mount_point)
    else
      Metalive::Shoutcast.new attributes.update(:port => port-1)
    end
  end

  private

  def validate_mode
    unless send("allows_#{mode}?")
      errors.add(:mode, :not_available)
    end
  end

end

class OutgoingStream < Stream

  def puppet_configuration_prefix
    "link_outgoing"
  end

  attr_accessor :quality
  validates_numericality_of :quality, :greater_than_or_equal_to => 0, :less_than_or_equal_to => 10
  validates_presence_of :quality

  validates_presence_of :host, :port, :if => :push?

  def after_initialize
    self.quality ||= 5
    super
  end

  def quality=(quality)
    @quality = quality.present? ? quality.to_i : nil
  end

end

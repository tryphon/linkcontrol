class StreamModePresenter

  attr_accessor :mode, :name, :wikipedia_page

  def initialize(mode, name, wikipedia_page)
    @mode, @name, @wikipedia_page = mode, name, wikipedia_page
  end

  @@instances = 
    [ 
     StreamModePresenter.new(:cbr, "CBR", "Constant_bitrate"),
     StreamModePresenter.new(:vbr, "VBR", "Variable_bitrate"),
    ]

  def wikipedia_url
    "http://#{I18n.locale}.wikipedia.org/wiki/#{wikipedia_page}"
  end

  def self.find(mode)
    all.find { |p| p.mode == mode }
  end

  def self.all
    @@instances
  end

end

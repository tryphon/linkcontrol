class PuppetConfiguration

  @@configuration_file = "tmp/config.pp"
  cattr_accessor :configuration_file

  @@system_update_command = nil
  cattr_accessor :system_update_command

  def initialize
    @attributes = HashWithIndifferentAccess.new
  end

  def fetch(key)
    @attributes[key]
  end
  alias_method :[], :fetch

  def push(key, value)
    @attributes[key] = value
  end
  alias_method :[]=, :push

  def empty?
    @attributes.empty?
  end

  def attributes(prefix = nil)
    return @attributes.dup.symbolize_keys if prefix.blank?

    prefix = normalize_prefix(prefix)

    @attributes.inject({}) do |selection, pair|
      key, value = pair
      if key.to_s.start_with?(prefix)
        unprefixed_key = key[prefix.length..-1]
        selection[unprefixed_key.to_sym] = value
      end
      selection
    end
  end

  def update_attributes(values, prefix = nil)
    prefix = normalize_prefix(prefix)
    values.each_pair do |key, value|
      push("#{prefix}#{key}", value)
    end
    self
  end
  
  def normalize_prefix(prefix)
    if prefix
      prefix = prefix.to_s
      prefix.last == '_' ? prefix : "#{prefix}_" 
    end
  end

  def load
    return unless File.exists?(configuration_file)
    File.readlines(configuration_file).collect(&:strip).each do |line|
      if line =~ /^\$([^=]+)="(.*)"$/
        configuration_key, value = $1, $2
        @attributes[configuration_key] = value
      end
    end
  end

  def self.load
    self.new.tap(&:load)
  end

  def save
    File.open(configuration_file, "w") do |f|
      @attributes.each_pair do |key, value|
        f.puts "$#{key}=\"#{value}\""
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

end

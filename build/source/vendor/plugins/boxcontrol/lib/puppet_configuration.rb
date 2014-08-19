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

  def clear(prefix = "")
    prefix = prefix.to_s
    @attributes.each_key do |key|
      @attributes.delete(key) if key.start_with?(prefix)
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
      key, value =
        case line 
        when /^\$([^=]+)="(.*)"$/
          key, raw_value = $1, $2
          unescaped_value = raw_value.gsub('\n', "\n").gsub('\"','"')
          [key, unescaped_value]
        when /^\$([^=]+)=\[(.*)\]$/
          key, raw_value = $1, $2
          value = 
            begin
              eval("[#{raw_value}]") 
            rescue Exception => e
              Rails.logger.error "Can't read value '[#{raw_value}]' : #{e}"
              nil
            end
          [key, value]
        end
      
      @attributes[key] = value if key and value
    end
  end

  def self.load
    unless pending_transaction?
      self.new.tap(&:load)
    else
      Thread.current[:puppet_configuration]
    end
  end

  def self.transaction(&block)
    configuration = PuppetConfiguration.load
    Thread.current[:puppet_configuration] = configuration
    begin
      yield configuration
    ensure
      Thread.current[:puppet_configuration] = nil
    end
    configuration.save
  end

  def self.pending_transaction?
    not Thread.current[:puppet_configuration].nil?
  end

  def save
    return true if PuppetConfiguration.pending_transaction?

    Rails.logger.debug "write puppet configuration into #{configuration_file}"
    File.open(configuration_file, "w") do |f|
      @attributes.each_pair do |key, value|
        string_value =
          case value
          when Array
            value.inspect
          else
            escaped_value = value.to_s.gsub("\n",'\n').gsub("\r","").gsub('"','\"')
            "\"#{escaped_value}\""
          end
        f.puts "$#{key}=#{string_value}"
      end
    end

    if system_update_command
      system system_update_command
    else
      true
    end
  rescue => e
    Rails.logger.error "Can't save configuration : #{e}"
    false
  end
  
  def self.destroy
    File.delete(PuppetConfiguration.configuration_file) if File.exists?(PuppetConfiguration.configuration_file)
  end

end

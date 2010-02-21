class Network < ActiveForm::Base

  @@configuration_file = "tmp/config.pp"
  cattr_accessor :configuration_file

  attr_accessor :method
  attr_accessor :static_address
  attr_accessor :static_netmask
  attr_accessor :static_gateway
  attr_accessor :static_dns1

  attr_accessor :linkstream_target_host

  def self.acts_as_ip_port(*names)
    names.each do |name|
      attr_accessor name
      define_method("#{name}=") do |value|
        value = value.to_i
        instance_variable_set "@#{name}", value
      end
    end
  end

  acts_as_ip_port :linkstream_target_port, :linkstream_udp_port, :linkstream_http_port

  def save
    File.open(configuration_file, "w") do |f|
      Network.attribute_names.each do |attribute|
        value = send(attribute)
        configuration_key = attribute.start_with?("linkstream") ? attribute : "network_#{attribute}" 
        
        f.puts "$#{configuration_key}=\"#{value}\""
      end
    end

    true
  rescue
    false
  end

  def new_record?
    false
  end

  def load
    File.readlines(configuration_file).collect(&:strip).each do |line|
      if line =~ /^\$([^=]+)="(.*)"$/
        configuration_key, value = $1, $2

        attribute = configuration_key.gsub(/^network_/, '')
        send("#{attribute}=", value)
      end
    end
  end

  def self.load
    Network.new.tap do |network|
      network.load
    end
  end

end

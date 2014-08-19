class StreamPresenter

  def initialize(stream)
    @stream = stream
  end

  def format
    StreamFormatPresenter.find(@stream.format)
  end

  def mode
    StreamModePresenter.find(@stream.mode)
  end

  def status_class
    @stream.enabled? ? "enabled" : "disabled"
  end

  def name_with_status
    returning([]) do |parts|
      parts << @stream.name
      if @stream.disabled?
        parts << "(#{I18n.translate('streams.disabled')})" 
      end
    end.join(" ")
  end

  @@description_attributes = %w{description genre related_url}

  def blank_description_attributes?
    @@description_attributes.collect do |attribute|
      @stream.send(attribute)
    end.all?(&:blank?)
  end

  def options_for_server_type
    selected_server_type = @stream.server_type

    # FIXME in rails 3, options_for_select supports a map with html attributes
    Stream::ServerType.all.map do |server_type| 
      selected_attribute = ' selected="selected"' if selected_server_type == server_type
      data_disabled_attribute = " data-disabled=\"#{server_type.disabled_attributes.join(' ')}\"" if server_type.disabled_attributes.present?

      "<option value=\"#{server_type.id}\" #{selected_attribute}#{data_disabled_attribute}>#{server_type.name}</option>"
    end.join("\n")
  end

end

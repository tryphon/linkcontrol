module StreamsHelper

  def format_radio_button(form, format_presenter)
    data_attributes = {
      :"data-allows-cbr" => format_presenter.allows_cbr?, 
      :"data-allows-vbr" => format_presenter.allows_vbr?
    }
    form.radio_button :format, format_presenter.format, data_attributes
  end

  def format_radio_buttons(form)
    content_tag(:ul) do
      StreamFormatPresenter.all.collect do |format_presenter|
        content_tag(:li) do 
          [ format_radio_button(form, format_presenter),
            form.label("format_#{format_presenter.format}", format_presenter.name),
            link_to(image_tag('ui/help.png', :alt => '?'), format_presenter.wikipedia_url) ].join(" ")
        end
      end.join("\n")
    end
  end

  def mode_radio_button(form, mode_presenter)
    data_attributes = {
      :"data-allows-cbr" => mode_presenter.mode == :cbr,
      :"data-allows-vbr" => mode_presenter.mode == :vbr
    }
    form.radio_button :mode, mode_presenter.mode, data_attributes
  end

  def mode_radio_buttons(form)
    content_tag(:ul) do
      StreamModePresenter.all.collect do |mode_presenter|
        content_tag(:li) do
          [ mode_radio_button(form, mode_presenter),
            form.label("mode_#{mode_presenter.mode}", mode_presenter.name),
            link_to(image_tag('ui/help.png', :alt => '?'), mode_presenter.wikipedia_url) ].join(" ")
        end
      end.join("\n")
    end
  end

end

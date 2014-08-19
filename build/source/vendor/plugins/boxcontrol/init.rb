# Include hook code here

ActionView::Helpers::AssetTagHelper.register_javascript_include_default "boxcontrol"

Rails.configuration.after_initialize do
  require 'box_ext'
end

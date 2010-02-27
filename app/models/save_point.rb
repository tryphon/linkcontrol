require 'fileutils'

class SavePoint < ActiveForm::Base

  def transient_file
    Network.configuration_file
  end

  @@persistent_file = "tmp/config_saved.pp"
  cattr_accessor :persistent_file

  def save
    FileUtils.copy_file(transient_file, persistent_file)
    true
  rescue
    false
  end

end

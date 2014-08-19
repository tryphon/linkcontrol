$: << "#{File.dirname(__FILE__)}/../../vendor/plugins/user_interface/lib"
require 'user_interface/tasks'

UserInterface::Tasks::Css.new :stylesheet, :color => "#ea5d05", :logo => 'linkbox'
UserInterface::Tasks::Install.new :logo => 'linkbox'


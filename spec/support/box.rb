RSpec.configure do |config|
  config.before(:suite) do
    Box::PuppetConfiguration.configuration_file = "tmp/config_test.pp"
    Box::PuppetConfiguration.system_update_command = "/bin/true"

    Box::Release.latest_url = "public/updates/latest.yml"
    Box::Release.current_url = "public/current.yml"
    Box::Release.install_command = "/bin/true"
  end

  config.before do
    FileUtils.rm_f Box::PuppetConfiguration.configuration_file
  end
end

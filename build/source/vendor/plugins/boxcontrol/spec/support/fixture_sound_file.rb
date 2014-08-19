module FixtureSoundFileSupport
  def fixture_sound_file(format = :ogg)
    filename = File.expand_path "#{File.dirname __FILE__}/../fixtures/test.#{format}"
    
    unless File.exists?(filename)
      Sox::Command.new do |sox| 
        sox.input fixture_sound_file(:ogg)
        sox.output filename
      end.run!
    end
    
    filename
  end
end

include FixtureSoundFileSupport

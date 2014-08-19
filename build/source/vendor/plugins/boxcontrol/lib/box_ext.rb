require 'box'

class Box::Release

  def self.human_name
    I18n.translate "activerecord.models.release"
  end

  def presenter
    @presenter ||= ReleasePresenter.new self
  end

  def to_param
    status.installed? ? "current" : "latest"
  end

end

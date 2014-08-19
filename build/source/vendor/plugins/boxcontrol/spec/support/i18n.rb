module I18n
  def self.with_locale(locale)
    current_local = default_locale
    begin
      default_locale = locale
    ensure
      default_locale = current_local
    end
  end
end

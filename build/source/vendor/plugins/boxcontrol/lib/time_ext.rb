class Time

  def floor(attribute, modulo)
    actual = self.send(attribute)
    self.change(attribute => actual - actual%modulo)
  end

end

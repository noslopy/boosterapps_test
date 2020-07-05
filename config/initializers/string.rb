class String
  def to_uri
    URI(self)
  end
end
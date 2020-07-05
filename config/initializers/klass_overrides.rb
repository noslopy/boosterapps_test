class String
  def to_uri
    URI(self)
  end

  def to_bool
    return true if self == true || self =~ (/^(true|t|yes|y|1)$/i)
    return false if self == false || self.blank? || self =~ (/^(false|f|no|n|0)$/i)
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class Fixnum
  def to_bool
    return true if self == 1
    return false if self == 0
    raise ArgumentError.new("invalid value for Boolean: \"#{self}\"")
  end
end

class TrueClass
  def to_i; 1; end
  def to_bool; self; end
end

class FalseClass
  def to_i; 0; end
  def to_bool; self; end
end

class NilClass
  def to_bool; false; end
end


class Float
  def prettify
    to_i == self ? to_i : self
  end
end


class String
  def pretty
    self.gsub(/[^\d\.]/, '').to_f.prettify
  end
end

class Array
  def custom_difference(other)
    cpy = dup
    other.each do |e|
      ndx = cpy.rindex(e)
      cpy.delete_at(ndx) if ndx
    end
    cpy
  end
end
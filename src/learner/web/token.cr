require "random/secure"

class Learner::Web::Token
  property secret : String
  property value : String

  def initialize(@value, secret)
    @secret = secret || self.class.generate
  end

  def to_s
    "#{value}.#{secret}"
  end

  def self.generate : String
    Random::Secure.hex(64)
  end
end

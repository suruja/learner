require "json"

class Learner::JSON
  property json : String

  def initialize(@json)
  end

  def parse
    ::JSON.parse(json)
  end

  def to_vector : Learner::Vector
    parse.as_a.map { |i| i.as_f }.as(Learner::Vector)
  end

  def to_vectors : Learner::Vectors
    parse.as_a.map { |a|
      a.as_a.map { |i|
        i.as_f
      }
    }.as(Learner::Vectors)
  end
end

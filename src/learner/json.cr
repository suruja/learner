require "json"

class Learner::JSON
  property json : String

  def initialize(@json)
  end

  def parse
    ::JSON.parse(json)
  end

  def to_vector : Learner::Vector
    parse.as_a.map { |i|
      case i
      when .as_f? then i.as_f
      when .as_i? then i.as_i.to_f
      else             raise Exception.new
      end
    }.as(Learner::Vector)
  end

  def to_vectors : Learner::Vectors
    parse.as_a.map { |a|
      a.as_a.map { |i|
        case i
        when .as_f? then i.as_f
        when .as_i? then i.as_i.to_f
        else             raise Exception.new
        end
      }
    }.as(Learner::Vectors)
  end
end

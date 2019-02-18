require "json"

class Learner::Engine::JSON
  property json : String

  def initialize(@json)
  end

  def parse
    ::JSON.parse(json)
  end

  def to_vector : Vector
    parse.as_a.map { |i|
      case i
      when .as_f? then i.as_f
      when .as_i? then i.as_i.to_f
      else             raise Exception.new
      end
    }.as(Vector)
  end

  def to_vectors : Vectors
    parse.as_a.map { |a|
      a.as_a.map { |i|
        case i
        when .as_f? then i.as_f
        when .as_i? then i.as_i.to_f
        else             raise Exception.new
        end
      }
    }.as(Vectors)
  end
end

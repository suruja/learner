require "./ruler"

class Learner::Engine::Classifier
  property value : Vector
  property category : Vector?
  property categories : VectorSet
  property confidence : Float64

  def initialize(@value, @categories)
    @confidence = 0.0
    @category = nil
  end

  def run
    @category = categories.min_by { |ctg| Ruler.new(ctg, value).distance }
    @confidence = 100.0 * (1.0 - Ruler.new(@category.as(Vector), value).distance)
  end
end

require "./ruler"

class Learner::Classifier
  property value : Learner::Vector
  property category : Learner::Vector?
  property categories : Learner::Vectors
  property confidence : Float64

  def initialize(@value, @categories)
    @confidence = 0.0
    @category = nil
  end

  def run
    @category = categories.min_by { |ctg| Learner::Ruler.new(ctg, value).distance }
    @confidence = 100.0 * (1.0 - Learner::Ruler.new(@category.as(Learner::Vector), value).distance)
  end
end

class Learner::Ruler
  property a : Learner::Vector
  property b : Learner::Vector

  def initialize(@a, @b)
  end

  def distance
    a.each_with_index.reduce(0.0) { |memo, (coord, i)|
      memo + Math.sqrt((coord - b[i]) ** 2)
    }
  end
end

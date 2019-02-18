class Learner::Engine::Ruler
  property a : Vector
  property b : Vector

  def initialize(@a, @b)
  end

  def distance
    a.each_with_index.reduce(0.0) { |memo, (coord, i)|
      memo + Math.sqrt((coord - b[i]) ** 2)
    }
  end
end

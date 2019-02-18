require "./engine/json"
require "./engine/csv_adapter"
require "./engine/classifier"
require "./engine/base"

module Learner::Engine
  extend self

  alias Vector = Array(Float64)
  alias Vectors = Array(Vector)

  class FileNotFound < ::Exception; end

  def run(machine_id : String, value : String) : Vector
    learner = Learner::Engine::Base.new(machine_id)
    learner.load
    vector = Learner::Engine::JSON.new(value).to_vector
    learner.run(vector)
  end

  def classify(machine_id : String, value : String, categories : String) : Classifier
    learner = Learner::Engine::Base.new(machine_id)
    learner.load
    vector = Learner::Engine::JSON.new(value).to_vector
    learner.classify(
      value: vector,
      categories: Learner::Engine::JSON.new(categories).to_vectors,
    )
  end
end

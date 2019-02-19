require "./engine/json"
require "./engine/csv_adapter"
require "./engine/classifier"
require "./engine/base"

module Learner::Engine
  extend self

  ROOT_PATH = File.expand_path(
    ENV.fetch("KEMAL_ENV", "development") == "test" ? "#{__DIR__}/../../spec" : "#{__DIR__}/../.."
  )

  alias Vector = Array(Float64)
  alias Vectors = Array(Vector)

  class FileNotFound < ::Exception; end

  class IdAlreadyTaken < ::Exception; end

  def run(engine_id : String, value : String) : Vector
    learner = Learner::Engine::Base.new(engine_id)
    learner.load
    vector = Learner::Engine::JSON.new(value).to_vector
    learner.run(vector)
  end

  def classify(engine_id : String, value : String, categories : String) : Classifier
    learner = Learner::Engine::Base.new(engine_id)
    learner.load
    vector = Learner::Engine::JSON.new(value).to_vector
    learner.classify(
      value: vector,
      categories: Learner::Engine::JSON.new(categories).to_vectors,
    )
  end
end

require "./engine/json"
require "./engine/csv_adapter"
require "./engine/upload"
require "./engine/categories"
require "./engine/classifier"
require "./engine/base"

module Learner::Engine
  extend self

  ROOT_PATH = File.expand_path(
    ENV.fetch("KEMAL_ENV", "development") == "test" ? "#{__DIR__}/../../spec" : "#{__DIR__}/../../data"
  )

  alias Vector = Array(Float64)
  alias Vectors = Array(Vector)
  alias VectorSet = Set(Vector)
  alias Matrix = Array(Vectors)

  class FileNotFound < ::Exception; end

  class IdAlreadyTaken < ::Exception; end

  def run(engine_id : String, value : String) : Vector
    learner = Learner::Engine::Base.new(engine_id)
    learner.load
    vector = Learner::Engine::JSON.new(value).to_vector
    learner.run(vector)
  end

  def classify(engine_id : String, value : String) : Classifier
    learner = Learner::Engine::Base.new(engine_id)
    learner.load
    vector = Learner::Engine::JSON.new(value).to_vector
    learner.classify(vector)
  end

  def destroy(engine_id : String, filename : String)
    engine_path = Learner::Engine::Base.path(engine_id)
    upload_path = Learner::Engine::CSVAdapter.path(filename)
    begin
      File.delete(upload_path)
      File.delete(engine_path)
    rescue Errno
      raise Learner::Engine::FileNotFound.new
    end
  end
end

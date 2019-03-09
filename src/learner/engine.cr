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

  def build(engine_id : String, filename : String, input_size : Int32, output_size : Int32, body : IO, mode : Learner::Engine::Upload::Mode)
    learner = Learner::Engine::Base.new(engine_id)
    adapter = Learner::Engine::CSVAdapter.new(
      filename: filename,
      input_size: input_size,
      output_size: output_size,
    )
    engine_upload = Learner::Engine::Upload.new(
      engine_path: learner.path,
      path: adapter.path,
      body: body,
      mode: mode,
    )
    engine_upload.run
    adapter.run
    learner.training_data = adapter.data
    learner.categories = adapter.categories
    learner.build
    learner.train
    learner.save
  end

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

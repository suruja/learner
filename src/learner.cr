require "kemal"
require "./learner/json"
require "./learner/machine"
require "./learner/csv_adapter"
require "./learner/classifier"

module Learner
  VERSION = "0.1.0"

  alias Vector = Array(Float64)
  alias Vectors = Array(Vector)

  class Web
    def self.upload(env, method)
      env.response.content_type = "application/json"

      machine_id = env.params.url["machine_id"].as(String)
      learner = Learner::Machine.new(machine_id)

      adapter = Learner::CSVAdapter.new(
        filename: machine_id,
        input_size: env.params.query.fetch("input_size", 2).to_i32,
        output_size: env.params.query.fetch("output_size", 1).to_i32,
      )

      HTTP::FormData.parse(env.request) do |upload|
        filename = upload.filename
        # Be sure to check if file.filename is not empty otherwise it'll raise a compile time error
        if !filename.is_a?(String)
          {error: "No filename included in upload"}.to_json
        else
          File.open(adapter.path, (method == "PATCH" ? "a" : "w")) do |f|
            IO.copy(upload.body, f)
          end
          adapter.run
          learner.training_data = adapter.data
          puts learner.training_data
          learner.build
          learner.train
          learner.save
          {body: "Upload OK"}.to_json
        end
      end
    end

    def self.post(env)
      upload(env, "POST")
    end

    def self.patch(env)
      upload(env, "PATCH")
    end
  end
end

post "/:machine_id/upload" do |env|
  Learner::Web.post(env)
end

patch "/:machine_id/upload" do |env|
  Learner::Web.patch(env)
end

get "/:machine_id/run" do |env|
  env.response.content_type = "application/json"

  machine_id = env.params.url["machine_id"].as(String)
  learner = Learner::Machine.new(machine_id)
  if learner.persisted?
    learner.load
    value = Learner::JSON.new(env.params.query.fetch("value", "[]")).to_vector
    {value: learner.run(value)}.to_json
  else
    {error: "No data"}.to_json
  end
end

get "/:machine_id/classify" do |env|
  env.response.content_type = "application/json"

  machine_id = env.params.url["machine_id"].as(String)
  categories = Learner::JSON.new(env.params.query.fetch("categories", "[]")).to_vectors
  learner = Learner::Machine.new(machine_id)
  learner.categories = categories.as(Learner::Vectors)
  if learner.persisted?
    learner.load
    value = Learner::JSON.new(env.params.query.fetch("value", "[]")).to_vector
    classifier = learner.classify(value)
    {
      value:      classifier.category,
      confidence: classifier.confidence,
    }.to_json
  else
    {error: "No data"}.to_json
  end
end

Kemal.run

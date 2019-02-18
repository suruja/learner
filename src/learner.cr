require "kemal"
require "./learner/engine"
require "./learner/web"

add_handler Learner::Web::ErrorHandler.new

before_all do |env|
  puts "Setting response content type"
  env.response.content_type = "application/json"
end

post "/:machine_id/upload" do |env|
  Learner::Web::Helpers.post_upload(env)
end

patch "/:machine_id/upload" do |env|
  Learner::Web::Helpers.patch_upload(env)
end

get "/:machine_id/run" do |env|
  machine_id = env.params.url["machine_id"].as(String)
  learner = Learner::Engine::Base.new(machine_id)
  learner.load
  query_value = env.params.query.fetch("value", "[]")
  value = Learner::Engine::JSON.new(query_value).to_vector
  {value: learner.run(value)}.to_json
end

get "/:machine_id/classify" do |env|
  machine_id = env.params.url["machine_id"].as(String)
  query_categories = env.params.query.fetch("categories", "[]")
  categories = Learner::Engine::JSON.new(query_categories).to_vectors
  learner = Learner::Engine::Base.new(machine_id)
  learner.categories = categories
  learner.load
  query_value = env.params.query.fetch("value", "[]")
  value = Learner::Engine::JSON.new(query_value).to_vector
  classifier = learner.classify(value)
  {
    value:      classifier.category,
    confidence: classifier.confidence,
  }.to_json
end

Kemal.run

require "kemal"
require "./learner/engine"
require "./learner/web"

add_handler Learner::Web::ErrorHandler.new

before_all do |env|
  puts "Setting response content type"
  env.response.content_type = "application/json"
end

post "/:engine_id" do |env|
  Learner::Web::Helpers.upload(env, "POST")
end

put "/:engine_id" do |env|
  Learner::Web::Helpers.upload(env, "PUT")
end

patch "/:engine_id" do |env|
  Learner::Web::Helpers.upload(env, "PATCH")
end

delete "/:engine_id" do |env|
  engine_id = env.params.url["engine_id"].as(String)
  filename = Learner::Web::Token.new(
    value: engine_id,
    secret: env.params.query["token"],
  ).to_s
  Learner::Engine.destroy(
    engine_id: engine_id,
    filename: filename,
  )
  env.response.status_code = 202
  {body: "OK"}.to_json
end

get "/:engine_id/run" do |env|
  value = Learner::Engine.run(
    engine_id: env.params.url["engine_id"].as(String),
    value: env.params.query.fetch("value", "[]"),
  )
  {value: value}.to_json
end

get "/:engine_id/classify" do |env|
  classifier = Learner::Engine.classify(
    engine_id: env.params.url["engine_id"].as(String),
    value: env.params.query.fetch("value", "[]"),
  )
  {
    value:      classifier.category,
    confidence: classifier.confidence,
  }.to_json
end

error 404 do
  {error: "Not found"}.to_json
end

Kemal.run

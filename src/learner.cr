require "kemal"
require "./learner/engine"
require "./learner/web"

add_handler Learner::Web::ErrorHandler.new

before_all do |env|
  puts "Setting response content type"
  env.response.content_type = "application/json"
end

post "/:engine_id/upload" do |env|
  Learner::Web::Helpers.post_upload(env)
end

put "/:engine_id/upload" do |env|
  Learner::Web::Helpers.put_upload(env)
end

patch "/:engine_id/upload" do |env|
  Learner::Web::Helpers.patch_upload(env)
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

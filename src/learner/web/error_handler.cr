require "kemal/handler"

class Learner::Web::ErrorHandler < Kemal::Handler
  def call(env)
    begin
      call_next env
    rescue ::JSON::ParseException
      env.response.status_code = 406
      env.response.print({error: "JSON parsing exception."}.to_json)
      env.response.close
    rescue ex : SHAInet::NeuralNetRunError
      env.response.status_code = 500
      message = ex.message.as(String)
      env.response.print({
        error: "#{message[0...(message.index("(SHAInet::NeuralNetRunError)").as(Int32))].strip}.",
      }.to_json)
      env.response.close
    rescue Learner::Engine::FileNotFound
      env.response.status_code = 406
      env.response.print({error: "Engine not initialized."}.to_json)
      env.response.close
    rescue Learner::Engine::IdAlreadyTaken
      env.response.status_code = 406
      env.response.print({error: "Engine ID already taken."}.to_json)
      env.response.close
    end
  end
end

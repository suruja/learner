require "./token"

class Learner::Web::Helpers
  def self.upload(env, method)
    env.response.content_type = "application/json"

    engine_id = env.params.url["engine_id"].as(String)
    learner = Learner::Engine::Base.new(engine_id)

    token = Token.new(
      value: engine_id,
      secret: (method == "POST") ? nil : env.params.query.fetch("token", nil),
    )
    adapter = Learner::Engine::CSVAdapter.new(
      filename: token.to_s,
      input_size: env.params.query.fetch("input_size", 2).to_i32,
      output_size: env.params.query.fetch("output_size", 1).to_i32,
    )

    result = ({} of Symbol => String).to_json

    HTTP::FormData.parse(env.request) do |upload|
      filename = upload.filename
      # Be sure to check if file.filename is not empty otherwise it'll raise a compile time error
      if !filename.is_a?(String)
        env.response.status_code = 406
        result = {error: "No filename included in upload"}.to_json
      else
        if ((method == "PATCH") || (method == "PUT")) && !File.exists?(adapter.path)
          raise Learner::Engine::FileNotFound.new
        elsif (method == "POST") && File.exists?(learner.path)
          raise Learner::Engine::IdAlreadyTaken.new
        end
        File.open(adapter.path, (method == "PATCH" ? "a" : "w")) do |f|
          IO.copy(upload.body, f)
          f.puts "\n"
        end
        adapter.run
        learner.training_data = adapter.data
        learner.build
        learner.train
        learner.save
        env.response.status_code = (method == "POST") ? 201 : 202
        result = {body: "Upload OK", token: token.secret}.to_json
      end
    end

    result
  end

  def self.post_upload(env)
    upload(env, "POST")
  end

  def self.put_upload(env)
    upload(env, "PUT")
  end

  def self.patch_upload(env)
    upload(env, "PATCH")
  end
end

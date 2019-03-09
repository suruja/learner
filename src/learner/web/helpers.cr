require "./token"

class Learner::Web::Helpers
  def self.upload(env, method)
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
        engine_upload = Learner::Engine::Upload.new(
          engine_path: learner.path,
          path: adapter.path,
          body: upload.body,
          mode: {
            "POST"  => Learner::Engine::Upload::Mode::Create,
            "PATCH" => Learner::Engine::Upload::Mode::Append,
            "PUT"   => Learner::Engine::Upload::Mode::Replace,
          }[method],
        )
        engine_upload.run
        adapter.run
        learner.training_data = adapter.data
        learner.categories = adapter.categories
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

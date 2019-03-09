require "./token"

class Learner::Web::Helpers
  def self.upload(env, method)
    engine_id = env.params.url["engine_id"].as(String)
    token = Token.new(
      value: engine_id,
      secret: (method == "POST") ? nil : env.params.query.fetch("token", nil),
    )
    engine_args = {
      engine_id:   engine_id,
      filename:    token.to_s,
      input_size:  env.params.query.fetch("input_size", 2).to_i32,
      output_size: env.params.query.fetch("output_size", 1).to_i32,
      mode:        {
        "POST"  => Learner::Engine::Upload::Mode::Create,
        "PATCH" => Learner::Engine::Upload::Mode::Append,
        "PUT"   => Learner::Engine::Upload::Mode::Replace,
      }[method],
    }

    result = ({} of Symbol => String).to_json

    if env.params.query.fetch("data", nil)
      body = CSV.build(separator: ';') do |csv|
        Learner::Engine::JSON.new(env.params.query["data"]).to_vectors.each do |vector|
          csv.row vector
        end
      end
      Learner::Engine.build(**engine_args.merge(body: IO::Memory.new(body)))
      env.response.status_code = 202
      result = {body: "Upload OK", token: token.secret}.to_json
    else
      HTTP::FormData.parse(env.request) do |upload|
        filename = upload.filename
        # Be sure to check if file.filename is not empty otherwise it'll raise a compile time error
        if !filename.is_a?(String)
          env.response.status_code = 406
          result = {error: "No filename included in upload"}.to_json
        else
          Learner::Engine.build(**engine_args.merge(body: upload.body))
          env.response.status_code = (method == "POST") ? 201 : 202
          result = {body: "Upload OK", token: token.secret}.to_json
        end
      end
    end

    result
  end
end

class Learner::Web::Helpers
  def self.upload(env, method)
    env.response.content_type = "application/json"

    machine_id = env.params.url["machine_id"].as(String)
    learner = Learner::Engine::Base.new(machine_id)

    adapter = Learner::Engine::CSVAdapter.new(
      filename: machine_id,
      input_size: env.params.query.fetch("input_size", 2).to_i32,
      output_size: env.params.query.fetch("output_size", 1).to_i32,
    )

    result = ({} of Symbol => String).to_json

    HTTP::FormData.parse(env.request) do |upload|
      filename = upload.filename
      # Be sure to check if file.filename is not empty otherwise it'll raise a compile time error
      if !filename.is_a?(String)
        result = {error: "No filename included in upload"}.to_json
      else
        File.open(adapter.path, (method == "PATCH" ? "a" : "w")) do |f|
          IO.copy(upload.body, f)
          f.puts "\n"
        end
        adapter.run
        learner.training_data = adapter.data
        learner.build
        learner.train
        learner.save
        result = {body: "Upload OK"}.to_json
      end
    end

    result
  end

  def self.post_upload(env)
    upload(env, "POST")
  end

  def self.patch_upload(env)
    upload(env, "PATCH")
  end
end

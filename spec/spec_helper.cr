require "spec"
require "spec-kemal"
require "file_utils"
require "json"
require "../src/learner"

class SpecHelper
  property engine_id : String
  property input_size : Int32
  property output_size : Int32
  property filepath : String
  property token : String

  def initialize(@engine_id, @input_size, @output_size, @filepath)
    @token = ""
  end

  def filename
    File.basename(filepath)
  end

  def encapsulate(&block)
    prepare
    yield
    cleanup
  end

  def prepare
    FileUtils.mkdir("#{Learner::Engine::ROOT_PATH}/saves")
    FileUtils.mkdir("#{Learner::Engine::ROOT_PATH}/uploads")
  end

  def cleanup
    FileUtils.rm_r("#{Learner::Engine::ROOT_PATH}/saves")
    FileUtils.rm_r("#{Learner::Engine::ROOT_PATH}/uploads")
  end

  def upload(method, resource, &block)
    IO.pipe do |reader, writer|
      channel = Channel(String).new(1)

      spawn do
        HTTP::FormData.build(writer) do |formdata|
          channel.send(formdata.content_type)
          File.open(filepath) do |file|
            metadata = HTTP::FormData::FileMetadata.new(filename: filename)
            headers = HTTP::Headers{"Content-Type" => "text/csv"}
            formdata.file("file", file, metadata, headers)
          end
        end

        writer.close
      end

      headers = HTTP::Headers{"Content-Type" => channel.receive}
      request = HTTP::Request.new(
        method: method,
        resource: resource,
        headers: headers,
        body: reader,
      )
      Global.response = process_request(request)
      yield(response)
    end
  end
end

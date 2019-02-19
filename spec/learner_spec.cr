require "./spec_helper"

helper = SpecHelper.new(
  engine_id: "hello",
  input_size: 2,
  output_size: 1,
  filepath: File.expand_path("#{Learner::Engine::ROOT_PATH}/fixtures/xor.csv"),
)

helper.encapsulate do
  describe Learner do
    it "allows create new training data" do
      helper.upload(
        method: "POST",
        resource: "/#{helper.engine_id}/upload?input_size=#{helper.input_size}&output_size=#{helper.output_size}"
      ) do |response|
        helper.token = JSON.parse(response.body)["token"].as_s
        response.status_code.should eq(201)
      end
    end

    it "allows update existing training data" do
      helper.upload(
        method: "PUT",
        resource: "/#{helper.engine_id}/upload?input_size=#{helper.input_size}&output_size=#{helper.output_size}&token=#{helper.token}"
      ) do |response|
        response.status_code.should eq(202)
      end
    end

    it "allows append existing training data" do
      helper.upload(
        method: "PATCH",
        resource: "/#{helper.engine_id}/upload?input_size=#{helper.input_size}&output_size=#{helper.output_size}&token=#{helper.token}"
      ) do |response|
        response.status_code.should eq(202)
      end
    end

    {
      [0.0, 0.0] => 0.0,
      [1.0, 0.0] => 1.0,
      [0.0, 1.0] => 1.0,
      [1.0, 1.0] => 0.0,
    }.each do |input, output|
      it "predicts correct output" do
        get "/#{helper.engine_id}/run?value=#{input}"
        value = JSON.parse(response.body)["value"].as_a.first.as_f
        ((value - output).abs < 0.1).should eq(true)
      end
    end

    {
      [0.0, 0.0] => 0.0,
      [1.0, 0.0] => 1.0,
      [0.0, 1.0] => 1.0,
      [1.0, 1.0] => 0.0,
    }.each do |input, output|
      it "classify correct output" do
        get "/#{helper.engine_id}/classify?value=#{input}&categories=#{[[0.0], [1.0]].to_json}"
        value = JSON.parse(response.body)["value"].as_a.first.as_f
        value.should eq(output)
      end
    end
  end
end

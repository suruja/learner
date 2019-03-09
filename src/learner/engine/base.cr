require "shainet"

class Learner::Engine::Base
  property training_data : Matrix
  property network : SHAInet::Network
  property learning_rate : Float64
  property momentum : Float64
  property filename : String
  property categories : VectorSet

  def initialize(@filename, @training_data = Matrix.new)
    @learning_rate = 0.7
    @momentum = 0.3
    @network = SHAInet::Network.new
    @categories = VectorSet.new
  end

  def build
    network.add_layer(:input, input_size, :memory, SHAInet.sigmoid)
    network.add_layer(:hidden, hidden_size, :memory, SHAInet.sigmoid)
    network.add_layer(:output, output_size, :memory, SHAInet.sigmoid)
    network.fully_connect

    network.learning_rate = learning_rate
    network.momentum = momentum
  end

  private def input_size
    training_data.first.first.size
  end

  private def hidden_size
    training_data.first.map { |i| i.size }.max
  end

  private def output_size
    training_data.first.last.size
  end

  def train
    network.train(
      data: training_data,
      training_type: :sgdm,
      cost_function: :mse,
      epochs: 10000,
      error_threshold: 0.000001,
      log_each: 1000)
  end

  def run(value : Vector) : Vector
    network.run(value)
  end

  def persisted?
    File.exists?(path)
  end

  def load
    raise FileNotFound.new unless persisted?
    network.load_from_file(path)
    @categories = Learner::Engine::Categories.load(categories_path)
  end

  def save
    network.save_to_file(path)
    Learner::Engine::Categories.save(
      path: categories_path,
      data: @categories,
    )
  end

  def path
    self.class.path(filename)
  end

  def self.path(filename)
    "#{ROOT_PATH}/saves/#{filename}.nn"
  end

  def categories_path
    self.class.categories_path(filename)
  end

  def self.categories_path(filename)
    "#{ROOT_PATH}/saves/#{filename}.ctg"
  end

  def classify(value : Vector)
    result = run(value)
    classifier = Classifier.new(
      value: result,
      categories: categories,
    )
    classifier.run
    classifier
  end
end

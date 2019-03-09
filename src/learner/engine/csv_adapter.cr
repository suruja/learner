class Learner::Engine::CSVAdapter
  property filename : String
  property data : Matrix
  property categories : VectorSet
  property input_size : Int32
  property output_size : Int32

  def initialize(@filename, @input_size, @output_size)
    @data = Matrix.new
    @categories = VectorSet.new
  end

  def run
    parser = CSV::Parser.new(
      string_or_io: File.read(path),
      separator: ';',
    )
    result = parser.parse.reduce({data: Matrix.new, categories: VectorSet.new}) do |memo, line|
      if line.size > 0
        vectors = [
          line[0...input_size],
          line[input_size...(input_size + output_size)],
        ]
        memo[:data] << vectors.map do |vector|
          vector.map { |coord| coord.to_f }
        end
        memo[:categories] << vectors.last.map { |coord| coord.to_f }
      end
      memo
    end
    @data = result[:data]
    @categories = result[:categories]
  end

  def path
    self.class.path(filename)
  end

  def self.path(filename)
    "#{ROOT_PATH}/uploads/#{filename}.csv"
  end
end

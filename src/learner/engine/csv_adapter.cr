class Learner::Engine::CSVAdapter
  property filename : String
  property data : Array(Vectors)
  property input_size : Int32
  property output_size : Int32

  def initialize(@filename, @input_size, @output_size)
    @data = Array(Vectors).new
  end

  def run
    parser = CSV::Parser.new(
      string_or_io: File.read(path),
      separator: ';',
    )
    @data = parser.parse.reduce(Array(Vectors).new) do |memo, line|
      if line.size > 0
        vectors = [
          line[0...input_size],
          line[input_size...(input_size + output_size)],
        ]
        memo << vectors.map do |vector|
          vector.map do |coord|
            coord.to_f
          end
        end
      end
      memo
    end
  end

  def path
    self.class.path(filename)
  end

  def self.path(filename)
    "#{ROOT_PATH}/uploads/#{filename}.csv"
  end
end

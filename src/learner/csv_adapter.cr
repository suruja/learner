class Learner::CSVAdapter
  property filename : String
  property data : Array(Learner::Vectors)
  property input_size : Int32
  property output_size : Int32

  def initialize(@filename, @input_size, @output_size)
    @data = Array(Learner::Vectors).new
  end

  def run
    parser = CSV::Parser.new(
      string_or_io: File.read(path),
      separator: ';',
    )
    @data = parser.parse.map do |line|
      puts line
      vectors = [
        line[0...input_size],
        line[input_size...(input_size + output_size)],
      ]
      vectors.map do |vector|
        vector.map do |coord|
          coord.to_f
        end
      end
    end
  end

  def path
    "./uploads/#{filename}.csv"
  end
end

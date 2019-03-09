require "csv"

class Learner::Engine::Categories
  def self.load(path : String) : VectorSet
    CSV::Parser.new(
      string_or_io: File.read(path),
      separator: ';',
    ).parse.reduce(VectorSet.new) do |memo, line|
      if line.size > 0
        memo << line.map { |coord| coord.to_f }
      end
      memo
    end
  end

  def self.save(path : String, data : VectorSet) : Bool
    result = CSV.build(separator: ';') do |csv|
      data.each do |category|
        csv.row category
      end
    end
    File.write(path, result)
    true
  end
end

class Learner::Engine::Upload
  enum Mode
    Create
    Append
    Replace
  end

  property engine_path : String
  property path : String
  property body : IO
  property mode : Mode

  def initialize(@path, @engine_path, @mode, @body)
  end

  def run
    if ((mode == Mode::Append) || (mode == Mode::Replace)) && !File.exists?(path)
      raise Learner::Engine::FileNotFound.new
    elsif (mode == Mode::Create) && File.exists?(engine_path)
      raise Learner::Engine::IdAlreadyTaken.new
    end
    File.open(path, (mode == Mode::Append ? "a" : "w")) do |f|
      IO.copy(body, f)
    end
  end
end

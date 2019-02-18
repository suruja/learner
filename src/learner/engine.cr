require "./engine/json"
require "./engine/csv_adapter"
require "./engine/classifier"
require "./engine/base"

module Learner::Engine
  alias Vector = Array(Float64)
  alias Vectors = Array(Vector)

  class FileNotFound < ::Exception; end
end

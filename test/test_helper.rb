require "test_helper"
require "tempfile"

module WikiExternalFilterTestHelper
  def plantuml(source)
    input = Tempfile.new(["plantuml", ".puml"])
    output = Tempfile.new(["plantuml", ".png"])
    input.write("@startuml\n#{source}\n@enduml")
    input.flush
    input.rewind
    system("plantuml", "-pipe", in: input, out: output)
    Magick::Image.read(output.path)
  end

  def dot(source)
    input = Tempfile.new(["dot", ".dot"])
    output = Tempfile.new(["dot", ".svg"])
    input.write(source)
    input.flush
    input.rewind
    system("dot", "-Tsvg", in: input, out: output)
    Magick::Image.read(output.path)
  end
end

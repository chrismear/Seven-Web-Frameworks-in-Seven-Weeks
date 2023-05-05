module JSON
  module_function
  def parse(source, _ = {})
    Parser.new(source).parse
  end
end

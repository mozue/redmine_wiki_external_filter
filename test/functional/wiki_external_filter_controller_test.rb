require_relative "../test_helper"

class WikiExternalFilterControllerTest < Redmine::ControllerTest
  include WikiExternalFilterTestHelper

  test "#filter" do
    macro = "plantuml"
    source = "Alice -> Bob"
    index = 0
    info = WikiExternalFilter::Filter.config[macro]
    name = Digest::SHA256.hexdigest(source)
    filter = WikiExternalFilter::Filter.new
    filter.build([], source, nil, macro, info.merge("cache_seconds" => 60))
    get(:filter, params: {index: index, macro: macro, name: name})
    assert_response(:success)
    assert_equal("image/png", @response.content_type)
    assert_equal(plantuml(source),
                 MiniMagick::Image.read(@response.body))
  end
end

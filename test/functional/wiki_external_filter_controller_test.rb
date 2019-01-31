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
    get :filter, index: index, macro: macro, name: name
    assert_response(:success)
    assert_equal("image/png", @response.content_type)
    assert_equal(Magick::Image.read(fixture_path("plantuml.png")),
                 Magick::Image.read_inline(Base64.encode64(@response.body)))
  end
end

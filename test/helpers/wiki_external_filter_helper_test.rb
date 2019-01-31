require "test_helper"

class WikiExternalFilterHelperTest < ActionView::TestCase
  include ERB::Util

  def fixture_path(*components)
    File.join(__dir__, "..", "fixtures", *components)
  end

  setup do
    Setting.plugin_wiki_external_filter["cache_seconds"] = 60
  end

  test "PlantUML" do
    source = "Alice -> Bob"
    index = 0
    name = Digest::SHA256.hexdigest(source)
    path = wiki_external_filter_path("index" => index,
                                     "macro" => "plantuml",
                                     "name" => name)
    assert_dom_equal(<<-HTML.chomp,
<p><img class="externalfilterinline"
        src="#{h(path)}"
        alt="#{h(source)}"></p>
                     HTML
                     textilizable(<<-TEXTILE))
{{plantuml
#{source}
}}
                     TEXTILE
    cache = Rails.cache.read(["wiki_external_filter", "plantuml", name].join("_"))
    assert_equal(Magick::Image.read(fixture_path("plantuml.png")),
                 Magick::Image.read_inline(Base64.encode64(cache[index])))
  end
end

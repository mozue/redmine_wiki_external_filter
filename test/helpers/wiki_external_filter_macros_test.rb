require "test_helper"

class WikiExternalFilterMacrosTest < ActionView::TestCase
  include ERB::Util

  def fixture_path(*components)
    File.join(__dir__, "..", "fixtures", *components)
  end

  setup do
    Setting.plugin_wiki_external_filter["cache_seconds"] = 60
  end

  test "PlantUML" do
    macro = "plantuml"
    source = "Alice -> Bob"
    index = 0
    name = Digest::SHA256.hexdigest(source)
    path = wiki_external_filter_path("index" => index,
                                     "macro" => macro,
                                     "name" => name)
    assert_dom_equal(<<-HTML.chomp,
<p><img class="externalfilterinline"
        src="#{h(path)}"
        alt="#{h(source)}"></p>
                     HTML
                     textilizable(<<-TEXTILE))
{{#{macro}
#{source}
}}
                     TEXTILE
    cache_key = WikiExternalFilter::Filter.construct_cache_key(macro, name)
    cache = Rails.cache.read(cache_key)
    assert_equal(Magick::Image.read(fixture_path("plantuml.png")),
                 Magick::Image.read_inline(Base64.encode64(cache[index])))
  end

  test "Grpahviz" do
    macro = "graphviz"
    source = <<-SOURCE.chomp
digraph finite_state_machine {
    rankdir=LR;
    size="8.5"
    node [shape = doublecircle]; LR_0 LR_3 LR_4 LR_8;
    node [shape = circle];
    LR_0 -> LR_2 [ label = "SS(B)" ];
    LR_0 -> LR_1 [ label = "SS(S)" ];
    LR_1 -> LR_3 [ label = "S($end)" ];
    LR_2 -> LR_6 [ label = "SS(b)" ];
    LR_2 -> LR_5 [ label = "SS(a)" ];
    LR_2 -> LR_4 [ label = "S(A)" ];
    LR_5 -> LR_7 [ label = "S(b)" ];
    LR_5 -> LR_5 [ label = "S(a)" ];
    LR_6 -> LR_6 [ label = "S(b)" ];
    LR_6 -> LR_5 [ label = "S(a)" ];
    LR_7 -> LR_8 [ label = "S(b)" ];
    LR_7 -> LR_5 [ label = "S(a)" ];
    LR_8 -> LR_6 [ label = "S(b)" ];
    LR_8 -> LR_5 [ label = "S(a)" ];
}
    SOURCE
    index = 0
    name = Digest::SHA256.hexdigest(source)
    path = wiki_external_filter_path("index" => index,
                                     "macro" => macro,
                                     "name" => name)
    assert_dom_equal(<<-HTML.chomp,
<p><img class="externalfilterinline"
        src="#{h(path)}"
        alt="#{h(source)}"></p>
                     HTML
                     textilizable(<<-TEXTILE))
{{#{macro}
#{source}
}}
                     TEXTILE
    cache_key = WikiExternalFilter::Filter.construct_cache_key(macro, name)
    cache = Rails.cache.read(cache_key)
    assert_equal(Magick::Image.read(fixture_path("graphviz.svg")),
                 Magick::Image.read_inline(Base64.encode64(cache[index])))
  end
end

module WikiExternalFilter
  class Renderer
    def initialize(view, args, source, attachments, macro, info)
      @view = view
      filter = Filter.new
      @result = filter.build(args, source, attachments, macro, info)
    end

    def render
      result = @result.dup
      result[:render_type] = 'inline'
      html = render_common(result).chop
      html << headers_common(result).chop
      html.html_safe
    end

    def render_block(wiki_name)
      result = result.dup
      result[:render_type] = 'block'
      result[:wiki_name] = wiki_name
      result[:inside] = render_common(result)
      html = render_to_string(:partial => 'wiki_external_filter/block',
                              :locals => result).chop
      html << headers_common(result).chop
      html
    end

    private
    def render_common(result)
      render_to_string(:partial => "wiki_external_filter/macro_#{result[:template]}",
                       :locals => result)
    end

    def headers_common(result)
      render_to_string(:partial => 'wiki_external_filter/headers',
                       :locals => result)
    end

    def render_to_string(*args)
      @view.controller.render_to_string(*args)
    end
  end
end

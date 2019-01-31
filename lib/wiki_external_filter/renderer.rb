# Copyright (C) 2010  Alexander Tsvyashchenko <ndl@ndl.kiev.ua>
# Copyright (C) 2012  mkinski <miko.kinski@yahoo.de>
# Copyright (C) 2013  zzloiz <www.zloi@gmail.com>
# Copyright (C) 2013  Christoph Dwertmann <cdwertmann@gmail.com>
# Copyright (C) 2013  YOSHITANI Mitsuhiro <luckval@gmail.com>
# Copyright (C) 2019  Kouhei Sutou <kou@clear-code.com>
# Copyright (C) 2019  Shimadzu Corporation
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

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

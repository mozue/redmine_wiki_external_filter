# Copyright (C) 2010  Alexander Tsvyashchenko <ndl@ndl.kiev.ua>
# Copyright (C) 2012  mkinski <miko.kinski@yahoo.de>
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

class WikiExternalFilterController < ApplicationController
  def filter
    name = params[:name]
    macro = params[:macro]
    index = params[:index].to_i
    filename = params[:filename] ? params[:filename] : name
    config = WikiExternalFilter::Filter.config
    cache_key = WikiExternalFilter::Filter.construct_cache_key(macro, name)
    content = Rails.cache.read cache_key

    Rails.logger.debug "Config:#{config} Key: #{cache_key} Content: #{content}"

    if content
      send_data content[index], :type => config[macro]['outputs'][index]['content_type'], :disposition => 'inline', :filename => filename
    else
      render_404
    end
  end
end

# Copyright (C) 2010  Alexander Tsvyashchenko <ndl@ndl.kiev.ua>
# Copyright (C) 2012  mkinski <miko.kinski@yahoo.de>
# Copyright (C) 2012  zzloiz <www.zloi@gmail.com>
# Copyright (C) 2013  Christoph Dwertmann <cdwertmann@gmail.com>
# Copyright (C) 2019-2024  Sutou Kouhei <kou@clear-code.com>
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

Rails.logger.info 'Starting wiki_external_filter plugin for Redmine'

Redmine::Plugin.register :wiki_external_filter do
  name 'Wiki External Filter plugin'
  author 'Sutou Kouhei, Alexander Tsvyashchenko (the original author)'
  description 'Processes given text using external command and renders its output'
  author_url 'https://github.com/clear-code/redmine_wiki_external_filter'
  version WikiExternalFilter::Version::STRING
  requires_redmine :version_or_higher => '5.0.0'

  settings :default => {'cache_seconds' => '60'}, :partial => 'wiki_external_filter/settings'

  config = WikiExternalFilter::Filter.config
  Rails.logger.debug "Config: #{config.inspect}"

  config.keys.each do |name|
    Rails.logger.info "Registering #{name} macro with wiki_external_filter"
    Redmine::WikiFormatting::Macros.register do
      info = config[name]
      desc info['description']
      macro name do |obj, args, text|
        m = WikiExternalFilter::Renderer.new(self, args, text, obj.respond_to?('page') ? obj.page.attachments : nil, name, info)
        m.render
      end
      # code borrowed from wiki latex plugin
      # code borrowed from wiki template macro
      desc info['description']
      macro (name + "_include").to_sym do |obj, args, text|
        page = Wiki.find_page(args.to_s, :project => @project)
        raise 'Page not found' if page.nil? || !User.current.allowed_to?(:view_wiki_pages, page.wiki.project)
        @included_wiki_pages ||= []
        raise 'Circular inclusion detected' if @included_wiki_pages.include?(page.title)
        @included_wiki_pages << page.title
        m = WikiExternalFilter::Renderer.new(self, args, page.content.text, page.attachments, name, info)
        @included_wiki_pages.pop
        m.render_block(args.to_s)
      end
    end
  end
end


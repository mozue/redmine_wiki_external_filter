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

namespace :wiki_external_filter do
  test_pattern = "plugins/wiki_external_filter/test/**/*_test.rb"
  desc "Run tests for Wiki External Filter plugin"
  if Rails.const_defined?(:TestUnit)
    task :test => "db:test:prepare" do |t|
      $LOAD_PATH.push("test")
      Rails::TestUnit::Runner.rake_run([test_pattern])
    end
  else
    Rake::TestTask.new :test => "db:test:prepare" do |t|
      t.libs << "test"
      t.verbose = true
      t.pattern = test_pattern
    end
  end
end

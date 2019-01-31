namespace :wiki_external_filter do
  desc "Run tests for Wiki External Filter plugin"
  Rake::TestTask.new :test => "db:test:prepare" do |t|
    t.libs << "test"
    t.verbose = true
    t.pattern = "plugins/wiki_external_filter/test/**/*_test.rb"
  end
end

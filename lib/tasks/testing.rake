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

require "bundler/gem_tasks"
require "rake/testtask"
require "minitest"

Rake::TestTask.new do |t|
	t.libs << 'test'
end

desc "Run tests"
task :default => :test
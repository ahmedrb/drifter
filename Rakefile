require 'bundler'
Bundler::GemHelper.install_tasks

desc "Run tests"
task :test do
   path = File.dirname(__FILE__) + '/test/*_test.rb'
   Dir[path].each { |f| require f }
end

require 'bundler/gem_tasks'

require 'rake/testtask'
Rake::TestTask.new(:test) do |t|
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
end
task :default => :test

task :console do
  require 'irb'
  require 'irb/completion'
  require 'imgix'
  ARGV.clear
  IRB.start
end

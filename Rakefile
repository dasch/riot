require 'rubygems'
require 'rake'

task :default => [:test]

desc "Run tests"
task :test do
  $:.concat ['./test', './lib']
  Dir.glob("./test/*_test.rb").each { |test| require test }
end

desc "Run Flog against library (except tests)"
task :flog do
  puts %x[find ./lib -name *.rb | xargs flog]
end

desc "Run Flay against library (except tests)"
task :flay do
  puts %x[find ./lib -name *.rb | xargs flay]
end

desc "Run Roodi against library (except tests)"
task :roodi do
  puts %x[find ./lib -name *.rb | xargs roodi]
end

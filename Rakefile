require 'bundler'
Bundler::GemHelper.install_tasks

task :test do
  $LOAD_PATH.unshift './lib'
  require 'herald'
  require 'minitest/autorun'
  Dir.glob("test/*_test.rb").each { |test| require "./#{test}" }
end
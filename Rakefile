require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "paperclip_archive_processor"
  gem.homepage = "http://github.com/sleistner/paperclip_archive_processor"
  gem.license = "MIT"
  gem.summary = %Q{
    extract paperclip attachments and save them to file or s3 storage
  }
  gem.description = %Q{
    extract paperclip attachments and save them to file or s3 storage
  }
  gem.email = "sleistner@gmail.com"
  gem.authors = ["sleistner"]
  gem.add_dependency 'paperclip', '~> 2.3.3'
  gem.add_dependency 'zip', '>= 2.0.2'
  gem.add_dependency 'aws-s3'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

require 'rcov/rcovtask'
Rcov::RcovTask.new do |test|
  test.libs << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
end

task :default => :test

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "paperclip_archive_processor #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

desc 'Start an IRB session with all necessary files required.'
task :shell do |t|
  chdir File.dirname(__FILE__)
  exec 'irb -I lib/ -I lib/paperclip_archive_processor -r rubygems -r tempfile -r test/helper'
end

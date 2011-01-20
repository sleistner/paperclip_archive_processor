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
    Extract paperclip archive attachments to file or S3.
  }
  gem.description = %Q{
    Extract paperclip archive attachments to file or S3.

    Usage:

    has_attached_file :archive,
                      :url  => '/assets/games/assets/:id/archive.:extension',
                      :extract_archive => true
  }
  gem.email = "sleistner@gmail.com"
  gem.authors = ["sleistner"]
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

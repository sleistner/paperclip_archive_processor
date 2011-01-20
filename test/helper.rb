require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'test/unit'
require 'shoulda'
require 'mocha'
require 'redgreen'
require 'active_record'
require 'active_record/version'
require 'active_support'
require 'aws/s3'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'paperclip_archive_processor'

ROOT = File.join(File.dirname(__FILE__), '..')

class Test::Unit::TestCase
  def setup
    silence_warnings do
      Object.const_set(:Rails, stub('Rails', :root => ROOT, :env => 'test'))
    end
    create_dummy_class
  end
end

config = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.logger = ActiveSupport::BufferedLogger.new(File.dirname(__FILE__) + "/debug.log")
ActiveRecord::Base.establish_connection(config['test'])


def reset_class(class_name)
  ActiveRecord::Base.send(:include, Paperclip::Glue)
  Object.send(:remove_const, class_name) rescue nil
  klass = Object.const_set(class_name, Class.new(ActiveRecord::Base))
  klass.class_eval{ include Paperclip::Glue }
  klass
end

def rebuild_table(table_name, options = {})
  ActiveRecord::Base.connection.create_table table_name, :force => true do |table|
    table.column :archive_file_name, :string
    table.column :archive_content_type, :string
    table.column :archive_file_size, :integer
    table.column :archive_updated_at, :datetime
    table.column :archive_fingerprint, :string
  end
end

def create_dummy_class
  reset_class(:Dummy)
  rebuild_table(:dummies)
end

def file(name = '5x.zip')
  (@_files ||= {})[name] ||= File.new(File.join(File.dirname(__FILE__), 'fixtures', name), 'rb')
end

require 'paperclip'
require 'paperclip_archive_processor/integration'
require 'paperclip_archive_processor/processor'
require 'paperclip_archive_processor/extractor'
require 'paperclip_archive_processor/zip_util'

if defined?(Paperclip::InstanceMethods)
  Paperclip::ClassMethods.send(:extend, PaperclipArchiveProcessor::Integration)
end



module PaperclipArchiveProcessor

  module Processor

    class StorageMethodNotFound < StandardError; end

    def self.extract(attachment)
      extractor = PaperclipArchiveProcessor::Extractor.extractor_for(attachment.content_type)
      processor = processor_for(attachment)
      processor.extract(attachment, extractor)
    end

    private

    def self.processor_for(attachment)
      storage_class_name = attachment.instance_variable_get(:@storage).to_s.capitalize
      begin
        PaperclipArchiveProcessor::Processor.const_get(storage_class_name)
      rescue NameError
        raise StorageMethodNotFound, "Cannot load storage module '#{storage_class_name}'"
      end
    end

    class Filesystem
      def self.extract(attachment, extractor)
        path = attachment.to_file.path
        extractor.extract(path, File.dirname(path))
      end
    end

    class S3

      def self.extract(attachment, extractor)
        extract_path    = Dir.mktmpdir
        s3_path_prefix  = File.dirname(attachment.path)
        bucket_name     = attachment.instance_variable_get(:@options)[:bucket]
        options         = options_for(attachment)

        extractor.extract(attachment.to_file.path, extract_path).each do |name|
          file = File.join(extract_path, name)
          write(File.join(s3_path_prefix, name), File.new(file), bucket_name, options) if File.file?(file)
        end
      end

      def self.options_for(attachment)
        { :content_type => attachment.content_type,
          :access => attachment.instance_variable_get(:@s3_permissions)
        }.merge(attachment.instance_variable_get(:@s3_headers))
      end

      def self.write(path, file, bucket_name, options)
        begin
          AWS::S3::S3Object.store(path, file, bucket_name, options)
        rescue AWS::S3::ResponseError
          raise
        end
      end

    end

  end

end

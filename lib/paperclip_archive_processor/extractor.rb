module PaperclipArchiveProcessor

  module Extractor

    class ExtractorNotFound < StandardError; end

    def self.extractor_for(content_type)
      case content_type
      when /zip/ then Zip
      else
        raise ExtractorNotFound, "Cannot load extractor for content type '#{content_type}'"
      end
    end

    class Zip

      def self.extract(file, destination)
        PaperclipArchiveProcessor::ZipUtil.unpack(file, destination).map do |entry|
          entry.name
        end
      end

    end

  end

end

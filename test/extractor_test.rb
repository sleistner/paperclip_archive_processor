require 'helper'

class ExtractorTest < Test::Unit::TestCase

  context '#find_extractor' do

    context 'content type "application/x-zip-compressed" given' do

      should 'return the zip extractor' do
        extractor = PaperclipArchiveProcessor::Extractor.extractor_for("application/x-zip-compressed")
        assert_same PaperclipArchiveProcessor::Extractor::Zip, extractor
      end

    end


    context 'unknown centent type given' do

      should 'raise an extractor not found error' do
        assert_raise PaperclipArchiveProcessor::Extractor::ExtractorNotFound do
          PaperclipArchiveProcessor::Extractor.extractor_for("application/unknown-compressed")
        end
      end

    end

  end

  context '#extract' do

    context 'content type "application/x-zip-compressed" given' do

      setup do
        @extractor = PaperclipArchiveProcessor::Extractor.extractor_for("application/x-zip-compressed")
      end

      should 'invoke ZipUtil#unpack' do
        destination = File.join(Dir::tmpdir, 'foo')
        PaperclipArchiveProcessor::ZipUtil.expects(:unpack).with(file, destination).returns([])
        @extractor.extract(file, destination)
      end

    end

  end

end

require 'helper'

class ProcessorTest < Test::Unit::TestCase

  context 'extract' do

    context 'attachment content type "application/x-zip-compressed"' do

      setup do
        Dummy.has_attached_file :archive, :extract_archive => true
        @dummy = Dummy.new
        @dummy.archive = file
      end

      context 'attachment is configured to use the filesystem storage' do

        should 'use the filesystem processor' do
          PaperclipArchiveProcessor::Processor::Filesystem.expects(:extract).with(@dummy.archive, PaperclipArchiveProcessor::Extractor::Zip)
          PaperclipArchiveProcessor::Processor.extract(@dummy.archive)
        end

        should 'call the extractor with local file paths' do
          path = @dummy.archive.to_file.path
          destination = File.dirname(path)
          PaperclipArchiveProcessor::Extractor::Zip.expects(:extract).with(path, destination).returns([])
          PaperclipArchiveProcessor::Processor.extract(@dummy.archive)
        end

      end

      context 'attachment is configured to use the s3 storage' do

      setup do
        Dummy.has_attached_file :archive,
                                :storage => :s3,
                                :s3_credentials => { :access_key_id => 'id', :secret_access_key => 'key' },
                                :url => ':s3_alias_url',
                                :path => 'foo',
                                :bucket => 'test',
                                :extract_archive => true
        @dummy = Dummy.new
        @dummy.archive = file('5x.zip')
      end

        should 'use the s3 processor' do
          PaperclipArchiveProcessor::Processor::S3.expects(:extract).with(@dummy.archive, PaperclipArchiveProcessor::Extractor::Zip)
          PaperclipArchiveProcessor::Processor.extract(@dummy.archive)
        end

        should 'call the extractor with tempfile destination path' do
          Dir.expects(:mktmpdir).returns(Dir.tmpdir).at_least_once
          path = @dummy.archive.to_file.path
          PaperclipArchiveProcessor::Extractor::Zip.expects(:extract).with(path, Dir.mktmpdir).returns([])
          PaperclipArchiveProcessor::Processor.extract(@dummy.archive)
        end

        should 'upload to s3' do
          archive = @dummy.archive
          AWS::S3::S3Object.expects(:store).with(
            regexp_matches(/.*[1-5]+$/),
            kind_of(File),
            archive.instance_variable_get(:@options)[:bucket],
            {
              :content_type => archive.content_type,
              :access => archive.instance_variable_get(:@s3_permissions)
            }.merge(archive.instance_variable_get(:@s3_headers))
          ).times(5)
          PaperclipArchiveProcessor::Processor.extract(@dummy.archive)
        end

      end

      context 'attachment is configured to use an unknown storage type' do

        setup do
          Dummy.has_attached_file :archive, :extract_archive => true
          @dummy = Dummy.new
          @dummy.archive = file
          @dummy.archive.instance_variable_set(:@storage, :tape)
        end

        should 'raise an storage not found error' do
          assert_raise PaperclipArchiveProcessor::Processor::StorageMethodNotFound do
            PaperclipArchiveProcessor::Processor.extract(@dummy.archive)
          end
        end

      end

    end

  end

end

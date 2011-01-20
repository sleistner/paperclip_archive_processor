require 'helper'

class IntegrationTest < Test::Unit::TestCase

  should 'extend paperclip class methods' do
    Paperclip::Railtie.insert
    assert Paperclip::ClassMethods.public_method_defined?(:has_attached_file_original)
  end

  context 'has configured an attachment for :archive' do

    context 'extract_archive option is set to true' do

      setup do
        Dummy.has_attached_file :archive, :extract_archive => true
        @dummy = Dummy.new
      end

      context 'archive file assigned' do

        setup do
          @dummy.archive = file
        end

        should 'mark archive as dirty' do
          @dummy.save
          assert @dummy.instance_variable_get(:@_archive_has_changed)
        end

        should 'call the processor extract method' do
          PaperclipArchiveProcessor::Processor.expects(:extract).with(@dummy.archive)
          @dummy.save
        end

      end

      context 'archive file unassigned' do

        should 'mark not archive as dirty' do
          @dummy.save
          assert ! @dummy.instance_variable_get(:@_archive_has_changed)
        end

        should 'not call the processor extract method' do
          PaperclipArchiveProcessor::Processor.expects(:extract).never
          @dummy.save
        end

      end

    end

    context 'extract_archive option is undefined or set to false' do

      setup do
        Dummy.has_attached_file :archive
        @dummy = Dummy.new
        @dummy.archive = file
      end

      should 'not call the processor extract method' do
        PaperclipArchiveProcessor::Processor.expects(:extract).never
        @dummy.save
      end

    end

  end
end

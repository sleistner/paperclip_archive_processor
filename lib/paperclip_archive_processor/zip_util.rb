require 'zip/zipfilesystem'
require 'fileutils'

module PaperclipArchiveProcessor

  class ZipUtil #:nodoc:

    # Pack up an archive from a directory on disk
    def self.pack(input, archive, excludes)
      Zip::ZipFile.open(archive, Zip::ZipFile::CREATE) do |zip|
        add_file_to_zip(zip, input, excludes)
      end
    end

    def self.pack_single_file(input, archive)
      Zip::ZipFile.open(archive, Zip::ZipFile::CREATE) do |zip|
        file_name = File.basename(input)
        zip.add(file_name, input)
      end
    end

    # Unpack an archive with all its subdirectories to a directory on disk
    def self.unpack(archive, destination)
      Zip::ZipFile.open(archive) do |zip|
        zip.each do |file|
          file_path = File.join destination, file.name
          FileUtils.mkdir_p File.dirname(file_path)
          # remove existing files
          FileUtils.rm file_path if File.exist?(file_path) && File.file?(file_path)
          zip.extract file, file_path
        end
      end
    end

    def self.add_file_to_zip(zip, path, excludes)
      if(File.directory?(path))
        zip.dir.mkdir(path)
        Dir.open(path).each do |child|
          if(!excluded?(child, excludes))
            add_file_to_zip(zip, File.join(path, child), excludes)
          end
        end
      else
        File.open(path) do |src|
          zip.file.open(path, 'w') do |dest|
            dest.write src.read
          end
        end
      end
    end

    def self.excluded?(str, excludes)
      excludes.each do |exc|
        if(str == exc)
          return true
        end
      end
      return false
    end

  end

end

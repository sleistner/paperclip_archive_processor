module PaperclipArchiveProcessor

  module Integration
    def self.extended(base)
      base.extend ClassMethods
    end
  end

  module ClassMethods

    def self.extended(base)
      base.module_eval do

        private

        def create_callback(name, &block)
          class_eval do
            define_method(name, &block)
          end
        end

        def define_before_save_callback(variable_name, attachment_name)
          name = "before_save_filter_for_#{attachment_name}"
          create_callback(name) do
            instance_variable_set(variable_name, try(attachment_name).dirty?)
            true
          end
          send(:before_save, name)
        end

        def define_after_save_callback(variable_name, attachment_name)
          name = "after_save_filter_for_#{attachment_name}"
          create_callback(name) do
            if instance_variable_get(variable_name)
              PaperclipArchiveProcessor::Processor.extract(try(attachment_name))
              true
            end
          end
          send(:after_save, name)
        end

        def define_processor_callbacks(attachment_name)
          variable_name = "@_#{attachment_name}_has_changed"
          define_before_save_callback(variable_name, attachment_name)
          define_after_save_callback(variable_name, attachment_name)
        end

        public

        alias has_attached_file_original has_attached_file

        def has_attached_file(name, options = {})
          has_attached_file_original(name, options)

          if options.delete(:extract_archive)
            define_processor_callbacks(name)
          end
        end
      end

    end

  end

end


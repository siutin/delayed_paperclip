require 'delayed_job'

module DelayedPaperclip
  module Jobs
    class DelayedJob < Struct.new(:instance_klass, :instance_id, :attachment_name)

      if Gem.loaded_specs['delayed_job'].version >= Gem::Version.new("2.1.0") # this is available in newer versions of DelayedJob. Using the newee Job api thus.

        def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
          ::Delayed::Job.enqueue(
            :payload_object => new(instance_klass, instance_id, attachment_name),
            :priority => instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            :queue => instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      else

        def self.enqueue_delayed_paperclip(instance_klass, instance_id, attachment_name)
          ::Delayed::Job.enqueue(
            new(instance_klass, instance_id, attachment_name),
            instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:priority].to_i,
            instance_klass.constantize.paperclip_definitions[attachment_name][:delayed][:queue]
          )
        end

      end

      def perform
        DelayedPaperclip.process_job(instance_klass, instance_id, attachment_name)
      end

      def success
        success_hook_method_name = :delayed_paperclip_success_hook
        instance = instance_klass.constantize.unscoped.find(instance_id)

        if instance && instance.methods.include?(success_hook_method_name)
          instance.send(success_hook_method_name, attachment_name)
        end

      end
    end
  end
end
# encoding: utf-8

module Backup
  module Notifier
    class Webhook < Base

      ##
      # Container for the Model object
      attr_accessor :model

      ##
      # Domain to post back to
      attr_accessor :domain

      ##
      # Controller to post back to
      attr_accessor :controller

      ##
      # Action to post back to
      attr_accessor :action

      ##
      # Hash key for access to your app
      attr_accessor :secret_key

      ##
      # Instantiates a new Backup::Notifier::Webhook object
      def initialize(&block)
        load_defaults!

        instance_eval(&block) if block_given?

        set_defaults!
      end

      ##
      # Performs the notification
      # Takes an exception object that might've been created if an exception occurred.
      # If this is the case it'll invoke notify_failure!(exception), otherwise, if no
      # error was raised, it'll go ahead and notify_success!
      #
      # If'll only perform these if on_success is true or on_failure is true
      def perform!(model, exception = false)
        @model = model

        if notify_on_success? and exception.eql?(false)
          log!
          notify_success!
        elsif notify_on_failure? and not exception.eql?(false)
          log!
          notify_failure!(exception)
        end
      end

    private

      ##
      # Sends a tweet informing the user that the backup operation
      # proceeded without any errors
      def notify_success!
        # return a hash:
        # backup = {
        #   :label
        #   :file_path
        #   :start_time
        #   :end_time
        #   :size
        #   :compressed?
        #   :database
        #   :state (success || failure)
        # }
      end

      ##
      # Sends a tweet informing the user that the backup operation
      # raised an exception
      def notify_failure!(exception)
        # return a hash:
        # backup = {
        #   :label
        #   :file_path
        #   :start_time
        #   :end_time
        #   :size
        #   :compressed?
        #   :database
        #   :state (success || failure)
        # }

      end


    end
  end
end

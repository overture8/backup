# encoding: utf-8

##
# If the Ruby version of this process is 1.8.x or less
# then use the JSON gem. Otherwise if the current process is running
# Ruby 1.9.x or later then it is built in and we can load it from the Ruby core lib
if RUBY_VERSION < '1.9.0'
  Backup::Dependency.load('json')
else
  require 'json'
end

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
      # Port to post back to
      attr_accessor :port

      ##
      # Path to post back to
      attr_accessor :path

      ##
      # Hash key for access to your app
      attr_accessor :secret_key

      ##
      # Instantiates a new Backup::Notifier::Webhook object
      def initialize(&block)
        load_defaults!
        instance_eval(&block) if block_given?
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
        backup = {
          :backup_fields => {
            :label_name => model.label,
            :file_path => Backup::Model.file,
            :start_time => model.time,
            :end_time => Time.now,
            :state => 'success'
          }
        }
        req = Net::HTTP::Post.new(path, initheader = {'Content-Type' =>'application/json'})
        req.body = backup.to_json
        response = Net::HTTP.new(domain, port).start {|http| http.request(req) }
      end

      ##
      # Sends a tweet informing the user that the backup operation
      # raised an exception
      def notify_failure!(exception)
        backup = {
          :backup_fields => {
            :label_name => model.label,
            :file_path => Backup::Model.file,
            :start_time => model.time,
            :end_time => Time.now,
            :state => 'failed',
            :exception => exception
          }
        }

        req = Net::HTTP::Post.new(path, initheader = {'Content-Type' =>'application/json'})
        req.body = backup.to_json
        response = Net::HTTP.new(domain, port).start {|http| http.request(req) }
      end

    end
  end
end

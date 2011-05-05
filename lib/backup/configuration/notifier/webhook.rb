# encoding: utf-8

module Backup
  module Configuration
    module Notifier
      class Webhook < Base
        class << self

          ##
          # Secret key
          attr_accessor :key

        end
      end
    end
  end
end

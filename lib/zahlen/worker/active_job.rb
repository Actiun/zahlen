module ::ActiveJob
  class Base; end
end

module Zahlen
  module Worker
    class ActiveJob < ::ActiveJob::Base
      queue_as queue_name.to_sym if defined? ::ActiveJob::Core && !queue_name.blank?

      def self.can_run?
        defined?(::ActiveJob::Core)
      end

      def self.call(klass, *args)
        perform_later(klass.to_s, *args)
      end

      def perform(klass, *args)
        klass.safe_constantize.call(*args)
      end
    end
  end
end

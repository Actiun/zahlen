require 'zahlen/worker/base'
require 'zahlen/worker/active_job'
require 'zahlen/worker/sidekiq'
require 'zahlen/worker/sucker_punch'

module Zahlen
  module Worker
    class << self
      attr_accessor :registry

      def find(symbol)
        if registry.has_key? symbol
          return registry[symbol]
        else
          raise "No such worker type: #{symbol}"
        end
      end

      def autofind
        # prefer ActiveJob over the other workers
        if Zahlen::Worker::ActiveJob.can_run?
          return Zahlen::Worker::ActiveJob
        end

        registry.values.each do |worker|
          if worker.can_run?
            return worker
          end
        end

        raise "No eligible background worker systems found."
      end
    end

    self.registry = {
      sidekiq:      Zahlen::Worker::Sidekiq,
      sucker_punch: Zahlen::Worker::SuckerPunch,
      active_job:   Zahlen::Worker::ActiveJob
    }
  end
end

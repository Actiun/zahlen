require 'zahlen/engine'
require "zahlen/worker"
require 'conekta_event'
require 'jquery-rails'

module Zahlen
  class << self
    attr_accessor :gateway,
                  :publishable_key,
                  :secret_key,
                  :background_worker,
                  :queue_name,
                  :event_filter,
                  :default_currency,
                  :active_payments_methods,
                  :uuid_generator,
                  :subscribables

    def configure(&block)
      raise ArgumentError, "must provide a block" unless block_given?
      block.arity.zero? ? instance_eval(&block) : yield(self)
    end

    def reset!
      ConektaEvent.event_retriever = Retriever

      self.gateway = 'conekta'
      self.publishable_key = nil
      self.secret_key = nil
      self.background_worker = nil
      self.queue_name = nil
      self.event_filter = lambda { |event| event }
      self.default_currency = 'MXN'
      self.uuid_generator = lambda { SecureRandom.urlsafe_base64.gsub(/-|_/, '')[0..19] }
      self.subscribables = {}
    end

    def subscribe(name, callable = Proc.new)
      ConektaEvent.subscribe(name, callable)
    end

    def instrument(name, object)
      ConektaEvent.backend.instrument(ConektaEvent.namespace.call(name), object)
    end

    def all(callable = Proc.new)
      ConektaEvent.all(callable)
    end

    def register_subscribable(klass)
      subscribables[klass.plan_class] = klass
    end

    def queue!(klass, *args)
      if background_worker.is_a? Symbol
        Zahlen::Worker.find(background_worker).call(klass, *args)
      elsif background_worker.respond_to?(:call)
        background_worker.call(klass, *args)
      else
        Zahlen::Worker.autofind.call(klass, *args)
      end
    end
  end

  class Retriever
    def self.call(params)
      return nil if GatewayWebhook.exists?(gateway: Zahlen.gateway, gateway_reference_id: params[:id])
      GatewayWebhook.create!(gateway: Zahlen.gateway, gateway_reference_id: params[:id])
      event = Conekta::Event.find(params[:id])
      Rails.logger.info "Retriever event => #{event}"
      Zahlen.event_filter.call(event)
    end
  end

  self.reset!
end

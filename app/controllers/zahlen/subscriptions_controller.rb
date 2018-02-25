module Zahlen
  class SubscriptionsController < ApplicationController
    before_action :set_subscription

    def show
      redirector = @subscription.redirector

      new_path = redirector.respond_to?(:redirect_path) ? redirector.redirect_path(@subscription) : '/'
      redirect_to new_path
    end

    def status
      head :not_found && return unless @subscription

      error_msg = @subscription.errors.full_messages.compact.to_sentence
      render json: {
        uuid:   @subscription.uuid,
        status: @subscription.state,
        error:  error_msg.presence
      }, status: error_msg.blank? ? 200 : 400
    end

    def change_plan
      find_plan
      payment_method = params[:payment_method]

      Zahlen::ChangeSubscriptionPlan.call(@subscription, @plan, payment_method)

      flash.keep
      if payment_method == 'card'
        message = 'Tu subscripción ha sido actualizada y el nuevo plan será cobrado hasta tu siguiente fecha de cargo.'
      else
        message = 'Tu subscripción será actualizada una vez que el pago sea concretado.'
      end
      redirect_to subscription_path(uuid: @subscription.uuid), flash: { sucesss: message }
    end

    def update_card
      Zahlen::ChangeSubscriptionCard.call(@subscription, params[:gateway_card_id])
      flash.keep
      message = 'Tu forma de pago fue actualizada.'

      if @subscription.errors.empty?
        message = 'Tu forma de pago fue actualizada.'
        redirect_to subscription_path(uuid: @subscription.uuid), flash: { sucesss: message }
      else
        redirect_to subscription_path(uuid: @subscription.uuid), flash: { alert: @subscription.errors.full_messages.to_sentence }
      end
    end

    private

    def set_subscription
      @subscription = Subscription.find_by(uuid: params[:uuid])
    end

    def find_plan
      plan_class = Zahlen.subscribables[params[:plan_class]]
      raise ActionController::RoutingError.new('Not Found') unless plan_class && plan_class.subscribable?

      @plan = plan_class.find_by!(id: params[:plan_id])
    end

  end
end

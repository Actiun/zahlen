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

    private

    def set_subscription
      @subscription = Subscription.find_by(uuid: params[:uuid])
    end

  end
end

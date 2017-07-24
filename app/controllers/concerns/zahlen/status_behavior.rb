module Zahlen
  module StatusBehavior
    extend ActiveSupport::Concern

    def render_zahlen_status(object)
      render nothing: true, status: 404 && return unless object

      error_msg = object.errors.full_messages.compact.to_sentence

      render json: {
        uuid:   object.uuid,
        status: object.state,
        error:  error_msg.presence
      }, status: error_msg.blank? ? 200 : 400
    end
  end
end

module Zahlen
  module StatusBehavior
    extend ActiveSupport::Concern

    def render_zahlen_status(object)
      head :not_found && return unless object

      error_msg = object.errors.full_messages.compact.to_sentence

      render json: {
        uuid:   object.uuid,
        status: object.state,
        error:  error_msg.presence
      }, status: error_msg.blank? ? 200 : 400
    end
  end
end

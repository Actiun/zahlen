require 'active_support/concern'

module Zahlen
  module Uuider
    extend ActiveSupport::Concern

    included do
      before_save :populate_uuid
      validates_uniqueness_of :uuid
    end

    def populate_uuid
      if new_record?
        while !valid? || uuid.nil?
          prefix = try(:uuid_prefix)
          self.uuid = "#{prefix}#{Zahlen.uuid_generator.call}"
        end
      end
    end
  end
end

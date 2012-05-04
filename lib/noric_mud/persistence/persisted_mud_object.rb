require 'ostruct'

module NoricMud
  module Persistence
    class PersistedMudObject < ActiveRecord::Base
      self.abstract_class = true

      def initialize mutex=Mutex.new
        super()
        @mutex = mutex # mutex must be synchronized for any CRUD to persisted properties
        @transient = nil
      end

      # asynchronously save persisted attributes.
      # if transient exists, persisted attributes
      # are copied from transient during the save
      def async_save
        transient? ? async_save_with_transient : async_save_without_transient
        nil
      end

      # return the transient instance associated with this
      def transient
        unless @transient
          @transient = transient_class.new
          @mutex.synchronize { copy_persisted_attributes self, @transient }
        end
        @transient
      end

      protected

      def transient?
        !@transient.nil?
      end

      # subclasses of PersistedMudObject override #copy_persisted_attributes
      # to copy the subclasses' persisted properties
      #  e.g. PersistedMob overrides #copy_persisted_attributes
      #       to copy the persisted properties of Mob
      def copy_persisted_attributes from, to
        # override in subclass
      end

      # subclasses of PersistedMudObject override ::transient_class
      # to return the transient class associated with the subclass
      def transient_class
        raise "#transient_class must be overridden"
      end

      private

      # invoked by #async_save when transient? == true
      def async_save_with_transient
        transient_copy = OpenStruct.new # use OpenStruct to cache persisted attributes
        copy_persisted_attributes transient, transient_copy # copy @transient into transient_copy to cache persisted attributes, because they may change in @transient before the asyncronous save completes
        NoricMud::async do
          @mutex.synchronize do
            copy_persisted_attributes transient_copy, self
            save
          end
        end
      end

      # invoked by #async_save when transient? == false
      def async_save_witheout_transient
        NoricMud::async { @mutex.synchronize { self.save } }
      end
    end
  end
end

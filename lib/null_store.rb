module ActiveSupport
  module Cache
    class NullStore < Store
      def read_entry(key, options)
        nil
      end

      def write_entry(key, entry, options)
        entry
      end

      def delete(name, options = nil)
        super do
          nil
        end
      end

      def exist?(name, options = nil)
        super do
          false
        end
      end

      def increment(name, amount = 1, options = nil)
        nil
      end

      def decrement(name, amount = 1, options=nil)
        nil
      end
    end
  end
end

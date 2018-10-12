module OasParser
  module RawAccessor
    def self.included(klass)
      klass.extend ClassMethods
    end

    def method_missing(method_name, *args, &block)
      super unless self.class.raw_key? method_name
      raw[method_name.to_s]
    end

    def respond_to_missing?(method_name, include_private = false)
      self.class.raw_key?(method_name) || super
    end

    module ClassMethods
      def raw_keys(*args)
        @raw_keys = args
      end

      def raw_key?(key)
        (@raw_keys || []).include?(key)
      end
    end
  end
end

module Afterbanks
  class Resource
    def initialize(data)
      generate_attr_readers
      set_data(data)
    end

    def fields_information
      self.class.fields_information
    end

    private

    def generate_attr_readers
      fields_information.each do |field, _|
        define_singleton_method(field) do
          instance_variable_get("@#{field}")
        end
      end
    end

    def set_data(data)
      fields_information.each do |field, type|
        next unless data.key?(field.to_s) || data[field.to_sym]

        raw_value = data[field.to_s] || data[field.to_sym]
        value = value_for(raw_value, type)
        instance_variable_set("@#{field}", value)
      end
    end

    def value_for(raw_value, type)
      case type
      when :boolean
        [true, "1", 1].include?(raw_value)
      when :date
        if raw_value.is_a?(Date)
          raw_value
        else
          Date.parse(raw_value)
        end
      else
        raw_value
      end
    end

    def marshal_dump
      dump = {}

      fields_information.each do |field, _|
        dump[field] = send(field)
      end

      dump
    end

    def marshal_load(serialized_resource)
      keys = serialized_resource.keys

      keys.each do |key|
        serialized_resource[key.to_s] = serialized_resource.delete(key)
      end

      initialize(serialized_resource)
    end

    class << self
      def fields_information
        @fields_information
      end

      def has_fields(fields_information)
        @fields_information = fields_information
      end
    end
  end
end

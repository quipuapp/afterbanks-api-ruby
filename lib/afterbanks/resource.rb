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
        next unless data.key?(field.to_s)

        raw_value = data[field.to_s]
        value = value_for(raw_value, type)
        instance_variable_set("@#{field}", value)
      end
    end

    def value_for(raw_value, type)
      case type
      when :boolean
        ["1", 1].include?(raw_value)
      when :date
        Date.parse(raw_value) if raw_value
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

    def marshal_load(serialized_bank)
      keys = serialized_bank.keys

      keys.each do |key|
        serialized_bank[key.to_s] = serialized_bank.delete(key)
      end

      initialize(serialized_bank)
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

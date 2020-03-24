module Afterbanks
  class Resource
    def initialize(data)
      generate_attr_readers
      set_data(data)
    end

    def fields
      self.class.fields
    end

    def resources
      self.class.resources
    end

    def collections
      self.class.collections
    end

    protected

    def self.treat_errors_if_any(response)
      return unless response.is_a?(Hash)

      code = response['code']
      message = response['message']
      additional_info = response['additional_info']

      case code
      when 1
        raise GenericError.new(message: message)
      when 2
        raise ServiceUnavailableTemporarilyError.new(message: message)
      when 3
        raise ConnectionDataError.new(message: message)
      when 4
        raise AccountIdDoesNotExistError.new(message: message)
      when 5
        raise CutConnectionError.new(message: message)
      when 6
        raise HumanActionNeededError.new(message: message)
      when 50
        if additional_info && additional_info['session_id']
          raise OTPNeededError.new(
            message: message,
            additional_info: additional_info
          )
        end

        raise AccountIdNeededError.new(message: message)
      end

      nil
    end

    private

    def generate_attr_readers
      self.class.fields_information.each do |field, _|
        define_singleton_method(field) do
          instance_variable_get("@#{field}")
        end
      end
    end

    def set_data(data)
      self.class.fields_information.each do |field, type|
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

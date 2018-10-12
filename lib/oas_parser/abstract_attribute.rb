module OasParser
  class AbstractAttribute
    include OasParser::RawAccessor

    def name(format = nil)
      default = @name || raw['name']
      return default unless format
      case format
      when 'text/xml'
        xml_name? ? xml_name : default
      else default
      end
    end

    def enum
      raw['enum'] || (schema ? schema['enum'] : nil)
    end

    def array?
      type == 'array'
    end

    def object?
      type == 'object'
    end

    def collection?
      array? || object?
    end

    def empty?
      raise 'Called empty? on non collection type' unless collection?
      return true if object? && raw['properties'].blank?
      return true if array? && items.blank?
      false
    end

    def properties
      return nil unless collection?
      return [] if empty?
      return convert_property_schema_to_properties(raw['properties']) if object?
      return convert_property_schema_to_properties(items) if array?
      nil
    end

    def xml_options?
      raw['xml'].present?
    end

    def xml_attribute?
      return false unless xml_options?
      raw['xml']['attribute'].present?
    end

    def xml_text?
      # See: https://github.com/OAI/OpenAPI-Specification/issues/630#issuecomment-350680346
      return false unless xml_options?
      %w[text x-text].any? { |k| raw['xml'][k] }
    end

    def xml_name?
      return false unless xml_options?
      xml_name.present?
    end

    def xml_name
      raw['xml']['name']
    end

    def subproperties_are_one_of_many?
      return false unless array?
      items['oneOf'].present?
    end
  end
end

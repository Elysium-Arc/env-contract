# frozen_string_literal: true

require "json"
require "env/contract/version"

module EnvContract
  class Error < StandardError; end
  class MissingVariable < Error; end
  class InvalidType < Error; end

  Entry = Struct.new(:name, :required, :type, :default, :desc, :values, :separator, keyword_init: true)

  def self.define(&block)
    registry.instance_eval(&block)
    registry
  end

  def self.registry
    @registry ||= Registry.new
  end

  def self.reset!
    @registry = Registry.new
  end

  def self.load!
    registry.load!
  end

  def self.sample
    registry.sample
  end

  class Registry
    def initialize
      @entries = []
    end

    def required(name, type: :string, default: nil, desc: nil, values: nil, separator: nil)
      add(name, required: true, type: type, default: default, desc: desc, values: values, separator: separator)
    end

    def optional(name, type: :string, default: nil, desc: nil, values: nil, separator: nil)
      add(name, required: false, type: type, default: default, desc: desc, values: values, separator: separator)
    end

    def load!
      values = {}
      @entries.each do |entry|
        raw = ENV[entry.name]
        if raw.nil? || raw == ""
          if entry.required && entry.default.nil?
            raise MissingVariable, "Missing ENV #{entry.name}"
          end
          raw = entry.default
        end
        values[entry.name] = cast(raw, entry)
      end
      values
    end

    def sample
      lines = []
      @entries.each do |entry|
        lines << "# #{entry.desc}" if entry.desc
        value = entry.default.nil? ? "" : entry.default
        lines << "#{entry.name}=#{value}"
      end
      lines.join("\n") + "\n"
    end

    private

    def add(name, required:, type:, default:, desc:, values:, separator:)
      @entries << Entry.new(
        name: name.to_s,
        required: required,
        type: type,
        default: default,
        desc: desc,
        values: values,
        separator: separator
      )
    end

    def cast(value, entry)
      return nil if value.nil?
      type = entry.type
      case type
      when :string
        value.to_s
      when :integer
        Integer(value)
      when :float
        Float(value)
      when :boolean
        return true if value == true || %w[true 1 yes y].include?(value.to_s.downcase)
        return false if value == false || %w[false 0 no n].include?(value.to_s.downcase)
        raise InvalidType, "Invalid boolean #{value}"
      when :array
        separator = entry.separator || ","
        return value if value.is_a?(Array)
        value.to_s.split(separator).map(&:strip)
      when :json
        JSON.parse(value.to_s)
      when :enum
        options = Array(entry.values).map(&:to_s)
        raise InvalidType, "Enum values are required for #{entry.name}" if options.empty?
        candidate = value.to_s
        return candidate if options.include?(candidate)
        raise InvalidType, "Invalid enum #{value}"
      else
        return type.call(value) if type.respond_to?(:call)
        raise InvalidType, "Unknown type #{type}"
      end
    rescue ArgumentError, TypeError
      raise InvalidType, "Invalid #{type} #{value}"
    end
  end
end

require "env/contract/railtie"

# frozen_string_literal: true

require "json"
require "env/contract/version"

module EnvContract
  class Error < StandardError; end
  class MissingVariable < Error; end
  class InvalidType < Error; end

  Entry = Struct.new(:name, :required, :type, :default, :desc, keyword_init: true)

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

    def required(name, type: :string, default: nil, desc: nil)
      add(name, required: true, type: type, default: default, desc: desc)
    end

    def optional(name, type: :string, default: nil, desc: nil)
      add(name, required: false, type: type, default: default, desc: desc)
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
        values[entry.name] = cast(raw, entry.type)
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
      lines.join("
") + "
"
    end

    private

    def add(name, required:, type:, default:, desc:)
      @entries << Entry.new(name: name.to_s, required: required, type: type, default: default, desc: desc)
    end

    def cast(value, type)
      return nil if value.nil?
      case type
      when :string
        value.to_s
      when :integer
        Integer(value)
      when :float
        Float(value)
      when :boolean
        return true if value == true || value.to_s.downcase == "true"
        return false if value == false || value.to_s.downcase == "false"
        raise InvalidType, "Invalid boolean #{value}"
      when :json
        JSON.parse(value.to_s)
      else
        raise InvalidType, "Unknown type #{type}"
      end
    rescue ArgumentError, TypeError
      raise InvalidType, "Invalid #{type} #{value}"
    end
  end
end

require "env/contract/railtie"

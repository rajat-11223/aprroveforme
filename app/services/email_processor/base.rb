# frozen_string_literal: true

class EmailProcessor
  class StopProcessing < StandardError; end

  class Base
    def self.triggered_by(*opts)
      @triggered_by = opts
    end

    def initialize(email, options = {})
      @email = email
      @options = options
    end

    def process!
      if !slug.presence || self.class.triggerable?(slug)
        process
      end
    end

    private

    attr_reader :email, :options

    def from_email
      @from_email ||= email.from.dig(:email)
    end

    def from_with_name
      @from_with_name ||= begin
        full_str = email.from.dig(:full)
        name = full_str.split("<").first.strip

        [name, from_email]
      end
    end

    def slug
      @slug ||= options[:slug].try(:downcase).try(:to_sym)
    end

    def self.triggerable?(slug)
      return true if triggers.include?(:any)

      triggers.include?(slug)
    end

    def self.triggers
      self.instance_variable_get("@triggered_by") || []
    end
  end
end

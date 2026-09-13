module ClaudeCLI
  # Normalizes the various shapes a `validate:` callable can return into
  # a consistent [ok, message] pair.
  #
  # Accepted return values from the validator:
  #   true                 -> [true, nil]
  #   false                -> [false, "Invalid value"]
  #   "some message"       -> [false, "some message"]
  #   [true, ...]          -> [true, nil]
  #   [false, "message"]   -> [false, "message"]
  module Validation
    DEFAULT_MESSAGE = "Invalid value".freeze

    def self.run(validator, value)
      return [true, nil] unless validator

      result = validator.call(value)

      case result
      when true
        [true, nil]
      when false
        [false, DEFAULT_MESSAGE]
      when String
        [false, result]
      when Array
        ok, message = result
        ok ? [true, nil] : [false, message || DEFAULT_MESSAGE]
      when nil
        [true, nil]
      else
        # Truthy, non-standard return: treat as valid.
        [true, nil]
      end
    end
  end
end

# frozen_string_literal: true

module ActionText
  # Generic base class for all Action Text exceptions.
  class Error < StandardError; end

  # Raised when calling rich_text_area within a form without including
  # `has_rich_text :method_name` class method in the related object.
  class MissingHashRichTextError < Error
    def initialize(object:, method_name:)
      @object, @method_name = object, method_name
    end

    def to_s
      "can't access value, possibly missing class method `has_rich_text :#{method_name}`"\
      " for #{object.class.name} or `:#{method_name}` was misspelled"
    end

    private
      attr_reader :object, :method_name
  end
end

# frozen_string_literal: true

require 'test_helper'

class ActionText::FormHelperTest < ActionView::TestCase
  test "rich_text_area raises ActionText::MissingHashRichTextError when missing has_rich_text class method" do
    assert_raises ActionText::MissingHashRichTextError do
      form_with(model: Message.new, html: { id: "create-message" }) do |form|
        form.rich_text_area(:undeclared_attribute)
      end
    end
  end

  test "rich_text_area doesn't raise when has_rich_text class method is in place" do
    assert_nothing_raised do
      form_with(model: Message.new, html: { id: "create-message" }) do |form|
        form.rich_text_area(:content)
      end
    end
  end
end

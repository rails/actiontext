# frozen_string_literal: true

module ActionText
  module Attachable
    extend ActiveSupport::Concern

    LOCATOR_NAME = "attachable"

    class << self
      def from_node(node)
        if attachable = attachable_from_sgid(node["sgid"])
          attachable
        elsif attachable = attachable_from_attachables(node)
          attachable
        else
          ActionText::Attachables::MissingAttachable
        end
      end

      def from_attachable_sgid(sgid, options = {})
        method = sgid.is_a?(Array) ? :locate_many_signed : :locate_signed
        record = GlobalID::Locator.public_send(method, sgid, options.merge(for: LOCATOR_NAME))
        record or raise ActiveRecord::RecordNotFound
      end

      private
        def attachable_from_attachables(node)
          ActionText.attachables.reduce(nil) do |result, klass|
            next result if result

            if attachable = klass.from_node(node)
              result = attachable
            end

            result
          end
        end

        def attachable_from_sgid(sgid)
          from_attachable_sgid(sgid)
        rescue ActiveRecord::RecordNotFound
          nil
        end
    end

    class_methods do
      def from_attachable_sgid(sgid)
        ActionText::Attachable.from_attachable_sgid(sgid, only: self)
      end
    end

    def attachable_sgid
      to_sgid(expires_in: nil, for: LOCATOR_NAME).to_s
    end

    def attachable_content_type
      try(:content_type) || "application/octet-stream"
    end

    def attachable_filename
      filename.to_s if respond_to?(:filename)
    end

    def attachable_filesize
      try(:byte_size) || try(:filesize)
    end

    def attachable_metadata
      try(:metadata) || {}
    end

    def previewable_attachable?
      false
    end

    def as_json(*)
      super.merge(attachable_sgid: attachable_sgid)
    end

    def to_rich_text_attributes(attributes = {})
      attributes.dup.tap do |attrs|
        attrs[:sgid] = attachable_sgid
        attrs[:content_type] = attachable_content_type
        attrs[:previewable] = true if previewable_attachable?
        attrs[:filename] = attachable_filename
        attrs[:filesize] = attachable_filesize
        attrs[:width] = attachable_metadata[:width]
        attrs[:height] = attachable_metadata[:height]
      end.compact
    end
  end
end

# frozen_string_literal: true

require "rails/engine"
require "action_text"

require "action_text/attachables/content_attachment"
require "action_text/attachables/remote_image"

module ActionText
  class Engine < Rails::Engine
    isolate_namespace ActionText

    config.action_text = ActiveSupport::OrderedOptions.new
    config.action_text.attachables = [ ActionText::Attachables::ContentAttachment, ActionText::Attachables::RemoteImage ]

    config.eager_load_namespaces << ActionText

    initializer "action_text.attribute" do
      ActiveSupport.on_load(:active_record) do
        include ActionText::Attribute
      end
    end

    initializer "action_text.active_storage_extension" do
      ActiveSupport.on_load(:active_storage_blob) do
        include ActionText::Attachable

        def previewable_attachable?
          representable?
        end
      end
    end

    initializer "action_text.helper" do
      ActiveSupport.on_load(:action_controller_base) do
        helper ActionText::Engine.helpers
      end
    end

    initializer "action_text.config" do
      config.after_initialize do |app|
        ActionText.renderer ||= ApplicationController.renderer

        ActionText.attachables = app.config.action_text.attachables || []

        # FIXME: ApplicationController should have a per-request specific renderer
        # that's been set with the request.env env, and ActionText should just piggyback off
        # that by default rather than doing this work directly.
        ApplicationController.before_action do
          ActionText.renderer = ActionText.renderer.new(request.env)
        end
      end
    end
  end
end

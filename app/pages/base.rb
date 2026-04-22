# frozen_string_literal: true

module Relay::Pages
  ##
  # Base class for full-page renderers.
  class Base
    include Relay::Models

    ##
    # @param [Roda] roda
    # @return [Relay::Pages::Base]
    def initialize(roda)
      @roda = roda
    end

    ##
    # @return [String]
    #  The requested provider, defaulting to deepseek
    def provider
      session["provider"] || "deepseek"
    end

    ##
    # @return [String]
    #  The requested model, defaulting to deepseek-chat
    def model
      session["model"] || "deepseek-chat"
    end

    ##
    # @return [Relay::Models::Context]
    #  The current context for the user, provider, and model
    def ctx
      @ctx ||= begin
        context = current_context || default_context
        sync_context!(context)
      end
    end

    ##
    # @return [Array<Relay::Models::Context>]
    #  Saved contexts for the current user and provider, newest first.
    def contexts
      @contexts ||= Relay::Models::Context.where(user_id: user.id, provider:)
        .reverse_order(:updated_at)
        .all
        .select { _1.messages.any? }
    end

    ##
    # @return [Relay::Models::Context, nil]
    def current_context
      return unless session["context_id"]

      Relay::Models::Context.where(user_id: user.id, provider:, id: session["context_id"]).first
    end

    ##
    # @return [Relay::Models::Context]
    def default_context
      Relay::Models::Context.where(user_id: user.id, provider:, model:)
        .reverse_order(:updated_at)
        .first || Relay::Models::Context.create(user_id: user.id, provider:, model:)
    end

    ##
    # @param [Relay::Models::Context] context
    # @return [Relay::Models::Context]
    def sync_context!(context)
      session["context_id"] = context.id
      session["model"] = context[:model]
      context
    end

    ##
    # @return [Hash<String,LLM::Provider>]
    def llms
      @llms ||= {
        "openai" => LLM.openai(key: ENV["OPENAI_SECRET"]),
        "google" => LLM.google(key: ENV["GOOGLE_SECRET"]),
        "anthropic" => LLM.anthropic(key: ENV["ANTHROPIC_SECRET"]),
        "deepseek" => LLM.deepseek(key: ENV["DEEPSEEK_SECRET"]),
        "xai" => LLM.xai(key: ENV["XAI_SECRET"])
      }.transform_values(&:persist!)
    end

    ##
    # @return [Array<LLM::Model>]
    def chat_models
      llms.fetch(provider).models.all.select(&:chat?)
    end

    ##
    # @return [Relay::Models::User, nil]
    def user
      @user
    end

    ##
    # @return [Roda::RodaRequest]
    #  Alias the request object as `r` to match Roda route blocks.
    def r
      @roda.request
    end

    private

    ##
    # Renders a page template with the shared layout.
    # @param [String] name
    # @param [Hash] locals
    # @return [String]
    def page(name, **locals)
      view(File.join("pages", name), locals:, layout_opts: {locals:})
    end

    ##
    # Delegate missing methods to the current Roda instance.
    def method_missing(name, *args, **kwargs, &block)
      if @roda.respond_to?(name)
        @roda.send(name, *args, **kwargs, &block)
      else
        super
      end
    end

    ##
    # Respond to missing methods that are delegated to Roda.
    def respond_to_missing?(name, include_private = false)
      @roda.respond_to?(name) || super
    end
  end
end

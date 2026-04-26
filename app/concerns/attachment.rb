module Relay::Concerns
  module Attachment
    def attachment
      @attachment ||= Relay::Attachment.session(
        session:,
        root: Relay.root,
        user: respond_to?(:user) ? user : nil,
        provider: session["provider"]
      )
    end
  end
end

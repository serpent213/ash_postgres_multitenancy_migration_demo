defmodule Demo.Accounts.Identity do
  use Ash.Resource,
    otp_app: :demo,
    domain: Demo.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication]

  actions do
    defaults [:read]

    create :create do
      description "Create an identity for testing purposes"
      primary? true
      accept [:email]
    end

    read :get_by_subject do
      description "Get an identity by the subject claim in a JWT"
      argument :subject, :string, allow_nil?: false
      get? true
      prepare AshAuthentication.Preparations.FilterBySubject
    end

    read :get_by_email do
      description "Looks up an identity by their email"
      get? true

      argument :email, :ci_string do
        allow_nil? false
      end

      filter expr(email == ^arg(:email))
    end

    create :sign_in_with_magic_link do
      description "Sign in or register an identity with magic link."

      argument :token, :string do
        description "The token from the magic link that was sent to the user"
        allow_nil? false
      end

      upsert? true
      upsert_identity :unique_email
      upsert_fields [:email]

      # Uses the information from the token to create or sign in the user
      change AshAuthentication.Strategy.MagicLink.SignInChange

      metadata :token, :string do
        allow_nil? false
      end
    end

    action :request_magic_link do
      argument :email, :ci_string do
        allow_nil? false
      end

      run AshAuthentication.Strategy.MagicLink.Request
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end

    policy always() do
      forbid_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :email, :ci_string do
      allow_nil? false
      public? true
    end
  end

  relationships do
    has_many :users, Demo.Accounts.User do
      public? true
    end

    many_to_many :organisations, Demo.Accounts.Organisation do
      through Demo.Accounts.IdentityOrganisation
    end
  end

  identities do
    identity :unique_email, [:email]
  end

  authentication do
    add_ons do
      log_out_everywhere do
        apply_on_password_change? true
      end
    end

    tokens do
      enabled? true
      token_resource Demo.Accounts.Token
      signing_secret Demo.Secrets
      store_all_tokens? true
      require_token_presence_for_authentication? true
    end

    strategies do
      magic_link do
        identity_field :email
        registration_enabled? true
        require_interaction? true

        sender Demo.Accounts.Identity.Senders.SendMagicLinkEmail
      end
    end
  end

  postgres do
    table "identities"
    repo Demo.Repo
  end
end

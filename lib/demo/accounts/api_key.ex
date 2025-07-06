defmodule Demo.Accounts.ApiKey do
  use Ash.Resource,
    otp_app: :demo,
    domain: Demo.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer]

  actions do
    defaults [:read, :destroy]

    create :create do
      primary? true
      accept [:user_id, :organisation_id, :expires_at]

      change {AshAuthentication.Strategy.ApiKey.GenerateApiKey, prefix: :demo, hash: :api_key_hash}
    end
  end

  policies do
    bypass AshAuthentication.Checks.AshAuthenticationInteraction do
      authorize_if always()
    end
  end

  attributes do
    uuid_primary_key :id

    attribute :api_key_hash, :binary do
      allow_nil? false
      sensitive? true
    end

    attribute :expires_at, :utc_datetime_usec do
      allow_nil? false
    end
  end

  relationships do
    belongs_to :user, Demo.Accounts.User
    belongs_to :organisation, Demo.Accounts.Organisation
  end

  calculations do
    calculate :valid, :boolean, expr(expires_at > now())
  end

  identities do
    identity :unique_api_key, [:api_key_hash]
  end

  postgres do
    table "api_keys"
    repo Demo.Repo
  end
end

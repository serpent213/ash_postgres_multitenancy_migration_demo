defmodule Demo.Accounts.User do
  use Ash.Resource,
    otp_app: :demo,
    domain: Demo.Accounts,
    data_layer: AshPostgres.DataLayer,
    authorizers: [Ash.Policy.Authorizer],
    extensions: [AshAuthentication]

  actions do
    defaults [
      :read,
      :destroy,
      create: [:identity_id, :family_name, :given_names],
      update: [:family_name, :given_names]
    ]

    read :sign_in_with_api_key do
      argument :api_key, :string, allow_nil?: false
      prepare AshAuthentication.Strategy.ApiKey.SignInPreparation
      multitenancy :allow_global
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

    attribute :family_name, :string do
      public? true
    end

    attribute :given_names, :string do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :identity, Demo.Accounts.Identity do
      allow_nil? false
      public? true
    end

    has_many :projects, Demo.TimeTracking.Project do
      public? true
    end

    has_many :api_keys, Demo.Accounts.ApiKey

    has_many :valid_api_keys, Demo.Accounts.ApiKey do
      filter expr(valid)
    end
  end

  multitenancy do
    strategy :context
    global? true
  end

  authentication do
    strategies do
      api_key :api_key do
        api_key_relationship :valid_api_keys
        api_key_hash_attribute :api_key_hash
      end
    end
  end

  postgres do
    table "users"
    repo Demo.Repo
  end
end

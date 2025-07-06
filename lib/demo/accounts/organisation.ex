defmodule Demo.Accounts.Organisation do
  use Ash.Resource,
    otp_app: :demo,
    domain: Demo.Accounts,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:read, :destroy, create: [:name, :website_url], update: [:name, :website_url]]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :website_url, :string do
      allow_nil? false
      public? true
    end

    timestamps()
  end

  relationships do
    has_many :api_keys, Demo.Accounts.ApiKey

    many_to_many :identities, Demo.Accounts.Identity do
      through Demo.Accounts.IdentityOrganisation
    end
  end

  postgres do
    table "organisations"
    repo Demo.Repo

    manage_tenant do
      template ["org_", :id]
    end
  end
end

defmodule Demo.Accounts.IdentityOrganisation do
  use Ash.Resource,
    otp_app: :demo,
    domain: Demo.Accounts,
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [:read, :destroy, create: :*, update: :*]
  end

  relationships do
    belongs_to :identity, Demo.Accounts.Identity, primary_key?: true, allow_nil?: false
    belongs_to :organisation, Demo.Accounts.Organisation, primary_key?: true, allow_nil?: false
  end

  postgres do
    table "identity_organisations"
    repo Demo.Repo
  end
end

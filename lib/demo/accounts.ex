defmodule Demo.Accounts do
  use Ash.Domain, otp_app: :demo, extensions: [AshGraphql.Domain]

  resources do
    resource Demo.Accounts.Identity
    resource Demo.Accounts.User
    resource Demo.Accounts.Organisation
    resource Demo.Accounts.IdentityOrganisation
    resource Demo.Accounts.Token
    resource Demo.Accounts.ApiKey
  end
end

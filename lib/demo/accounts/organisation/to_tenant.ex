defmodule Demo.Accounts.Organisation.ToTenant do
  @moduledoc """
  Implementation of Ash.ToTenant protocol for Organisation.
  Converts Organisation struct to tenant identifier for schema-based multitenancy.
  """

  defimpl Ash.ToTenant, for: Demo.Accounts.Organisation do
    def to_tenant(%{id: id}, _resource) do
      "org_#{id}"
    end
  end
end

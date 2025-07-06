defmodule Demo.Scope do
  @moduledoc """
  Application scope containing user, tenant, and context information for Ash operations.
  """

  defstruct [:current_user, :current_tenant, :locale]

  defimpl Ash.Scope.ToOpts do
    def get_actor(%{current_user: current_user}), do: {:ok, current_user}
    def get_actor(_), do: :error

    def get_tenant(%{current_tenant: current_tenant}), do: {:ok, current_tenant}
    def get_tenant(_), do: :error

    def get_context(%{locale: locale}) when not is_nil(locale) do
      {:ok, %{shared: %{locale: locale}}}
    end

    def get_context(_), do: {:ok, %{shared: %{}}}

    # You typically configure tracers in config files
    # so this will typically return :error
    def get_tracer(_), do: :error

    # This should likely always return :error
    # unless you want a way to bypass authorization configured in your scope
    def get_authorize?(_), do: :error
  end
end

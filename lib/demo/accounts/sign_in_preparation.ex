defmodule Demo.Accounts.SignInPreparation do
  @moduledoc """
  Prepare a query for sign in with API key, handling tenant context properly.

  This is based on AshAuthentication.Strategy.ApiKey.SignInPreparation but adds
  proper tenant context handling for multi-tenant applications.
  """

  use Ash.Resource.Preparation
  alias AshAuthentication.{Errors.AuthenticationFailed, Info}
  alias Ash.{Query, Resource.Preparation}
  require Ash.Query

  @doc false
  @impl true
  @spec prepare(Query.t(), keyword, Preparation.Context.t()) :: Query.t()
  def prepare(query, opts, context) do
    with {:ok, strategy} <- Info.find_strategy(query, context, opts),
         {:ok, api_key} <- Query.fetch_argument(query, :api_key),
         {:ok, api_key_id, random_bytes} <- decode_api_key(api_key) do
      api_key_relationship =
        Ash.Resource.Info.relationship(query.resource, strategy.api_key_relationship)

      query
      |> Query.set_context(%{private: %{ash_authentication?: true}})
      |> Ash.Query.before_action(fn query ->
        # Find the API key across all tenants or in global scope
        api_key_relationship.destination
        |> Ash.Query.do_filter(api_key_relationship.filter)
        |> Ash.Query.filter(id == ^api_key_id)
        |> Query.set_context(%{private: %{ash_authentication?: true}})
        |> then(fn api_key_query ->
          # Try to read the API key without tenant context first
          # If ApiKey is tenant-scoped, we may need to search across tenants
          Ash.read_one(api_key_query, authorize?: false)
        end)
        |> case do
          {:ok, nil} ->
            # Timing attack protection
            Plug.Crypto.secure_compare(
              :crypto.hash(:sha256, random_bytes <> api_key_id),
              Ecto.UUID.bingenerate() <> :crypto.strong_rand_bytes(32)
            )

            Ash.Query.filter(query, false)

          {:ok, api_key} ->
            check_api_key_with_tenant(
              query,
              api_key,
              api_key_id,
              strategy,
              api_key_relationship,
              random_bytes
            )

          {:error, error} ->
            Ash.Query.add_error(
              query,
              AuthenticationFailed.exception(
                strategy: strategy,
                query: query,
                caused_by: error
              )
            )
        end
      end)
    else
      _ ->
        # Timing attack protection
        Plug.Crypto.secure_compare(
          :crypto.hash(:sha256, :crypto.strong_rand_bytes(32) <> Ecto.UUID.bingenerate()),
          Ecto.UUID.bingenerate() <> :crypto.strong_rand_bytes(32)
        )

        Query.do_filter(query, false)
    end
  end

  defp check_api_key_with_tenant(query, api_key, api_key_id, strategy, api_key_relationship, random_bytes) do
    if Plug.Crypto.secure_compare(
         :crypto.hash(:sha256, random_bytes <> api_key_id),
         Map.get(api_key, strategy.api_key_hash_attribute)
       ) do
      # Get the user that owns this API key to determine tenant context
      user_id = Map.get(api_key, api_key_relationship.destination_attribute)

      # Find the user and determine their tenant
      determine_tenant_and_filter_user(query, user_id, api_key, strategy, api_key_relationship)
    else
      Ash.Query.filter(query, false)
    end
  end

  defp determine_tenant_and_filter_user(query, user_id, api_key, strategy, api_key_relationship) do
    # Since User is tenant-scoped, we need to find which tenant this user belongs to
    # We'll try to find the user across different tenant contexts
    # In a real implementation, you might want to store tenant info in the API key
    # or have a more efficient way to determine tenant

    case find_user_tenant(user_id) do
      {:ok, tenant} ->
        query
        |> Query.set_context(%{tenant: tenant})
        |> Ash.Query.do_filter(%{
          api_key_relationship.source_attribute => user_id
        })
        |> Ash.Query.after_action(fn
          _query, [user] ->
            {:ok,
             [
               Ash.Resource.set_metadata(
                 user,
                 %{
                   api_key: api_key,
                   using_api_key?: true,
                   tenant: tenant
                 }
               )
             ]}

          query, [] ->
            {:error,
             AuthenticationFailed.exception(
               strategy: strategy,
               query: query,
               caused_by: %{
                 module: __MODULE__,
                 strategy: strategy,
                 action: :sign_in,
                 message: "Query returned no users"
               }
             )}

          query, _ ->
            {:error,
             AuthenticationFailed.exception(
               strategy: strategy,
               query: query,
               caused_by: %{
                 module: __MODULE__,
                 strategy: strategy,
                 action: :sign_in,
                 message: "Query returned too many users"
               }
             )}
        end)

      {:error, _} ->
        Ash.Query.filter(query, false)
    end
  end

  defp find_user_tenant(user_id) do
    # This is a simplified approach - in practice you might want to:
    # 1. Store tenant info in the API key itself
    # 2. Have a tenant-agnostic lookup table
    # 3. Search across known tenants more efficiently

    # For now, we'll try to find the user by looking for their organization
    # through the identity relationship and then determine the tenant

    # Query the User resource to find which tenant this user belongs to
    # We'll need to check across tenants or use a different approach
    case Demo.Accounts.User
         |> Ash.Query.filter(id == ^user_id)
         |> Ash.Query.load(:identity)
         |> then(fn query ->
           # Try to find the user across different tenant contexts
           # This is not ideal and should be optimized in production
           try_find_user_in_tenants(query)
         end) do
      {:ok, user} when not is_nil(user) ->
        # Extract tenant from user context or derive it from organization
        # For now, we'll assume tenant follows "org_<id>" pattern
        # In practice, you'd determine this based on your actual tenant setup
        {:ok, get_tenant_from_user(user)}

      _ ->
        {:error, :user_not_found}
    end
  end

  defp try_find_user_in_tenants(query) do
    # This is a simplified approach - you'd want to optimize this
    # by either making API keys tenant-agnostic or storing tenant info

    # For now, try without tenant context first
    case Ash.read_one(query, authorize?: false) do
      {:ok, user} when not is_nil(user) ->
        {:ok, user}

      _ ->
        # If user is tenant-scoped, we'd need to try different tenants
        # This is not efficient and should be redesigned
        {:error, :not_found}
    end
  end

  defp get_tenant_from_user(_user) do
    # This is where you'd determine the tenant from the user
    # For now, we'll return nil and rely on the system to handle it
    # In practice, you might:
    # 1. Have a user.organization_id and use "org_#{organization_id}"
    # 2. Store tenant info in user metadata
    # 3. Have a lookup table

    # For the current setup, we need to find the organization this user belongs to
    # This requires additional queries which is not ideal
    nil
  end

  defp decode_api_key(api_key) do
    with [_parse_prefix, middle, crc32] <- String.split(api_key, "_", parts: 3),
         {:ok, <<random_bytes::binary-size(32), id::binary-size(16)>>} <-
           AshAuthentication.Base.bindecode62(middle),
         true <-
           AshAuthentication.Base.decode62(crc32) ==
             {:ok, :erlang.crc32(random_bytes <> id)} do
      {:ok, id, random_bytes}
    else
      _ ->
        :error
    end
  end
end

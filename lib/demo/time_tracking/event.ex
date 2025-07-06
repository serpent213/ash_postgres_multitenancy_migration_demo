defmodule Demo.TimeTracking.Event do
  use Ash.Resource,
    otp_app: :demo,
    domain: Demo.TimeTracking,
    extensions: [AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [
      :read,
      :destroy,
      create: [:start_time, :duration, :timezone, :comment, :sync_status, :deleted],
      update: [:start_time, :duration, :timezone, :comment, :sync_status, :deleted]
    ]
  end

  attributes do
    uuid_primary_key :id

    attribute :start_time, :utc_datetime_usec do
      allow_nil? false
      public? true
    end

    attribute :duration, :integer do
      allow_nil? false
      public? true
    end

    attribute :timezone, :string do
      public? true
    end

    attribute :comment, :string do
      public? true
    end

    attribute :sync_status, :atom do
      public? true
    end

    attribute :deleted, :boolean do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :project, Demo.TimeTracking.Project do
      allow_nil? false
      public? true
    end
  end

  multitenancy do
    strategy :context
  end

  graphql do
    type :event
  end

  postgres do
    table "events"
    repo Demo.Repo
  end
end

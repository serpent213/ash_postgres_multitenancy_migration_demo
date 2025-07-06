defmodule Demo.TimeTracking.Photo do
  use Ash.Resource,
    otp_app: :demo,
    domain: Demo.TimeTracking,
    extensions: [AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [
      :read,
      :destroy,
      create: [
        :timestamp,
        :timezone,
        :comment,
        :rotation_angle,
        :mime_type,
        :sha256_hash,
        :sync_status,
        :file_upload_status,
        :deleted
      ],
      update: [
        :timestamp,
        :timezone,
        :comment,
        :rotation_angle,
        :mime_type,
        :sha256_hash,
        :sync_status,
        :file_upload_status,
        :deleted
      ]
    ]
  end

  attributes do
    uuid_primary_key :id

    attribute :timestamp, :utc_datetime_usec do
      allow_nil? false
      public? true
    end

    attribute :timezone, :string do
      public? true
    end

    attribute :comment, :string do
      public? true
    end

    attribute :rotation_angle, :integer do
      public? true
    end

    attribute :mime_type, :string do
      allow_nil? false
      public? true
    end

    attribute :sha256_hash, :string do
      public? true
    end

    attribute :sync_status, :atom do
      public? true
    end

    attribute :file_upload_status, :atom do
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
    type :photo
  end

  postgres do
    table "photos"
    repo Demo.Repo
  end
end

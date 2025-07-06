defmodule Demo.TimeTracking.Project do
  use Ash.Resource,
    otp_app: :demo,
    domain: Demo.TimeTracking,
    extensions: [AshGraphql.Resource],
    data_layer: AshPostgres.DataLayer

  actions do
    defaults [
      :read,
      :destroy,
      create: [:user_id, :name, :comment, :sync_status],
      update: [:name, :comment, :sync_status]
    ]
  end

  attributes do
    uuid_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :comment, :string do
      public? true
    end

    attribute :sync_status, :atom do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Demo.Accounts.User do
      allow_nil? false
      public? true
    end

    has_many :photos, Demo.TimeTracking.Photo do
      public? true
    end

    has_many :events, Demo.TimeTracking.Event do
      public? true
    end
  end

  multitenancy do
    strategy :context
  end

  graphql do
    type :project

    queries do
      get :get_project, :read
      list :projects, :read
    end

    mutations do
      create :create_project, :create
      update :update_project, :update
      destroy :destroy_project, :destroy
    end
  end

  postgres do
    table "projects"
    repo Demo.Repo
  end
end

defmodule Demo.TimeTracking do
  use Ash.Domain, otp_app: :demo, extensions: [AshGraphql.Domain]

  resources do
    resource Demo.TimeTracking.Project
    resource Demo.TimeTracking.Photo
    resource Demo.TimeTracking.Event
  end

  graphql do
    # Disable authorisation for prototyping
    authorize? false
  end
end

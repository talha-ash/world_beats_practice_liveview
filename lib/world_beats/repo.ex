defmodule WorldBeats.Repo do
  use Ecto.Repo,
    otp_app: :world_beats,
    adapter: Ecto.Adapters.Postgres
end

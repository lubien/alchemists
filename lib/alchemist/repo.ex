defmodule Alchemist.Repo do
  use Ecto.Repo,
    otp_app: :alchemist,
    adapter: Ecto.Adapters.Postgres
end

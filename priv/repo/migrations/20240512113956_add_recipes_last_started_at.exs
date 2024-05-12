defmodule Alchemist.Repo.Migrations.AddRecipesLastStartedAt do
  use Ecto.Migration

  def change do
    alter table(:recipes) do
      add :last_started_at, :utc_datetime_usec
    end
  end
end

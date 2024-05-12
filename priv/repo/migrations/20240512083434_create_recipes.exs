defmodule Alchemist.Repo.Migrations.CreateRecipes do
  use Ecto.Migration

  def change do
    create table(:recipes) do
      add :name, :string
      add :slug, :string
      add :code, :text
      add :fly_app_name, :string
      add :fly_machine_id, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:recipes, [:fly_machine_id])
    create unique_index(:recipes, [:fly_app_name])
  end
end

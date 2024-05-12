defmodule Alchemist.Recipes.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "recipes" do
    field :code, :string
    field :name, :string
    field :slug, :string
    field :fly_app_name, :string
    field :fly_machine_id, :string
    field :last_started_at, :utc_datetime_usec

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :slug, :code, :fly_app_name, :fly_machine_id, :last_started_at])
    |> validate_required([:name, :slug, :code, :fly_app_name])
    |> unique_constraint(:fly_machine_id)
    |> unique_constraint(:fly_app_name)
  end
end

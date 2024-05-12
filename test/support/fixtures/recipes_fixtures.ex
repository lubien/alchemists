defmodule Alchemist.RecipesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Alchemist.Recipes` context.
  """

  @doc """
  Generate a unique recipe fly_app_name.
  """
  def unique_recipe_fly_app_name, do: "some fly_app_name#{System.unique_integer([:positive])}"

  @doc """
  Generate a unique recipe fly_machine_id.
  """
  def unique_recipe_fly_machine_id, do: "some fly_machine_id#{System.unique_integer([:positive])}"

  @doc """
  Generate a recipe.
  """
  def recipe_fixture(attrs \\ %{}) do
    {:ok, recipe} =
      attrs
      |> Enum.into(%{
        code: "some code",
        fly_app_name: unique_recipe_fly_app_name(),
        fly_machine_id: unique_recipe_fly_machine_id(),
        name: "some name",
        slug: "some slug"
      })
      |> Alchemist.Recipes.create_recipe()

    recipe
  end
end

defmodule Alchemist.RecipesTest do
  use Alchemist.DataCase

  alias Alchemist.Recipes

  describe "recipes" do
    alias Alchemist.Recipes.Recipe

    import Alchemist.RecipesFixtures

    @invalid_attrs %{code: nil, name: nil, slug: nil, fly_app_name: nil, fly_machine_id: nil}

    test "list_recipes/0 returns all recipes" do
      recipe = recipe_fixture()
      assert Recipes.list_recipes() == [recipe]
    end

    test "get_recipe!/1 returns the recipe with given id" do
      recipe = recipe_fixture()
      assert Recipes.get_recipe!(recipe.id) == recipe
    end

    test "create_recipe/1 with valid data creates a recipe" do
      valid_attrs = %{code: "some code", name: "some name", slug: "some slug", fly_app_name: "some fly_app_name", fly_machine_id: "some fly_machine_id"}

      assert {:ok, %Recipe{} = recipe} = Recipes.create_recipe(valid_attrs)
      assert recipe.code == "some code"
      assert recipe.name == "some name"
      assert recipe.slug == "some slug"
      assert recipe.fly_app_name == "some fly_app_name"
      assert recipe.fly_machine_id == "some fly_machine_id"
    end

    test "create_recipe/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Recipes.create_recipe(@invalid_attrs)
    end

    test "update_recipe/2 with valid data updates the recipe" do
      recipe = recipe_fixture()
      update_attrs = %{code: "some updated code", name: "some updated name", slug: "some updated slug", fly_app_name: "some updated fly_app_name", fly_machine_id: "some updated fly_machine_id"}

      assert {:ok, %Recipe{} = recipe} = Recipes.update_recipe(recipe, update_attrs)
      assert recipe.code == "some updated code"
      assert recipe.name == "some updated name"
      assert recipe.slug == "some updated slug"
      assert recipe.fly_app_name == "some updated fly_app_name"
      assert recipe.fly_machine_id == "some updated fly_machine_id"
    end

    test "update_recipe/2 with invalid data returns error changeset" do
      recipe = recipe_fixture()
      assert {:error, %Ecto.Changeset{}} = Recipes.update_recipe(recipe, @invalid_attrs)
      assert recipe == Recipes.get_recipe!(recipe.id)
    end

    test "delete_recipe/1 deletes the recipe" do
      recipe = recipe_fixture()
      assert {:ok, %Recipe{}} = Recipes.delete_recipe(recipe)
      assert_raise Ecto.NoResultsError, fn -> Recipes.get_recipe!(recipe.id) end
    end

    test "change_recipe/1 returns a recipe changeset" do
      recipe = recipe_fixture()
      assert %Ecto.Changeset{} = Recipes.change_recipe(recipe)
    end
  end
end

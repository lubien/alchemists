defmodule Alchemist.Recipes do
  @moduledoc """
  The Recipes context.
  """

  import Ecto.Query, warn: false
  alias Alchemist.Repo

  alias Alchemist.Recipes.Recipe

  @image_ref "registry.fly.io/bugex-silent-cherry-2971:deployment-01HXMTTVP3X05QNZ203CA29TWK"

  @doc """
  Returns the list of recipes.

  ## Examples

      iex> list_recipes()
      [%Recipe{}, ...]

  """
  def list_recipes do
    Repo.all(Recipe)
  end

  @doc """
  Gets a single recipe.

  Raises `Ecto.NoResultsError` if the Recipe does not exist.

  ## Examples

      iex> get_recipe!(123)
      %Recipe{}

      iex> get_recipe!(456)
      ** (Ecto.NoResultsError)

  """
  def get_recipe!(id), do: Repo.get!(Recipe, id)

  @doc """
  Creates a recipe.

  ## Examples

      iex> create_recipe(%{field: value})
      {:ok, %Recipe{}}

      iex> create_recipe(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_recipe(attrs \\ %{}) do
    Repo.transaction(fn ->
      changeset = Recipe.changeset(%Recipe{}, attrs)

      with {:ok, recipe} <- Repo.insert(changeset),
           {:ok, %{status: 201}} <- Fly.create_app(recipe.fly_app_name),
           config = generate_fly_machine_config(recipe.code),
           {:ok, %{status: 200, body: %{"id" => id}}} <-
             Fly.create_machine(recipe.fly_app_name, config) do
        update_recipe(recipe, %{fly_machine_id: id})
      end
    end)
    |> case do
      {:ok, {:ok, _recipe} = result} -> result
      {:error, {:error, _error} = result} -> result
    end
  end

  defp generate_fly_machine_config(code) do
    %{
      "config" => %{
        "env" => %{
          "FLY_PROCESS_GROUP" => "app",
          "PRIMARY_REGION" => "gru",
          "CODE" => code
        },
        "init" => %{},
        "guest" => %{
          "cpu_kind" => "shared",
          "cpus" => 1,
          "memory_mb" => 1024
        },
        "image" => @image_ref,
        "metadata" => %{
          "fly_flyctl_version" => "0.2.50",
          "fly_platform_version" => "v2",
          "fly_process_group" => "app",
          "fly_release_id" => "e03j7MNppPA38TQYwzje4G139",
          "fly_release_version" => "2"
        },
        "services" => [
          %{
            "autostart" => true,
            "autostop" => true,
            "force_instance_key" => nil,
            "internal_port" => 4000,
            "min_machines_running" => 0,
            "ports" => [
              %{
                "force_https" => true,
                "handlers" => ["http"],
                "port" => 80
              },
              %{
                "handlers" => ["http", "tls"],
                "port" => 443
              }
            ],
            "protocol" => "tcp"
          }
        ]
      },
      "lease_ttl" => 300,
      "region" => "gru"
    }
  end

  @doc """
  Updates a recipe.

  ## Examples

      iex> update_recipe(recipe, %{field: new_value})
      {:ok, %Recipe{}}

      iex> update_recipe(recipe, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_recipe(%Recipe{} = recipe, attrs) do
    Repo.transaction(fn ->
      changeset = Recipe.changeset(recipe, attrs)

      with {:ok, updated_recipe} <- Repo.update(changeset),
           config = generate_fly_machine_config(recipe.code),
           {:ok, %{status: 200}} <-
             Fly.update_machine(recipe.fly_app_name, recipe.fly_machine_id, config) do
        {:ok, updated_recipe}
      end
    end)
  end

  @doc """
  Deletes a recipe.

  ## Examples

      iex> delete_recipe(recipe)
      {:ok, %Recipe{}}

      iex> delete_recipe(recipe)
      {:error, %Ecto.Changeset{}}

  """
  def delete_recipe(%Recipe{} = recipe) do
    Repo.delete(recipe)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking recipe changes.

  ## Examples

      iex> change_recipe(recipe)
      %Ecto.Changeset{data: %Recipe{}}

  """
  def change_recipe(%Recipe{} = recipe, attrs \\ %{}) do
    Recipe.changeset(recipe, attrs)
  end
end

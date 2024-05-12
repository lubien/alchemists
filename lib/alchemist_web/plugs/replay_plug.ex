defmodule AlchemistWeb.ReplayPlug do
  alias Alchemist.Recipes
  import Plug.Conn

  def init(_) do
    nil
  end

  def call(%{host: host} = conn, _tops)
      when host in ["localhost", "alchemists.fly.dev", "alchemists.lubien.dev"] do
    conn
  end

  def call(%{host: host} = conn, _opts) do
    case extract_slug_from_host(host) do
      {:ok, slug} ->
        replay_by_slug(conn, slug)

      _ ->
        conn
        |> send_resp(404, "Not found")
        |> halt()
    end
  end

  def extract_slug_from_host(host) do
    case String.split(host, ".") do
      [slug, "local"] ->
        {:ok, slug}

      [slug, "alchemists", "lubien", "dev"] ->
        {:ok, slug}

      _ ->
        {:error, :invalid}
    end
  end

  defp replay_by_slug(conn, slug) do
    now = DateTime.utc_now()
    recipe = Recipes.get_recipe_by!(slug: slug)

    recently_started? =
      recipe.last_started_at && DateTime.diff(now, recipe.last_started_at, :minute) < 2

    if recently_started? do
      Recipes.touch_recipe_last_started_at(recipe)
      fly_replay = "app=#{recipe.fly_app_name};instance=#{recipe.fly_machine_id}"

      if Application.get_env(:alchemist, :dev_routes) do
        conn
        |> send_resp(200, """
        Replayed to #{fly_replay}
        #{recipe |> Map.drop([:__struct__, :__meta__]) |> Jason.encode!(pretty: true)}
        """)
        |> halt()
      else
        conn
        |> put_resp_header("Fly-Replay", fly_replay)
        |> send_resp(204, "")
        |> halt()
      end
    else
      conn
    end
  end
end

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
    case String.split(host, ".") do
      [slug, "local"] ->
        replay_by_slug(conn, slug)

      [slug, "alchemists", "lubien", "dev"] ->
        replay_by_slug(conn, slug)

      _ ->
        conn
        |> send_resp(404, "Not found")
        |> halt()
    end
  end

  defp replay_by_slug(conn, slug) do
    recipe = Recipes.get_recipe_by!(slug: slug)

    conn
    |> put_resp_header(
      "Fly-Replay",
      "app=#{recipe.fly_app_name};instance=#{recipe.fly_machine_id}"
    )
    |> send_resp(204, "")
    |> halt()
  end
end

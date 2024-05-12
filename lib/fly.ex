defmodule Fly do
  @org_slug "onlyferas"

  def create_app(org_slug \\ @org_slug, app_name) do
    Req.post(req_config(),
      url: "/v1/apps",
      json: %{
        app_name: app_name,
        org_slug: org_slug
      }
    )
  end

  def create_machine(app_name, config) do
    Req.post(req_config(), url: "/v1/apps/#{app_name}/machines", json: config)
  end

  def update_machine(app_name, machine_id, config) do
    Req.post(req_config(), url: "/v1/apps/#{app_name}/machines/#{machine_id}", json: config)
  end

  defp req_config do
    Req.new(base_url: "https://api.machines.dev", auth: {:bearer, api_token()})
  end

  defp api_token do
    System.get_env("FLY_API_TOKEN")
  end
end

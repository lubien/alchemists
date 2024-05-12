defmodule AlchemistWeb.PageLive do
  use AlchemistWeb, :live_view
  alias Phoenix.LiveView.AsyncResult
  alias Alchemist.Recipes

  def handle_params(_params, uri, socket) do
    host =
      uri
      |> URI.parse()
      |> Map.get(:host)

    case AlchemistWeb.ReplayPlug.extract_slug_from_host(host) do
      {:ok, slug} ->
        handle_wait_recipe(slug, socket)

      {:error, :invalid} ->
        {:noreply, push_redirect(socket, to: ~p"/recipes", replace: true)}
    end
  end

  defp handle_wait_recipe(slug, socket) do
    recipe = Recipes.get_recipe_by!(slug: slug)

    if connected?(socket) do
      Process.send_after(self(), :check_if_can_continue, 5000)
    end

    socket =
      socket
      |> assign(:recipe, recipe)
      |> assign(:start_machine, AsyncResult.loading())
      |> assign(:exec_machine, AsyncResult.loading())
      |> start_async(:start_machine, fn ->
        Recipes.healt_check_recipe_started(recipe)
      end)
      |> start_async(:exec_machine, fn ->
        Recipes.healt_check_recipe_reachable(recipe)
      end)

    {:noreply, socket}
  end

  def handle_async(handler, result, socket) when handler in [:start_machine, :exec_machine] do
    %{assigns: %{recipe: recipe}} = socket
    current_status = Map.get(socket.assigns, handler)

    socket =
      case result do
        {:ok, :ok} ->
          assign(socket, handler, AsyncResult.ok(current_status, "Done!"))

        other ->
          reason =
            case other do
              {:ok, {:error, _message} = error} ->
                error

              _ ->
                {:error, "Something went wrong"}
            end

          socket
          |> assign(handler, AsyncResult.failed(current_status, reason))
          |> start_async(handler, fn ->
            :timer.sleep(3000)

            case handler do
              :start_machine -> Recipes.healt_check_recipe_started(recipe)
              :exec_machine -> Recipes.healt_check_recipe_reachable(recipe)
            end
          end)
      end

    {:noreply, socket}
  end

  def handle_info(:check_if_can_continue, socket) do
    %{assigns: %{recipe: recipe}} = socket
    can_continue? = socket.assigns.start_machine.ok? && socket.assigns.exec_machine.ok?

    socket =
      if can_continue? do
        Recipes.touch_recipe_last_started_at(recipe)

        socket
        |> put_flash(:info, "Ready!")
        |> push_navigate(external: Recipes.link_to_app(recipe))
      else
        Process.send_after(self(), :check_if_can_continue, 3000)
        socket
      end

    {:noreply, socket}
  end

  def render(assigns) do
    ~H"""
    <div>
      <.async_result :let={start_machine} assign={@start_machine}>
        <:loading>Starting machine...</:loading>
        <:failed :let={{:error, failure}}>
          There was an error starting the machine: <%= failure %>
        </:failed>
        <%= if start_machine do %>
          Started Machine. Status: <%= start_machine %>
        <% end %>
      </.async_result>

      <br />

      <.async_result :let={exec_machine} assign={@exec_machine}>
        <:loading>Checking server...</:loading>
        <:failed :let={{:error, failure}}>
          There was an error checking the server: <%= failure %>
        </:failed>
        <%= if exec_machine do %>
          Server checked. Status: <%= exec_machine %>
        <% end %>
      </.async_result>
    </div>
    """
  end
end

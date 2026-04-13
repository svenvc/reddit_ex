defmodule RedditWeb.LinkLive.Index do
  use RedditWeb, :live_view

  alias Reddit.Links

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Links
        <:actions>
          <.button variant="primary" navigate={~p"/links/new"}>
            <.icon name="hero-plus" /> New Link
          </.button>
        </:actions>
      </.header>

      <.table
        id="links"
        rows={@streams.links}
        row_click={fn {_id, link} -> JS.navigate(~p"/links/#{link}") end}
      >
        <:col :let={{_id, link}} label="Url">{link.url}</:col>
        <:col :let={{_id, link}} label="Title">{link.title}</:col>
        <:col :let={{_id, link}} label="Points">{link.points}</:col>
        <:action :let={{_id, link}}>
          <div class="sr-only">
            <.link navigate={~p"/links/#{link}"}>Show</.link>
          </div>
          <.link navigate={~p"/links/#{link}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, link}}>
          <.link
            phx-click={JS.push("delete", value: %{id: link.id}) |> hide("##{id}")}
            data-confirm="Are you sure?"
          >
            Delete
          </.link>
        </:action>
      </.table>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Links.subscribe_links()
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Links")
     |> stream(:links, list_links(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    link = Links.get_link!(socket.assigns.current_scope, id)
    {:ok, _} = Links.delete_link(socket.assigns.current_scope, link)

    {:noreply, stream_delete(socket, :links, link)}
  end

  @impl true
  def handle_info({type, %Reddit.Links.Link{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :links, list_links(socket.assigns.current_scope), reset: true)}
  end

  defp list_links(current_scope) do
    Links.list_links(current_scope)
  end
end

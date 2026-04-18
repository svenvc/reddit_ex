defmodule RedditWeb.RedditLive.Index do
  use RedditWeb, :live_view

  alias Reddit.Links
  alias Reddit.Public

  @number_of_links_to_show 32

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        <a href={~p"/reddit"} class="text-4xl">Reddit_ex</a>
        <:actions :if={@current_scope}>
          <.button variant="primary" navigate={~p"/reddit/links/new"}>
            <.icon name="hero-plus" /> New Link
          </.button>
        </:actions>
      </.header>

      <p class="font-thin italic mb-6">Aggregated links, submitted and voted by users</p>

      <div class="join">
        <input
          class="join-item btn"
          type="radio"
          name="options"
          aria-label="Most voted"
          checked={@list_sorting == "most-voted"}
          phx-click="toggle-list-sorting"
          phx-value-sorting="most-voted"
        />
        <input
          class="join-item btn"
          type="radio"
          name="options"
          aria-label="Most recent"
          checked={@list_sorting == "most-recent"}
          phx-click="toggle-list-sorting"
          phx-value-sorting="most-recent"
        />
      </div>

      <.table
        id="links"
        rows={@streams.links}
      >
        <:col :let={{_id, link}} label="URL">
          <a href={link.url} title={"Open #{link.url}"}>{link.url}</a>
        </:col>
        <:col :let={{_id, link}} label="Title">{link.title}</:col>
        <:col :let={{_id, link}} label="Date">{Date.to_iso8601(link.updated_at)}</:col>
        <:col :let={{_id, link}} label="Votes">{link.points}</:col>
        <:action :let={{_id, link}} :if={@current_scope}>
          <.link phx-click="vote-up" phx-value-link-id={link.id} title="Vote link up">
            <span class="hero-arrow-up-circle h-6 w-6" />
          </.link>
        </:action>
        <:action :let={{_id, link}} :if={@current_scope}>
          <.link phx-click="vote-down" phx-value-link-id={link.id} title="Vote link down">
            <span class="hero-arrow-down-circle h-6 w-6" />
          </.link>
        </:action>
        <:action :let={{_id, link}} :if={@current_scope}>
          <.link
            :if={link.user_id == @current_scope.user.id}
            navigate={~p"/reddit/links/#{link}/edit"}
            title="Edit link"
          >
            <span class="hero-ellipsis-horizontal-circle h-6 w-6" />
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

    if Phoenix.Flash.get(socket.assigns.flash, :info) ||
         Phoenix.Flash.get(socket.assigns.flash, :error) do
      Process.send_after(self(), :clear_flash, 2500)
    end

    socket
    |> assign(:page_title, "Reddit_ex")
    |> assign(:list_sorting, "most-voted")
    |> stream(:links, list_links("most-voted"))
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    link = Links.get_link!(socket.assigns.current_scope, id)
    {:ok, _} = Links.delete_link(socket.assigns.current_scope, link)

    socket
    |> stream_delete(:links, link)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("vote-up", %{"link-id" => link_id}, socket) do
    link = Public.resolve_link(link_id)

    flash =
      if link do
        case Reddit.Links.vote_link_up(socket.assigns.current_scope, link) do
          :voted_up -> "Link voted up"
          :already_voted_up -> "Link already vote up"
        end
      else
        "Unknown link"
      end

    Process.send_after(self(), :clear_flash, 2500)

    socket
    |> put_flash(:info, flash)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("vote-down", %{"link-id" => link_id}, socket) do
    link = Public.resolve_link(link_id)

    flash =
      if link do
        case Reddit.Links.vote_link_down(socket.assigns.current_scope, link) do
          :voted_down -> "Link voted down"
          :already_voted_down -> "Link already voted down"
        end
      else
        "Unknown link"
      end

    Process.send_after(self(), :clear_flash, 2500)

    socket
    |> put_flash(:info, flash)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("toggle-list-sorting", %{"sorting" => sorting}, socket)
      when sorting in ~w(most-voted most-recent) do
    socket
    |> assign(:list_sorting, sorting)
    |> stream(:links, list_links(sorting), reset: true)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info({type, %Reddit.Links.Link{}}, socket)
      when type in [:created, :updated, :deleted] do
    socket
    |> stream(:links, list_links(socket.assigns.list_sorting), reset: true)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    socket
    |> clear_flash()
    |> then(&{:noreply, &1})
  end

  defp list_links(sorting) when sorting in ~w(most-voted most-recent) do
    case sorting do
      "most-voted" -> Public.list_links_highest_points(@number_of_links_to_show)
      "most-recent" -> Public.list_links_most_recent(@number_of_links_to_show)
    end
  end
end

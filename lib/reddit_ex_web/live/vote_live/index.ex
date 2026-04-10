defmodule RedditWeb.VoteLive.Index do
  use RedditWeb, :live_view

  alias Reddit.Links

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Listing Votes
        <:actions>
          <.button variant="primary" navigate={~p"/votes/new"}>
            <.icon name="hero-plus" /> New Vote
          </.button>
        </:actions>
      </.header>

      <.table
        id="votes"
        rows={@streams.votes}
        row_click={fn {_id, vote} -> JS.navigate(~p"/votes/#{vote}") end}
      >
        <:col :let={{_id, vote}} label="Link">{vote.link_id}</:col>
        <:col :let={{_id, vote}} label="Direction">{vote.direction}</:col>
        <:action :let={{_id, vote}}>
          <div class="sr-only">
            <.link navigate={~p"/votes/#{vote}"}>Show</.link>
          </div>
          <.link navigate={~p"/votes/#{vote}/edit"}>Edit</.link>
        </:action>
        <:action :let={{id, vote}}>
          <.link
            phx-click={JS.push("delete", value: %{id: vote.id}) |> hide("##{id}")}
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
      Links.subscribe_votes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Listing Votes")
     |> stream(:votes, list_votes(socket.assigns.current_scope))}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    vote = Links.get_vote!(socket.assigns.current_scope, id)
    {:ok, _} = Links.delete_vote(socket.assigns.current_scope, vote)

    {:noreply, stream_delete(socket, :votes, vote)}
  end

  @impl true
  def handle_info({type, %Reddit.Links.Vote{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, stream(socket, :votes, list_votes(socket.assigns.current_scope), reset: true)}
  end

  defp list_votes(current_scope) do
    Links.list_votes(current_scope)
  end
end

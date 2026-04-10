defmodule RedditWeb.VoteLive.Show do
  use RedditWeb, :live_view

  alias Reddit.Links

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        Vote {@vote.id}
        <:subtitle>This is a vote record from your database.</:subtitle>
        <:actions>
          <.button navigate={~p"/votes"}>
            <.icon name="hero-arrow-left" />
          </.button>
          <.button variant="primary" navigate={~p"/votes/#{@vote}/edit?return_to=show"}>
            <.icon name="hero-pencil-square" /> Edit vote
          </.button>
        </:actions>
      </.header>

      <.list>
        <:item title="Direction">{@vote.direction}</:item>
      </.list>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      Links.subscribe_votes(socket.assigns.current_scope)
    end

    {:ok,
     socket
     |> assign(:page_title, "Show Vote")
     |> assign(:vote, Links.get_vote!(socket.assigns.current_scope, id))}
  end

  @impl true
  def handle_info(
        {:updated, %Reddit.Links.Vote{id: id} = vote},
        %{assigns: %{vote: %{id: id}}} = socket
      ) do
    {:noreply, assign(socket, :vote, vote)}
  end

  def handle_info(
        {:deleted, %Reddit.Links.Vote{id: id}},
        %{assigns: %{vote: %{id: id}}} = socket
      ) do
    {:noreply,
     socket
     |> put_flash(:error, "The current vote was deleted.")
     |> push_navigate(to: ~p"/votes")}
  end

  def handle_info({type, %Reddit.Links.Vote{}}, socket)
      when type in [:created, :updated, :deleted] do
    {:noreply, socket}
  end
end

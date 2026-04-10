defmodule RedditWeb.VoteLive.Form do
  use RedditWeb, :live_view

  alias Reddit.Links
  alias Reddit.Links.Vote

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
        <:subtitle>Use this form to manage vote records in your database.</:subtitle>
      </.header>

      <.form for={@form} id="vote-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:direction]}
          type="select"
          label="Direction"
          prompt="Choose a value"
          options={Ecto.Enum.values(Reddit.Links.Vote, :direction)}
        />
        <footer>
          <.button phx-disable-with="Saving..." variant="primary">Save Vote</.button>
          <.button navigate={return_path(@current_scope, @return_to, @vote)}>Cancel</.button>
        </footer>
      </.form>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    {:ok,
     socket
     |> assign(:return_to, return_to(params["return_to"]))
     |> apply_action(socket.assigns.live_action, params)}
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    vote = Links.get_vote!(socket.assigns.current_scope, id)

    socket
    |> assign(:page_title, "Edit Vote")
    |> assign(:vote, vote)
    |> assign(:form, to_form(Links.change_vote(socket.assigns.current_scope, vote)))
  end

  defp apply_action(socket, :new, _params) do
    vote = %Vote{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Vote")
    |> assign(:vote, vote)
    |> assign(:form, to_form(Links.change_vote(socket.assigns.current_scope, vote)))
  end

  @impl true
  def handle_event("validate", %{"vote" => vote_params}, socket) do
    changeset = Links.change_vote(socket.assigns.current_scope, socket.assigns.vote, vote_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"vote" => vote_params}, socket) do
    save_vote(socket, socket.assigns.live_action, vote_params)
  end

  defp save_vote(socket, :edit, vote_params) do
    case Links.update_vote(socket.assigns.current_scope, socket.assigns.vote, vote_params) do
      {:ok, vote} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vote updated successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, vote)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_vote(socket, :new, vote_params) do
    case Links.create_vote(socket.assigns.current_scope, vote_params) do
      {:ok, vote} ->
        {:noreply,
         socket
         |> put_flash(:info, "Vote created successfully")
         |> push_navigate(
           to: return_path(socket.assigns.current_scope, socket.assigns.return_to, vote)
         )}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp return_path(_scope, "index", _vote), do: ~p"/votes"
  defp return_path(_scope, "show", vote), do: ~p"/votes/#{vote}"
end

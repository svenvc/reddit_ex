defmodule RedditWeb.RedditLive.Form do
  use RedditWeb, :live_view

  alias Reddit.Links
  alias Reddit.Links.Link

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.header>
        {@page_title}
      </.header>

      <p class="font-thin italic">Links will be validated automatically</p>

      <.form for={@form} id="link-form" phx-change="validate" phx-submit="save">
        <.input
          field={@form[:url]}
          type="text"
          label="Url"
          phx-debounce="blur"
        />
        <.input
          field={@form[:title]}
          type="text"
          label="Title"
          phx-debounce="blur"
          disabled={!(@link_validated && @link_valid)}
          value={
            if @form[:title].value != "",
              do: @form[:title].value,
              else: assigns[:link_extracted_title]
          }
        />
        <footer class="mt-6">
          <.button
            phx-disable-with="Saving..."
            variant="primary"
            disabled={!(@link_validated && @link_valid)}
          >
            Save Link
          </.button>
          <.button
            :if={@link.id}
            phx-click={JS.push("delete-link", value: %{link_id: @link.id})}
            data-confirm="Are you sure?"
          >
            Delete Link
          </.button>
          <.button navigate={return_path(@current_scope, @return_to, @link)}>Cancel</.button>
        </footer>
      </.form>

      <%!-- <div class="font-thin text-sm mt-10">
        <p>{"link_validated: #{assigns[:link_validated]}"}</p>
        <p>{"link_valid: #{assigns[:link_valid]}"}</p>
        <p>{"link_extracted_title: #{assigns[:link_extracted_title]}"}</p>
        <p>{"link_validation_error: #{assigns[:link_validation_error]}"}</p>
      </div> --%>
    </Layouts.app>
    """
  end

  @impl true
  def mount(params, _session, socket) do
    socket
    |> assign(:return_to, return_to(params["return_to"]))
    |> assign(:link_validated, false)
    |> apply_action(socket.assigns.live_action, params)
    |> then(&{:ok, &1})
  end

  defp return_to("show"), do: "show"
  defp return_to(_), do: "index"

  defp apply_action(socket, :edit, %{"id" => id}) do
    link = Links.get_link!(socket.assigns.current_scope, id)

    spawn_link_validation(link.url)

    socket
    |> assign(:page_title, "Edit Link")
    |> assign(:link, link)
    |> assign(:form, to_form(Links.change_link(socket.assigns.current_scope, link)))
  end

  defp apply_action(socket, :new, _params) do
    link = %Link{user_id: socket.assigns.current_scope.user.id}

    socket
    |> assign(:page_title, "New Link")
    |> assign(:link, link)
    |> assign(:form, to_form(Links.change_link(socket.assigns.current_scope, link)))
  end

  @impl true
  def handle_event("validate", %{"link" => link_params}, socket) do
    changeset = Links.change_link(socket.assigns.current_scope, socket.assigns.link, link_params)

    spawn_link_validation(link_params["url"])

    socket
    |> assign(form: to_form(changeset, action: :validate))
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("save", %{"link" => link_params}, socket) do
    save_link(socket, socket.assigns.live_action, link_params)
  end

  @impl true
  def handle_event("delete-link", %{"link_id" => link_id}, socket) do
    link = Links.get_link!(socket.assigns.current_scope, link_id)
    Links.delete_link(socket.assigns.current_scope, link)

    socket
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info({:link_validated, validation_result}, socket) do
    IO.puts("link_validated #{inspect(validation_result)}")

    Process.send_after(self(), :clear_flash, 2500)

    case validation_result do
      {:ok, title} ->
        url = Phoenix.HTML.Form.input_value(socket.assigns.form, :url)
        exiting_title = Phoenix.HTML.Form.input_value(socket.assigns.form, :title)

        new_title =
          if is_nil(exiting_title) || exiting_title == "" do
            title
          else
            exiting_title
          end

        changeset =
          Links.change_link(socket.assigns.current_scope, socket.assigns.link, %{
            "url" => url,
            "title" => new_title
          })

        socket
        |> assign(form: to_form(changeset, action: :validate))
        |> assign(link_valid: true)
        |> assign(link_extracted_title: title)
        |> assign(link_validation_error: nil)
        |> put_flash(:info, ":link_valid")

      {:error, message} ->
        socket
        |> assign(link_valid: false)
        |> assign(link_extracted_title: nil)
        |> assign(link_validation_error: message)
        |> put_flash(:error, message)
    end
    |> assign(link_validated: true)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_info(:clear_flash, socket) do
    socket
    |> clear_flash()
    |> then(&{:noreply, &1})
  end

  defp save_link(socket, :edit, link_params) do
    case Links.update_link(socket.assigns.current_scope, socket.assigns.link, link_params) do
      {:ok, link} ->
        socket
        |> put_flash(:info, "Link updated successfully")
        |> push_navigate(
          to: return_path(socket.assigns.current_scope, socket.assigns.return_to, link)
        )
        |> then(&{:noreply, &1})

      {:error, %Ecto.Changeset{} = changeset} ->
        socket
        |> assign(form: to_form(changeset))
        |> then(&{:noreply, &1})
    end
  end

  defp save_link(socket, :new, link_params) do
    case Links.create_link(socket.assigns.current_scope, link_params) do
      {:ok, link} ->
        socket
        |> put_flash(:info, "Link created successfully")
        |> push_navigate(
          to: return_path(socket.assigns.current_scope, socket.assigns.return_to, link)
        )
        |> then(&{:noreply, &1})

      {:error, %Ecto.Changeset{} = changeset} ->
        socket
        |> assign(form: to_form(changeset))
        |> then(&{:noreply, &1})
    end
  end

  defp return_path(_scope, "index", _link), do: ~p"/reddit"

  defp spawn_link_validation(url) do
    parent = self()

    Process.spawn(
      fn ->
        validation_result = Reddit.Utils.validate_url_and_extract_html_title(url)
        Process.send(parent, {:link_validated, validation_result}, [])
      end,
      []
    )
  end
end

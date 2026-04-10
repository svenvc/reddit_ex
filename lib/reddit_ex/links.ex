defmodule Reddit.Links do
  @moduledoc """
  The Links context.
  """

  import Ecto.Query, warn: false
  alias Reddit.Repo

  alias Reddit.Links.Link
  alias Reddit.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any link changes.

  The broadcasted messages match the pattern:

    * {:created, %Link{}}
    * {:updated, %Link{}}
    * {:deleted, %Link{}}

  """
  def subscribe_links(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Reddit.PubSub, "user:#{key}:links")
  end

  defp broadcast_link(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Reddit.PubSub, "user:#{key}:links", message)
  end

  @doc """
  Returns the list of links.

  ## Examples

      iex> list_links(scope)
      [%Link{}, ...]

  """
  def list_links(%Scope{} = scope) do
    Repo.all_by(Link, user_id: scope.user.id)
  end

  @doc """
  Gets a single link.

  Raises `Ecto.NoResultsError` if the Link does not exist.

  ## Examples

      iex> get_link!(scope, 123)
      %Link{}

      iex> get_link!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_link!(%Scope{} = scope, id) do
    Repo.get_by!(Link, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a link.

  ## Examples

      iex> create_link(scope, %{field: value})
      {:ok, %Link{}}

      iex> create_link(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_link(%Scope{} = scope, attrs) do
    with {:ok, link = %Link{}} <-
           %Link{}
           |> Link.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_link(scope, {:created, link})
      {:ok, link}
    end
  end

  @doc """
  Updates a link.

  ## Examples

      iex> update_link(scope, link, %{field: new_value})
      {:ok, %Link{}}

      iex> update_link(scope, link, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_link(%Scope{} = scope, %Link{} = link, attrs) do
    true = link.user_id == scope.user.id

    with {:ok, link = %Link{}} <-
           link
           |> Link.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_link(scope, {:updated, link})
      {:ok, link}
    end
  end

  @doc """
  Deletes a link.

  ## Examples

      iex> delete_link(scope, link)
      {:ok, %Link{}}

      iex> delete_link(scope, link)
      {:error, %Ecto.Changeset{}}

  """
  def delete_link(%Scope{} = scope, %Link{} = link) do
    true = link.user_id == scope.user.id

    with {:ok, link = %Link{}} <-
           Repo.delete(link) do
      broadcast_link(scope, {:deleted, link})
      {:ok, link}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking link changes.

  ## Examples

      iex> change_link(scope, link)
      %Ecto.Changeset{data: %Link{}}

  """
  def change_link(%Scope{} = scope, %Link{} = link, attrs \\ %{}) do
    true = link.user_id == scope.user.id

    Link.changeset(link, attrs, scope)
  end
end

defmodule Reddit.Links do
  @moduledoc """
  The Links context.
  """

  import Ecto.Query, warn: false
  alias Reddit.Repo

  alias Reddit.Links.Link
  alias Reddit.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any link changes from any user.

  The broadcasted messages match the pattern:

    * {:created, %Link{}}
    * {:updated, %Link{}}
    * {:deleted, %Link{}}

  """
  def subscribe_links() do
    Phoenix.PubSub.subscribe(Reddit.PubSub, "global:links")
  end

  defp broadcast_link(message) do
    Phoenix.PubSub.broadcast(Reddit.PubSub, "global:links", message)
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
      broadcast_link({:created, link})
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
      broadcast_link({:updated, link})
      {:ok, link}
    end
  end

  def update_link(:any_scope, %Link{} = link, attrs) do
    with {:ok, link = %Link{}} <-
           link
           |> Link.changeset(attrs)
           |> Repo.update() do
      broadcast_link({:updated, link})
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
      broadcast_link({:deleted, link})
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

  alias Reddit.Links.Vote
  alias Reddit.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any vote changes.

  The broadcasted messages match the pattern:

    * {:created, %Vote{}}
    * {:updated, %Vote{}}
    * {:deleted, %Vote{}}

  """
  def subscribe_votes(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Reddit.PubSub, "user:#{key}:votes")
  end

  defp broadcast_vote(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Reddit.PubSub, "user:#{key}:votes", message)
  end

  @doc """
  Returns the list of votes.

  ## Examples

      iex> list_votes(scope)
      [%Vote{}, ...]

  """
  def list_votes(%Scope{} = scope) do
    Repo.all_by(Vote, user_id: scope.user.id)
  end

  @doc """
  Gets a single vote.

  Raises `Ecto.NoResultsError` if the Vote does not exist.

  ## Examples

      iex> get_vote!(scope, 123)
      %Vote{}

      iex> get_vote!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_vote!(%Scope{} = scope, id) do
    Repo.get_by!(Vote, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a vote.

  ## Examples

      iex> create_vote(scope, %{field: value})
      {:ok, %Vote{}}

      iex> create_vote(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_vote(%Scope{} = scope, attrs) do
    with {:ok, vote = %Vote{}} <-
           %Vote{}
           |> Vote.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_vote(scope, {:created, vote})
      {:ok, vote}
    end
  end

  @doc """
  Updates a vote.

  ## Examples

      iex> update_vote(scope, vote, %{field: new_value})
      {:ok, %Vote{}}

      iex> update_vote(scope, vote, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_vote(%Scope{} = scope, %Vote{} = vote, attrs) do
    true = vote.user_id == scope.user.id

    with {:ok, vote = %Vote{}} <-
           vote
           |> Vote.changeset(attrs, scope)
           |> Repo.update() do
      broadcast_vote(scope, {:updated, vote})
      {:ok, vote}
    end
  end

  @doc """
  Deletes a vote.

  ## Examples

      iex> delete_vote(scope, vote)
      {:ok, %Vote{}}

      iex> delete_vote(scope, vote)
      {:error, %Ecto.Changeset{}}

  """
  def delete_vote(%Scope{} = scope, %Vote{} = vote) do
    true = vote.user_id == scope.user.id

    with {:ok, vote = %Vote{}} <-
           Repo.delete(vote) do
      broadcast_vote(scope, {:deleted, vote})
      {:ok, vote}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking vote changes.

  ## Examples

      iex> change_vote(scope, vote)
      %Ecto.Changeset{data: %Vote{}}

  """
  def change_vote(%Scope{} = scope, %Vote{} = vote, attrs \\ %{}) do
    true = vote.user_id == scope.user.id

    Vote.changeset(vote, attrs, scope)
  end

  def vote_link_up(%Scope{} = scope, %Link{} = link) do
    existing_vote = Repo.get_by(Vote, link_id: link.id, user_id: scope.user.id)

    if existing_vote do
      if existing_vote.direction == :down do
        {:ok, result} =
          Repo.transact(fn ->
            {:ok, _vote} = update_vote(scope, existing_vote, %{direction: :up})
            inc_link_points(link, 2)
            {:ok, :voted_up}
          end)

        result
      else
        :already_voted_up
      end
    else
      {:ok, result} =
        Repo.transact(fn ->
          {:ok, _vote} = create_vote(scope, %{link_id: link.id, direction: :up})
          inc_link_points(link, 1)
          {:ok, :voted_up}
        end)

      result
    end
  end

  def vote_link_down(%Scope{} = scope, %Link{} = link) do
    existing_vote = Repo.get_by(Vote, link_id: link.id, user_id: scope.user.id)

    if existing_vote do
      if existing_vote.direction == :up do
        {:ok, result} =
          Repo.transact(fn ->
            {:ok, _vote} = update_vote(scope, existing_vote, %{direction: :down})
            inc_link_points(link, -2)
            {:ok, :voted_down}
          end)

        result
      else
        :already_voted_down
      end
    else
      {:ok, result} =
        Repo.transact(fn ->
          {:ok, _vote} = create_vote(scope, %{link_id: link.id, direction: :down})
          inc_link_points(link, -1)
          {:ok, :voted_down}
        end)

      result
    end
  end

  def inc_link_points(%Link{} = link, delta) do
    {1, _} =
      Reddit.Links.Link
      |> Ecto.Query.where(id: ^link.id)
      |> Reddit.Repo.update_all(inc: [points: delta])

    broadcast_link({:updated, link})
  end
end

defmodule Reddit.Links.Vote do
  use Ecto.Schema
  import Ecto.Changeset

  schema "votes" do
    field :direction, Ecto.Enum, values: [:up, :down]
    field :link_id, :id
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(vote, attrs, user_scope) do
    vote
    |> cast(attrs, [:direction])
    |> validate_required([:direction])
    |> put_change(:user_id, user_scope.user.id)
  end
end

defmodule Reddit.Links.Link do
  use Ecto.Schema
  import Ecto.Changeset

  schema "links" do
    field :url, :string
    field :title, :string
    field :points, :integer, default: 0
    field :user_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(link, attrs, user_scope) do
    link
    |> cast(attrs, [:url, :title, :points])
    |> validate_required([:url, :title, :points])
    |> put_change(:user_id, user_scope.user.id)
  end
end

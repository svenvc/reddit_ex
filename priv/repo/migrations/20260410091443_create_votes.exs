defmodule Reddit.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:votes) do
      add :direction, :string
      add :link_id, references(:links, on_delete: :nothing)
      add :user_id, references(:users, type: :id, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:votes, [:user_id])

    create index(:votes, [:link_id])
  end
end

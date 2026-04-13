defmodule Reddit.Repo.Migrations.VoteLinkOnDelete do
  use Ecto.Migration

  def change do
    drop constraint(:votes, "votes_link_id_fkey")

    alter table(:votes) do
      modify :link_id, references(:links, on_delete: :delete_all)
    end
  end
end

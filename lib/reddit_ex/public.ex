defmodule Reddit.Public do
  import Ecto.Query

  alias Reddit.Repo

  def list_links_highest_points(limit \\ 3) do
    from(link in Reddit.Links.Link,
      select: link,
      order_by: [desc: link.points],
      limit: ^limit
    )
    |> Repo.all()
  end

  def list_links_most_recent(limit \\ 3) do
    from(link in Reddit.Links.Link,
      select: link,
      order_by: [desc: link.updated_at],
      limit: ^limit
    )
    |> Repo.all()
  end

  def resolve_link(link_id) do
    Repo.get_by(Reddit.Links.Link, id: link_id)
  end
end

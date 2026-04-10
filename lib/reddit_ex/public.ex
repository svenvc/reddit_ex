defmodule Reddit.Public do
  import Ecto.Query

  def list_links_highest_points(limit \\ 3) do
    from(link in Reddit.Links.Link,
      select: link,
      order_by: [desc: link.points],
      limit: ^limit)
    |> Reddit.Repo.all()
  end

  def list_links_most_recent(limit \\ 3) do
    from(link in Reddit.Links.Link,
      select: link,
      order_by: [desc: link.updated_at],
      limit: ^limit
    )
    |> Reddit.Repo.all()
  end
end

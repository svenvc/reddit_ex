# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Reddit.Repo.insert!(%Reddit.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

svc =
  Reddit.Accounts.get_user_by_email("svc@mac.com") ||
    Reddit.Accounts.register_user(%{email: "svc@mac.com"})

scope = Reddit.Accounts.Scope.for_user(svc)

urls = [
  "https://elixir-lang.org",
  "https://phoenixframework.org",
  "https://elixirstatus.com",
  "https://hex.pm",
  "https://hexdocs.pm",
  "https://erlef.org",
  "https://www.erlang.org",
  "https://elixir-radar.com",
  "https://elixirmerge.com",
  "https://elixirweekly.net"
]

Enum.each(urls, fn url ->
  {:ok, title} = Reddit.Utils.validate_url_and_extract_html_title(url)
  Reddit.Links.create_link(scope, %{url: url, title: title, points: :rand.uniform(20)})
end)

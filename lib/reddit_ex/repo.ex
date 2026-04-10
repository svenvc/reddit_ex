defmodule Reddit.Repo do
  use Ecto.Repo,
    otp_app: :reddit_ex,
    adapter: Ecto.Adapters.Postgres
end

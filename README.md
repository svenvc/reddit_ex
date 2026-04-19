# Reddit

Minimal Reddit clone written using Elixir and the Phoenix framework.

For a live demo of this application, see [https://reddit.stfx.eu](https://reddit.stfx.eu)

The goal of this project is to demonstrate how to deploy a non-trivial web app.
This application has a public, before login side as well an a private, after login side.
The standard authentication layer is used with email based registration or one time login links.
Mails are sent using Gmail.
Persistence of users, links and votes in handled via PostgreSQL.
This is an open source application.


## dev

This is a standard Elixir Phoenix project that you can run in dev mode locally.

- Run `mix setup` to install and setup dependencies
- Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`
- Make sure PostgreSQL is accessible (postgres:postgres@localhost or change `config/dev.exs`)

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Note that even in dev, Gmail is used. You can reactivate the local dummy
by editing `config/config.exs` and restore the line
`config :reddit_ex, Reddit.Mailer, adapter: Swoosh.Adapters.Local`


## deploy

An easier solution is to use a container, see [Dockerfile](dockerfile),
while the [compose.yaml](compose.yaml) builds on that to include PostgreSQL.

The following environment variables should be set:

- SECRET_KEY_BASE=
- PHX_HOST=
- POSTGRES_DB=reddit
- POSTGRES_USER=reddit
- POSTGRES_PASSWORD=
- DATABASE_URL=ecto://$POSTGRES_USER:$POSTGRES_PASSWORD@psql-reddit/$POSTGRES_DB
- GOOGLE_CLIENT_ID=
- GOOGLE_CLIENT_SECRET=
- GOOGLE_REFRESH_TOKEN=

The port exposed should then be reverse-proxied to the outside world as https.

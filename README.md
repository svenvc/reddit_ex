# Reddit

Minimal Reddit clone written using Elixir and the Phoenix framework.

For a live demo of this application, see [https://reddit.stfx.eu](https://reddit.stfx.eu)

The goal of this project is to demonstrate how to deploy a non-trivial web app.
This application has a public, before login side as well an a private, after login side.
The standard authentication layer is used with email based registration or one time login links.
Mails are sent using Gmail.
Persistence of users, links and votes in handled via PostgreSQL.
This is an open source application.

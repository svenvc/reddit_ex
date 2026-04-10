defmodule RedditWeb.PageController do
  use RedditWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end

defmodule RedditWeb.VoteLiveTest do
  use RedditWeb.ConnCase

  import Phoenix.LiveViewTest
  import Reddit.LinksFixtures

  @create_attrs %{direction: :up}
  @update_attrs %{direction: :down}
  @invalid_attrs %{direction: nil}

  setup :register_and_log_in_user

  defp create_vote(%{scope: scope}) do
    vote = vote_fixture(scope)

    %{vote: vote}
  end

  describe "Index" do
    setup [:create_vote]

    test "lists all votes", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/votes")

      assert html =~ "Listing Votes"
    end

    test "saves new vote", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/votes")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Vote")
               |> render_click()
               |> follow_redirect(conn, ~p"/votes/new")

      assert render(form_live) =~ "New Vote"

      assert form_live
             |> form("#vote-form", vote: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#vote-form", vote: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/votes")

      html = render(index_live)
      assert html =~ "Vote created successfully"
    end

    test "updates vote in listing", %{conn: conn, vote: vote} do
      {:ok, index_live, _html} = live(conn, ~p"/votes")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#votes-#{vote.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/votes/#{vote}/edit")

      assert render(form_live) =~ "Edit Vote"

      assert form_live
             |> form("#vote-form", vote: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#vote-form", vote: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/votes")

      html = render(index_live)
      assert html =~ "Vote updated successfully"
    end

    test "deletes vote in listing", %{conn: conn, vote: vote} do
      {:ok, index_live, _html} = live(conn, ~p"/votes")

      assert index_live |> element("#votes-#{vote.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#votes-#{vote.id}")
    end
  end

  describe "Show" do
    setup [:create_vote]

    test "displays vote", %{conn: conn, vote: vote} do
      {:ok, _show_live, html} = live(conn, ~p"/votes/#{vote}")

      assert html =~ "Show Vote"
    end

    test "updates vote and returns to show", %{conn: conn, vote: vote} do
      {:ok, show_live, _html} = live(conn, ~p"/votes/#{vote}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/votes/#{vote}/edit?return_to=show")

      assert render(form_live) =~ "Edit Vote"

      assert form_live
             |> form("#vote-form", vote: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#vote-form", vote: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/votes/#{vote}")

      html = render(show_live)
      assert html =~ "Vote updated successfully"
    end
  end
end

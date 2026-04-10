defmodule Reddit.LinksTest do
  use Reddit.DataCase

  alias Reddit.Links

  describe "links" do
    alias Reddit.Links.Link

    import Reddit.AccountsFixtures, only: [user_scope_fixture: 0]
    import Reddit.LinksFixtures

    @invalid_attrs %{title: nil, url: nil, points: nil}

    test "list_links/1 returns all scoped links" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      link = link_fixture(scope)
      other_link = link_fixture(other_scope)
      assert Links.list_links(scope) == [link]
      assert Links.list_links(other_scope) == [other_link]
    end

    test "get_link!/2 returns the link with given id" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      other_scope = user_scope_fixture()
      assert Links.get_link!(scope, link.id) == link
      assert_raise Ecto.NoResultsError, fn -> Links.get_link!(other_scope, link.id) end
    end

    test "create_link/2 with valid data creates a link" do
      valid_attrs = %{title: "some title", url: "some url", points: 42}
      scope = user_scope_fixture()

      assert {:ok, %Link{} = link} = Links.create_link(scope, valid_attrs)
      assert link.title == "some title"
      assert link.url == "some url"
      assert link.points == 42
      assert link.user_id == scope.user.id
    end

    test "create_link/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Links.create_link(scope, @invalid_attrs)
    end

    test "update_link/3 with valid data updates the link" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      update_attrs = %{title: "some updated title", url: "some updated url", points: 43}

      assert {:ok, %Link{} = link} = Links.update_link(scope, link, update_attrs)
      assert link.title == "some updated title"
      assert link.url == "some updated url"
      assert link.points == 43
    end

    test "update_link/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      link = link_fixture(scope)

      assert_raise MatchError, fn ->
        Links.update_link(other_scope, link, %{})
      end
    end

    test "update_link/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Links.update_link(scope, link, @invalid_attrs)
      assert link == Links.get_link!(scope, link.id)
    end

    test "delete_link/2 deletes the link" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      assert {:ok, %Link{}} = Links.delete_link(scope, link)
      assert_raise Ecto.NoResultsError, fn -> Links.get_link!(scope, link.id) end
    end

    test "delete_link/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      link = link_fixture(scope)
      assert_raise MatchError, fn -> Links.delete_link(other_scope, link) end
    end

    test "change_link/2 returns a link changeset" do
      scope = user_scope_fixture()
      link = link_fixture(scope)
      assert %Ecto.Changeset{} = Links.change_link(scope, link)
    end
  end

  describe "votes" do
    alias Reddit.Links.Vote

    import Reddit.AccountsFixtures, only: [user_scope_fixture: 0]
    import Reddit.LinksFixtures

    @invalid_attrs %{direction: nil}

    test "list_votes/1 returns all scoped votes" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      vote = vote_fixture(scope)
      other_vote = vote_fixture(other_scope)
      assert Links.list_votes(scope) == [vote]
      assert Links.list_votes(other_scope) == [other_vote]
    end

    test "get_vote!/2 returns the vote with given id" do
      scope = user_scope_fixture()
      vote = vote_fixture(scope)
      other_scope = user_scope_fixture()
      assert Links.get_vote!(scope, vote.id) == vote
      assert_raise Ecto.NoResultsError, fn -> Links.get_vote!(other_scope, vote.id) end
    end

    test "create_vote/2 with valid data creates a vote" do
      valid_attrs = %{direction: :up}
      scope = user_scope_fixture()

      assert {:ok, %Vote{} = vote} = Links.create_vote(scope, valid_attrs)
      assert vote.direction == :up
      assert vote.user_id == scope.user.id
    end

    test "create_vote/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Links.create_vote(scope, @invalid_attrs)
    end

    test "update_vote/3 with valid data updates the vote" do
      scope = user_scope_fixture()
      vote = vote_fixture(scope)
      update_attrs = %{direction: :down}

      assert {:ok, %Vote{} = vote} = Links.update_vote(scope, vote, update_attrs)
      assert vote.direction == :down
    end

    test "update_vote/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      vote = vote_fixture(scope)

      assert_raise MatchError, fn ->
        Links.update_vote(other_scope, vote, %{})
      end
    end

    test "update_vote/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      vote = vote_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Links.update_vote(scope, vote, @invalid_attrs)
      assert vote == Links.get_vote!(scope, vote.id)
    end

    test "delete_vote/2 deletes the vote" do
      scope = user_scope_fixture()
      vote = vote_fixture(scope)
      assert {:ok, %Vote{}} = Links.delete_vote(scope, vote)
      assert_raise Ecto.NoResultsError, fn -> Links.get_vote!(scope, vote.id) end
    end

    test "delete_vote/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      vote = vote_fixture(scope)
      assert_raise MatchError, fn -> Links.delete_vote(other_scope, vote) end
    end

    test "change_vote/2 returns a vote changeset" do
      scope = user_scope_fixture()
      vote = vote_fixture(scope)
      assert %Ecto.Changeset{} = Links.change_vote(scope, vote)
    end
  end
end

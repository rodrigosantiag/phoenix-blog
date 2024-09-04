defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures
    import Blog.CommentsFixtures

    @invalid_attrs %{content: nil, subtitle: nil, title: nil}

    test "list_posts/0 returns all posts in correct order" do
      post = post_fixture()

      old_post =
        post_fixture(
          title: "older post",
          published_on: NaiveDateTime.add(NaiveDateTime.utc_now(), -1, :day)
        )

      assert Posts.list_posts() == [post, old_post]
    end

    test "list_posts/0 does not return invisible posts" do
      post_fixture(visible: false)
      assert Posts.list_posts() == []
    end

    test "list_posts/0 does not return posts scheduled for the future" do
      post_fixture(published_on: NaiveDateTime.add(NaiveDateTime.utc_now(), 1, :day))
      assert Posts.list_posts() == []
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == Repo.preload(post, :comments)
    end

    test "get_post!/1 returns the post with given id and associated comments" do
      post = post_fixture()
      comment = comment_fixture(post_id: post.id)
      assert Posts.get_post!(post.id).comments == [comment]
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{
        content: "some content",
        subtitle: "some subtitle",
        title: "some title",
        published_on: NaiveDateTime.utc_now(),
        visible: true
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.content == "some content"
      assert post.title == "some title"
      assert post.published_on == NaiveDateTime.utc_now() |> NaiveDateTime.to_date()
      assert post.visible == true
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()

      update_attrs = %{
        content: "some updated content",
        title: "some updated title",
        published_on: NaiveDateTime.add(NaiveDateTime.utc_now(), -1, :day),
        visible: false
      }

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.content == "some updated content"
      assert post.title == "some updated title"

      assert post.published_on ==
               NaiveDateTime.add(NaiveDateTime.utc_now(), -1, :day) |> NaiveDateTime.to_date()

      assert post.visible == false
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert Repo.preload(post, :comments) == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end

    test "list_posts/1 filters posts by exact, partial and case-insensitive matching" do
      post = post_fixture()

      # exact match
      assert Posts.list_posts("some title") == [post]
      # exact match case-insensitive
      assert Posts.list_posts("Some Title") == [post]

      # partial match at the beginning
      assert Posts.list_posts("some") == [post]
      # partial match at the beginning case-insensitive
      assert Posts.list_posts("sOMe") == [post]
      # partial match at the end
      assert Posts.list_posts("title") == [post]
      # partial match at the end case-insensitive
      assert Posts.list_posts("titlE") == [post]
      # partial match in the middle
      assert Posts.list_posts("tle") == [post]

      # no match
      assert Posts.list_posts("other") == []

      # no filter
      assert Posts.list_posts("") == [post]
    end
  end
end

defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures
    import Blog.CommentsFixtures
    import Blog.AccountsFixtures
    import Blog.TagsFixtures

    @invalid_attrs %{content: nil, subtitle: nil, title: nil}

    test "list_posts/0 returns all posts in correct order" do
      post = post_fixture()

      old_post =
        post_fixture(
          title: "older post",
          published_on: NaiveDateTime.add(NaiveDateTime.utc_now(), -1, :day)
        )

      assert Posts.list_posts() |> Enum.map(& &1.id) == [post, old_post] |> Enum.map(& &1.id)
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
      comment = comment_fixture(post_id: post.id, user_id: post.user_id)
      assert Posts.get_post!(post.id).comments == [Repo.preload(comment, :user)]
    end

    test "create_post/1 with valid data creates a post" do
      user = user_fixture()

      valid_attrs = %{
        content: "some content",
        subtitle: "some subtitle",
        title: "some title",
        published_on: NaiveDateTime.utc_now(),
        visible: true,
        user_id: user.id
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

    test "create_post/1 with tags" do
      user = user_fixture()
      tag1 = tag_fixture()
      tag2 = tag_fixture()

      valid_attrs1 = %{content: "some content", title: "post 1", user_id: user.id}
      valid_attrs2 = %{content: "some content", title: "post 2", user_id: user.id}

      assert {:ok, %Post{} = post1} = Posts.create_post(valid_attrs1, [tag1, tag2])
      assert {:ok, %Post{} = post2} = Posts.create_post(valid_attrs2, [tag1])

      assert Repo.preload(post1, :tags).tags == [tag1, tag2]
      assert Repo.preload(post2, :tags).tags == [tag1]

      assert Repo.preload(tag1, posts: [:tags]).posts == [post1, post2]
      assert Repo.preload(tag2, posts: [:tags]).posts == [post1]
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
      post = post_fixture(title: "some title")
      post_id = post.id

      # exact match
      assert [%{id: ^post_id}] = Posts.list_posts("some title")
      # exact match case-insensitive
      assert [%{id: ^post_id}] = Posts.list_posts("Some Title")

      # partial match at the beginning
      assert [%{id: ^post_id}] = Posts.list_posts("some")
      # partial match at the beginning case-insensitive
      assert [%{id: ^post_id}] = Posts.list_posts("sOMe")
      # partial match at the end
      assert [%{id: ^post_id}] = Posts.list_posts("title")
      # partial match at the end case-insensitive
      assert [%{id: ^post_id}] = Posts.list_posts("titlE")
      # partial match in the middle
      assert [%{id: ^post_id}] = Posts.list_posts("tle")

      # no match
      assert [] = Posts.list_posts("other")

      # no filter
      assert [%{id: ^post_id}] = Posts.list_posts("")
    end
  end
end

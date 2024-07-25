defmodule AshSanityTest do
  use AshSanity.CMSCase

  alias AshSanity.MockFinch
  alias AshSanity.Test. Post
  alias Ecto.UUID

  require Ash.Query

  import Mox
  setup :verify_on_exit!

  setup do
    response = %{
      _id: UUID.generate(),
      _type: "post",
      title: "My First Post!",
      slug: %{
        _type: "slug",
        current: "my-first-post"
      },
      body: "Hello World",
      status: "IS_PUBLISHED",
      author: %{
        _id: UUID.generate(),
        fullName: "John Doe"
      },
      image: %{
        title: "My Image",
        author: %{
          _id: UUID.generate(),
          fullName: "John Doe"
        }
      },
      filters: [
        %{
          _type: "identityFilter",
          identityType: "educators"
        }
      ],
      comments: [
        %{
          _id: UUID.generate(),
          comment: "First!",
          author: %{
            _id: UUID.generate(),
            fullName: "Jane Doe"
          }
        }
      ],
      _createdAt: DateTime.utc_now(),
      _updatedAt: DateTime.utc_now()
    }

    response_body = %{result: [response]} |> Jason.encode!()

    {:ok, response: response, response_body: response_body}
  end

  describe "with no filter applied" do
    test "retrieves all data", ctx do
      expect(MockFinch, :request, fn _request, Sanity.Finch, _ ->
        {:ok,
         %Finch.Response{
           body: ctx.response_body,
           headers: [],
           status: 200
         }}
      end)

      [post | _] = Ash.read!(Post)

      assert post.id == ctx.response[:_id]
      assert post.body == ctx.response.body
      assert post.slug == ctx.response.slug.current

      assert length(post.filters) == 1
    end
  end

  describe "with filter" do
    test "applies equality filter for strings", ctx do
      expect(MockFinch, :request, fn request, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(request.query)
        assert query =~ ~s(_id == "1234")

        {:ok, %Finch.Response{body: ctx.response_body, headers: [], status: 200}}
      end)

      Post |> Ash.Query.filter(id == "1234") |> Ash.read!()
    end

    test "applies equality filter for atoms", ctx do
      expect(MockFinch, :request, fn request, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(request.query)
        assert query =~ ~s(status == "IS_PUBLISHED")

        {:ok, %Finch.Response{body: ctx.response_body, headers: [], status: 200}}
      end)

      Post |> Ash.Query.filter(status == :IS_PUBLISHED) |> Ash.read!()
    end

    test "applies contains filter", ctx do
      expect(MockFinch, :request, fn request, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(request.query)
        assert query =~ ~s(title match "Hello")

        {:ok, %Finch.Response{body: ctx.response_body, headers: [], status: 200}}
      end)

      Post |> Ash.Query.filter(contains(title, "Hello")) |> Ash.read!()
    end

    test "applies greater than filter", ctx do
      expect(MockFinch, :request, fn request, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(request.query)
        assert query =~ ~s(_createdAt > "2016-04-25")

        {:ok, %Finch.Response{body: ctx.response_body, headers: [], status: 200}}
      end)

      Post |> Ash.Query.filter(created_at > "2016-04-25") |> Ash.read!()
    end

    test "applies less than filter", ctx do
      expect(MockFinch, :request, fn request, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(request.query)
        assert query =~ ~s(_createdAt < "2016-04-25")

        {:ok, %Finch.Response{body: ctx.response_body, headers: [], status: 200}}
      end)

      Post |> Ash.Query.filter(created_at < "2016-04-25") |> Ash.read!()
    end
  end

  describe "with pagination" do
    test "paginates results", ctx do
      MockFinch
      |> expect(:request, 1, fn %{query: query}, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(query)

        assert query =~ ~s(| order(_id asc\))
        assert query =~ ~s([0...10])

        {:ok, %Finch.Response{body: ctx.response_body, headers: [], status: 200}}
      end)
      |> expect(:request, 1, fn %{query: query}, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(query)

        assert query =~ ~s(| order(_id asc\))
        assert query =~ ~s([10...20])

        {:ok, %Finch.Response{body: ctx.response_body, headers: [], status: 200}}
      end)

      assert page = %Ash.Page.Offset{results: [_]} = Post |> Ash.read!(page: [limit: 10])

      Ash.page(page, :next)
    end
  end

  describe "sorting" do
    test "sorts results", ctx do
      expect(MockFinch, :request, fn request, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(request.query)
        assert query =~ ~s(| order(_createdAt asc\))

        {:ok, %Finch.Response{body: ctx.response_body, headers: [], status: 200}}
      end)

      assert Post |> Ash.Query.sort([:created_at]) |> Ash.read!()
    end
  end

  describe "loading references" do
    test "loads related document", ctx do
      expect(MockFinch, :request, fn request, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(request.query)
        assert query =~ ~s(author->)

        {:ok,
         %Finch.Response{
           body: ctx.response_body,
           headers: [],
           status: 200
         }}
      end)

      [post | _] = Post |> Ash.read!()

      assert post.author.full_name == ctx.response.author.fullName
    end

    test "loads related documents", ctx do
      expect(MockFinch, :request, fn request, Sanity.Finch, _ ->
        %{"query" => query} = URI.decode_query(request.query)
        assert query =~ ~s(comments[]->)

        {:ok,
         %Finch.Response{
           body: ctx.response_body,
           headers: [],
           status: 200
         }}
      end)

      [post | _] = Post |> Ash.read!()

      [first_comment | _] = post.comments

      assert first_comment.comment == hd(ctx.response.comments).comment
    end
  end
end

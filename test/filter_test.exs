defmodule AshSanity.FilterTest do
  use AshSanity.CMSCase

  alias AshSanity.MockFinch
  alias AshSanity.Test.{Api, Post}

  require Ash.Query

  import Mox
  setup :verify_on_exit!

  describe "with no filter applied" do
    test "retrieves all data" do
      expect(MockFinch, :request, fn _request, Sanity.Finch, [receive_timeout: 30_000] ->
        {:ok, %Finch.Response{body: ~s({"result": []}), headers: [], status: 200}}
      end)

      assert [] == Api.read!(Post)
    end
  end

  describe "with filter" do
    test "applies equality filter" do
      expect(MockFinch, :request, fn request, Sanity.Finch, [receive_timeout: 30_000] ->
        expected_query = URI.encode_query(query: ~s(*[_type == "post" && _id == "1234"]))

        assert expected_query == request.query

        {:ok, %Finch.Response{body: ~s({"result": []}), headers: [], status: 200}}
      end)

      assert [] == Post |> Ash.Query.filter(_id == "1234") |> Api.read!()
    end

    test "applies contains filter" do
      expect(MockFinch, :request, fn request, Sanity.Finch, [receive_timeout: 30_000] ->
        expected_query = URI.encode_query(query: ~s(*[_type == "post" && title match "Hello"]))

        assert expected_query == request.query

        {:ok, %Finch.Response{body: ~s({"result": []}), headers: [], status: 200}}
      end)

      assert [] == Post |> Ash.Query.filter(contains(title, "Hello")) |> Api.read!()
    end

    test "applies greater than filter" do
      expect(MockFinch, :request, fn request, Sanity.Finch, [receive_timeout: 30_000] ->
        expected_query =
          URI.encode_query(query: ~s(*[_type == "post" && _createdAt > "2016-04-25"]))

        assert expected_query == request.query

        {:ok, %Finch.Response{body: ~s({"result": []}), headers: [], status: 200}}
      end)

      assert [] == Post |> Ash.Query.filter(_createdAt > "2016-04-25") |> Api.read!()
    end

    test "applies less than filter" do
      expect(MockFinch, :request, fn request, Sanity.Finch, [receive_timeout: 30_000] ->
        expected_query =
          URI.encode_query(query: ~s(*[_type == "post" && _createdAt < "2016-04-25"]))

        assert expected_query == request.query

        {:ok, %Finch.Response{body: ~s({"result": []}), headers: [], status: 200}}
      end)

      assert [] == Post |> Ash.Query.filter(_createdAt < "2016-04-25") |> Api.read!()
    end
  end

  describe "with pagination" do
    test "paginates first page of results" do
      expect(MockFinch, :request, fn request, Sanity.Finch, [receive_timeout: 30_000] ->
        expected_query = URI.encode_query(query: ~s(*[_type == "post"] | order(_id asc\)[0...10]))

        assert expected_query == request.query

        {:ok, %Finch.Response{body: ~s({"result": []}), headers: [], status: 200}}
      end)

      assert %Ash.Page.Offset{results: []} = Post |> Api.read!(page: [limit: 10])
    end
  end
end

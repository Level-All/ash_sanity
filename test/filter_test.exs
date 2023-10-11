defmodule AshSanity.FilterTest do
  use AshSanity.CMSCase

  alias AshSanity.MockFinch
  alias AshSanity.Test.{Api, Post}

  require Ash.Query

  import Mox
  setup :verify_on_exit!

  describe "with no filter applied" do
    test "retrieves all data" do
      expect(MockFinch, :request, fn request, Sanity.Finch, [receive_timeout: 30_000] ->
        {:ok, %Finch.Response{body: ~s({"result": []}), headers: [], status: 200}}
      end)

      assert [] == Api.read!(Post)
    end
  end
end

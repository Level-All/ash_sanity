defmodule AshSanity.QueryTest do
  use ExUnit.Case, async: true

  alias AshSanity.Query

  describe "build/1" do
    test "builds a basic query" do
      query = %AshSanity.Query{
        resource: AshSanity.Test.Post,
        api: AshSanity.Test.Api,
        filter: %Ash.Filter.Simple{
          resource: AshSanity.Test.Post,
          predicates: []
        },
        type: "post"
      }

      assert Query.build(query) ==
               ~s(*[_type == "post"]{_id, slug, title, body, "author": author->{_id, fullName}, "image": image {title, "author": author->{_id, fullName}}, "comments": comments[]->{_id, comment, "author": author->{_id, fullName}}, _createdAt, _updatedAt})
    end

    test "select specific fields" do
      query = %AshSanity.Query{
        resource: AshSanity.Test.Post,
        api: AshSanity.Test.Api,
        filter: %Ash.Filter.Simple{
          resource: AshSanity.Test.Post,
          predicates: []
        },
        type: "post",
        select: [:title]
      }

      assert Query.build(query) == ~s(*[_type == "post"]{_id, title})
    end

    test "filter criteria" do
      query = %AshSanity.Query{
        resource: AshSanity.Test.Post,
        api: AshSanity.Test.Api,
        filter: %Ash.Filter.Simple{
          resource: AshSanity.Test.Post,
          predicates: [%{__operator__?: true, operator: :==, left: :id, right: "1234"}]
        },
        type: "post"
      }

      assert Query.build(query) ==
               ~s(*[_type == "post" && _id == "1234"]{_id, slug, title, body, "author": author->{_id, fullName}, "image": image {title, "author": author->{_id, fullName}}, "comments": comments[]->{_id, comment, "author": author->{_id, fullName}}, _createdAt, _updatedAt})
    end
  end
end

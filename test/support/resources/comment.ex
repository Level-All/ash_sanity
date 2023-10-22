defmodule AshSanity.Test.Comment do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshSanity.DataLayer

  sanity do
    type("comment")
    cms(AshSanity.TestCMS)
  end

  actions do
    defaults [:read]
  end

  attributes do
    attribute :id, :string do
      primary_key? true
      allow_nil? false
    end

    attribute :comment, :string

    attribute :post_id, :string
  end
end

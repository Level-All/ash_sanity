defmodule AshSanity.Test.Post do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshSanity.DataLayer

  sanity do
    type("post")
    cms(AshSanity.TestCMS)
  end

  actions do
    defaults [:read]
  end

  attributes do
    attribute :_id, :string do
      writable? false
      default &Ash.UUID.generate/0
      primary_key? true
      allow_nil? false
    end

    attribute :title, :string
  end
end

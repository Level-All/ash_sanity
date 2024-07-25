defmodule AshSanity.Test.Comment do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshSanity.DataLayer,
    domain: AshSanity.Test.Domain

  sanity do
    type("comment")
    cms(AshSanity.TestCMS)
  end

  actions do
    defaults([:read])
  end

  attributes do
    attribute :id, :string do
      writable?(false)
      default(&Ash.UUID.generate/0)
      primary_key?(true)
      allow_nil?(false)
    end

    attribute(:comment, :string)

    attribute(:author, AshSanity.Type.Reference, constraints: [instance_of: AshSanity.Test.User])
  end
end

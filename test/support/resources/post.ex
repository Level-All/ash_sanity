defmodule AshSanity.Test.Post do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshSanity.DataLayer,
    domain: AshSanity.Test.Domain

  sanity do
    type("post")
    cms(AshSanity.TestCMS)
  end

  actions do
    read :read do
      primary?(true)
      pagination(offset?: true, required?: false)
    end
  end

  attributes do
    attribute :id, :string do
      writable?(false)
      default(&Ash.UUID.generate/0)
      primary_key?(true)
      allow_nil?(false)
    end

    attribute(:slug, AshSanity.Type.Slug)

    attribute(:title, :string)

    attribute(:body, :string)

    attribute(:status, :atom, constraints: [one_of: [:DRAFT, :IS_PUBLISHED]])

    attribute(:author, AshSanity.Type.Reference, constraints: [instance_of: AshSanity.Test.User])

    attribute(:image, AshSanity.Type.Object, constraints: [instance_of: AshSanity.Test.Image])

    attribute(:filters, {:array, AshSanity.Type.Object},
      constraints: [items: [one_of: [AshSanity.Test.IdentityFilter]]]
    )

    attribute(
      :comments,
      {:array, AshSanity.Type.Reference},
      constraints: [items: [instance_of: AshSanity.Test.Comment]]
    )

    create_timestamp(:created_at)
    update_timestamp(:updated_at)
  end
end

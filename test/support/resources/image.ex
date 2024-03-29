defmodule AshSanity.Test.Image do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshSanity.DataLayer

  sanity do
    type "image"
    cms AshSanity.TestCMS
  end

  resource do
    require_primary_key?(false)
  end

  actions do
    read :read do
      primary?(true)
      pagination(offset?: true, required?: false)
    end
  end

  attributes do
    attribute(:title, :string)

    attribute(:author, AshSanity.Type.Reference, constraints: [instance_of: AshSanity.Test.User])
  end
end

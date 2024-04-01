defmodule AshSanity.Test.IdentityFilter do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshSanity.DataLayer

  sanity do
    type("identityFilter")
    cms(AshSanity.TestCMS)
  end

  resource do
    require_primary_key?(false)
  end

  actions do
    read :read do
      primary?(true)
    end
  end

  attributes do
    attribute(:identity_type, :string)
  end
end

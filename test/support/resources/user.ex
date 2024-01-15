defmodule AshSanity.Test.User do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshSanity.DataLayer

  sanity do
    type("user")
    cms(AshSanity.TestCMS)
  end

  actions do
    read :read do
      primary? true
      pagination offset?: true, required?: false
    end
  end

  attributes do
    attribute :id, :string do
      writable? false
      default &Ash.UUID.generate/0
      primary_key? true
      allow_nil? false
    end

    attribute :full_name, :string
  end
end

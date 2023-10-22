defmodule AshSanity.Test.Post do
  @moduledoc false
  use Ash.Resource,
    data_layer: AshSanity.DataLayer

  sanity do
    type("post")
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

    attribute :title, :string

    attribute :body, :string

    attribute :content_code, :string

    attribute :order_rank, :string

    create_timestamp :created_at
    update_timestamp :updated_at
  end

  relationships do
    has_many :comments, AshSanity.Test.Comment
  end
end

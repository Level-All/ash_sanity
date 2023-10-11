defmodule AshSanity.DataLayer.Info do
  @moduledoc "Introspection functions for AshSanity CMS"

  alias Spark.Dsl.Extension

  def cms(resource) do
    Extension.get_opt(resource, [:sanity], :cms, nil, true)
  end

  def type(resource) do
    Extension.get_opt(resource, [:sanity], :type, nil, true)
  end
end

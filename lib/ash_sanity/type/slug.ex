defmodule AshSanity.Type.Slug do
  @moduledoc """
  Custom type to support Sanity slugs.

  https://www.sanity.io/docs/slug-type
  """
  use Ash.Type

  @impl Ash.Type
  def storage_type(_) do
    :string
  end

  @impl Ash.Type
  def cast_stored(%{"current" => current}, _constraints) do
    {:ok, current}
  end

  @impl Ash.Type
  def cast_input(term, _constraints) do
    {:ok, term}
  end

  @impl Ash.Type
  def dump_to_native(term, _constraints) do
    {:ok, term}
  end
end

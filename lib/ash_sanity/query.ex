defmodule AshSanity.Query do
  @moduledoc """
  Query helpers for AshSanity
  """
  defstruct resource: nil, api: nil, filter: nil, type: nil

  def build(query) do
    ~s(*[_type == "#{query.type}"])
  end
end

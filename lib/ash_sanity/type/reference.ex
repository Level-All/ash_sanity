defmodule AshSanity.Type.Reference do
  @moduledoc """
  Represents a struct.

  This cannot be loaded from a database, it can only be used to cast input.

  Use the `instance_of` constraint to specify that it must be an instance of a specific struct.
  """
  alias AshSanity.DataLayer
  use Ash.Type

  @constraints [
    instance_of: [
      type: :atom,
      doc: "The module the struct should be an instance of"
    ]
  ]

  @impl Ash.Type
  def constraints, do: @constraints

  @impl Ash.Type
  def storage_type(_), do: :map

  @impl Ash.Type
  def cast_input(nil, _), do: {:ok, nil}

  def cast_input(%struct{} = value, constraints) do
    case constraints[:instance_of] do
      nil ->
        {:ok, value}

      ^struct ->
        {:ok, value}

      _ ->
        :error
    end
  end

  def cast_input(_, _), do: :error

  @impl Ash.Type
  def cast_input_array(_list, _constraints) do
    {:ok, []}
  end

  @impl Ash.Type
  def load(record, load, _constraints, %{api: api} = context) do
    opts = context |> Map.take([:actor, :authorize?, :tenant, :tracer]) |> Map.to_list()

    api.load(record, load, opts)
  end

  @impl Ash.Type
  def can_load?(constraints) do
    constraints[:instance_of] && Ash.Resource.Info.resource?(constraints[:instance_of])
  end

  @impl Ash.Type
  def cast_stored(term, instance_of: resource) do
    DataLayer.cast_document(term, resource)
  end

  @impl Ash.Type
  def cast_stored_array(list, constraints) do
    DataLayer.cast_documents(list, constraints[:items][:instance_of])
  end

  @impl Ash.Type
  def dump_to_native(nil, _), do: {:ok, nil}
  def dump_to_native(_, _), do: :error

  @impl Ash.Type
  def dump_to_native_array(_list, _constraints) do
    {:ok, []}
  end
end

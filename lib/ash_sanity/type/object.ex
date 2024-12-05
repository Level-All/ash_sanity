defmodule AshSanity.Type.Object do
  @moduledoc """
  Represents an attribute that is a complex object in Sanity.

  Use the `instance_of` constraint to specify that it must 
  be an instance of a specific resource type.
  """
  alias AshSanity.DataLayer
  use Ash.Type

  @constraints [
    instance_of: [
      type: :atom,
      doc: "The module the object should be an instance of"
    ],
    one_of: [
      type: {:list, :atom},
      doc: "A list of modules the object may be an instance of"
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
  def load(record, load, _constraints, context) do
    opts = context |> Map.take([:actor, :authorize?, :tenant, :tracer]) |> Map.to_list()

    Ash.load(record, load, opts)
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
    constraints = Keyword.get(constraints, :items, constraints)

    case constraints do
      [instance_of: resource] ->
        {:ok,
         Enum.map(list, fn term ->
           {:ok, document} = DataLayer.cast_document(term, resource)
           document
         end)}

      [one_of: resources] ->
        {:ok,
         Enum.map(list, fn term ->
           resource =
             Enum.find(resources, fn resource ->
               term["_type"] == AshSanity.DataLayer.Info.type(resource)
             end)

           {:ok, document} = DataLayer.cast_document(term, resource)
           document
         end)}
    end
  end

  @impl Ash.Type
  def dump_to_native(nil, _), do: {:ok, nil}
  def dump_to_native(_, _), do: :error

  @impl Ash.Type
  def dump_to_native_array(_list, _constraints) do
    {:ok, []}
  end
end

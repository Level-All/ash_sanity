defmodule AshSanity.Type.Reference do
  @moduledoc """
  Represents a reference to another Sanity document.

  Use the `instance_of` constraint to specify that it must 
  be an instance of a specific document type.
  """
  alias Ash.Actions.Read.Calculations
  alias Ash.Resource.Info
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
  def load(record, load, _constraints, %{domain: domain} = context) do
    opts = Ash.Context.to_opts(context, domain: domain)

    Ash.load(record, load, opts)
  end

  @impl Ash.Type
  def merge_load(left, right, constraints, context) do
    instance_of = constraints[:instance_of]

    if instance_of do
      left = Ash.Query.load(instance_of, left)
      right = Ash.Query.load(instance_of, right)

      if left.valid? do
        {:ok, Ash.Query.merge_query_load(left, right, context)}
      else
        {:error, Ash.Error.to_ash_error(left.errors)}
      end
    else
      {:error, "References must have an `instance_of` constraint to be loaded through"}
    end
  end

  @impl Ash.Type
  def get_rewrites(merged_load, calculation, path, constraints) do
    instance_of = constraints[:instance_of]

    if instance_of && Info.resource?(instance_of) do
      merged_load = Ash.Query.load(instance_of, merged_load)
      Calculations.get_all_rewrites(merged_load, calculation, path)
    else
      []
    end
  end

  @impl Ash.Type
  def rewrite(value, rewrites, _constraints) do
    Calculations.rewrite(rewrites, value)
  end

  @impl Ash.Type
  def can_load?(constraints) do
    instance_of = constraints[:instance_of]

    instance_of && Info.resource?(instance_of)
  end

  @impl Ash.Type
  def cast_stored(term, instance_of: resource) do
    DataLayer.cast_document(term, resource)
  end

  @impl Ash.Type
  def cast_stored_array(list, instance_of: resource) do
    DataLayer.cast_documents(list, resource)
  end

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

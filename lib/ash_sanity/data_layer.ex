defmodule AshSanity.DataLayer do
  @moduledoc """
  Implementation of the Ash.DataLayer behaviour for Sanity.
  """
  @behaviour Ash.DataLayer

  alias AshSanity.Utils

  @sanity %Spark.Dsl.Section{
    name: :sanity,
    describe: """
    Sanity data layer configuration
    """,
    modules: [
      :cms
    ],
    examples: [
      """
      sanity do
        cms MyApp.CMS
        type "task"
      end
      """
    ],
    schema: [
      cms: [
        type: :atom,
        required: true,
        doc:
          "The cms that will be used to fetch your data. See the `AshSanity.CMS` documentation for more"
      ],
      type: [
        type: :string,
        doc: """
        The type of the document in Sanity.
        """
      ]
    ]
  }

  @sections [@sanity]

  use Spark.Dsl.Extension, sections: @sections

  def can?(_, :filter), do: true
  def can?(_, {:filter_expr, _}), do: true
  def can?(_, :read), do: true
  def can?(_, :nested_expressions), do: true
  def can?(_, :sort), do: true
  def can?(_, :limit), do: true
  def can?(_, :offset), do: true

  def can?(_, {:sort, _}), do: true

  def can?(_, _), do: false

  def offset(query, offset, _), do: {:ok, %{query | offset: offset}}

  def resource_to_query(resource, api) do
    %AshSanity.Query{
      resource: resource,
      api: api
    }
  end

  def filter(query, filter, _resource) do
    if query.filter do
      {:ok, %{query | filter: Ash.Filter.add_to_filter!(query.filter, filter)}}
    else
      {:ok, %{query | filter: filter}}
    end
  end

  def limit(query, limit, _), do: {:ok, %{query | limit: limit}}

  def select(query, select, _resource), do: {:ok, %{query | select: select}}

  def sort(query, sort, _resource), do: {:ok, %{query | sort: sort}}

  def run_query(query, resource, _parent \\ nil) do
    cms = AshSanity.DataLayer.Info.cms(resource)
    type = AshSanity.DataLayer.Info.type(resource)

    query = %{query | type: type}

    query
    |> cms.all()
    |> cast_documents(resource)
  end

  def cast_documents(documents, resource) do
    documents
    |> Enum.reduce_while({:ok, []}, fn document, {:ok, casted} ->
      case cast_document(document, resource) do
        {:ok, casted_document} ->
          {:cont, {:ok, [casted_document | casted]}}

        {:error, error} ->
          {:halt, {:error, error}}
      end
    end)
    |> case do
      {:ok, documents} ->
        {:ok, Enum.reverse(documents)}

      {:error, error} ->
        {:error, error}
    end
  end

  def cast_document(document, resource) do
    resource
    |> Ash.Resource.Info.attributes()
    |> Enum.reduce_while({:ok, %{}}, fn attribute, {:ok, attrs} ->
      case get_attribute(document, attribute) do
        nil ->
          {:cont, {:ok, Map.put(attrs, attribute.name, nil)}}

        value ->
          cast_attribute(attribute, value, attrs)
      end
    end)
    |> case do
      {:ok, attrs} ->
        {:ok,
         %{
           struct(resource, attrs)
           | __meta__: %Ecto.Schema.Metadata{state: :loaded, schema: resource}
         }}

      {:error, error} ->
        {:error, error}
    end
  end

  defp cast_attribute(attribute, value, attrs) do
    case Ash.Type.cast_stored(attribute.type, value, attribute.constraints) do
      {:ok, value} ->
        {:cont, {:ok, Map.put(attrs, attribute.name, value)}}

      :error ->
        {:halt, {:error, "Failed to load #{inspect(value)} as type #{inspect(attribute.type)}"}}

      {:error, error} ->
        {:halt, {:error, error}}
    end
  end

  defp get_attribute(document, attribute) do
    Map.get(document, Utils.camelize(attribute))
  end
end

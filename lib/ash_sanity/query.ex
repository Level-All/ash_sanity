defmodule AshSanity.Query do
  @moduledoc """
  Query helpers for AshSanity
  """
  defstruct [:resource, :api, :filter, :type, :sort, :offset, :limit]

  def build(query) do
    ~s(*[_type == "#{query.type}"#{build_filters(query.filter)}]#{build_ordering(query.sort)}#{build_slice(query)})
  end

  defp build_filters(%Ash.Filter{expression: expression}) do
    case expression do
      %{__function__?: true, name: :contains, arguments: [field, value]} ->
        ~s( && #{Ash.Query.Ref.name(field)} match "#{value}")

      %{__operator__?: true, operator: :==, left: left, right: right} when is_binary(right) ->
        ~s( && #{Ash.Query.Ref.name(left)} == "#{right}")

      _ ->
        ""
    end
  end

  defp build_filters(%Ash.Filter.Simple{predicates: predicates}) do
    Enum.reduce(predicates, "", fn predicate, acc ->
      case predicate do
        %{__function__?: true, name: :contains, arguments: [field, value]} ->
          ~s( && #{Ash.Query.Ref.name(field)} match "#{value}")

        %{__operator__?: true, operator: :==, left: left, right: right} when is_binary(right) ->
          acc <> ~s( && #{Ash.Query.Ref.name(left)} == "#{right}")

        _ ->
          ""
      end
    end)
  end

  defp build_filters(nil), do: ""

  defp build_ordering(nil), do: ""

  defp build_ordering([]), do: ""

  defp build_ordering(orderings) do
    orderings =
      orderings
      |> Enum.map_join(", ", fn {field, direction} ->
        ~s(#{field} #{Atom.to_string(direction)})
      end)

    ~s( | order(#{orderings}\))
  end

  defp build_slice(%{offset: nil, limit: nil}), do: ""
  defp build_slice(%{offset: _offset, limit: nil}), do: ""

  defp build_slice(%{offset: offset, limit: limit}) do
    ~s([#{offset}...#{limit - 1}])
  end
end

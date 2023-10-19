defmodule AshSanity.Utils do
  @moduledoc """
  Helpers for AshSanity
  """
  def camelize(:id), do: "_id"
  def camelize(:created_at), do: "_createdAt"
  def camelize(:updated_at), do: "_updatedAt"

  def camelize(%{attribute: %{name: :id}}), do: "_id"
  def camelize(%{attribute: %{name: :created_at}}), do: "_createdAt"
  def camelize(%{attribute: %{name: :updated_at}}), do: "_updatedAt"

  def camelize(%Ash.Query.Ref{} = field),
    do: Ash.Query.Ref.name(field) |> to_string() |> camelize()

  def camelize(%Ash.Resource.Attribute{} = field),
    do: field.name |> to_string() |> camelize()

  def camelize(word) when is_binary(word) do
    beginning_uderscore? = String.starts_with?(word, ["_"])

    word =
      case Regex.split(~r/(?:^|[-_])|(?=[A-Z])/, to_string(word)) do
        words ->
          words
          |> Enum.filter(&(&1 != ""))
          |> camelize_list(:lower)
          |> Enum.join()
      end

    if beginning_uderscore? do
      "_" <> word
    else
      word
    end
  end

  defp camelize_list([], _), do: []

  defp camelize_list([h | tail], :lower) do
    [lowercase(h)] ++ camelize_list(tail, :upper)
  end

  defp camelize_list([h | tail], :upper) do
    [capitalize(h)] ++ camelize_list(tail, :upper)
  end

  def capitalize(word), do: String.capitalize(word)
  def lowercase(word), do: String.downcase(word)
end

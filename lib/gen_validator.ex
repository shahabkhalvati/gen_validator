defmodule GenValidator do
  @moduledoc """
  Documentation for `GenValidator`.
  """

  alias GenValidator.Validation

  @doc """
  ## Examples

      iex> GenValidator.is_valid?(2, fn x -> x == 2 end)
      :not_implemented_yet

      iex> GenValidator.is_valid?("", fn x -> x == 2 end)
      :not_implemented_yet

  """
  def is_valid?(_data, _schema) do
    :not_implemented_yet
  end

  def validate(data, schema, validation_result_type) do
    schema
    |> Enum.map(fn {key, rules} ->
      rules
      |> apply_key(key)
      |> build_validation(validation_result_type.acc())
      |> then(&{key, &1})
    end)
    |> Enum.map(fn {key, validation} -> {key, validation.(Map.get(data, key))} end)
    |> validation_result_type.fold()
  end

  defp apply_key(rules, key) do
    rules
    |> Enum.map(fn rule -> rule.(key) end)
  end

  defp build_validation(rules, acc) do
    Validation.from(rules, acc)
  end
end

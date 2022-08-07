defmodule GenValidator.Predicates do
  @doc """
  ## Examples

    iex> email?("name@some.thing")
    true

    iex> email?("something")
    false

    iex> email?("")
    false

    iex> email?(23)
    false

    iex> email?(nil)
    false

  """
  def email?(str) when is_binary(str), do: Regex.match?(~r/@/, str)
  def email?(_data), do: false
end

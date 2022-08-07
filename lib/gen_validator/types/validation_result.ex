defmodule GenValidator.Types.ValidationResult do
  @spec valid(any) :: {:valid, any} | {:invalid, any}
  def valid(map_fn \\ default_on_valid()), do: &{:valid, map_fn.(&1)}
  def invalid(map_fn \\ default_on_invalid()), do: &{:invalid, map_fn.(&1)}

  defp default_on_valid(), do: & &1

  defp default_on_invalid(),
    do: fn {key, error_message, _provided_data} ->
      {key, error_message}
    end

  @spec is_invalid({:invalid, any} | {:valid, any}) :: boolean
  def is_invalid({:valid, _}), do: false
  def is_invalid({:invalid, _}), do: true
end

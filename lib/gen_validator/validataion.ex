defmodule GenValidator.Validation do
  @doc """
  ## Examples

    iex> of(fn _ -> false end, & &1).(&is_binary/1, "is not string").("key").("something")
    {"key", "something"}

    iex> of(& &1, fn _ -> true end).(&is_binary/1, "is not string").("key").(123)
    {"key", "is not string", 123}

  """
  def of(on_fail, on_success),
    do: fn predicate, error_message ->
      validation(on_fail, on_success, predicate, error_message)
    end

  def from(validations, collector) when is_list(validations) do
    fn data -> Enum.into(validations, collector, & &1.(data)) end
  end

  defp validation(on_fail, on_success, predicate, error_message),
    do: fn key ->
      &if_else(
        predicate,
        fn data -> on_success.({key, data}) end,
        fn data -> on_fail.({key, error_message, data}) end
      ).(&1)
    end

  defp if_else(pred, on_success, on_else),
    do: fn data ->
      if pred.(data) do
        on_success.(data)
      else
        on_else.(data)
      end
    end
end

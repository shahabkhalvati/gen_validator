defmodule GenValidator.Types.ValidationObj do
  alias GenValidator.Types.ValidationObj

  # result: :pending | :valid | :invalid
  defstruct result: :pending, data: nil

  def acc() do
    %__MODULE__{}
  end

  def fold(result_list) do
    result_list
    |> Enum.map(fn {_key, result} -> result end)
    |> Enum.reduce({:pending, %{}}, &concat(&2, &1))
  end

  defp concat({:pending, empty}, r), do: r

  defp concat({:valid, _data}, {:invalid, r_errs_obj}),
    do: {:invalid, r_errs_obj}

  defp concat({:invalid, l_err_obj}, {:valid, _data}),
    do: {:invalid, l_err_obj}

  defp concat({:valid, l_data}, {:valid, r_data}),
    do: {:valid, Map.merge(l_data, r_data)}

  defp concat({:invalid, l_err_obj}, {:invalid, r_errs_obj}),
    do: {:invalid, Map.merge(l_err_obj, r_errs_obj)}

  defimpl Collectable do
    def into(error_list) do
      collector_fun = fn
        %ValidationObj{result: result, data: acc} = validation_list_acc, {:cont, elem} ->
          case elem do
            {:invalid, validation_result} ->
              if result in [:pending, :valid] do
                of({:invalid, [validation_result]})
              else
                of({:invalid, [validation_result | acc]})
              end

            {:valid, current} ->
              if result == :pending do
                of({:valid, current})
              else
                validation_list_acc
              end
          end

        %ValidationObj{result: :valid, data: {key, map}}, :done ->
          {:valid, %{key => map}}

        %ValidationObj{result: :invalid, data: acc}, :done ->
          {:invalid, to_map(acc)}

        _validation_list_acc, :halt ->
          :ok
      end

      {error_list, collector_fun}
    end

    defp to_map(descriptors) do
      Enum.reduce(descriptors, %{}, &merge/2)
    end

    defp merge({key, value} = _current, acc_obj) do
      acc_obj
      |> Map.merge(%{key => [value]}, fn _k, v1, [v2] -> [v2 | v1] end)
    end

    defp of({result, validation_list}), do: %ValidationObj{result: result, data: validation_list}
  end
end

defmodule GenValidator.Types.ValidationList do
  alias GenValidator.Types.ValidationList

  # result: :pending | :valid | :invalid
  defstruct result: :pending, data: nil

  def acc() do
    %__MODULE__{}
  end

  defimpl Collectable do
    def into(error_list) do
      collector_fun = fn
        %ValidationList{result: result, data: acc} = validation_list_acc, {:cont, elem} ->
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

        %ValidationList{result: :valid, data: data}, :done ->
          {:valid, data}

        %ValidationList{result: :invalid, data: acc}, :done ->
          {:invalid, Enum.reverse(acc)}

        _validation_list_acc, :halt ->
          :ok
      end

      {error_list, collector_fun}
    end

    defp of({result, validation_list}), do: %ValidationList{result: result, data: validation_list}
  end
end

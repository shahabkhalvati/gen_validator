defmodule GenValidator.Types.ValidationList do
  alias GenValidator.Types.ValidationList

  # result: :pending | :valid | :invalid
  defstruct result: :pending, data: nil

  def acc() do
    %__MODULE__{}
  end

  defimpl Collectable do
    def into(error_list) do
      {error_list, &collect/2}
    end

    defp collect(%ValidationList{result: result, data: acc} = validation_list_acc, {:cont, elem}) do
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
    end

    defp collect(%ValidationList{result: :valid, data: data}, :done),
      do: {:valid, data}

    defp collect(%ValidationList{result: :invalid, data: acc}, :done),
      do: {:invalid, Enum.reverse(acc)}

    defp collect(_validation_list_acc, :halt), do: :ok

    defp of({result, validation_list}), do: %ValidationList{result: result, data: validation_list}
  end
end

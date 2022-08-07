defmodule GenValidator.ValidataionTest do
  use ExUnit.Case
  doctest GenValidator.Validation, import: true

  alias GenValidator.Validation

  defp always_false(_), do: false
  defp always_true(_), do: true

  test "validation – interface / true | false" do
    error_message = "is not string"
    validation = Validation.of(&always_false/1, &always_true/1)

    is_string? = validation.(&is_binary/1, error_message).("")

    assert is_string?.("something") == true
    assert is_string?.(123) == false
    assert is_string?.(nil) == false
  end

  test "validation – interface / data | report" do
    validation = Validation.of(&Function.identity/1, &Function.identity/1)

    is_string? = validation.(&is_binary/1, "is not string")

    assert is_string?.(:key).("something") == {:key, "something"}
    assert is_string?.(:key).(123) == {:key, "is not string", 123}
    assert is_string?.(:key).(nil) == {:key, "is not string", nil}
  end

  test "validation – interface / custom API" do
    on_success = &always_true/1
    on_fail = fn {_key, error_message, _provided_data} -> {false, error_message} end

    validation = Validation.of(on_fail, on_success)

    is_string? = validation.(&is_binary/1, "is not string").("")

    assert is_string?.("something") == true
    assert is_string?.(123) == {false, "is not string"}
    assert is_string?.(nil) == {false, "is not string"}
  end

  test "validation – interface / multiple checks" do
    on_success = &always_true/1
    on_fail = fn {_key, error_message, _provided_data} -> {false, error_message} end

    validation = Validation.of(on_fail, on_success)

    is_string? = validation.(&is_binary/1, "is not string").("")
    is_longer_than_4? = validation.(&(String.length(&1) > 4), "is not long enough").("")
    has_at_sign? = validation.(&Regex.match?(~r/@/, &1), "is not long enough").("")

    is_valid? = Validation.from([is_string?, is_longer_than_4?, has_at_sign?], [])

    assert is_valid?.("something") == [true, true, {false, "is not long enough"}]
  end
end

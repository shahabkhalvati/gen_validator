defmodule GenValidator.Types.ValidationListTest do
  use ExUnit.Case
  doctest GenValidator.Predicates, import: true

  alias GenValidator.Validation
  alias GenValidator.Types.ValidationResult
  alias GenValidator.Types.ValidationList

  test "collects validation errors" do
    on_success = ValidationResult.valid(fn {_key, data} -> data end)

    on_fail =
      ValidationResult.invalid(fn {_key, error_message, _provided_data} ->
        {false, error_message}
      end)

    validation = Validation.of(on_fail, on_success)

    is_string? = validation.(&is_binary/1, "is not string").("")
    is_longer_than_4? = validation.(&(String.length(&1) > 4), "is not long enough").("")
    has_at_sign? = validation.(&Regex.match?(~r/@/, &1), "does not have at_sign").("")

    is_valid? =
      Validation.from([is_string?, is_longer_than_4?, has_at_sign?], ValidationList.acc())

    assert is_valid?.("") ==
             {:invalid, [{false, "is not long enough"}, {false, "does not have at_sign"}]}

    assert is_valid?.("something") == {:invalid, [{false, "does not have at_sign"}]}
    assert is_valid?.("some@thing") == {:valid, "some@thing"}
  end

  test "collects validation error messages" do
    on_success = ValidationResult.valid(fn {_key, data} -> data end)

    on_fail =
      ValidationResult.invalid(fn {_key, error_message, _provided_data} -> error_message end)

    validation = Validation.of(on_fail, on_success)

    is_string? = validation.(&is_binary/1, "is not string").("")
    is_longer_than_4? = validation.(&(String.length(&1) > 4), "is not long enough").("")
    has_at_sign? = validation.(&Regex.match?(~r/@/, &1), "does not have at_sign").("")

    is_valid? =
      Validation.from([is_string?, is_longer_than_4?, has_at_sign?], ValidationList.acc())

    assert is_valid?.("") == {:invalid, ["is not long enough", "does not have at_sign"]}
    assert is_valid?.("something") == {:invalid, ["does not have at_sign"]}
    assert is_valid?.("some@thing") == {:valid, "some@thing"}
  end
end

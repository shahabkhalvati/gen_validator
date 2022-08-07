defmodule GenValidator.Types.ValidationObjTest do
  use ExUnit.Case
  doctest GenValidator.Predicates, import: true

  alias GenValidator.Validation
  alias GenValidator.Types.ValidationResult
  alias GenValidator.Types.ValidationObj

  test "collects validation errors" do
    on_success = ValidationResult.valid()
    on_fail = ValidationResult.invalid()

    validation = Validation.of(on_fail, on_success)

    is_string? = validation.(&is_binary/1, "is not string").("Email")
    starts_with_s? = validation.(&String.starts_with?(&1, "s"), "does not start with s").("Email")
    is_longer_than_4? = validation.(&(String.length(&1) > 4), "is not long enough").("Email")
    has_at_sign? = validation.(&Regex.match?(~r/@/, &1), "does not have at_sign").("Email")

    is_valid? =
      Validation.from(
        [is_string?, starts_with_s?, is_longer_than_4?, has_at_sign?],
        ValidationObj.acc()
      )

    assert is_valid?.("") ==
             {:invalid,
              %{
                "Email" => [
                  "does not start with s",
                  "is not long enough",
                  "does not have at_sign"
                ]
              }}

    assert is_valid?.("something") ==
             {:invalid,
              %{
                "Email" => ["does not have at_sign"]
              }}

    assert is_valid?.("some@thing") == {:valid, %{"Email" => "some@thing"}}
  end
end

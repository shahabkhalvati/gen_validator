defmodule GenValidatorTest do
  use ExUnit.Case

  doctest GenValidator

  alias GenValidator.Validation
  alias GenValidator.Types.ValidationResult
  alias GenValidator.Types.ValidationObj

  test "Validates object against schema" do
    on_success = ValidationResult.valid()
    on_fail = ValidationResult.invalid()

    validation = Validation.of(on_fail, on_success)

    is_string? = validation.(&is_binary/1, "is not string")
    has_space? = validation.(&String.contains?(&1, " "), "should have space")
    is_longer_than_4? = validation.(&(String.length(&1) > 4), "is not long enough")
    has_at_sign? = validation.(&Regex.match?(~r/@/, &1), "does not have at_sign")

    schema = %{
      "full_name" => [is_string?, has_space?],
      "email" => [is_string?, is_longer_than_4?, has_at_sign?]
    }

    invalid_data = %{
      "full_name" => "Homer",
      "email" => "ing"
    }

    assert GenValidator.validate(invalid_data, schema, ValidationObj) ==
             {:invalid,
              %{
                "full_name" => ["should have space"],
                "email" => ["is not long enough", "does not have at_sign"]
              }}

    valid_data = %{
      "full_name" => "Homer Simpson",
      "email" => "thing@some.ing"
    }

    assert GenValidator.validate(valid_data, schema, ValidationObj) == {:valid, valid_data}
  end

  test "Drops the fields missing from schema" do
    on_success = ValidationResult.valid()
    on_fail = ValidationResult.invalid()

    validation = Validation.of(on_fail, on_success)
    skip = validation.(fn _ -> true end, "")

    schema = %{
      "full_name" => [skip]
    }

    data = %{
      "full_name" => "Homer Simpson",
      "email" => "thing@some.ing"
    }

    assert GenValidator.validate(data, schema, ValidationObj) ==
             {:valid, %{"full_name" => "Homer Simpson"}}
  end
end

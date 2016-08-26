defmodule Bonbon.Allergen.Name.Translation do
    use Bonbon.Web, :model
    use Translecto.Schema.Translation
    @moduledoc """
      A model representing the different allergen names for the different
      translations.
    """

    schema "allergen_name_translations" do
        translation
        field :term, :string
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translation_changeset(params)
        |> cast(params, [:term])
        |> validate_required([:term])
        |> format_lowercase(:term)
    end
end

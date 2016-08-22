defmodule Bonbon.Ingredient do
    use Bonbon.Web, :model
    use Translecto.Schema.Translatable
    import Translecto.Changeset

    schema "ingredients" do
        translatable :type, Bonbon.IngredientTypeTranslation
        translatable :name, Bonbon.IngredientNameTranslation
        timestamps
    end

    @doc """
      Builds a changeset based on the `struct` and `params`.
    """
    def changeset(struct, params \\ %{}) do
        struct
        |> translatable_changeset(params, [:type, :name])
        |> cast(params, [:type, :name])
        |> validate_required([:name])
        |> unique_constraint(:name)
    end
end
Overview
--------

These models are the interface to the underlying database. Currently all models are just Ecto schemas over a PostgreSQL database. Understanding the schemas and how they connect together is crucial to interacting with the database.


The current higher level connections are described in the model below:

```svgbob
                       +----------------+
                       | Cuisine.Region |
                       +--------+-------+
                                |
                                |
                                v 1
+------------+ +--------+ +-----------+ +--------------+
|  Allergen  | |  Diet  | |  Cuisine  | |  Ingredient  |
+----------+-+ +------+-+ +---+-------+ +-+------------+
           |          |       |           |
           .          |       |           .
            \         |       |          /
             \        |       |         /
              \       v M     v 1      /
               \  M +-------------+ M /
                .-->|  Item.Food  |<-.
                    +-------------+
```

An `Item.Food` can have many `Allergen`, `Diet`, and `Ingredient`, but only one `Cuisine`. These many relationships are exposed in `Item.Food.AllergenList`, `Item.Food.DietList`, and `Item.Food.IngredientList` respectively.

A `Cuisine` can have only one `Region`.


The above layout allows us to associate food with what allergies will be triggered from its consumption, what diets are allowed to consume it, what ingredients it consists of, and what style of cuisine it is. e.g. A plain pizza with ham might belong to the cuisine of type `Pizza` (which belongs to the regional style `Italian`), consists of the ingredients `mozzarella`, `ham`, `tomato sauce`, `flour`, `egg`, `yeast`, and so can't be eaten by people following any strict diet, or people with allergies to `gluten`, `egg`, and `meat`.

For more information on the individual models themselves, refer to their individual module documentation.


Translations
------------

Certain models store translatable data, this is done to allow for translatable searches for certain items and localised responses. Translations are currently implemented using the library [Translecto](https://github.com/ScrimpyCat/Translecto), for an in-depth look into how this library works see the [docs](https://hexdocs.pm/translecto/).

Translations are stored in separate models (ending with `Translation`). An example structure of these models is as follows:

```svgbob
+-----------+
| Diet      |               +-----------------------------------------+
+----+------+               | Diet.Name.Translation                   |
| id | name |               +--------------+-----------+--------------+
|----|------|               | translate_id | locale_id | term         |
| 1  | 2    +--.            |--------------|-----------|--------------|
| 2  | 3    |   \           | 1            | "en"      | "vegan"      |
+-----------+    .--------->| 2            | "en"      | "vegetarian" |
                  \         | 1            | "fr"      | "végétalien" |
                   '------->| 2            | "fr"      | "végétarien" |
                            +-----------------------------------------+
```

Where the `name` field contains the `translate_id` in the translation table. A `locale_id` is then needed to get the specific localised variant.

An example of manually querying all diet's in French could be done using the following expression:

```elixir
from diet in Diet,
    join: name in Diet.Name.Translation,
    on: diet.name == name.translate_id and name.locale_id == "fr",
    select: %{
        id: diet.id,
        name: name.term
    }
```

However the Translecto library provides a convenient interface to do the above:

```elixir
from diet in Diet,
    locale: "fr",
    translate: name in diet.name,
    select: %{
        id: diet.id,
        name: name.term
    }
```

### Locale

To translate the translatable models into a given localisation, a locale is provided. We have taken the approach of creating a model (`Bonbon.Model.Locale`) for the different locales, and they are in the format of culture codes (ISO 3166-1 alpha-2 and ISO 639-1 code).

To simplify lookup of the `locale_id`, the module provides functions to retrieve a `locale_id` for a given culture code. Two examples of this is as follows:

```elixir
from diet in Diet,
    locale: ^Locale.to_locale_id!("fr"),
    translate: name in diet.name,
    select: name.term

from diet in Diet,
    locales: ^Locale.to_locale_id_list!("en_AU"),
    translate: name in diet.name,
    select: name.term
```


Exercises
---------

Here are some simple exercises to gain further familiarity with the implementation. Note: results may differ depending how seed data has changed since writing this document. _Meta: If these exercises become a useful way to introduce new developers to the codebase, will likely create new seed data just for the exercises._

1. Retrieve the allergen (`Bonbon.Model.Allergen`) names in English (not specific to any region variant). Result: `["balsam of peru", "egg allergy", "fruit allergy", "garlic allergy", "gluten allergy", "hot pepper allergy", "meat allergy", "milk allergy", "oat allergy", "peanut allergy", "rice allergy", "seafood allergy", "soy allergy", "sulfite allergy", "tartrazine allergy", "tree nut allergy", "wheat allergy"]`.
2. Find the ingredient (`Bonbon.Model.Ingredient`) names an Australian (Australian English) may search to refer to a `spring onion`. Result: `["spring onion", "shallot"]`.
3. Find all ingredients with the type `meat` (English). Result: `["pork", "poultry"]`.
4. Add a new translatable field to `Bonbon.Model.Diet` to allow for localised descriptions to be provided to the diets to describe what they are. Result:
```elixir
# Should respond to the following test
Bonbon.Repo.all from diet in Bonbon.Model.Diet,
    locale: ^Bonbon.Model.Locale.to_locale_id!("en"),
    translate: info in diet.info,
    select: info.description
```

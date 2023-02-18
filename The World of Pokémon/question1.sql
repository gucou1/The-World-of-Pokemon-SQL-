-- Question 1) Which Pokémon Has the highest total points? And the lowest?

SELECT
  pokedex_number,
  name,
  total,
  Gen
  
FROM
    `pokemonproject2023.Pokemon.pokedex`

WHERE
  total = (
            SELECT
              MAX(total)
            FROM
              `pokemonproject2023.Pokemon.pokedex`
  )
 OR
  total = (
            SELECT
              MIN(total)
            FROM
              `pokemonproject2023.Pokemon.pokedex`
  )
  
-- Results:
| pokedex_number | name | total | Gen |
| -------------- | ---- | ----- | --- |
| 746 | Wishiwashi | 175 | VII |
| 890 | Eternatus Eternamax | 1125 | VIII|
  

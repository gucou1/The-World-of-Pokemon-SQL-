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
  

-----------------------------------------------------------------------------------------
-- Question 2) How many types are there and how are Pokémon distributed through them?



SELECT
  DISTINCT (final_count.type) AS Type,
  SUM(final_count.pokemon) AS Pokemon
  
  FROM -- Subquery to Union the counts for type 1 and type 2 as multiple pokemon fall into 2 distinct types
    (
     SELECT 
       DISTINCT(type_1)AS type,
       COUNT(type_1) AS pokemon
      
     FROM
        `pokemonproject2023.Pokemon.pokedex`
     GROUP BY
       type_1

     UNION ALL
      
  SELECT
     DISTINCT(type_2) AS type,
     COUNT(type_2) as pokemon
      
  FROM
     `pokemonproject2023.Pokemon.pokedex`

  GROUP BY
     type_2
  ) AS final_count
  
WHERE  
  Type IS NOT NULL

GROUP BY
  Type
  
ORDER BY
  Pokemon DESC



-------------------------------------------------------------------------------------------------
-- Question 3) How many Generations are there today and how many Pokémon do each Generation have?



WITH generation AS -- Casting the Gen dimension as INT to order them in ascending order (from I to IX)
  (
      SELECT 
        Gen,
        (CASE 
          WHEN Gen = 'I' THEN CAST('1' AS INT64)
          WHEN Gen = 'II' THEN CAST('2' AS INT64)
          WHEN Gen = 'III' THEN CAST('3' AS INT64)
          WHEN Gen = 'IV' THEN CAST('4' AS INT64)
          WHEN Gen = 'V' THEN CAST('5' AS INT64)
          WHEN Gen = 'VI' THEN CAST('6' AS INT64)
          WHEN Gen = 'VII' THEN CAST('7' AS INT64)
          WHEN Gen = 'VIII' THEN CAST('8' AS INT64)
          WHEN Gen = 'IX' THEN CAST('9' AS INT64)
        END) AS gen1,
        COUNT(DISTINCT(pokedex_number)) AS pokemon_count
    
    FROM `pokemonproject2023.Pokemon.pokedex`
      
    GROUP BY gen1, Gen
      
    ORDER BY gen1
  )
  
SELECT
  Gen AS Generation,
  pokemon_count  
  
FROM
  generation
  


-------------------------------------------------------------------------------------------------
-- Question 4) How do Legendary Pokémon compare to Normal Pokémon?


-- For this question, we will answer with 2 tables.

-- First a count of Pokemon for each of the Grouping
-- Legendary Pokémon can be divided into 3 sub-groups:
  -- Legendary, sub-Legendary and Mythical.
-- All others, are Normal.
  
SELECT
  class,
  COUNT(DISTINCT(pokedex_number) AS pokemon -- Counting only distinct pokédex_entries
                                            -- Excluding alternative forms
  
FROM
  `pokemonproject2023.Pokemon.pokedex`
  
GROUP BY
  class  ;
        
        
-- Now we query for the Average Stats by each class
  
SELECT
  class,
  ROUND(AVG(total),2) AS total,
  ROUND(AVG(hp),2) AS hp,
  ROUND(AVG(attack),2) AS attack,
  ROUND(AVG(defense),2) AS defense,
  ROUND(AVG(sp_atk), 2) AS sp_atk,
  ROUND(AVG(sp_def), 2) AS sp_def,
  ROUND(AVG(speed), 2) AS speed,
  ROUND(AVG(height), 2) AS height,
  ROUND(AVG(weight), 2) AS weight
  
FROM
  `pokemonproject2023.Pokemon.pokedex`
  
GROUP BY
  class
  
ORDER BY
  total DESC
        
        

-------------------------------------------------------------------------------------------------
-- Question 5) Which Pokémon from Gen I and Ground type are more "petable"?
    
 -- I'll also use 2 tables here. 
 -- First one, let's check the max, min, avg, for friendship level
        
SELECT 
  MAX(base_friendship_avg) AS max_petable,
  MIN(base_friendship_avg) AS min_petable,
  AVG(base_friendship_avg) AS avg_petable
        
FROM
  pokemonproject2023.Pokemon.pokedex; 
        
-- Now, let's answer the main question. After that we can compare how those Pokémon
-- stand against the average of all Pokémon
        
SELECT 
  pokedex_number,
  name,
  Gen,
  type_1,
  type_2,
  base_friendship_avg

FROM 
  pokemonproject2023.Pokemon.pokedex

-- Checking for Pokemon from Gen I and are
-- Ground Type (either type 1 or type 2)

WHERE
  Gen= 'I' AND (type_1 = 'Ground' OR type_2 = 'Ground')

ORDER BY
  base_friendship_avg DESC,
  pokedex_number        
        
       
        
-------------------------------------------------------------------------------------------------
-- Question 6) Which Pokémon are Purple in all their Evolutionary Stages and are Air or Water type?
        
        
SELECT 
  main.base_pokedex,
  main.stage1,
  main.stage1_color,
  stage1_type.type_1 AS stage1_type1,
  stage1_type.type_2 AS stage1_type2,
  main.stage2_pokedex,
  main.stage2,
  main.stage2_color,
  stage2_type.type_1 AS stage2_type1,
  stage2_type.type_2 AS stage2_type2,
  main.stage3_pokedex,
  main.stage3,
  main.stage3_color,
  stage3_type.type_1 AS stage3_type1,
  stage3_type.type_2 AS stage3_type2
        
FROM  
-- Subquery to join the evolution families table and color table 
-- where the color is always Purple. 
-- This gives a table with all the evolution states that are Purple coloured
  (
    SELECT 
      color_base.pokedex_number AS base_pokedex,
      evo.base AS stage1,
      color_base.color AS stage1_color,
      color_2nd.pokedex_number AS stage2_pokedex,
      color_2nd.name AS stage2,
      color_2nd.color AS stage2_color,
      color_3rd.pokedex_number AS stage3_pokedex,
      color_3rd.name AS stage3,
      color_3rd.color AS stage3_color

    FROM `pokemonproject2023.Pokemon.evolution_family` AS evo
      LEFT JOIN `pokemonproject2023.Pokemon.color`AS color_base
        ON evo.base = color_base.name
      LEFT JOIN `pokemonproject2023.Pokemon.color` AS color_2nd
        ON evo.second_stage = color_2nd.name
      LEFT JOIN `pokemonproject2023.Pokemon.color` AS color_3rd
        ON evo.third_stage = color_3rd.name
    
    WHERE
      color_base.color = 'Purple' AND color_2nd.color = 'Purple' AND color_3rd.color = 'Purple'
  ) AS main
        
-- Joining the previous table with the Pokedex Table to get the type 1 and type 2
-- for each of the evolution stage
-- and only showing the results where either type_1 or type_2 is "Flying" or "Water" type.
-- Final table will show all the Pokemon that are Purple in all evolutionary stages 
-- and either Water or Flying type
     LEFT JOIN `pokemonproject2023.Pokemon.pokedex` AS stage1_type
        ON main.stage1 = stage1_type.name
      LEFT JOIN `pokemonproject2023.Pokemon.pokedex` AS stage2_type
        ON main.stage2 = stage2_type.name
      LEFT JOIN `pokemonproject2023.Pokemon.pokedex` AS stage3_type
        ON main.stage3 = stage3_type.name
        
WHERE 
    stage1_type.type_1 = 'Flying' OR stage1_type.type_1 = 'Water'
 OR stage1_type.type_2 = 'Flying' OR stage1_type.type_2 = 'Water'
 OR stage2_type.type_1 = 'Flying' OR stage2_type.type_1 = 'Water'
 OR stage2_type.type_2 = 'Flying' OR stage2_type.type_2 = 'Water'
 OR stage3_type.type_1 = 'Flying' OR stage3_type.type_1 = 'Water'
 OR stage3_type.type_2 = 'Flying' OR stage3_type.type_2 = 'Water'
        
ORDER BY 
  base_pokedex ASC

        
        
-----------------------------------------------------------------------------------------
-- Question 7) Analysis of my favorite Pokémon.
        
        
-- My favourite Pokemon are Squirtle and Psyduck-
-- so I need to find them, but I can't remember their Pokedex Number
        
SELECT
  *
        
FROM
  pokemonproject2023.Pokemon.pokedex
        
WHERE 
  name IN ('Squirtle', 'Psyduck');
        
---------------------------------------------------------------------
-- What's their Evolutionary Family? Are they base stage, 2nd or 3rd?
        
SELECT
  base,
  second_stage,
  third_stage
        
FROM
  pokemonproject2023.Pokemon.evolution_family
        
WHERE
  base IN ('Squirtle', 'Psyduck') OR
  second_stage IN ('Squirtle', 'Psyduck') OR
  third_stage IN ('Squirtle', 'Psyduck');
        
-------------------------------------------------------------------
-- Are they the same color all throughout their evolutionary stages?
        
SELECT
  evo.base,
  color_base.color,
  evo.second_stage,
  color_2nd.color,
  evo.third_stage,
  color_3rd.color
        
FROM
  pokemonproject2023.Pokemon.evolution_family AS evo
        
LEFT JOIN pokemonproject2023.Pokemon.color AS color_base -- joining for base form color
  ON evo.base = color_base.name
LEFT JOIN pokemonproject2023.Pokemon.color AS color_2nd -- joining for second form color
  ON evo.second_stage = color_2nd.name
LEFT JOIN pokemonproject2023.Pokemon.color AS color_3rd -- joining for third form color
  ON evo.third_stage = color_3rd.name
        
WHERE
  base IN ('Squirtle', 'Psyduck');
        
----------------------------------------------------------------------
-- How do they compare in battle stats against other Pokemon?
-- Let's compare them against different groups of Pokemon
-- First, we create a CTE for Squirtle and Psyduck's stats
        
        
WITH squirtle_psyduck AS 
(
  SELECT 
    name,
    Gen,
    class,
    total,
    hp,
    attack,
    defense,
    sp_atk,
    sp_def,
    speed,
    height,
    weight,
    BMI
  
FROM
    pokemonproject2023.Pokemon.pokedex
  
WHERE
    name IN ('Squirtle', 'Psyduck')
  
),
        
-- We want to compare these 2 against a few groups's average stats
-- 1) All Gen I Pokemon (Excluding Legendary, Sub-Legendary, Mythical)
-- 2) All Gen I Base Forms (Excluding Legendary, Sub-Legendary, Mythical)
-- 3) All Generations' Base Forms (Excluding Legendary, Sub-Legendary, Mythical)
-- 4) All Pokemon (Excluding Legendary, Sub-Legendary, Mythical)
-- 5) Against Legendary, Sub-Legendary, Mythical
-- 6) Finally, compare Squirtle and Psyduck's Final Evolution with the previous groups
        
all_Gen_I AS -- 1) All Gen I average stats
(
  SELECT
    'Normal Class All Stages' AS name,
    'I' AS Gen,
    class,
    AVG(total) AS total,
    AVG(hp) AS hp,
    AVG(attack) AS attack,
    AVG(defense) AS defense,
    AVG(sp_atk) AS sp_atk,
    AVG(sp_def) AS sp_def,
    AVG(speed) AS speed,
    AVG(height) AS height,
    AVG(weight) AS weight,
    AVG(BMI) AS BMI
  
FROM
    pokemonproject2023.Pokemon.pokedex AS pokedex
  
WHERE 
    class = 'Normal' AND
    Gen = 'I'
  
GROUP BY 
    class
),
        
base_Gen_I AS -- 2) Base forms Gen I average stats
(
  SELECT
    'Normal Class Base Stage' AS name,
    'I' AS Gen,
    class,
    AVG(total) AS total,
    AVG(hp) AS hp,
    AVG(attack) AS attack,
    AVG(defense) AS defense,
    AVG(sp_atk) AS sp_atk,
    AVG(sp_def) AS sp_def,
    AVG(speed) AS speed,
    AVG(height) AS height,
    AVG(weight) AS weight,
    AVG(BMI) AS BMI
  
FROM
    pokemonproject2023.Pokemon.pokedex AS pokedex
  
    INNER JOIN -- Joining to compare only against base form evolution stages
      pokemonproject2023.Pokemon.evolution_family AS evo
      ON
        pokedex.name = evo.base
  
WHERE 
    class = 'Normal' AND
    Gen = 'I'
  
GROUP BY 
    class
),
        
base_all_Gen AS -- 3) Base forms average stats for all Generations
(
  SELECT
    'Normal Class Base Stage' AS name,
    'All Generations' AS Gen,
    class,
    AVG(total) AS total,
    AVG(hp) AS hp,
    AVG(attack) AS attack,
    AVG(defense) AS defense,
    AVG(sp_atk) AS sp_atk,
    AVG(sp_def) AS sp_def,
    AVG(speed) AS speed,
    AVG(height) AS height,
    AVG(weight) AS weight,
    AVG(BMI) AS BMI
  
FROM
    pokemonproject2023.Pokemon.pokedex AS pokedex
  
    INNER JOIN -- Joining to compare only against base form evolution stages
      pokemonproject2023.Pokemon.evolution_family AS evo
      ON
        pokedex.name = evo.base
  
WHERE 
    class = 'Normal'
  
GROUP BY 
    class
),
        
all_normal AS -- 4) All Pokemon for 'Normal' class
(
  SELECT
    'Normal Class All Stages' AS name,
    'All Gen' AS Gen,
    class,
    AVG(total) AS total,
    AVG(hp) AS hp,
    AVG(attack) AS attack,
    AVG(defense) AS defense,
    AVG(sp_atk) AS sp_atk,
    AVG(sp_def) AS sp_def,
    AVG(speed) AS speed,
    AVG(height) AS height,
    AVG(weight) AS weight,
    AVG(BMI) AS BMI
  
FROM
    pokemonproject2023.Pokemon.pokedex AS pokedex
  
WHERE 
    class = 'Normal'
  
GROUP BY 
    class
),
        
all_legendary AS -- 5) All Legendary, Sub-Legendary, Mythical
(
  SELECT
    CASE
      WHEN class = 'Legendary'
        THEN 'Legendary'
      WHEN class = 'Sub-Legendary'
        THEN 'Sub-legendary'
          ELSE 'Mythical'
    END AS name,
    'All Gen' AS Gen,
    class,
    AVG(total) AS total,
    AVG(hp) AS hp,
    AVG(attack) AS attack,
    AVG(defense) AS defense,
    AVG(sp_atk) AS sp_atk,
    AVG(sp_def) AS sp_def,
    AVG(speed) AS speed,
    AVG(height) AS height,
    AVG(weight) AS weight,
    AVG(BMI) AS BMI
  
FROM
    pokemonproject2023.Pokemon.pokedex AS pokedex
  
WHERE 
    class <> 'Normal'
  
GROUP BY 
    class
),
        
final_stage_stats AS -- 6) Final Stage's Stats
(
  WITH base_and_final_stage AS
  (
    SELECT
      base,
      CASE -- check what's the final evolution
        WHEN third_stage IS NOT NULL -- Third and final stage
          THEN third_stage
            ELSE second_stage -- Second and final stage
      END AS final_evolution
    
    FROM
      pokemonproject2023.Pokemon.evolution_family
  )
  
  SELECT
    base.base,
    base.final_evolution,
    pokedex.Gen,
    pokedex.class,
    pokedex.total,
    pokedex.hp,
    pokedex.attack,
    pokedex.defense,
    pokedex.sp_atk,
    pokedex.sp_def,
    pokedex.speed,
    pokedex.height,
    pokedex.weight,
    pokedex.BMI
  
 FROM base_and_final_stage AS base
  
    LEFT JOIN pokemonproject2023.Pokemon.pokedex AS pokedex
      ON
      base.final_evolution = pokedex.name
  
  WHERE
    base.base IN ('Squirtle', 'Psyduck') -- Final stages for our 2 Pokemon
)

-- Now, we Union the results for further comparison.
-- How do Squirtle and Psyduck compare with the
-- Previously defined groups?
        
SELECT
  *
        
FROM
  all_legendary -- All Legendary, Sub-Legendar and Mythical
        
UNION ALL
        
SELECT
  *
        
FROM
  all_normal -- All Normal Class Pokemon
        
UNION ALL
        
SELECT
  *
        
FROM
  base_all_Gen -- All Base Form Pokemon from all Gens
        
UNION ALL
        
SELECT
  *
        
FROM
  base_Gen_I -- All Base Form Gen I Pokemon
        
UNION ALL
        
SELECT
  *
        
FROM
  all_Gen_I -- All Gen I Pokemon
        
UNION ALL 
        
SELECT
  *
        
FROM
  squirtle_psyduck -- Squirtle and Psyduck Stats
        
UNION ALL
        
SELECT -- select only the columns to match
  final_evolution AS name,
  Gen,
  class,
  total,
  hp,
  attack,
  defense,
  sp_atk,
  sp_def,
  speed,
  height,
  weight,
  BMI
        
FROM
  final_stage_stats -- Final Stages' stats
        
ORDER BY 
  name DESC, Gen DESC

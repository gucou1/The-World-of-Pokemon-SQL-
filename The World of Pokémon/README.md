# LET'S CATCH THEM ALL !

> In this project I delved into the fantastic world of remarkable creatures, known as Pokémon, to develop my Analytical Skills with Excel, PowerQuery and SQL. The anime sensation as accompanied me since I was very young so it's time to make Ash and Pikachu (and a bunch of other lovable characters) proud of this "good ol' fan".

## Table of Contents

- Business Questions
- Data Gathering
- Querying Data
- Presenting The Final Answers


## Business Questions

> I asked a group of friends to challenge me with questions they'd would like to be answered.

<details><summary> Final Questions: </summary>
<p>

1. Which Pokémon Has the highest total points? And the lowest?
  2. How many types are there and how are Pokémon distributed through them?
  3. How many Generations are there today and how many Pokémon do each Generation have?
  4. How do Legendary Pokémon compare to Normal Pokémon?
  5. Which Pokémon from Gen I and Ground type are more "petable"?
  6. Which Pokémon are Purple in all their Evolutionary Stages and are Air or Water type?
  7. Analysis of my favorite Pokémon.

</p>
</details>


## Data Gathering

> To answer my friends questions I needed data (duh!). So I went on a quest for all the information I needeed. Let me show you what I did:

Using Excel's PowerQuery I collected the information needed from the Web. <br>

I needed Data on all Pokémon to date. Pokédex entry number, name, stats, types, Generation. Are they legendary or not? What is their main color? And even their friendship level, to grasp how "petable" they could be.
I would need to know their evolutionary family, If they are base form, second or third stage evolution and understand their evolution stages. <br>

Mainly all data came from https://bulbapedia.bulbagarden.net, which then was transformed to better fit the analysis needs.

After some tough data wrangling, I got 4 tables:
- pokemon_main_table -- <sub>Main Pokédex table with all stats, names, alternative forms, pokedex entry # </sub>
- pokemon_evolutions_table -- <sub>Evolution families, by base, second and third forms. </sub>
- pokemon_color_table  -- <sub>Color of each pokémon </sub>
- pokemon_all_simple -- <sub>This is just a simple pokédex. Just name and pokédex entry # </sub>

> These tables were then saved in .csv format and uploaded in Google BigQuery for further exploration.<br>
> The resulting tables in the Pokemon Schema are: <br> 


color <br> 
evolution family <br> 
pokedex <br>
pokedex_simple <br>
>  Now, we will jump into SQL!
 <br> 
 <br>

## Querying Data

### 1. Which Pokémon Has the highest total points? And the lowest?
<details><summary>SQL Code: </summary>
<p>

``` SQL
SELECT
  pokedex_number,
  name,
  total,
  Gen
  
FROM
    `pokemonproject2023.Pokemon.pokedex`

WHERE
  total = (
            SELECT
              MAX(total)
            FROM
              `pokemonproject2023.Pokemon.pokedex`
  )
 OR
  total = (
            SELECT
              MIN(total)
            FROM
              `pokemonproject2023.Pokemon.pokedex`
  )
```
</p>
</details>

> Query 1 results:


| pokedex_number | name | total | Gen |
| -------------- | ---- | ----- | --- |
| 746 | Wishiwashi | 175 | VII |
| 890 | Eternatus Eternamax | 1125 | VIII|
 <br>

### 2. How many types are there and how are Pokémon distributed through them?
<details><summary>SQL Code: </summary>
<p>
  
  ``` SQL
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

``` 
  
  </p>
</details>

> Query 2 results:

| Type | Pokemon | 
| ---- | -------- | 
Water	| 176
Flying	| 161
Normal	| 156
Grass	| 146
Psychic	| 133
Bug	| 119
Fire	| 95
Fighting	| 93
Poison	| 92
Dark	| 92
Ground	| 92
Rock	| 91
Dragon	| 89
Fairy	| 87
Electric	| 87
Ghost	| 86
Steel	| 85
Ice	| 65
 <br>

### 3. How many Generations are there today and how many Pokémon do each Generation have?
<details><summary>SQL Code: </summary>
<p>
  
  ``` SQL
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
  ```
  
  </p>
</details>

> Query 3 results:

|Generation | pokemon_count|
|---------- | -------------|
I	| 151
II | 100
III	| 135
IV | 107
V	| 156
VI	| 72
VII	| 88
VIII	| 96
IX	| 103
 <br>

### 4. How do Legendary Pokémon compare to Normal Pokémon?
> For this question, I will answer with 2 tables.

<details><summary>SQL Code #1: </summary>
<p>
  
  ``` SQL
  
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
  ```
  
   </p>
</details>

> Question 4, Query #1 results:

| class	| pokemon|
| ----- | -------|
Normal	| 909
Mythical	| 22
Legendary	| 26
Sub-Legendary	| 51

  
<details><summary>SQL Code #2: </summary>
<p>  
  
  ``` SQL
  
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
  ```
  
  </p>
</details>

> Question 4, Query #2 results:

| class	| total	| hp | attack	| defense	| sp_atk | sp_def	| speed	| height | weight |
| ----- | ----- | -- | ------ | ------- | ------ | ------ | ----- | ------ | ------ | 
Legendary	| 675.21	| 112.27	| 122.04	| 107.9	| 120.23	| 109.71	| 103.06	| 4.21	| 387.67
Mythical	| 597.78	| 83.94	| 108.44	| 93.25	| 112.86	| 97.58	| 101.69	| 1.39	| 91.61
Sub-Legendary	| 576.05	| 89.09	| 104.76	| 93.44	| 103.35	| 92.86	| 92.55	| 1.95	| 155.54
Normal	| 419.54	| 67.95	| 76.58	| 71.03	| 68.6	| 68.58	| 66.8	| 1.11	| 52.72
 <br>

### 5. Which Pokémon from Gen I and Ground type are more "petable"?
> Here I will also want 2 tables to answer


<details><summary>SQL Code #1: </summary>
<p>
  
  ``` SQL 
  
  -- First one, let's check the max, min, avg, for friendship level
        
SELECT 
  MAX(base_friendship_avg) AS max_petable,
  MIN(base_friendship_avg) AS min_petable,
  AVG(base_friendship_avg) AS avg_petable
        
FROM
  pokemonproject2023.Pokemon.pokedex; 
  ```
  
  </p>
</details>

> Question 5, Query #1 results:

 
| max_petable	| min_petable	| avg_petable |
| ----------- | ----------- | ----------- | 
140	| 0	| 55.044326241134804

<details><summary>SQL Code #2: </summary>
<p>
  
  ``` SQL 
  
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
  ```
  
  </p>
</details>


> Question 5, Query #2 results:

| pokedex_number	| name	| Gen	| type_1	| type_2	| base_friendship_avg
| -------------- | ------ | ----| ------| --------| --------------------| 
27	| Sandshrew	| I	| Ground	| 	| 60
28	| Sandslash	| I	| Ground	| 	| 60
31	| Nidoqueen	| I	| Poison	| Ground	| 60
34	| Nidoking	| I	| Poison	| Ground	| 60
50	| Alolan Diglett	| I	| Ground	| Steel	| 60
50	| Diglett	| I	| Ground	| 	| 60
51	| Dugtrio	| I	| Ground	| 	| 60
51	| Alolan Dugtrio	| I	| Ground	| Steel	| 60
74	| Geodude	| I	| Rock	| Ground	| | 60
75	| Graveler| I	| Rock	| Ground	| 60
76	| Golem	| I	| Rock	| Ground	| 60
95	| Onix	| I	| Rock	| Ground	| 60
104	| Cubone	| I	| Ground	| 	| 60
105	| Marowak	| I	| Ground	| 	| 60
111	| Rhyhorn	| I	| Ground	| Rock	| 60
112	| Rhydon	| I	| Ground	| Rock	| 60
 <br>

### 6. Which Pokémon are Purple in all their Evolutionary Stages and are Air or Water type?
<details><summary>SQL Code: </summary>
<p>
  
  ``` SQL
  
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
  
  ```
  
  </p>
</details>

> Query 6 results:


base_pokedex	| stage1	| stage1_color	| stage1_type1	| stage1_type2	| stage2_pokedex	| stage2	| stage2_color	| stage2_type1	| stage2_type2	| stage3_pokedex	| stage3	| stage3_color	| stage3_type1	| stage3_type2
| ----------| ---------| -| -| -| -| -| -| -| -| -| -| -| -| -| 
41	| Zubat	| Purple	| Poison	| Flying	| 42	| Golbat	| Purple	| Poison	| Flying	| 169	| Crobat	| Purple	| Poison	| Flying

 <br>
 
### 7. Analysis of my favorite Pokémon.
> This one is going to have a few tables.
Come with me and stay strong, I'm almost finished!

My favourite Pokemon are Squirtle and Psyduck-
so I need to find them, but I can't remember their Pokedex Number
<details><summary>SQL Code #1: </summary>
<p>

```SQL
        
SELECT
  *
        
FROM
  pokemonproject2023.Pokemon.pokedex
        
WHERE 
  name IN ('Squirtle', 'Psyduck');
  
  ```
  
  </p>
</details>

> Question 7, Query #1 results:

pokedex_number	| name	| Gen	| type_1	| type_2	| total	| hp	| attack	| defense	| sp_atk	| sp_def	| speed	| height	| weight	| BMI	| class	| alternative_form	| base_friendship_avg
| -| -| -| -| -| -| -| -| -| -| -| -| -| -| -| -| -| -| 
7	| Squirtle	| I	| Water		| 314	| 44	| 48	| 65	| 50	| 64	| 43	| 0.5	| 9.0	| 360	| Normal		| 60
54	| Psyduck	| I	| Water		| 320	| 50	| 52	| 48	| 65	| 50	| 55	| 0.8	| 19.6	| 306	| Normal		| 60


 <br>

---------------------------------------------------------------------
 What's their Evolutionary Family? Are they base stage, 2nd or 3rd?

<details><summary>SQL Code #2: </summary>
<p>

 ``` SQL
 
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
  
  ```
  
  </p>
</details>

> Question 7, Query #2 results:

base	| second_stage	| third_stage
| -| -| -| 
Squirtle	| Wartortle	| Blastoise
Psyduck	| Golduck	


 <br>


-------------------------------------------------------------------
Are they the same color all throughout their evolutionary stages?

<details><summary>SQL Code #3: </summary>
<p>

``` SQL

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
  
  ```
  
  </p>
</details>

> Question 7, Query #3 results:

base	| color	| second_stage	| color_1	| third_stage	| color_2
| -| -| -| -| -| -| 
Squirtle	| Blue	| Wartortle	| Blue	| Blastoise	| Blue
Psyduck	| Yellow	| Golduck	| Blue	


 <br>
    
----------------------------------------------------------------------
How do they compare in battle stats against other Pokemon?

<details><summary>SQL Code #4: </summary>
<p>

-- Let's compare them against different groups of Pokemon
-- First, we create a CTE for Squirtle and Psyduck's stats

``` SQL
        
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
  
  ```
  </p>
</details>

> Question 7, Query #4 results:


name	| Gen	| class	| total	| hp	| attack	| defense	| sp_atk	| sp_def	| speed	| height	| weight	| BMI
| ----| ----| -----| -----| ------| -------| ----------| ----| ------| -----| ----------| ----| -----------| 
Sub-legendary	| All Gen	| Sub-Legendary	| 576.0454545454545	| 89.090909090909037	| 104.75757575757576	| 93.439393939393938	| 103.34848484848486	| 92.863636363636374	| 92.545454545454533	| 1.9545454545454555	| 155.5424242424242	| 329.13636363636368
Squirtle	| I	| Normal	| 314.0	| 44.0	| 48.0	| 65.0	| 50.0	| 64.0	| 43.0	| 0.5	| 9.0	| 360.0
Psyduck	| I	| Normal	| 320.0	| 50.0	| 52.0	| 48.0	| 65.0	| 50.0	| 55.0	| 0.8	| 19.6	| 306.0
Normal Class Base Stage	| I	| Normal	| 333.7659574468085	| 51.521276595744695	| 62.351063829787243	| 61.265957446808507	| 48.542553191489347	| 51.712765957446805	| 58.37234042553191	| 0.83723404255319156	| 26.929787234042546	| 405.10638297872339
Normal Class Base Stage	| All Generations	| Normal	| 347.23475046210751	| 55.890942698706141	| 62.741219963031412	| 59.896487985212588	| 54.3475046210721	| 56.480591497227344	| 57.878003696857625	| 0.743438077634011	| 27.708687615526845	| 461.26432532347451
Normal Class All Stages	| I	| Normal	| 416.74226804123725	| 63.974226804123745	| 76.195876288659818	| 70.71134020618554	| 67.030927835051543	| 67.247422680412441	| 71.58247422680418	| 1.2654639175257725	| 52.343298969072151	| 356.0876288659793
Normal Class All Stages	| All Gen	| Normal	| 419.53874202370088	| 67.94530537830444	| 76.580674567000784	| 71.027347310847873	| 68.60437556973568	| 68.584320875114059	| 66.796718322698226	| 1.113582497721056	| 52.717228805834125	| 408.17137648131256
Mythical	| All Gen	| Mythical	| 597.777777777778	| 83.944444444444457	| 108.44444444444444	| 93.249999999999986	| 112.8611111111111	| 97.583333333333343	| 101.69444444444443	| 1.3888888888888888	| 91.605555555555583	| 364.63888888888886
Legendary	| All Gen	| Legendary	| 675.21153846153845	| 112.26923076923077	| 122.03846153846152	| 107.90384615384615	| 120.23076923076923	| 109.71153846153847	| 103.05769230769234	| 4.2117647058823531	| 387.66862745098041	| 19868.607843137252
Golduck	| I	| Normal	| 500.0	| 80.0	| 82.0	| 78.0	| 95.0	| 80.0	| 85.0	| 1.7	| 76.6	| 265.0
Blastoise	| I	| Normal	| 530.0	| 79.0	| 83.0	| 100.0	| 85.0	| 105.0	| 78.0	| 1.6	| 85.5	| 334.0


 <br>

----------------------------------------------------------------------
> Picking up on this last Query, I decided to try something new I had learnt recently.
I wanted to compare just the Total from these groups and try and creat a box & whiskers plot, later.
Let's see how it goes



<details><summary>SQL Code #5: </summary>
<p>

``` SQL

CREATE OR REPLACE TEMP TABLE class_stats AS -- Stats table with relative ranking and total count for each class
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
    ROW_NUMBER() OVER(PARTITION BY class ORDER BY total) AS series, -- relative ranking
    SUM(1) OVER(PARTITION BY class) AS n_data_points -- finds total number of date point for each class
  
  FROM
    pokemonproject2023.Pokemon.pokedex

);

CREATE OR REPLACE TEMP TABLE total_quartiles AS -- Table to find the values for Quartiles 1 and 3 and the Median
(
  SELECT
    name,
    Gen,
    class,
    total,
    AVG(CASE
          WHEN
            series >= (FLOOR(n_data_points / 2) / 2)
          AND
            series <= (FLOOR(n_data_points / 2) / 2) +1
            THEN
              total / 1
            ELSE NULL END
        ) OVER(PARTITION BY class) AS q1_total, -- Calculations for Quartile 1, values below the median
    AVG(CASE 
          WHEN 
            series >= (n_data_points / 2)
          AND
            series <= (n_data_points / 2) + 1
            THEN
              total / 1
            ELSE NULL END  
        ) OVER(PARTITION BY class) AS median_total, -- Calculations for the Median
    
    AVG(CASE
          WHEN 
            series >= (CEIL(n_data_points / 2) + (FLOOR(n_data_points / 2) / 2))
          AND
            series <= (CEIL(n_data_points / 2) + (FLOOR(n_data_points / 2) / 2) + 1)
            THEN
              total / 1
            ELSE NULL END
        ) OVER(PARTITION BY class)AS q3_total -- Calculations for Quartile 3, values above the median

  FROM
    class_stats
);

-- FINAL TABLE
SELECT --First part, valus for Legendary, Sub- Legendary, Mythical and all Normal 
  CASE
    WHEN class = 'Normal'
      THEN 'All Gen All Normal'
    ELSE
      class
     END AS groups_stats,
  MIN(total) AS minimum_total,
  AVG(q1_total) AS q1,
  AVG(median_total) AS median_total,
  AVG(q3_total) AS q3,
  MAX(total) AS maximum_total

FROM
  total_quartiles

GROUP BY 
  class

UNION ALL -- UNION table for All Pokemon from Gen I (excl Legendary groups)

SELECT
  'All Gen I' AS groups_stats,
  MIN(total) AS minimum_total,
  AVG(q1_total) AS q1,
  AVG(median_total) AS median_total,
  AVG(q3_total) AS q3,
  MAX(total) AS maximum_total

FROM
  total_quartiles

WHERE
  Gen = 'I' 
  AND
  class = 'Normal'

GROUP BY
  class

UNION ALL -- UNION table for Gen I Base Forms (excl Legendary groups)

SELECT
  'Gen I Base Forms' AS groups_stats,
  MIN(total) AS minimum_total,
  AVG(q1_total) AS q1,
  AVG(median_total) AS median_total,
  AVG(q3_total) AS q3,
  MAX(total) AS maximum_total

FROM
  total_quartiles AS t
  INNER JOIN
    pokemonproject2023.Pokemon.evolution_family AS evo
    ON
      t.name = evo.base

WHERE
  Gen = 'I' 
  AND
  class = 'Normal'

GROUP BY
  class

UNION ALL -- UNION table for all Generations Base Forms (excl Legendary groups)

SELECT
  'All Gen Base Forms' AS groups_stats,
  MIN(total) AS minimum_total,
  AVG(q1_total) AS q1,
  AVG(median_total) AS median_total,
  AVG(q3_total) AS q3,
  MAX(total) AS maximum_total

FROM
  total_quartiles AS t
  INNER JOIN
    pokemonproject2023.Pokemon.evolution_family AS evo
    ON
      t.name = evo.base

WHERE
  class = 'Normal'

GROUP BY
  class

```
  </p>
</details>

> Question 7, Query #5 results:


groups_stats	| minimum_total	| q1	| median_total	| q3	| maximum_total
| ----------| ----------------| ----| -------------| -----| -----------| 
All Gen All Normal	| 175	| 325.0	| 440.0| 	499.5	| 700
Legendary	| 200	| 670.0	| 680.0	| 700.0	| 1125
Sub-Legendary	| 385	| 570.0	| 580.0	| 580.0	| 700
Mythical	| 300	| 600.0	| 600.0	| 600.0	| 720
All Gen I	| 195	| 325.0	| 440.0	| 499.5	| 640
Gen I Base Forms	| 195	| 325.0	| 440.0	| 499.5	| 535
All Gen Base Forms	| 175	| 325.0	| 440.0	| 499.5	| 640

 <br>
 <br>
 <br>
  
## Presenting The Final Answers

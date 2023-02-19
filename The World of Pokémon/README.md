# LET'S CATCH THEM ALL !

> In this project I delved into the fantastic world of remarkable creatures, known as Pokémon, to develop my Analytical Skills with Excel, PowerQuery and SQL. The anime sensation as accompanied me since I was very young so it's time to make Ash and Pikachu (and a bunch of other lovable characters) proud of this "good ol' fan".

## Table of Contents

- Business Questions
- Data Gathering
- Querying Data
- Presenting the final answers


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


### 7. Analysis of my favorite Pokémon.
<details><summary>SQL Code: </summary>
<p>
  </p>
</details>

> Query 7 results:

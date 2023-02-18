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
- pokemon_main_table <!-- Main Pokédex table with all stats, names, alternative forms, pokedex entry # -->
- pokemon_evolutions_table <!-- Evolution families, by base, second and third forms. -->
- pokemon_color_table  <!-- Color of each pokémon -->
- pokemon_all_simple <!-- This is just a simple pokédex. Just name and pokédex entry #

> These tables were then saved in .csv format and uploaded in Google BigQuery for further exploration.<br>
>  Now, we will jump to SQL!


## Querying Data

> 



# daniel_charvat_project_sql
Projekt SQL Daniel Charvát

Pro zodpovezeni otazek jsem vytvoril dve tabulky
t_daniel_charvat_project_sql_primary_final - data mezd v jednotlivych sektorech a cen potravin pro ČR v obdobi od roku 2006 do roku 2018
t_daniel_charvat_project_sql_secondary_final - makroekonomicka data evropskych zemi (hdp, gini, populace) za stejne obdobi jako u prvni tabulky

Informace k datum:
Casto jsem pouzival CTE a vyuzival jsem funkce LAG, abych porovnal aktualni roky s predchozimi.
Pri cisteni dat bylo nutne osetrit nekolik specifik a to zejmena chybejici hodnoty NULL pri vypoctu procentualnich zmen.
Jelikoz jsem pouzival funkci LAG, pro vypocet mezirocniho rustu chybi referencni data pro prvni rok naseho sledovaneho obdobi.
Kvuli tomu SQL generuje pro prvni rok hodnotu NULL. Tyhle radky jsem tak cilene vyfiltroval pryc (pomoci WHERE IS NOT NULL)
Dale zdroje pro data mezd i cen nezacinaly ve stejne obdobi, primarni tabulka proto spojuje to obdobi, pro ktere existuje dostatecny prunik dat.


/*
 * Vyzkumne otazky
*/

-- 1. Rostou v prubehu let mzdy ve vsech odvetvich, nebo v nekterych klesaji?

-- ODPOVED na otazku 1
-- Ne, nerostou, napriklad u administrativni a podpurne cinnosti, ci cinnosti v oblasti nemovitosti
-- jsou roky, kdy mezirocne prumerna mzda v techto odvetvich klesla

-- 2. Kolik je mozne si koupit litru mleka a kilogramu chleba za prvni a posledni srovantelne obdobi v dostupnych datech cen a mezd?

-- Odpoved na otazku 2
-- v roce 2006 jsem si mohl koupit cca 1307 kg chleba
-- v roce 2018 jsem si mohl koupit cca 1363 kg chleba
-- dostupnost chleba se tak mirne zlepsila
-- v roce 2006 jsem si mohl koupit cca 1460 litru mleka
-- v roce 2018 jsem si mohl koupit cca 1667 litru mleka
-- dostupnost mleka se tak mirne zlepsila

-- 3. Ktera kategorie potravin zdražuje nejpomaleji (je u ni nejnizsi procentualni mezirocni narust)?

-- Odpoved na otazku 3
-- dle vysledku jsou dokonce dve potraviny, ktere ve sledovanem obdobi zlevnovaly:
-- Rajska jablka cervena kulata a Cukr krystalovy
-- Cukr zlevnoval nejvice
-- nejpomaleji zdrazovaly Banany zlute

-- 4. Existuje rok, ve kterem byl mezirocni narust cen potravin vyrazne vyssi nez rust mezd (vetsi nez 10 %)?

-- Odpoved na otazku 4
-- Ne, neni zadny rok, kdy by rust cen potravin predcil vic nez 10 % rust mezd.

-- 5. Ma vyska HDP vliv na zmeny ve mzdach a cenach potravin? Neboli pokud HDP vzroste vyrazneji v jednom roce, projevi se to na cenach potravin ci mzdach ve stejnem nebo nasledujicim roce vyraznejsim rustem?

-- Odpoved na otazku 5
-- podle meho nazoru, vliv HDP na ceny ci mzdy ve stejnem a nasledujicim roce je velice nejednoznacny.
-- Muzeme si vsimnout, ze napriklad v roce 2007 byl rust hdp vysoky, rust mezd a rust cen take.
-- Na druhou stranu napriklad v roce 2015, kdy byl rust hdp take silny, rust mezd nedosahoval vubec takovych hodnot, jako v roce 2007.
-- Ceny potravin dokonce klesaly.
-- Nepochybne, rust hdp ma vliv na rust ci pokles mezd a cen, avsak je to jen jeden z promennych, ktery ma na tyto veliciny vliv.


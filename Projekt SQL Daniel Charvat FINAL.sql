--PROJECT SQL

--mzdy
SELECT 
	*
FROM czechia_payroll_unit;

SELECT
	*
FROM czechia_payroll_calculation AS cpc;

SELECT 
	payroll_year,
	industry_branch_code,
	value
FROM czechia_payroll AS cp 
WHERE cp.calculation_code = 200 AND cp.value_type_code = 5958;

SELECT
	cp.payroll_year,
	cpib.name AS industry_name,
	cp.value AS average_salary
FROM czechia_payroll AS cp
LEFT JOIN czechia_payroll_industry_branch AS cpib
	ON cp. industry_branch_code = cpib.code 
WHERE cp.calculation_code = 200 AND cp.value_type_code = 5958;

SELECT
	cp.payroll_year,
	cpib.name AS industry_name,
	AVG(cp.value) AS average_salary
FROM czechia_payroll AS cp
LEFT JOIN czechia_payroll_industry_branch AS cpib
	ON cp. industry_branch_code = cpib.code 
WHERE cp.calculation_code = 200 AND cp.value_type_code = 5958
GROUP BY 
	cp.payroll_year,
	cpib.name;

--ceny
SELECT
	*
FROM czechia_price AS cp;

SELECT
	*
FROM czechia_price AS cp
LEFT JOIN czechia_price_category AS cpc
	ON cp. category_code = cpc. code;

SELECT
	EXTRACT(YEAR FROM cp.date_from) AS price_year,
	cpc.name AS category_name,
	AVG(cp.value) AS average_price
FROM czechia_price AS cp
LEFT JOIN czechia_price_category AS cpc
	ON cp.category_code = cpc.code 
GROUP BY 
	EXTRACT(YEAR FROM cp.date_from), cpc.name;


-- ted spojim ty dva prikazy dohromady a vytvorim tabulku
CREATE TABLE t_daniel_charvat_project_SQL_primary_final AS
WITH mzdy AS (
SELECT
	cp.payroll_year,
	cpib.name AS industry_name,
	AVG(cp.value) AS average_salary
FROM czechia_payroll AS cp
LEFT JOIN czechia_payroll_industry_branch AS cpib
	ON cp. industry_branch_code = cpib.code 
WHERE cp.calculation_code = 200 AND cp.value_type_code = 5958
GROUP BY 
	cp.payroll_year,
	cpib.name
),
ceny AS (
SELECT
	EXTRACT(YEAR FROM cp.date_from) AS price_year,
	cpc.name AS category_name,
	AVG(cp.value) AS average_price
FROM czechia_price AS cp
LEFT JOIN czechia_price_category AS cpc
	ON cp.category_code = cpc.code 
GROUP BY 
	EXTRACT(YEAR FROM cp.date_from), cpc.name
)
SELECT
	m.payroll_year AS YEAR,
	m.industry_name,
	m.average_salary,
	c.category_name,
	c.average_price
FROM mzdy AS m
INNER JOIN ceny AS c
	ON m.payroll_year = c.price_year;

SELECT
*
FROM t_daniel_charvat_project_sql_primary_final;

-- druha tabulka evropske zeme

SELECT 
	*
FROM countries;

SELECT
	country,
	gdp,
	YEAR,
	gini,
	population
FROM economies;

SELECT
	e.country,
	e.gdp,
	e.year,
	e.gini,
	e.population
FROM economies AS e
INNER JOIN countries AS c
	ON c.country = e.country
WHERE c.continent = 'Europe'
	AND e.YEAR IN (
				SELECT YEAR 
				FROM t_daniel_charvat_project_sql_primary_final);

-- vytvarim tabulku

CREATE TABLE t_daniel_charvat_project_sql_secondary_final AS
SELECT
	e.country,
	e.gdp,
	e.year,
	e.gini,
	e.population
FROM economies AS e
INNER JOIN countries AS c
	ON c.country = e.country
WHERE c.continent = 'Europe'
	AND e.YEAR IN (
				SELECT YEAR 
				FROM t_daniel_charvat_project_sql_primary_final);

SELECT
	*
FROM t_daniel_charvat_project_sql_secondary_final AS tdcpssf;


/*
 * Vyzkumne otazky
*/

-- 1. Rostou v prubehu let mzdy ve vsech odvetvich, nebo v nekterych klesaji?

-- mam za kazdou potravinu a rok prumernou mzdu, kdybych udelal avg
-- tak mi to da blbost, musim to nejak ocistit?

SELECT 
	YEAR,
	industry_name,
	average_salary
FROM t_daniel_charvat_project_sql_primary_final AS tdcpspf 
GROUP BY 
	YEAR,
	industry_name,
	average_salary 
ORDER BY
	industry_name,
	YEAR DESC;

-- ODPOVED na otazku 1
-- Ne, nerostou, napriklad u administrativni a podpurne cinnosti, ci cinnosti v oblasti nemovitosti
-- jsou roky, kdy mezirocne prumerna mzda v techto odvetvich klesla

-- 2. Kolik je mozne si koupit litru mleka a kilogramu chleba za prvni a posledni srovantelne obdobi v dostupnych datech cen a mezd?

SELECT
	YEAR,
	category_name,
	AVG(average_salary)/AVG(average_price) AS quantity
FROM t_daniel_charvat_project_sql_primary_final AS tdcpspf 
WHERE category_name IN ('Mléko polotučné pasterované', 'Chléb konzumní kmínový')
	AND YEAR IN (2006,2018)
	AND average_salary IS NOT NULL
	AND average_price IS NOT NULL
GROUP BY
	YEAR,
	category_name;

-- Odpoved na otazku 2
-- v roce 2006 jsem si mohl koupit cca 1307 kg chleba
-- v roce 2018 jsem si mohl koupit cca 1363 kg chleba
-- dostupnost chleba se tak mirne zlepsila
-- v roce 2006 jsem si mohl koupit cca 1460 litru mleka
-- v roce 2018 jsem si mohl koupit cca 1667 litru mleka
-- dostupnost mleka se tak mirne zlepsila

-- 3. Ktera kategorie potravin zdražuje nejpomaleji (je u ni nejnizsi procentualni mezirocni narust)?

SELECT 
	YEAR,
	category_name,
	average_price
FROM t_daniel_charvat_project_sql_primary_final AS tdcpspf;

SELECT 
	YEAR,
	category_name,
	average_price,
	LAG(average_price) OVER 
	(PARTITION BY category_name
	 ORDER BY YEAR ASC) AS previous_year_price
FROM t_daniel_charvat_project_sql_primary_final AS tdcpspf
GROUP BY
	YEAR,
	category_name,
	average_price;

-- procentualni zmena
WITH cenove_zmeny AS (
SELECT 
	YEAR,
	category_name,
	average_price,
	LAG(average_price) OVER 
	(PARTITION BY category_name
	 ORDER BY YEAR ASC) AS previous_year_price
FROM t_daniel_charvat_project_sql_primary_final AS tdcpspf
GROUP BY
	YEAR,
	category_name,
	average_price
)
SELECT
	category_name,
	ROUND(CAST(AVG((average_price - previous_year_price)/previous_year_price)*100 AS NUMERIC),2) AS procentualni_zmena
FROM cenove_zmeny
WHERE previous_year_price IS NOT NULL
GROUP BY 
category_name
ORDER BY procentualni_zmena DESC;

-- Odpoved na otazku 3
-- dle vysledku jsou dokonce dve potraviny, ktere ve sledovanem obdobi zlevnovaly:
-- Rajska jablka cervena kulata a Cukr krystalovy
-- Cukr zlevnoval nejvice
-- nejpomaleji zdrazovaly Banany zlute

-- 4. Existuje rok, ve kterem byl mezirocni narust cen potravin
-- vyrazne vyssi nez rust mezd (vetsi nez 10 %)?

-- musim si udelat rocni prumer vsech mezd a vsech potravin
-- aktualni rok a minuly rok vedle sebe
WITH rocni_prumery AS(
SELECT
	YEAR,
	AVG(average_price) AS prumerna_cena,
	AVG(average_salary) AS prumerna_mzda
FROM t_daniel_charvat_project_sql_primary_final AS tdcpspf 
GROUP BY
	YEAR
ORDER BY 
	YEAR ASC
),
predchozi_roky AS(
SELECT 
	YEAR,
	prumerna_cena,
	LAG(prumerna_cena) OVER (ORDER BY YEAR ASC) AS minula_cena,
	prumerna_mzda,
	LAG(prumerna_mzda) OVER (ORDER BY YEAR ASC) AS minula_mzda
FROM rocni_prumery
)
SELECT
	YEAR,
	ROUND(CAST(((prumerna_cena - minula_cena)/minula_cena)*100 AS NUMERIC), 2) AS rust_cen_procenta,
	ROUND(CAST(((prumerna_mzda - minula_mzda)/minula_mzda)*100 AS NUMERIC), 2) AS rust_mezd_procenta,
	ROUND(CAST(((prumerna_cena - minula_cena)/minula_cena)*100 - ((prumerna_mzda - minula_mzda)/minula_mzda)*100 AS NUMERIC),2) AS rozdil_v_procentech
FROM predchozi_roky
WHERE minula_cena IS NOT NULL
ORDER BY rozdil_v_procentech DESC;

-- Odpoved na otazku 4
-- Ne, neni zadny rok, kdy by rust cen potravin predcil vic nez 10 % rust mezd.

-- 5. Ma vyska HDP vliv na zmeny ve mzdach a cenach potravin?
-- Neboli, pokud HDP vzroste vyrazneji v jednom roce, projevi se to na cenach potravin ci mzdach
-- ve stejnem nebo nasledujicim roce vyraznejsim rustem?

SELECT
		YEAR,
		AVG(average_price) AS prumerna_cena,
		AVG(average_salary) AS prumerna_mzda
	FROM t_daniel_charvat_project_sql_primary_final AS tdcpspf 
	GROUP BY
		YEAR;
		
		
		

WITH rocni_prumery AS(
	SELECT
		YEAR,
		AVG(average_price) AS prumerna_cena,
		AVG(average_salary) AS prumerna_mzda
	FROM t_daniel_charvat_project_sql_primary_final AS tdcpspf 
	GROUP BY
		YEAR
),
rust_cen_mezd AS (
	SELECT
		YEAR,
		ROUND(CAST(((prumerna_cena - LAG(prumerna_cena) OVER (ORDER BY YEAR ASC)) / LAG(prumerna_cena) OVER (ORDER BY YEAR ASC)) * 100 AS NUMERIC),2) AS rust_cen_procenta,
		ROUND(CAST(((prumerna_mzda - LAG(prumerna_mzda) OVER (ORDER BY YEAR ASC)) / LAG(prumerna_mzda) OVER (ORDER BY YEAR ASC)) * 100 AS NUMERIC),2) AS rust_mezd_procenta
	FROM rocni_prumery
),
rust_hdp AS (
	SELECT
		YEAR,
		ROUND(CAST(((gdp - LAG(gdp) OVER (ORDER BY YEAR ASC)) / LAG(gdp) OVER (ORDER BY YEAR ASC)) * 100 AS NUMERIC),2) AS rust_hdp_procenta
	FROM t_daniel_charvat_project_SQL_secondary_final
	WHERE country = 'Czech Republic'
)
SELECT
	h.YEAR,
	h.rust_hdp_procenta,
	cm.rust_mezd_procenta,
	cm.rust_cen_procenta
FROM rust_hdp AS h
INNER JOIN rust_cen_mezd AS cm
	ON h.YEAR = cm.YEAR
WHERE h.rust_hdp_procenta IS NOT NULL
AND cm.rust_cen_procenta IS NOT NULL
ORDER BY 
	h.YEAR ASC;
	
-- Odpoved na otazku 5
-- podle meho nazoru, vliv HDP na ceny ci mzdy ve stejnem a nasledujicim roce je velice nejednoznacny.
-- Muzeme si vsimnout, ze napriklad v roce 2007 byl rust hdp vysoky, rust mezd a rust cen take.
-- Na druhou stranu napriklad v roce 2015, kdy byl rust hdp take silny, rust mezd nedosahoval vubec takovych hodnot, jako v roce 2007.
-- Ceny potravin dokonce klesaly.
-- Nepochybne, rust hdp ma vliv na rust ci pokles mezd a cen, avsak je to jen jeden z promennych, ktery ma na tyto veliciny vliv.

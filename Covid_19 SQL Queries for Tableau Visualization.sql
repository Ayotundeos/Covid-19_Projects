-- Covid-19 Data Exploration Queries for Tableau Visualization

-- 01 Query for the visualization of the global death rate

SELECT 
 SUM (new_cases) AS total_cases, 
 SUM(new_deaths) AS total_deaths,
 SUM(new_deaths)/SUM(new_cases)*100 AS world_death_pct
FROM Covid19..covid19deaths
WHERE Location NOT IN ('World', 'High income', 'Upper middle income', 'Europe', 'Asia', 'North America', 'South America', 'Lower middle income', 'European Union', 'Africa', 'low income', 'Oceania')
  ORDER BY 1,2,3


  -- 02 Query for the visualization of total death count per continent

 SELECT continent, MAX(total_deaths) AS highest_death_count
FROM	Covid19..covid19deaths
WHERE continent != '' -- Excluding a blank row in 'continent' column
GROUP BY continent
ORDER BY highest_death_count DESC


-- 03 Query for the visualization of the infected rate per country

SELECT Location, Population, MAX(total_cases) AS highest_covid_cases, ROUND ((MAX(total_cases/population)*100), 2) AS pct_pop_infected
FROM	Covid19..covid19deaths
GROUP BY Location, Population
ORDER BY pct_pop_infected DESC


-- 04 Visualization of the infecter Population Rate
SELECT Location, Population, CONVERT (date, date) AS Date, MAX(total_cases) AS highest_covid_cases, ROUND ((MAX(total_cases/population)*100), 2) AS pct_pop_infected
FROM	Covid19..covid19deaths
GROUP BY Location, Population, date
ORDER BY pct_pop_infected DESC

/* Covid-19 Data Exploration*/

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Covid19..covid19deaths
ORDER BY 1, 2


-- Exploring the percentage of Total Deaths per Total Cases
--This shows the likelyhood of dying after contracting the virus in Germany

ALTER TABLE covid19deaths
ALTER COLUMN total_cases float --Coverting datatype from nvarchar to float. I used 'float' cause if I use 'int or bigint(avoid overflow), all my Percentage values returns 0). Still trying to figure that out!

ALTER TABLE covid19deaths
ALTER COLUMN total_deaths float

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Percentage_Deaths
FROM	Covid19..covid19deaths
WHERE Location like '%Germany%'
ORDER BY 1, 2


-- Exploring Total Cases per Population
--This shows what percentage of the population that got Covid in Germany

SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS Pct_Infected_Pop
FROM	Covid19..covid19deaths
WHERE Location like '%Germany%'
ORDER BY 1, 2


-- Exploring Countries with the Highest Covid Rate per Population

SELECT Location, Population, MAX(total_cases) AS higest_Covid_Cases, MAX((total_cases/population))*100 AS pct_pop_infected
FROM	Covid19..covid19deaths
GROUP BY Location, Population
ORDER BY pct_pop_infected DESC


-- Exploring Countries with the Highest Death Rate per Population

SELECT Location, MAX(total_deaths) AS higest_Death_Rate
FROM	Covid19..covid19deaths
WHERE Location NOT IN ('World', 'High income', 'Upper middle income', 'Europe', 'Asia', 'North America', 'South America', 'Lower middle income', 'European Union', 'Africa', 'low income', 'Oceania') --Excluding this values from the 'Location' column (They can be considered as outliers in this code chunk)
GROUP BY Location
ORDER BY higest_Death_Rate DESC


-- Exploring Continents with the Highest Death Rate per Population

SELECT continent, MAX(total_deaths) AS higest_Death_Rate
FROM	Covid19..covid19deaths
WHERE continent != '' -- Excluding a blank row in 'continent' column
GROUP BY continent
ORDER BY higest_Death_Rate DESC


-- Exploring the Global Covid Infection Rate

SELECT 
 SUM (new_cases) AS Total_Cases, 
 SUM(new_deaths) AS total_deaths,
 SUM(new_deaths)/SUM(new_cases)*100 AS World_death_pct
FROM Covid19..covid19deaths


-- Exploring the correlation between Covid-19 vaccinations and Covid-19 deaths

SELECT *
FROM Covid19..covid19vaccinations


-- Joining the Covid19deaths and the Covid19vaccinations tables togethter
-- Exploring Total Population per Vaccination Rate
--Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT CD.continent, CD.Location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS FLOAT)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.date) AS Incremental_vac_count_byLocation -- To have the daily summation of new vaccinations per location
FROM Covid19..covid19deaths AS CD --CD as an alias for covid19deaths
JOIN Covid19..covid19vaccinations AS CV -- Same
 ON CD.Location = CV.Location
 AND CD.date = CV.date
 WHERE CD.Location NOT IN ('World', 'High income', 'Upper middle income', 'Europe', 'Asia', 'North America', 'South America', 'Lower middle income', 'European Union', 'Africa', 'low income', 'Oceania')
  ORDER BY 1,2,3


  -- USE CTE
 -- This Common Table Expression will make it possible for me to perform calculations with the new column 'Incremental_vac_count_byLocation'

 WITH Pop_per_Vac (continent, Location, date, population, new_vaccinations, Incremental_vac_count_byLocation) AS
 (
 SELECT CD.continent, CD.Location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS FLOAT)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.date) AS Incremental_vac_count_byLocation
FROM Covid19..covid19deaths AS CD
JOIN Covid19..covid19vaccinations AS CV
 ON CD.Location = CV.Location
 AND CD.date = CV.date
 WHERE CD.Location NOT IN ('World', 'High income', 'Upper middle income', 'Europe', 'Asia', 'North America', 'South America', 'Lower middle income', 'European Union', 'Africa', 'low income', 'Oceania')
)
SELECT *, (Incremental_vac_count_byLocation/population)*100 AS Incremental_pcnt_pop_vac
FROM Pop_per_Vac


-- Temporary Table
-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #Pcnt_Vac_Pop
CREATE TABLE #Pcnt_Vac_Pop
Continent nvarchar(510),
Location nvarchar(510),
Date datetime,
Population numeric,
new_vaccacinations numeric,
Incremental_vac_count_byLocation numeric
)
INSERT INTO #Pcnt_Vac_Pop
SELECT CD.continent, CD.Location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS FLOAT)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.date) AS Incremental_vac_count_byLocation
FROM Covid19..covid19deaths AS CD
JOIN Covid19..covid19vaccinations AS CV
 ON CD.Location = CV.Location
 AND CD.date = CV.date
 WHERE CD.Location NOT IN ('World', 'High income', 'Upper middle income', 'Europe', 'Asia', 'North America', 'South America', 'Lower middle income', 'European Union', 'Africa', 'low income', 'Oceania')
 ORDER BY 1,2,3

SELECT *, (Incremental_vac_count_byLocation/population)*100 AS Incremental_pcnt_pop_vac
FROM #Pcnt_Vac_Pop


-- Creating VIEWS of some of my queries to store the data for visualization in Tableau

CREATE VIEW Pcnt_Vac_Pop AS
SELECT CD.continent, CD.Location, CD.date, CD.population, CV.new_vaccinations,
SUM(CAST(CV.new_vaccinations AS FLOAT)) OVER (PARTITION BY CD.Location ORDER BY CD.Location, CD.date) AS Incremental_vac_count_byLocation
FROM Covid19..covid19deaths AS CD
JOIN Covid19..covid19vaccinations AS CV
 ON CD.Location = CV.Location
 AND CD.date = CV.date
 WHERE CD.Location NOT IN ('World', 'High income', 'Upper middle income', 'Europe', 'Asia', 'North America', 'South America', 'Lower middle income', 'European Union', 'Africa', 'low income', 'Oceania')
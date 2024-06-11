SELECT *
FROM
  `portfolio-project-424902.Project_1.covid deaths`
Where continent is not null
Order by
  3,4


--SELECT *
--FROM
  --`portfolio-project-424902.Project_1.covid vaccinations`
-- Where continent is not null
--Order by
  --3,4


SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM
  `portfolio-project-424902.Project_1.covid deaths`
Where continent is not null
order by 1,2


-- Looking at Total Cases vs Total Deaths
-- rough estimates of the likelihood of dying if you contract covid in your country

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
FROM
  `portfolio-project-424902.Project_1.covid deaths`
WHERE Location = "United States" AND continent is not null
order by 1,2

-- Looking at Total Cases vs Population
-- percentage of population contracted Covid

SELECT Location, date, population, total_cases, (total_deaths/population)*100 as case_percentage
FROM
  `portfolio-project-424902.Project_1.covid deaths`
WHERE Location = "United States" AND continent is not null
order by 1,2

-- What countries have the highest infection rates compared to population

SELECT Location, population, MAX(total_cases) as highest_infection_count, MAX((total_cases/population))*100 as percent_population_infected
FROM
  `portfolio-project-424902.Project_1.covid deaths`
Where continent is not null
Group by location, population
order by percent_population_infected desc

-- Countries with Highest death count

Select Location, Max(cast(total_deaths as INT64)) as total_death_count
FROM
  `portfolio-project-424902.Project_1.covid deaths`
Where continent is not null
Group by location
order by total_death_count desc


-- Continents with the highest death count

Select continent, Max(cast(total_deaths as INT64)) as total_death_count
FROM
  `portfolio-project-424902.Project_1.covid deaths`
Where continent is not null
Group by continent
order by total_death_count desc


-- Global death percentage and cases

SELECT SUM(new_cases) as tot_cases, SUM(cast(new_deaths as INT64)) as tot_deaths, SUM(cast(new_deaths as INT64))/SUM(New_Cases)*100 as death_percentage
FROM
  `portfolio-project-424902.Project_1.covid deaths`
WHERE continent is not null
order by 
  1,2

-- Total Population vs Vaccinations
-- Percentage of population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as INT64)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
FROM
  `portfolio-project-424902.Project_1.covid deaths` dea
JOIN
  `portfolio-project-424902.Project_1.covid vaccinations` vac
  On dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
Order by
  2,3


-- Using CTE to perform Calculation on Partition by in previous query

With pop_vs_vac 
as (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as INT64)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
FROM
  `portfolio-project-424902.Project_1.covid deaths` dea
JOIN
  `portfolio-project-424902.Project_1.covid vaccinations` vac
  On dea.location = vac.location AND dea.date = vac.date
Where dea.continent is not null
  )
Select *, (rolling_vaccinations/population)*100
FROM pop_vs_vac



--Using a Table to perform Calculation on Partition By in previous query


CREATE OR REPLACE TABLE portfolio-project-424902.Project_1.percent_population_vaccinated
AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as INT64)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
FROM
  `portfolio-project-424902.Project_1.covid deaths` dea
JOIN
  `portfolio-project-424902.Project_1.covid vaccinations` vac
ON dea.location = vac.location AND dea.date = vac.date


SELECT
*,
(rolling_vaccinations / population) * 100 AS percent_population_vaccinated
FROM
`portfolio-project-424902.Project_1.percent_population_vaccinated`

 
-- Creating view for demonstration, but i do not have access to my view, nor will I be able to connect to Tableau

DROP TABLE IF EXISTS `portfolio-project-424902.Project_1.percent_population_vaccinated`;
--CREATE VIEW `portfolio-project-424902.Project_1.percent_population_vaccinated` AS
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(Cast(vac.new_vaccinations as INT64)) OVER (Partition by dea.location Order by dea.location, dea.date) as rolling_vaccinations
--FROM
 -- `portfolio-project-424902.Project_1.covid deaths` dea
--JOIN
 -- `portfolio-project-424902.Project_1.covid vaccinations` vac
--ON dea.location = vac.location 
 -- AND dea.date = vac.date
--WHERE
 -- dea.continent IS NOT NULL

-- I am dropping the view to maintain my table code above. I turned the above code into text

--DROP VIEW IF EXISTS `portfolio-project-424902.Project_1.percent_population_vaccinated`

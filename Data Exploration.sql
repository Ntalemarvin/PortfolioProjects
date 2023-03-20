/*
Covid 19 Data Exploration 
Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types ie cast
*/

--SELECT * 
--FROM PortfolioProject..CovidDeaths
--ORDER BY 3,4
--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

-- Total Cases vs Total Deaths
SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases),3)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location LIKE 'uganda'
ORDER BY 1,2

-- Total Cases vs Population
-- shows what percenatge of OverAllpopulation contracted covid
SELECT location, date, total_cases, population, ROUND((total_cases/population),3)*100 AS PercentagePopulationContracted
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'uganda'
ORDER BY 1,2

--Countries with Highest Infection Rate compared  to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, ROUND(MAX((total_cases/population)),3)*100 AS PercentagePopulationContracted
FROM PortfolioProject..CovidDeaths
--WHERE location LIKE 'uganda'
WHERE continent is not null
GROUP BY location, population
ORDER BY PercentagePopulationContracted DESC

-- Countries with Highest Death Count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAK THINGS DOWN BY CONTINENT
-- countries with highest death rate

SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS null
GROUP BY location
ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS
SELECT SUM(new_cases) as total_cases, SUM(CAST(new_deaths AS INT)) as total_deaths, 
ROUND(SUM(CAST(new_deaths AS INT)) /SUM(new_cases) *100,2) AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT null
--GROUP BY date
ORDER BY 1,2 

-- Total Population vs Vacinations
-- USE CTE
WITH Popvsvacc (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS
(
	SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
	SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
	AS RollingPeopleVaccinated
	FROM PortfolioProject ..CovidDeaths death
	JOIN PortfolioProject ..CovidVaccinations vacc
		ON death.date = vacc.date
		AND death.location = vacc.location
	WHERE death.continent IS NOT NULL
	--ORDER BY 1,2,3
)

SELECT * ,ROUND((RollingPeopleVaccinated/population)*100,3) AS PeopleVaccinated
FROM Popvsvacc

--Temp Table
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )

INSERT INTO #PercentPopulationVaccinated
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
AS RollingPeopleVaccinated
FROM PortfolioProject ..CovidDeaths death
	JOIN PortfolioProject ..CovidVaccinations vacc
	ON death.date = vacc.date
	AND death.location = vacc.location
--WHERE death.continent IS NOT NULL
--ORDER BY 1,2,3

SELECT * ,ROUND((RollingPeopleVaccinated/population)*100,3) AS PercentPeopleVaccinated
FROM #PercentPopulationVaccinated

-- Creating View to store for Later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT death.continent, death.location, death.date, death.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS INT)) OVER (PARTITION BY death.location ORDER BY death.location, death.date)
AS RollingPeopleVaccinated
FROM PortfolioProject ..CovidDeaths death
	JOIN PortfolioProject ..CovidVaccinations vacc
	ON death.date = vacc.date
	AND death.location = vacc.location
WHERE death.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated

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

/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

SELECT *
FROM CovidVaccinationsCSV
ORDER BY 3,4


-- Select Data that we are going to be starting with
	
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortofolioProject..CovidDeathsCSV
ORDER BY 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

ALTER TABLE CovidDeathsCSV ALTER COLUMN Total_deaths float

SELECT Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortofolioProject..CovidDeathsCSV
WHERE location like '%states%'
ORDER BY 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

ALTER TABLE CovidDeathsCSV ALTER COLUMN total_cases float

SELECT Location, date, total_cases, Population, (total_cases/population)*100 AS PeopleWhoGotCOVID
FROM PortofolioProject..CovidDeathsCSV
ORDER BY 1,2


-- Countries with Highest Infection Rate compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortofolioProject..CovidDeathsCSV
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


-- Countries with Highest Death Count per Population

SELECT Location, MAX(total_deaths) AS TotalDeathCount
FROM PortofolioProject..CovidDeathsCSV
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population

SELECT continent, MAX(total_deaths) AS TotalDeathCount
FROM PortofolioProject..CovidDeathsCSV
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortofolioProject..CovidDeathsCSV
where continent is not null 
order by 1,2

SELECT *
FROM CovidVaccinationsCSV
ORDER BY 1,2

SELECT *
FROM PortofolioProject..CovidDeathsCSV dea
JOIN PortofolioProject..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	and dea.date = vac.date


-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations
FROM PortofolioProject..CovidDeathsCSV dea
JOIN PortofolioProject..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
FROM PortofolioProject..CovidDeathsCSV dea
JOIN PortofolioProject..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

with PopVsVac (continent, location, date, population, new_Vaccinations, RollingPeopleVaccinated) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
FROM PortofolioProject..CovidDeathsCSV dea
JOIN PortofolioProject..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
SELECT *, (RollingPeopleVaccinated/cast(population as float))*100 AS PercentageRolling
FROM PopVsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date date,
Population Numeric,
New_Vaccinations Numeric,
RollingPeopleVaccinated Numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
FROM PortofolioProject..CovidDeathsCSV dea
JOIN PortofolioProject..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentageRolling
FROM #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_Vaccinations,
SUM(vac.new_vaccinations) OVER(Partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated 
FROM PortofolioProject..CovidDeathsCSV dea
JOIN PortofolioProject..CovidVaccinationsCSV vac
	ON dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
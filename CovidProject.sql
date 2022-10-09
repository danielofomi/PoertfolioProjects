SELECT * 
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject..CovidVaccinations
--ORDER BY 3,4


--SElect Data that we are going to be using

SELECT Location, Date, Total_cases, New_Cases, Total_deaths, population
FROM PortfolioProject..CovidDeaths
where continent is not null
ORDER BY 1,2


-- Looking at Total Cases Vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT Location, Date, Total_cases, Total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
ORDER BY 1,2


-- Looking at total cases vs population
-- SHows what percentage of population gets covid
SELECT Location, Date, population,Total_cases,  (total_cases/population)*100 as CasePerPopulation
FROM PortfolioProject..CovidDeaths
where location like '%states%'
and continent is not null
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as PercentagePopuationInfected
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY Location, Population
ORDER BY PercentagePopuationInfected DESC

-- SHowing Countries with highest death count per population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY Location
ORDER BY TotalDeathCounts DESC


--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is not null
GROUP BY continent
ORDER BY TotalDeathCounts DESC

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCounts
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
where continent is null
GROUP BY location
ORDER BY TotalDeathCounts DESC


--GLOBAL NUMBERS

SELECT SUM(new_cases) as totsl_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


SELECT date, SUM(new_cases) as totsl_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--where location like '%states%'
WHERE continent is not null
GROUP BY date
ORDER BY 1,2


--USE CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3
)
select *, (RollingPeopleVaccinated/population) * 100
From PopvsVac


-- TEMP Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

select *, (RollingPeopleVaccinated/population) * 100
From #PercentPopulationVaccinated


-- Creating view to store data late for visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--ORDER BY 2,3

Select * 
FROM PercentPopulationVaccinated
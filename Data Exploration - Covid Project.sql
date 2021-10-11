
--Data Exploration of covid deaths

SELECT * FROM PortfolioProject..CovidDeaths
ORDER BY 3, 4

--SELECT * FROM PortfolioProject..CovidVaccinations
--ORDER BY 3, 4


--Select data to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2 


-- Looking at Total Cases VS Total Deaths
-- Shows the likelihood of dying if you contract covid in the UK
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'United Kingdom'
ORDER BY 1, 2 


-- Looking at Total Cases VS Population
-- Shows the percentage of the population that have had covid 
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
WHERE Location = 'United Kingdom'
ORDER BY 1, 2 
-- As of the 16th of October 200, 1% of the UK population contracted covid

--Looking at every country now
SELECT Location, date, Population, total_cases, (total_cases/population)*100 AS CasePercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1, 2 


-- Looking at countries with the Highest Infection Rate compared to their Population 
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) AS CasePercentage
FROM PortfolioProject..CovidDeaths
GROUP BY Location, Population
ORDER BY CasePercentage DESC
-- Seychelles has the highest case percentage compared to their population, at 22%, however they also have a low population (approx. 99,000) 
-- Interestingly, the entire continent of Africa has had less infections (X) & also has a lower case percentage (X) than X (X infections, X%)


--Looking at countries with the Highest Death Count per Population
SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC
-- United States has the highest death count with over 700,000 total deaths 
-- The United Kingdom is ranked 8th, with a total death count of approx. 138,000


-- Breaking it down by continent 
-- Looking at continents with highest death count
SELECT location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC 
-- Highest death count is in Europe, with approx. 1.2 million deaths



--Cumulative Global Numbers over time 
SELECT date, SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent  IS NOT NULL
GROUP BY date 
ORDER BY 1, 2 

--Total Global Numbers
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths AS INT)) AS TotalDeaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent  IS NOT NULL
ORDER BY 1, 2 
-- ~237 million global cases 
-- ~4.8 million deaths globally (2.04% of those who were infected) 



--Joining the deaths table with the vaccinations table 
SELECT * 
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date



-- Looking at Total Population VS Vaccinations 

SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL 
ORDER BY 2, 3


-- Creating a column for the rolling total over time 
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS TotalVaccinated
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL 
ORDER BY 2, 3


-- Using a CTE 
WITH PopvsVac (Continent, Location, date, Population, New_Vaccinations, TotalVaccinated)
AS
(SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS TotalVaccinated
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL)
SELECT * , (TotalVaccinated/Population)*100 AS PercentVaccinated
FROM PopvsVac


-- Using a TEMP TABLE 
CREATE TABLE #PercentPopulationVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
TotalVaccinated NUMERIC
)

INSERT INTO #PercentPopulationVaccinated
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS TotalVaccinated
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL 

SELECT * , (TotalVaccinated/Population)*100 AS PercentVaccinated
FROM #PercentPopulationVaccinated 



-- Creating a view to store for later visualisations 

CREATE VIEW PercentPopulationVaccinated AS 
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS TotalVaccinated
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated 


-- Forgot to add the percentage column
DROP VIEW IF EXISTS PercentPopulationVaccinated

CREATE VIEW PercentPopulationVaccinated AS 
SELECT Deaths.continent, Deaths.location, Deaths.date, Deaths.population, Vacc.new_vaccinations,
SUM(cast(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date) AS TotalVaccinated,
SUM(cast(Vacc.new_vaccinations AS INT)) OVER (PARTITION BY Deaths.location ORDER BY Deaths.location, Deaths.date)/population*100 AS PercentVaccinated
FROM PortfolioProject..CovidDeaths AS Deaths
JOIN PortfolioProject..CovidVaccinations AS Vacc
	ON Deaths.location = Vacc.location
	AND Deaths.date = Vacc.date
WHERE Deaths.continent IS NOT NULL

SELECT * FROM PercentPopulationVaccinated 


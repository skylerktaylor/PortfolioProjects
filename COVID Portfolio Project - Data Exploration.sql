SELECT *
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 3,4;

-- SELECT *
-- FROM COVID_VACCINATIONS
-- ORDER BY 3,4

-- Select the data that we are going to be using 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentages
FROM covid_deaths
WHERE location like '%States%' 
And continent IS NOT NULL
ORDER BY 1,2;

-- Looking at the Total Cases vs Population
-- Shows what percentage of the population got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
FROM covid_deaths
WHERE location like '%States%' 
AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at counties that have the highest infection rate compare to population

SELECT location, population, Max(total_cases) as HighestInfectioncount , Max((total_cases/population))*100 as PercentPopulationInfected
FROM covid_deaths
WHERE continent IS NOT NULL
-- WHERE location like '%States%'
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;

-- Showing Counties with the Hightest Death Count per Population 

SELECT location, Max(total_deaths) as TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL
-- WHERE location like '%States%'
GROUP BY location
ORDER BY TotalDeathCount DESC;

-- LET'S BREAK DOWN BY CONTINENT

-- Showing the continents with the hightest death count per population

SELECT continent, Max(total_deaths) as TotalDeathCount
FROM covid_deaths
WHERE continent IS NOT NULL and total_deaths IS NOT NULL
-- WHERE continent like '%States%'
GROUP BY continent
ORDER BY TotalDeathCount DESC;

-- Global Numbers

SELECT  SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths,SUM(new_deaths)/SUM(new_cases)* 100 as DeathPercentages
FROM covid_deaths
-- WHERE location like '%States%' 
Where continent IS NOT NULL 
--GROUP BY date
ORDER BY 1,2;

-- Looking at Total population vs Population

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY dea.location, dea.date)
AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/dea.population)* 100
FROM covid_deaths dea
JOIN covid_vaccinations vac
ON dea.location = vac.location
Where dea.continent IS NOT NULL and vac.new_vaccinations is NOT NULL
AND dea.date = vac.date
ORDER BY 2,3;

-- USE CTE

WITH PopvsVac 
AS 
(
    SELECT
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM covid_deaths dea
    JOIN covid_vaccinations vac
    ON dea.location = vac.location
    WHERE dea.continent IS NOT NULL 
    AND dea.date = vac.date
)
SELECT *, (PopvsVac.RollingPeopleVaccinated / PopvsVac.population) * 100 AS PercentPopulationVaccinated
FROM PopvsVac;


-- TEMP TABLE
DROP TEMPORARY TABLE if exists PercentPopulationVaccinated
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
    continent VARCHAR(250),
    location VARCHAR(255), 
    Date date, 
    Population numeric, 
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO PercentPopulationVaccinated
(
    SELECT
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM covid_deaths dea
    JOIN covid_vaccinations vac
    ON dea.location = vac.location
    WHERE dea.continent IS NOT NULL 
    AND dea.date = vac.date
);

SELECT *, (RollingPeopleVaccinated/population)*100 AS PercentRollingVaccinated
FROM PercentPopulationVaccinated;

-- Creating View to Store Data for later visualizations

CREATE VIEW PercentPopulationVaccinated
AS SELECT
        dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations, 
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
    FROM covid_deaths dea
    JOIN covid_vaccinations vac
    ON dea.location = vac.location
	AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL 
 
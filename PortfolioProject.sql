USE Covid;
-- LOAD DATA INFILE '/users/leonie/desktop/covidvaccinations.csv'
-- INTO TABLE covid.Covidvaccinations
-- FIELDS TERMINATED BY ',' 
-- ENCLOSED BY '"' 
-- IGNORE 1 LINES;

-- looking at total cases vs total deaths
-- shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 AS percentage_of_death
FROM coviddeath
WHERE location LIKE '%asia%'
ORDER BY 1,2;

-- looking at total cases vs population
-- show what percentage of population got covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS percentage_of_cases
FROM coviddeath
WHERE location LIKE '%asia%'
ORDER BY 1,2;


-- Looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM coviddeath
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC;


-- showing countries with highest death count per population
SELECT location, population, MAX(total_deaths) AS HighestDeathCount, MAX((total_deaths/population))*100 AS PercentPopulationDeath
FROM coviddeath
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationDeath DESC;


-- let's break things down by continent
-- showing continents with the highest death count per population
SELECT continent, MAX(total_deaths) AS HighestDeathCount
FROM coviddeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount DESC;

-- global numbers
SELECT date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage 
FROM coviddeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- just show the total new cases and new deaths across the world
SELECT SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage 
FROM coviddeath
WHERE continent IS NOT NULL
ORDER BY 1,2;


-- looking at total population vs vaccinations
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations 
FROM CovidVaccinations cv
JOIN coviddeath cd
   ON cv.location = cd.location
   AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3;


-- Want to show a rolling count
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
                SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM CovidVaccinations cv
JOIN coviddeath cd
   ON cv.location = cd.location
   AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3;

-- USE CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated) AS
(SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
                SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM CovidVaccinations cv
JOIN coviddeath cd
   ON cv.location = cd.location
   AND cv.date = cd.date
WHERE cd.continent IS NOT NULL
ORDER BY 1,2,3
)
SELECT *, (rollingpeoplevaccinated/population)*100
FROM PopVsVac;


-- TEMP TABLE
DROP TABLE IF EXISTS PercentagePopulationVavvinated;
CREATE TABLE PercentagePopulationVavvinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
);
INSERT INTO PercentagePopulationVavvinated
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
                SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM CovidVaccinations cv
JOIN coviddeath cd
   ON cv.location = cd.location
   AND cv.date = cd.date
WHERE cd.continent IS NOT NULL;
-- ORDER BY 1,2,3;
SELECT *, (rollingpeoplevaccinated/population)*100
FROM PercentagePopulationVavvinated;


-- Creating View to store data for later visualization
CREATE VIEW PercentagePopulationVaccinated AS
SELECT DISTINCT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
                SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS rolling_people_vaccinated
FROM CovidVaccinations cv
JOIN coviddeath cd
   ON cv.location = cd.location
   AND cv.date = cd.date
WHERE cd.continent IS NOT NULL;
-- ORDER BY 1,2,3;
SELECT *
FROM PercentagePopulationVaccinated;






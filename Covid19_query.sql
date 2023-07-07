--Covid 19 Data Exploration

SELECT * 
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 3,4


-- Data with we are going to start

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2


-- Total cases vs Total deaths in India based on date


SELECT location, date, total_cases, CAST(total_deaths AS INT), (total_deaths/total_cases)*100 AS death_percentage
FROM covid_deaths
WHERE location = 'India'


-- Total cases vs total deaths in world based on date


SELECT Location, date, total_cases, CAST(total_deaths AS INT), (total_deaths/total_cases)*100 AS death_percentage
From covid_deaths
WHERE continent IS NOT NULL 
ORDER BY 1,2


/* Total cases vs population to Show what percentage of population infected with Covid based on date */
-- 1. In India


SELECT location, date, CAST(population AS INT), total_cases, (total_cases/population)*100 AS infected_population_percentage
FROM covid_deaths
WHERE location = 'India'
ORDER BY 2


-- 2. In World


SELECT location, date, CAST(population AS BIGINT), total_cases, (total_cases/population)*100 AS infected_population_percentage
FROM covid_deaths
WHERE location IS NOT NULL
ORDER BY 1,2


-- Higest infection count in India compared to population


SELECT CAST(population AS BIGINT), MAX(total_cases) AS highest_infection_count, MAX((total_cases/population)*100) AS highest_infected_percentage
FROM covid_deaths
WHERE location = 'India'
GROUP BY population


-- Countries with Highest Infection rate compared to population


SELECT location, CAST(population AS BIGINT), MAX(total_cases) AS highest_infection_count, MAX((total_cases/population)*100) AS highest_infected_percentage
FROM covid_deaths
WHERE location IS NOT NULL AND total_cases>=1
GROUP BY location,population
ORDER BY highest_infected_percentage DESC


-- Countries with Highest Death Count per Population


SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL AND total_deaths>=1
GROUP BY location
ORDER BY total_death_count DESC


-- Asia Contintent with the highest death count per population


SELECT location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
WHERE continent LIKE 'Asia' 
GROUP BY location
ORDER BY total_death_count DESC


-- Contintents with the highest death count per population


SELECT continent, location, MAX(CAST(total_deaths AS INT)) AS total_death_count
FROM covid_deaths
WHERE continent IS NOT NULL
GROUP BY continent, location
ORDER BY total_death_count DESC


-- Total no. of cases, deaths and their percentage in World


SELECT SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, SUM(CAST(new_deaths AS NUMERIC))/SUM(new_cases)*100 AS death_percentage
FROM covid_deaths
WHERE continent IS NOT NULL


-- Total Population vs Vaccinationed people in Every Country(location) until now


SELECT cd.location, CAST(cd.population AS BIGINT), MAX(cv.total_vaccinations) 
FROM covid_deaths AS cd
INNER JOIN covid_vaccinations AS cv
ON cd.location = cv.location
GROUP BY 1,2
ORDER BY 1



-- No. of Population that has recieved at least one Covid Vaccine


SELECT cd.continent, cd.location, cd.date, CAST(cd.population AS BIGINT), cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.Date) AS RollingPeopleVaccinated
FROM covid_deaths AS cd
JOIN covid_vaccinations AS cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query


WITH Pop_vs_Vac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS (SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations,
	SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingPeopleVaccinated
	FROM covid_deaths AS cd
	JOIN covid_vaccinations AS cv
	ON cd.location = cv.location 
	AND cd.date = cv.date
	WHERE cd.continent IS NOT NULL
	GROUP BY 1,2,3,4,5
	ORDER BY 2,3
	)
SELECT *, (RollingPeopleVaccinated/population)*100 AS Vaccination_percentage
FROM Pop_vs_Vac


-- Creating View to store data for later visualizations


CREATE VIEW PopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(cv.new_vaccinations) OVER (PARTITION BY cd.Location ORDER BY cd.location, cd.Date) AS RollingPeopleVaccinated
FROM covid_deaths cd
JOIN covid_vaccinations cv
ON cd.location = cv.location
AND cd.date = cv.date
WHERE cd.continent IS NOT NULL 
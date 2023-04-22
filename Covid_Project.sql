
--  ANALYSING COVID DATA 

/*  
	The Covid-19 pandemic is the most important health disaster that has surrounded the world for the 3 years.
    In this study, data of COVID-19 between 1/1/2020 and 9/9/2020 for India ,USA, Germany and the global was obtained from 'ourworldindata'.
*/

-- We have two tables

SELECT * FROM CovidDeaths;
SELECT * FROM covidvaccinations;

-- Renamed column name 

ALTER TABLE coviddeaths
RENAME COLUMN ï»¿iso_code to  iso_code;

ALTER TABLE covidvaccinations
RENAME COLUMN ï»¿iso_code to  iso_code;

SELECT * FROM coviddeaths;



-- Filter out the data so we are gonna work with that.

SELECT
	continent,
    location,
    date,
    population,
    total_cases,
    total_deaths
FROM
	coviddeaths
WHERE continent <> '';



-- Checking how many continents we have in our data.
SELECT
	DISTINCT(continent)
FROM
	coviddeaths;
    
-- Checking how many countries we have in our data.
SELECT
	DISTINCT(location)
FROM
	coviddeaths;


-- Let's see the minimum and maximum date in our dataset

SELECT 
    MIN(date) AS min_date,
    MAX(date) AS max_date
FROM
    coviddeaths;




    
-- Observing total cases and total deaths due to covid

SELECT
    SUM(total_cases),
    SUM(total_deaths)
FROM
	coviddeaths;
  
  
  
  
  
-- Looking at Total case vs Total deaths and percentage of death.
-- Showing liklihood of dying if you contract with covid in your country.
  
SELECT
	continent,
    location,
    date,
    population,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS DeathPercentage
FROM
	coviddeaths
WHERE continent <> '';  
  
  
  
  
-- Looking into covid details of India.  
  
SELECT
	continent,
    location,
    date,
    population,
    total_cases,
    total_deaths,
    (total_deaths/total_cases)*100 AS DeathPercentage
FROM
	coviddeaths
WHERE 
	location = 'India'
    AND continent <> '';
    





-- Let's see percentage of people got covid
    
SELECT
    location,
    date,
    population,
    total_cases,
    (total_cases/population)*100 AS DeathPercentage
FROM
	coviddeaths
WHERE continent <> ''
ORDER BY  location, DeathPercentage; 






-- Looking at countries with highest infection rate compared to poulation.

SELECT
    location,
    population,
    MAX(total_cases) AS InfectionCount,
    MAX((total_cases)/population)*100 AS PercentagePopulationInfected
FROM
	coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY PercentagePopulationInfected DESC;




-- Showing countries with highest death count per population

SELECT
    location,
    population,
	MAX(total_deaths) AS HighestDeathCount
FROM
	coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY HighestDeathCount DESC;






-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with highest death count per population and highest death percentage per population.
 
SELECT
	*,
    (HighestDeathCount/population)*100 AS DeathPercentagePopulation
FROM
(SELECT
    location,
    population,
	MAX(total_deaths) AS HighestDeathCount
FROM
	coviddeaths
WHERE continent = ''
GROUP BY location
ORDER BY HighestDeathCount DESC) AS A
WHERE location NOT IN ('World' , 'International')
ORDER BY DeathPercentagePopulation DESC;





-- 	GLOBAL NUMBERS

-- Let's see total death percentage due to covid.

SELECT
	SUM(new_cases) AS TotalCases,
	SUM(new_deaths) AS TotalDeaths,
    (SUM(new_deaths)/SUM(new_cases))*100 AS TotalDeathPercentage
FROM
	coviddeaths
WHERE continent <> ''
ORDER BY TotalCases;






-- Showing rolling sum of vaccinated people and rolling percentage of vaccinated people.


SELECT
	cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) AS RollingPeopleVaccinated
FROM
	coviddeaths cd
	JOIN
    covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent <> ''
ORDER BY 1,2,3;


-- Doing further calculations by the use of CTE

WITH PopVsVac (continent , location , date, population , new_vaccinations , RollingPeopleVaccinated) AS 
(SELECT
	cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) AS RollingPeopleVaccinated
FROM
	coviddeaths cd
	JOIN
    covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent <> ''
ORDER BY 1,2,3)
SELECT 
	*,
    (RollingPeopleVaccinated/population)*100 AS RollingPercentagePeopleVac
FROM PopVsVac;



-- We can also use Temp table to do further calculations

DROP TABLE IF EXISTS PercentPeopleVaccinated;
CREATE TABLE PercentPeopleVaccinated
(
	continent nvarchar(255),
    location nvarchar(255),
    date text,
    population BIGINT,
    new_vaccinations INT,
    RollingPeopleVaccinated INT
);

INSERT INTO PercentPeopleVaccinated
SELECT
	cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) AS RollingPeopleVaccinated
FROM
	coviddeaths cd
	JOIN
    covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent <> ''
ORDER BY 1,2,3;

SELECT 
	*,
    (RollingPeopleVaccinated/population)*100 AS PercentagePeopleVaccinated
FROM 
	PercentPeopleVaccinated;
    
    
    



/* Creating views to store data for later visualizations */




-- 1. Storing rolling percentage of population vaccinated

CREATE VIEW PercentPopulationVaccinated AS 
SELECT
	cd.continent,
    cd.location,
    cd.date,
    cd.population,
    cv.new_vaccinations,
    SUM(new_vaccinations) OVER (PARTITION BY cd.location ORDER BY cd.location , cd.date) AS RollingPeopleVaccinated
FROM
	coviddeaths cd
	JOIN
    covidvaccinations cv ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent <> ''
ORDER BY 1,2,3;

SELECT * FROM PercentPopulationVaccinated;





-- 2. Storing latest percentage of death

CREATE VIEW LatestDeathPercentage AS 
SELECT
	SUM(new_deaths) AS TotalDeaths,
    SUM(new_cases) AS TotalCases,
    (SUM(new_deaths)/SUM(new_cases))*100 AS TotalDeathPercentage
FROM
	coviddeaths
WHERE continent <> ''
order by TotalCases;




-- 3. creating view to store information about continent wise highest death count and death percentage.

CREATE VIEW Continent_DeathPercentagePopulation AS
SELECT
	*,
    (HighestDeathCount/population)*100 AS DeathPercentagePopulation
FROM
(SELECT
    location,
    population,
	MAX(total_deaths) AS HighestDeathCount
FROM
	coviddeaths
WHERE continent = ''
GROUP BY location
ORDER BY HighestDeathCount DESC) AS A
WHERE location NOT IN ('World' , 'International')
ORDER BY DeathPercentagePopulation DESC;




-- 4. Creating view to showcase countries wise highest death count.

DROP VIEW IF EXISTS Country_highestDeathCount;
CREATE VIEW Country_highestDeathCount AS 
SELECT
    location,
    population,
	MAX(total_deaths) AS HighestDeathCount
FROM
	coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY HighestDeathCount DESC;

SELECT * FROM Country_highestDeathCount;




-- 5. View to show what percentage of population got covid in terms of countries

CREATE VIEW Country_PctPopulationInfected AS
SELECT
    location,
    population,
    MAX(total_cases) AS InfectionCount,
    MAX((total_cases)/population)*100 AS PercentagePopulationInfected
FROM
	coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY PercentagePopulationInfected DESC;





-- This is some useful views that basically helps us to create visulization.

SELECT * FROM PercentPopulationVaccinated ;
SELECT * FROM LatestDeathPercentage ;
SELECT * FROM Continent_DeathPercentagePopulation ;
SELECT * FROM Country_highestDeathCount ;
SELECT * FROM Country_PctPopulationInfected ;

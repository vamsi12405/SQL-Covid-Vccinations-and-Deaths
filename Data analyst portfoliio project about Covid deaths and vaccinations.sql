-- Look at the tables we ae working on

SELECT * FROM CovidDeaths;

SELECT * FROM CovidVaccinations;

-- Select data and order by the first four columns 
SELECT * FROM CovidDeaths ORDER BY 3,4

SELECT * FROM CovidVaccinations ORDER BY 3,4;

-- Select data that we are going to be using 
SELECT Location,date,total_cases,new_cases,total_deaths , population 
FROM CovidDeaths 
ORDER BY 1,2;

-- Looking at Total cases vs Total deaths 
-- Shows likelihood of dying of you contract covid in your country
SELECT Location,date,total_cases,total_deaths ,(total_cases/total_deaths)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location LIKE '%India%'
ORDER BY 1,2;

-- Looking at total cases vs population
-- Shows What percentage of population got covid
SELECT Location,date,population,total_cases,(total_cases/total_deaths)*100 AS DeathPercentage
FROM CovidDeaths
WHERE Location LIKE '%India%'
ORDER BY 1,2;

-- Looking at countries with highest infection rate compared to population 
SELECT Location,population,MAX(total_cases) AS HighestInfectionCount ,MAX((total_cases/population))*100 AS PercentagePopulationInfected 
FROM CovidDeaths  
GROUP BY Location,Population 
ORDER BY MAX((total_cases/population))*100 DESC;

-- Showing countries with highest death count per population
SELECT Location,MAX(CAST(total_deaths AS INT)) AS totaldeathcount 
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location

-- Let's break things down by continent
SELECT continent,MAX(CAST(total_deaths AS INT)) AS TotalDeathCount 
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY MAX(CAST(total_deaths AS INT)) DESC;

-- Showing continents with highest death count per population
SELECT continent,MAX(CAST(total_deaths AS INT)) AS Totaldeathcount
FROM CovidDeaths 
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Totaldeathcount DESC;

-- Global Numbers
SELECT date,SUM(new_cases) AS new_cases,SUM(CAST(new_deaths AS INT)) AS new_deaths,SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Looking at total population vs vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER(PARTITION BY dea.Location ORDER BY dea.Location,dea.date) 
AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

-- -- Using CTE to perform Calculation on Partition By in previous query
;WITH PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL
)
SELECT * , (RollingPeopleVaccinated/population)*100 
FROM PopvsVac;

-- Using Temp Table to perform Calculation on Partition By in previous query
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated 
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.Location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL

SELECT * , (RollingPeopleVaccinated/population)*100 FROM #PercentPopulationVaccinated;

-- Create view to store data for later visualization 
GO
CREATE VIEW PercentPopulationVacccinated AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS INT)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) 
AS RollingPeopleVAccinated
FROM CovidDeaths AS dea
JOIN CovidVaccinations AS vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
);
GO

SELECT * FROM PercentPopulationVacccinated;
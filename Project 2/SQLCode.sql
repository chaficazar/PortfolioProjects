-- Query 1
-- Looking at total_cases, new_cases, total_deaths and population per country

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
WHERE iso_code IS NOT NULL
ORDER BY 1, 2;

-- Query 2
-- Looking at Total Cases vs. Total Deaths in Lebanon

SELECT	location,
		date, 
		total_cases, 
		cast(total_deaths as bigint) AS total_deaths, 
		(cast(total_deaths as bigint)/total_cases)*100 AS DeathPerc
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE 'Lebanon'
ORDER BY 1, 2;

-- Query 3
-- Finding max death rate in Lebanon using Query 2 as a CTE and the corresponding date: 11 & 12 March 2020

WITH HighestDeathsLeb AS
(SELECT	location, 
		date, 
		total_cases,
		cast(total_deaths as bigint) AS TotDeaths, 
		(cast(total_deaths as bigint)/total_cases)*100 AS DeathPerc
FROM PortfolioProject1..CovidDeaths
WHERE location LIKE 'Lebanon')

SELECT date, DeathPerc
FROM HighestDeathsLeb
WHERE DeathPerc = (SELECT MAX(DeathPerc) FROM HighestDeathsLeb)

-- Query 4
-- Finding country with highest infection rate globally: Faroe Islands

WITH InfectedPopulation AS
(SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopInfected
FROM PortfolioProject1..CovidDeaths
GROUP BY location, date, total_cases, population)

SELECT DISTINCT location, PopInfected
FROM InfectedPopulation
WHERE PopInfected = (SELECT MAX(PopInfected) FROM InfectedPopulation);

-- Query 5
-- Looking at the highest infection rate worldwide

WITH InfectedPopulation AS
(SELECT location, date, total_cases, population, (total_cases/population)*100 AS PopInfected
FROM PortfolioProject1..CovidDeaths
GROUP BY location, date, total_cases, population)

SELECT DISTINCT location, MAX(PopInfected) AS Max_Pop_InfectionRate_Globally
FROM InfectedPopulation
WHERE location = 'World'
GROUP BY location

-- Query 6
-- Looking at Countries with Highest Infection Rate

SELECT DISTINCT continent, location, MAX(total_cases) AS HighestInfCount, population, MAX((total_cases/population))*100 AS MaxPopInfected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population
ORDER BY MaxPopInfected DESC

-- Query 7
-- Looking at highest infection rates per continent

DROP VIEW IF EXISTS A;
GO
CREATE VIEW A AS
WITH MaxInfRates AS
(SELECT DISTINCT continent, location, MAX(total_cases) AS HighestInfCount, population, MAX((total_cases/population))*100 AS MaxPopInfected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population)

SELECT continent, MAX(MaxPopInfected) AS MaxContInfRate
FROM MaxInfRates
GROUP BY continent
GO

DROP VIEW IF EXISTS B;
GO
CREATE VIEW B AS
WITH MaxInfRates AS
(SELECT DISTINCT continent, location, MAX(total_cases) AS HighestInfCount, population, MAX((total_cases/population))*100 AS MaxPopInfected
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location, population)

SELECT continent, location, MAX(MaxPopInfected) AS MaxContInfRate
FROM MaxInfRates
GROUP BY continent, location
GO

SELECT B.continent, B.location, B.MaxContInfRate
FROM B
INNER JOIN A
ON B.continent = A.continent AND B.MaxContInfRate = A.MaxContInfRate
ORDER BY MaxContInfRate DESC

-- Query 8
-- Looking at Countries with the highest Death count

SELECT location, MAX(cast(total_deaths as bigint)) AS TotalDeathCount
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Query 9
-- Looking at total_deaths by continent

WITH CountryMaxDeaths AS
(SELECT continent, location, MAX(cast(total_deaths as bigint)) AS MaxDeaths
FROM PortfolioProject1..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent, location)

SELECT continent, SUM(MaxDeaths) AS TotalDeaths
FROM CountryMaxDeaths
GROUP BY continent
ORDER BY TotalDeaths DESC

-- Query 10
-- GLOBAL NUMBERS

SELECT	SUM(new_cases) AS total_cases, 
		ROUND((MAX(total_cases)/population), 4)*100 AS GlobalInfRate,
		SUM(cast(new_deaths as int)) AS total_deaths, 
		ROUND(SUM(cast(new_deaths as int))/SUM(new_cases), 4)*100 AS DeathPerc
FROM PortfolioProject1..CovidDeaths
WHERE location = 'World'
GROUP BY population
ORDER BY 1, 2;

-- Query 11
-- Looking at total population vs. vaccinations (Rolling Vaccination count) in each country

SELECT	dea.continent, dea.location, dea.date, population, CAST(vac.new_vaccinations AS bigint) AS new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY vac.location ORDER BY vac.date) AS RollingVacCount
FROM PortfolioProject1..CovidDeaths AS dea
INNER JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY vac.location, vac.date

-- Rolling vaccination count globally

SELECT	dea.location,
		dea.date, population,
		CAST(vac.new_vaccinations AS bigint) AS new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY vac.location ORDER BY vac.date) AS RollingVacCount
FROM PortfolioProject1..CovidDeaths AS dea
INNER JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.location = 'World'
ORDER BY vac.location, vac.date

-- Query 12
-- Calculating rate of vaccination in each country
-- Looking at new_vaccinations, 

DROP VIEW IF EXISTS VaccinationRates;
GO
CREATE VIEW VaccinationRates AS
WITH VacPopRate AS
(SELECT	dea.continent, 
		dea.location, 
		dea.date, 
		population, 
		CAST(vac.new_vaccinations AS bigint) AS new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY vac.location ORDER BY vac.date) AS RollingVacCount,
		CAST(vac.people_vaccinated AS bigint) AS people_vaccinated,
		CAST(vac.people_fully_vaccinated AS bigint) AS people_fully_vaccinated
FROM PortfolioProject1..CovidDeaths AS dea
INNER JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date)

SELECT	continent, 
		location, 
		date, 
		population, 
		new_vaccinations,
		RollingVacCount, 
		people_vaccinated,
		(people_vaccinated/population)*100 AS PercPopVaccinated,
		people_fully_vaccinated,
		(people_fully_vaccinated/population)*100 AS PercPopFullyVaccinated
FROM VacPopRate
GO

-- Query 13
-- Global People Vaccination rates

WITH VacPopRate2 AS
(SELECT	dea.continent, 
		dea.location, 
		dea.date, 
		population, 
		CAST(vac.new_vaccinations AS bigint) AS new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY vac.location ORDER BY vac.date) AS RollingVacCount,
		CAST(vac.people_vaccinated AS bigint) AS people_vaccinated,
		CAST(vac.people_fully_vaccinated AS bigint) AS people_fully_vaccinated
FROM PortfolioProject1..CovidDeaths AS dea
INNER JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date)

SELECT	vac.location,
		dea.population,
		MAX(people_vaccinated) AS TotalPeopleVaccinated,
		MAX((people_vaccinated/dea.population))*100 AS PercPopVaccinated,
		MAX(people_fully_vaccinated) AS TotalPeopleFullyVaccinated,
		MAX((people_fully_vaccinated/dea.population))*100 AS PercPopFullyVaccinated
FROM VacPopRate2 AS vac
INNER JOIN PortfolioProject1..CovidDeaths AS dea
ON vac.location = dea.location
WHERE vac.location = 'World'
GROUP BY vac.location, dea.population

-- Query 14
-- Global Vaccination rates, infection rates and Death Rates

DROP VIEW IF EXISTS GlobalNumbers;
GO
CREATE VIEW GlobalNumbers AS
(SELECT	dea.location,
		dea.date,
		dea.total_cases,
		(total_cases/population)*100 AS InfRate,
		CAST(dea.total_deaths AS bigint) AS total_deaths,
		(CAST(dea.total_deaths AS bigint)/dea.total_cases)*100 AS DeathRate,
		CAST(vac.people_vaccinated AS bigint) AS people_vaccinated,
		(CAST(vac.people_vaccinated AS bigint)/population)*100 AS PercPeopleVaccinated,
		CAST(vac.people_fully_vaccinated AS bigint) AS people_fully_vaccinated,
		(CAST(vac.people_fully_vaccinated AS bigint)/population)*100 AS PercPeopleFullyVacccinated
FROM PortfolioProject1..CovidDeaths AS dea
INNER JOIN PortfolioProject1..CovidVaccinations AS vac
ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.location = 'World')
GO

SELECT * 
FROM GlobalNumbers
ORDER BY date

-- Query 15
-- Looking at highest vaccination rates among populations

SELECT	location, 
		MAX(PercPopVaccinated) AS VaccinatedPopulationRate, 
		MAX(PercPopFullyVaccinated) AS FullyVaccinatedPopulationRate
FROM VaccinationRates
WHERE PercPopVaccinated IS NOT NULL
GROUP BY location
HAVING MAX(PercPopVaccinated) < 100
ORDER BY VaccinatedPopulationRate DESC

-- Query 16
-- Looking at percentage of vaccinated population who are fully vaccinated

WITH VaccinationRateByCountry AS
	(SELECT	location, 
			MAX(PercPopVaccinated) AS VaccinatedPopulationRate, 
			MAX(PercPopFullyVaccinated) AS FullyVaccinatedPopulationRate
	FROM VaccinationRates
	WHERE PercPopVaccinated IS NOT NULL
	GROUP BY location
	HAVING MAX(PercPopVaccinated) < 100),
TotalDeathsByCountry AS
	(SELECT	location, 
			MAX(cast(total_deaths as bigint)) AS TotalDeathCount
	FROM PortfolioProject1..CovidDeaths
	WHERE continent IS NOT NULL
	GROUP BY location)
SELECT	a.location,
		a.VaccinatedPopulationRate,
		a.FullyVaccinatedPopulationRate,
		(b.FullyVaccinatedPopulationRate/a.VaccinatedPopulationRate)*100 AS PercOptedForBooster
FROM VaccinationRateByCountry AS a
INNER JOIN VaccinationRateByCountry AS b
ON a.location = b.location
ORDER BY PercOptedForBooster

-- Query 17
-- Looking at lowest vaccination rates among populations and the rate of extreme poverty

SELECT	vac1.location, 
		MAX(PercPopVaccinated) AS VaccinatedPopulationRate,
		MAX(PercPopFullyVaccinated) AS FullyVaccinatedPopulationRate, 
		extreme_poverty
FROM VaccinationRates AS vac1
INNER JOIN PortfolioProject1..CovidVaccinations AS vac2
ON vac1.location = vac2.location
WHERE PercPopVaccinated IS NOT NULL AND vac1.continent IS NOT NULL
GROUP BY vac1.location, extreme_poverty
HAVING MAX(PercPopVaccinated) < 100
ORDER BY VaccinatedPopulationRate

-- Query 18
-- Looking at countries with extreme poverty rates

SELECT	location, 
		MAX(cast(extreme_poverty as float)) AS MaxExtremePoverty
		FROM PortfolioProject1..CovidVaccinations 
GROUP BY location, extreme_poverty
ORDER BY MaxExtremePoverty DESC

-- Query 19
-- Looking at hospitalization rates per country where data is available

DROP VIEW IF EXISTS Hospitalizations;
GO
CREATE VIEW Hospitalizations AS 
(SELECT	location,
		date,
		icu_patients,
		SUM(CAST(icu_patients AS float)) OVER (PARTITION BY location ORDER BY date) AS Rolling_ICU_Patients,
		new_cases,
		SUM(CAST(new_cases AS float)) OVER (PARTITION BY location ORDER BY date) AS RollingNewCases,
		(SUM(CAST(icu_patients AS float)) OVER (PARTITION BY location ORDER BY date)/SUM(CAST(new_cases AS float)) OVER (PARTITION BY location ORDER BY date))*100 AS HospRate
FROM PortfolioProject1..CovidDeaths
WHERE icu_patients IS NOT NULL AND new_cases <> 0 AND location IS NOT NULL)
GO

-- Query 20
-- Looking at global hospitalization rate by day -- ICU data in database not accurate

SELECT	h.date,
		SUM(CAST(h.icu_patients AS bigint)) AS Total_ICU_Patients,
		cd.total_cases,
		SUM(CAST(h.icu_patients AS int))/cd.total_cases*100 AS GlobalHospRate
FROM Hospitalizations AS h
INNER JOIN PortfolioProject1..CovidDeaths AS cd
ON h.date = cd.date
WHERE cd.location = 'World'
GROUP BY h.date, cd.total_cases
ORDER BY h.date

-- Query 21
-- Highest Hospitalization rates

SELECT	h.location, 
		AVG(HospRate) AS AvgHospRate,
		AVG(CAST(total_deaths AS bigint)/total_cases)*100 AS AvgDeathRate
FROM Hospitalizations AS h
INNER JOIN PortfolioProject1..CovidDeaths AS cd
ON h.location = cd.location
GROUP BY h.location
ORDER BY AvgHospRate DESC

-- Query 22
-- Global Hopitalizations

SELECT SUM(CAST(icu_patients AS bigint)) AS GlobalHospitalizations
FROM Hospitalizations

-- Query 23
-- Finding dates where first vaccinations occurred by country ordered by First Vaccination Date

DROP VIEW IF EXISTS FirstVaccinationDate;
GO
CREATE VIEW FirstVaccinationDate AS
WITH FirstVaccinationDates AS
(SELECT	location, date, new_vaccinations,
		CASE
			WHEN	new_vaccinations <> 0 AND
					lead(new_vaccinations) OVER (PARTITION BY location ORDER BY date) IS NOT NULL
					AND lag(new_vaccinations) OVER (PARTITION BY location ORDER BY date) IS NULL
					THEN 1
					ELSE NULL
		END AS flag
FROM PortfolioProject1..CovidVaccinations)

SELECT location, MIN(date) AS FirstVaccinationDate
FROM FirstVaccinationDates
WHERE flag = 1
GROUP BY location
GO

SELECT *
FROM FirstVaccinationDate
ORDER BY FirstVaccinationDate

-- Query 24
-- Looking at Infection rates and death rates before and after the vaccine rollout

SELECT	location, -- Before vaccine rollout
		ROUND(AVG(InfRate), 2) AS AvgInfRate,
		ROUND(MAX(InfRate), 2) AS MaxInfRate,
		ROUND(AVG(DeathRate), 2) AS AvgDeathRate,
		ROUND(MAX(DeathRate), 2) AS MaxDeathRate,
		ROUND(MAX(PercPeopleVaccinated), 2) AS MaxPercPeopleVaccinated
FROM GlobalNumbers
WHERE date BETWEEN '2020-01-22' AND '2020-12-01'
GROUP BY location
UNION
SELECT	location, -- After vaccine rollout
		ROUND(AVG(InfRate), 2) AS AvgInfRate,
		ROUND(MAX(InfRate), 2) AS MaxInfRate,
		ROUND(AVG(DeathRate), 2) AS AvgDeathRate,
		ROUND(MAX(DeathRate), 2) AS MaxDeathRate,
		ROUND(MAX(PercPeopleVaccinated), 2) AS MaxPercPeopleVaccinated
FROM GlobalNumbers
WHERE date BETWEEN '2020-12-02' AND '2022-04-01'
GROUP BY location

-- Query 25
-- Looking at positive tests rate by country

SELECT	cv.location,
		MAX(CAST(total_tests AS bigint)) AS TotalTests,
		MAX(total_cases) AS TotalCases,
		MAX(total_cases)/MAX(CAST(total_tests AS bigint))*100 AS PosRate
FROM PortfolioProject1..CovidVaccinations AS cv
INNER JOIN PortfolioProject1..CovidDeaths AS cd
ON cv.location = cd.location
WHERE cv.continent IS NOT NULL
GROUP BY cv.location
ORDER BY PosRate DESC

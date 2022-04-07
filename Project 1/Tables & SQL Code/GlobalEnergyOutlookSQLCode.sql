--********************************************************************************************************************************--
--The column of country names contained a mix of countries as well as regions.
--All region names did not have Codes assigned to them except for the 'World' Region.
--To solve that the 'World' rows had to be updated to match the remainder of the regions.
--********************************************************************************************************************************--

-- Query 1 
-- Update World Entries to SET code to NULL in ConsumptionBySource Table

UPDATE PortfolioProject2..ConsumptionBySource SET Code = NULL
WHERE Country = 'World';

SELECT * FROM PortfolioProject2..ConsumptionBySource WHERE Country = 'World';

-- Query 2 
-- Update World Entries to SET code to NULL in ConsumptionPerCapita Table

UPDATE PortfolioProject2..ConsumptionPerCapita SET Code = NULL
WHERE Country = 'World'

SELECT * FROM PortfolioProject2..ConsumptionPerCapita

--********************************************************************************************************************************--

-- Query 3
-- Calculate the consumption sourced from renewables, consumption sourced from fossil fuels and total consumption for 2020 by Country

SELECT	Country, 
		Biofuels, 
		Solar,
		Wind,
		Hydro,
		Nuclear, 
		Gas, 
		Coal, 
		Oil, 
		(Biofuels + Solar + Wind + Hydro + Nuclear) AS SumRenewables,
		(Oil + Coal + Gas) AS SumFossilFuels,
		(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas) AS TotalConsumption
FROM PortfolioProject2..ConsumptionBySource
WHERE Code IS NOT NULL
	AND Year = 2020
ORDER BY Country;

-- Query 4
-- The following query returns MAX Consumptions for each source by Country Since 1965

SELECT	DISTINCT Country,
		MAX(Biofuels) OVER (PARTITION BY Country ORDER BY Country) AS MaxBiofuels,
		MAX(Solar) OVER (PARTITION BY Country ORDER BY Country) AS MaxSolar,
		MAX(Hydro) OVER (PARTITION BY Country ORDER BY Country) AS MaxHydro,
		MAX(Nuclear) OVER (PARTITION BY Country ORDER BY Country) AS MaxNuclear,
		Max(Gas) OVER (PARTITION BY Country ORDER BY Country) AS MaxGas,
		MAX(Coal) OVER (PARTITION BY Country ORDER BY Country) AS MaxCoal,
		MAX(Oil) OVER (PARTITION BY Country ORDER BY Country) AS MaxOil
FROM PortfolioProject2..ConsumptionBySource
WHERE Code IS NOT NULL

-- Query 5
-- Calculating share of Renewables (as %) in Total Consumption Per Country in 2020 using a CTE.

WITH ConsumptionBreakdown AS
(SELECT	Country,
		(Biofuels + Solar + Wind + Hydro + Nuclear) AS SumRenewables,
		(Oil + Coal + Gas) AS SumFossilFuels,
		(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas) AS TotalConsumption
FROM PortfolioProject2..ConsumptionBySource
WHERE Code IS NOT NULL
	AND Year = 2020)

SELECT	Country,
		ROUND((SumRenewables/TotalConsumption), 4)*100 AS ShareRenewables
FROM ConsumptionBreakdown
WHERE TotalConsumption <> 0
ORDER BY ShareRenewables DESC

-- Query 6
-- Calculating share of Fossil Fuels (as %) in Total Consumption Per Country in 2020 using a CTE

WITH ConsumptionBreakdown AS
(SELECT	Country,
		(Biofuels + Solar + Wind + Hydro + Nuclear) AS SumRenewables,
		(Oil + Coal + Gas) AS SumFossilFuels,
		(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas) AS TotalConsumption
FROM PortfolioProject2..ConsumptionBySource
WHERE Code IS NOT NULL
	AND Year = 2020)

SELECT	Country,
		ROUND((SumFossilFuels/TotalConsumption), 4)*100 AS ShareFossilFuels
FROM ConsumptionBreakdown
WHERE TotalConsumption <> 0
ORDER BY ShareFossilFuels DESC

-- Query 7
-- From the ConsumptionPerCapita Table, calculating the AVG Energy_per_capita globally in 2019

SELECT ROUND(AVG(Energy_per_capita), 2) as GlobalConsumptionAverage
FROM PortfolioProject2..ConsumptionPerCapita
WHERE Code IS NOT NULL
AND Year = 2019

-- Query 8
-- Combining share of fossil fuel, share of renewables and the energy consumed per capita by country for 2019 using a CTE
-- Joined the CTE with the ConsumptionPerCapita table to display the above-mentioned values in the same query
-- Assigned a rank for each country based on their Share of Fossil Fuels, Share of Renewables and Energy consumption per capita

DROP VIEW IF EXISTS Rankings;
GO
CREATE VIEW Rankings AS
WITH ConsumptionBreakdown AS
(SELECT	Country,
		(Biofuels + Solar + Wind + Hydro + Nuclear) AS SumRenewables,
		(Oil + Coal + Gas) AS SumFossilFuels,
		(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas) AS TotalConsumption
FROM PortfolioProject2..ConsumptionBySource
WHERE Code IS NOT NULL
	AND Year = 2019)

SELECT	cb.Country,
		ROUND((SumFossilFuels/TotalConsumption), 4)*100 AS ShareFossilFuels,
		ROW_NUMBER() OVER (ORDER BY ROUND((SumFossilFuels/TotalConsumption), 4)*100 DESC) AS RnkByShareFossilFuels,
		ROUND((SumRenewables/TotalConsumption), 4)*100 AS ShareRenewables,
		ROW_NUMBER() OVER (ORDER BY ROUND((SumRenewables/TotalConsumption), 4)*100 DESC) AS RnkByShareRenewables,
		cc.Energy_per_capita,
		ROW_NUMBER() OVER (ORDER BY cc.Energy_per_capita DESC) AS RnkByEnergyPerCapita
FROM ConsumptionBreakdown AS cb
INNER JOIN PortfolioProject2..ConsumptionPerCapita AS cc
ON cb.Country = cc.Country
WHERE TotalConsumption <> 0
AND Year = 2019;
GO

-- Query 9
-- Calculating the AVG Global energy consumption per capita and verifying if the energy consumption per capita in each country is higher/lower than the global average (2019)
-- If consumption per capita per country is higher, the query returns 'Higher Than Global Average'
-- Saved the results as a View to be used later on for further analysis

DROP VIEW IF EXISTS GlobalAvgComparison;
GO
CREATE VIEW GlobalAvgComparison AS
SELECT	Country,
		Energy_per_capita,
		(SELECT ROUND(AVG(Energy_per_capita), 2)
		FROM PortfolioProject2..ConsumptionPerCapita
		WHERE Code IS NOT NULL AND Year = 2019) AS GlobalAvgConsumption,
		CASE
			WHEN Energy_per_capita >	(SELECT ROUND(AVG(Energy_per_capita), 2) as GlobalConsumptionAverage 
										FROM PortfolioProject2..ConsumptionPerCapita
										WHERE Code IS NOT NULL
										AND Year = 2019)
			THEN 'Higher than Global Average'
			ELSE 'Lower Than Global Average'
		END AS 'HigherLower'
FROM PortfolioProject2..ConsumptionPerCapita
WHERE Year = 2019
AND Code IS NOT NULL
GROUP BY Country, Energy_per_capita;
GO

-- Query 10
-- Counting the number of countries where the energy consumed per capita is lower than the global average

SELECT COUNT(*) 
FROM GlobalAvgComparison
WHERE HigherLower = 'Lower Than Global Average'

-- Query 11
-- Creating a view to visualize SumRenewables, SumFossilFuels, TotalConsumption and the shares of renewables (%) and fossil fuels (%) for each country (2019)

DROP VIEW IF EXISTS ConsumptionBreakdown;
GO
CREATE VIEW ConsumptionBreakdown AS
SELECT	Country,
		(Biofuels + Solar + Wind + Hydro + Nuclear) AS SumRenewables,
		(Oil + Coal + Gas) AS SumFossilFuels,
		(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas) AS TotalConsumption,
		ROUND((Biofuels + Solar + Wind + Hydro + Nuclear)/(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas), 4)*100 As ShareRenewables,
		ROUND((Oil + Coal + Gas)/(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas), 4)*100 AS ShareFossilFuels
FROM PortfolioProject2..ConsumptionBySource
WHERE Code IS NOT NULL
	AND Year = 2019
	AND Solar <> 0;
GO

-- Query 12
-- Finding which countries get more of their energy from renewable sources than the global average in 2019
-- Query results indicate if consumption from renewable sources per country is higher/lower than the Global AVG Consumption from Renewables

SELECT	Country,
		SumRenewables,
		(SELECT ROUND(AVG(SumRenewables), 2) FROM ConsumptionBreakdown) AS GlobalAvgRenConsumption,
		CASE
			WHEN SumRenewables > (SELECT ROUND(AVG(SumRenewables), 2) FROM ConsumptionBreakdown) THEN 'Higher'
			ELSE 'Lower'
		END AS 'Higher/Lower'
FROM ConsumptionBreakdown
GROUP BY Country, SumRenewables

-- Query 13
-- Listing the countries which sourced most of their energy from renewable sources in 2019 and listing their corresponding rank in terms of energy consumption per capita
-- If consumption from renewable sources by country exceeds global average, the corresponding country is counted
-- Result from previous query used as a CTE in this query

WITH RenConsumption AS
(SELECT	Country,
		SumRenewables,
		(SELECT ROUND(AVG(SumRenewables), 2) FROM ConsumptionBreakdown) AS GlobalAvgRenConsumption,
		CASE
			WHEN SumRenewables > (SELECT ROUND(AVG(SumRenewables), 2) FROM ConsumptionBreakdown) THEN 'Higher'
			ELSE 'Lower'
		END AS 'Higher/Lower'
FROM ConsumptionBreakdown
GROUP BY Country, SumRenewables)

SELECT RenConsumption.Country, RnkByEnergyPerCapita
FROM RenConsumption
INNER JOIN Rankings
ON RenConsumption.Country = Rankings.Country
WHERE "Higher/Lower" = 'Higher'
ORDER BY RnkByEnergyPerCapita

-- Query 14
-- Fetching the top 10 countries with the highest share of energy sourced from fossil fuels and showing their rank in terms of energy consumption per capita

SELECT cb.Country, cb.ShareFossilFuels, r.RnkByEnergyPerCapita
FROM ConsumptionBreakdown AS cb
INNER JOIN Rankings r
ON cb.Country = r.Country
ORDER BY cb.ShareFossilFuels DESC;


-- Query 15
-- Fetching consumption from renewable sources, from fossil fuels, respective shares of renewables and fossil fuels per region, and total consumption grouped by region 2019

SELECT	Country, 
		ROUND((Biofuels + Solar + Wind + Hydro + Nuclear), 2) AS SumRenewables,
		ROUND((Biofuels + Solar + Wind + Hydro + Nuclear)/(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas), 4)*100 AS ShareRenewables,
		ROUND((Oil + Coal + Gas), 2) AS SumFossilFuels,
		ROUND((Oil + Coal + Gas)/(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas), 4)*100 AS ShareFossilFuels,
		(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas) AS TotalConsumption
FROM PortfolioProject2..ConsumptionBySource
WHERE Code IS NULL
	AND Year = 2019
	AND Country NOT LIKE 'Non-OECD' AND Country NOT LIKE 'OECD' AND Country NOT LIKE 'World'
ORDER BY ShareFossilFuels DESC;

-- Query 16
-- Looking at the increase in share of energy sourced from renewables across different regions between 1965 and 2019 using a self-join statement

WITH BegEnd AS
(SELECT	Country, Year,
		ROUND((Biofuels + Solar + Wind + Hydro + Nuclear), 2) AS SumRenewables,
		ROUND((Biofuels + Solar + Wind + Hydro + Nuclear)/(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas), 4)*100 AS ShareRenewables,
		ROUND((Oil + Coal + Gas), 2) AS SumFossilFuels,
		ROUND((Oil + Coal + Gas)/(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas), 4)*100 AS ShareFossilFuels,
		(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas) AS TotalConsumption
FROM PortfolioProject2..ConsumptionBySource
WHERE Code IS NULL
	AND Year IN (2019,1965)
	AND Country NOT LIKE 'Non-OECD' AND Country NOT LIKE 'OECD' AND Country NOT LIKE 'World')

SELECT	a.Country,
		(b.ShareRenewables - a.ShareRenewables) AS DiffRen
FROM BegEnd AS a
INNER JOIN BegEnd AS b
ON a.Country = b.Country AND b.year = a.year + 54
ORDER BY DiffRen DESC

-- Query 17
--Fetching the region that made the biggest progress in terms of increasing the energy sourced from renewables using the previous queries as a CTE

WITH BegEnd AS
(SELECT	Country, Year,
		ROUND((Biofuels + Solar + Wind + Hydro + Nuclear), 2) AS SumRenewables,
		ROUND((Biofuels + Solar + Wind + Hydro + Nuclear)/(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas), 4)*100 AS ShareRenewables,
		ROUND((Oil + Coal + Gas), 2) AS SumFossilFuels,
		ROUND((Oil + Coal + Gas)/(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas), 4)*100 AS ShareFossilFuels,
		(Biofuels + Solar + Wind + Hydro + Nuclear + Oil + Coal + Gas) AS TotalConsumption
FROM PortfolioProject2..ConsumptionBySource
WHERE Code IS NULL
	AND Year IN (2019,1965)
	AND Country NOT LIKE 'Non-OECD' AND Country NOT LIKE 'OECD' AND Country NOT LIKE 'World'),
ListDiffRen AS
(SELECT	a.Country,
		(b.ShareRenewables - a.ShareRenewables) AS DiffRen
FROM BegEnd AS a
INNER JOIN BegEnd AS b
ON a.Country = b.Country AND b.year = a.year + 54)

SELECT Country, DiffRen
FROM ListDiffRen
WHERE DiffRen = (SELECT MAX(DiffRen) From ListDiffRen)

-- Query 18
-- Looking at the shares of all sources (renewables & fossil fuels) as a percentage of global consumption at different intervals from 1965 to 2020

SELECT	Year,
		ROUND(Biofuels/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareBiofuels,
		ROUND(Solar/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareSolar,
		ROUND(Wind/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareWind,
		ROUND(Hydro/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareHydro,
		ROUND(Nuclear/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareNuclear,
		ROUND(Gas/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareGas,
		ROUND(Coal/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareCoal,
		ROUND(Oil/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareOil
FROM PortfolioProject2..ConsumptionBySource
WHERE Country = 'World' AND Year IN (1965, 1975, 1985, 1995, 2005, 2015, 2020)

-- Query 19
-- Calculating the variances in shares of energy sourced from renewables to identify the source that increased the most since 1965

WITH DiffSources AS
(SELECT	Country, Year,
		ROUND(Biofuels/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareBiofuels,
		ROUND(Solar/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareSolar,
		ROUND(Wind/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareWind,
		ROUND(Hydro/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareHydro,
		ROUND(Nuclear/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil), 4) * 100 AS ShareNuclear
FROM PortfolioProject2..ConsumptionBySource
WHERE Country = 'World' AND Year IN (1965,2020))

SELECT	(b.ShareBiofuels - a.ShareBiofuels) AS DiffBiofuels,
		(b.ShareSolar - a.ShareSolar) AS DiffSolar,
		(b.ShareWind - a.ShareWind) AS DiffWind,
		(b.ShareHydro - a.ShareHydro) AS DiffHydro,
		(b.ShareNuclear - a.ShareNuclear) AS DiffNuclear
FROM DiffSources AS a
INNER JOIN DiffSources AS b
ON a.Country = b.Country AND b.Year = a.Year + 55

-- Query 20
-- Looking at the difference between share of energy sourced from renewables between 1965 and 2020 globally

SELECT	Country, Year,
		(Biofuels + Solar + Wind + Hydro + Nuclear) AS SumRenewables,
		(Biofuels + Solar + Wind + Hydro + Nuclear)/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil) * 100 AS ShareRenewables,
		(Gas + Coal + Oil) AS SumFossilFuels,
		(Gas + Coal + Oil)/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil) * 100 AS ShareFossilFuels
FROM PortfolioProject2..ConsumptionBySource
WHERE Country = 'World' AND Year IN (1965, 2020)

-- Query 21
-- Showing the evolution of share of renewables and share of fossil fuels in the energy consumption between 1965 and 2020 year-on-year globally

SELECT	Country, Year,
		(Biofuels + Solar + Wind + Hydro + Nuclear) AS SumRenewables,
		(Biofuels + Solar + Wind + Hydro + Nuclear)/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil) * 100 AS ShareRenewables,
		(Gas + Coal + Oil) AS SumFossilFuels,
		(Gas + Coal + Oil)/(Biofuels + Solar + Wind + Hydro + Nuclear + Gas + Coal + Oil) * 100 AS ShareFossilFuels
FROM PortfolioProject2..ConsumptionBySource
WHERE Country = 'World'
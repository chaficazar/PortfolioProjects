=================================================================================================================================================
DATA CLEANING
=================================================================================================================================================

SELECT * FROM PortfolioProject4..Projects
SELECT * FROM PortfolioProject4..ProjectRoles
SELECT * FROM PortfolioProject4..Pipeline

-- Query 1
-- There are two Project columns: Project & Project 1. Checking if all rows are matching and deleting column Project 1

WITH Duplicates_CTE AS
(SELECT Project, Project1,
		CASE
			WHEN Project = Project1 THEN 'Match'
			ELSE 'Diff'
		END AS Flag
From PortfolioProject4..Projects)

SELECT Project
FROM Duplicates_CTE
WHERE Flag = 'Diff'

ALTER TABLE PortfolioProject4..Projects
DROP COLUMN Project1

-- For the Pipeline Table

WITH DuplicatesPipeline_CTE AS
(SELECT Project, Project1,
		CASE
			WHEN Project = Project1 THEN 'Match'
			ELSE 'Diff'
		END AS Flag
From PortfolioProject4..Pipeline)

SELECT Project
FROM DuplicatesPipeline_CTE
WHERE Flag = 'Diff'

ALTER TABLE PortfolioProject4..Pipeline
DROP COLUMN Project1


-- Query 2
-- Converting data in 'Completion Year' column from nvarchar to int

-- For the Projects table

SELECT CAST(CompletionYear AS int) AS CompletionYear
FROM PortfolioProject4..Projects

UPDATE PortfolioProject4..Projects
SET CompletionYear = CAST(CompletionYear AS date)

-- For the Pipeline table

SELECT CAST(CompletionYear AS int) AS CompletionYear
FROM PortfolioProject4..Pipeline

UPDATE PortfolioProject4..Pipeline
SET CompletionYear = CAST(CompletionYear AS int)

-- Query 3
-- Deleting Old ProjectID column from the Projects table and the ProjectRoles table

ALTER TABLE PortfolioProject4..Projects
DROP COLUMN "Old ProjectID"

ALTER TABLE PortfolioProject4..ProjectRoles
DROP COLUMN "Old ProjectID"

ALTER TABLE PortfolioProject4..Pipeline
DROP COLUMN "Old ProjectID"

-- Query 4
-- Streamlining Contract Type to to combine BOT, BO, BOO, BOOT, DBOT, DBFO, DBFOT, DBO, and DBOM to PPP Contract types as they are all variations of PPP Contracts

-- For the Projects table
-- Counting the number of contracts by type

SELECT DISTINCT "Contract Type", COUNT(*) AS NumberOfContracts
FROM PortfolioProject4..Projects
GROUP BY "Contract Type"

-- Testing the new nomanclature and checking the total number of contracts

WITH Test_CTE AS
(SELECT	Project,
		CASE
			WHEN "Contract Type" LIKE '%EPC%'
			THEN 'EPC'
			ELSE 'PPP'
		END AS NewContractType
FROM PortfolioProject4..Projects)

SELECT DISTINCT NewContractType, COUNT(*)
FROM Test_CTE
GROUP BY NewContractType

-- Updating the Contract Type column with the new classification

UPDATE PortfolioProject4..Projects
SET "Contract Type" = CASE
						WHEN "Contract Type" LIKE '%EPC%'
						THEN 'EPC'
						ELSE 'PPP'
					END

-- For the Pipeline table
-- Counting the number of contract types available

SELECT DISTINCT "Contract Type",
				COUNT(*) AS NumberOfContracts
FROM PortfolioProject4..Pipeline
GROUP BY "Contract Type"

-- Testing the new nomanclature and checking the total number of contracts

WITH Test_CTE AS
(SELECT	Project,
		CASE
			WHEN "Contract Type" LIKE '%BO%'
			THEN 'PPP'
			ELSE 'EPC'
		END AS NewContractType
FROM PortfolioProject4..Pipeline)

SELECT	DISTINCT NewContractType,
		COUNT(*) AS NewColumn
FROM Test_CTE
GROUP BY NewContractType

UPDATE PortfolioProject4..Pipeline
SET "Contract Type" =	CASE
							WHEN "Contract Type" LIKE '%BO%'
							THEN 'PPP'
							ELSE 'EPC'
						END

-- Query 5
-- Checking for duplicates. No duplicates found

-- For the Project table

WITH Duplicate_CTE AS
(SELECT *,
	ROW_NUMBER() OVER (PARTITION BY		"New ProjectId",
										"Project",
										"Country",
										"Industry",
										"Sector",
										"ProjectStatus",
										"Contract Type"
						ORDER BY		"New ProjectId") AS row_num
FROM PortfolioProject4..Projects)

SELECT *
FROM Duplicate_CTE
WHERE row_num > 1

-- For the Pipeline table

WITH Duplicates_CTE AS
(SELECT	*,
		ROW_NUMBER() OVER (PARTITION BY "New ProjectId",
										"Project",
										"Country",
										"Industry",
										"Sector",
										"ProjectStatus",
										"Contract Type"
						ORDER BY		"New ProjectId") AS row_num
FROM PortfolioProject4..Pipeline)

SELECT *
FROM Duplicates_CTE
WHERE row_num > 1

================================================================================================================================
DATA ANALYSIS
================================================================================================================================

-- Query 6
-- Finding total number of projects & project value per country per year

SELECT	Country, 
		AwardYear,
		COUNT(Project) AS ProjectCount, 
		SUM("Net Project Value ($m)") AS ProjectValue
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete'
GROUP BY Country, AwardYear
ORDER BY Country, AwardYear

-- Query 7
-- Calculating total value of projects across all GCC countries since 2012

SELECT	AwardYear,
		COUNT(Project) AS ProjectCount,
		SUM("Net Project Value ($m)") AS ProjectValue
FROM PortfolioProject4..Projects
WHERE ProjectStatus IN ('Execution', 'Complete')
GROUP BY AwardYear
ORDER BY AwardYear

-- Query 8
-- Looking at project distribution by country and by industry

SELECT	Country, 
		AwardYear, 
		Industry, COUNT(Project) AS ProjectCount, 
		ROUND(SUM("Net Project Value ($m)"), 1) AS ProjectValue
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete'
GROUP BY Country, AwardYear, Industry
ORDER BY Country, AwardYear, Industry

-- Query 9
-- Looking at projects by industry across all GCC countries

SELECT	AwardYear, 
		Industry, 
		COUNT(Project) AS ProjectCount, 
		ROUND(SUM("Net Project Value ($m)"), 1) AS ProjectValue
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete'
GROUP BY AwardYear, Industry
ORDER BY AwardYear, ProjectValue DESC

-- Query 10
-- Looking at the industry with highest project value per year across all GCC countries

DROP VIEW IF EXISTS TopIndustries
GO
CREATE VIEW TopIndustries AS
WITH ProjectCount_CTE AS
(SELECT AwardYear, 
		Industry, 
		COUNT(Project) AS ProjectCount, 
		ROUND(SUM("Net Project Value ($m)"), 1) AS ProjectValue
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete'
GROUP BY AwardYear, Industry)

SELECT	AwardYear, 
		Industry, 
		ProjectValue, 
		RANK() OVER (PARTITION BY AwardYear ORDER BY ProjectValue DESC) AS rnk
FROM ProjectCount_CTE
GO

SELECT	AwardYear,
		Industry,
		ProjectValue
FROM TopIndustries
WHERE rnk = 1

-- Query 11
-- Looking at projects by industry in Kuwait

SELECT	AwardYear, 
		Industry, 
		COUNT(Project) AS ProjectCount, 
		ROUND(SUM("Net Project Value ($m)"), 1) AS ProjectValue
FROM PortfolioProject4..Projects
WHERE	Country LIKE 'Kuwait'
AND		ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete'
GROUP BY AwardYear, Industry
ORDER BY AwardYear, ProjectValue DESC

-- Query 12
-- Looking at overall project count and project values over the years in Kuwait

WITH Kuwait_CTE AS
(SELECT AwardYear,
		COUNT(Project) AS ProjectCount, 
		ROUND(SUM("Net Project Value ($m)"), 1) AS ProjectValue
FROM PortfolioProject4..Projects
WHERE	Country LIKE 'Kuwait'
AND		ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete'
GROUP BY AwardYear)

SELECT	AwardYear,
		SUM(ProjectCount) AS TotalProjectCount_KW,
		SUM(ProjectValue) AS TotalProjectValue_KW
FROM Kuwait_CTE
GROUP BY AwardYear
ORDER BY AwardYear

-- Query 13
-- Looking at project status per country per year

SELECT	DISTINCT AwardYear,
		Country,
		ProjectStatus,
		COUNT(*) AS Nos
FROM PortfolioProject4..Projects
GROUP BY AwardYear, Country, ProjectStatus

-- Query 14
-- Finding the biggest economies in the GCC region

SELECT	Country,
		COUNT(Project) AS ProjectCount,
		SUM("Net Project Value ($m)") AS ExecutedProjects
FROM PortfolioProject4..Projects
WHERE ProjectStatus IN ('Execution', 'Complete')
GROUP BY Country
ORDER BY SUM("Net Project Value ($m)") DESC

-- Query 15
-- Finding the client with the most projects

WITH ProjectCount_CTE AS
(SELECT	AwardYear, 
		Country, 
		"Project Owner", 
		COUNT(*) AS NumberofProjects, 
		MAX(COUNT(*)) OVER (PARTITION BY Country, AwardYear ORDER BY COUNT(*) DESC) AS MaxProjectperYear
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Complete' OR ProjectStatus LIKE 'Execution'
GROUP BY AwardYear, Country, "Project Owner")

SELECT	AwardYear, 
		Country, 
		"Project Owner",
		NumberofProjects
FROM ProjectCount_CTE
WHERE NumberofProjects = MaxProjectperYear

-- Query 16
-- Finding the client with the largest projects in terms of net project values

DROP VIEW IF EXISTS BiggestClients;
GO
CREATE VIEW BiggestClients AS
WITH ProjectValue_CTE AS
(SELECT	AwardYear,
		Country,
		"Project Owner",
		"Net Project Value ($m)",
		SUM("Net Project Value ($m)") OVER (PARTITION BY "Project Owner", Country, AwardYear) AS SumValuePerClient
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Complete' OR ProjectStatus LIKE 'Execution')

SELECT	DISTINCT AwardYear,
		Country,
		"Project Owner",
		SumValuePerClient,
		MAX(SumValuePerClient) OVER (PARTITION BY Country, AwardYear) AS LargestProjectValue
FROM ProjectValue_CTE
GO

SELECT	AwardYear,
		Country,
		"Project Owner",
		LargestProjectValue
FROM BiggestClients
WHERE LargestProjectValue = SumValuePerClient
ORDER BY AwardYear, Country

-- Query 17
-- Finding contractors with highest amount of contracts by country and year

WITH Contractors_CTE AS
(SELECT	AwardYear,
		Country,
		CompanyName,
		COUNT(*) AS Proj_per_contractor
FROM PortfolioProject4..Projects p
INNER JOIN PortfolioProject4..ProjectRoles r
ON p."New ProjectId " = r."New ProjectId "
WHERE	r.Role LIKE 'Civil'  OR
		r.Role LIKE 'Developer' OR 
		r.Role LIKE 'Electrical' OR 
		r.Role LIKE 'Electromechanical' OR 
		r.Role LIKE 'HVAC' OR 
		r.Role LIKE 'Instrumentation' OR
		r.Role LIKE 'Main Contractor' OR
		r.Role LIKE 'Maintenance Contractor' OR
		r.Role LIKE 'Maintenance Electrical' OR
		r.Role LIKE 'Maintenance Mechanical' OR
		r.Role LIKE 'Mechanical' OR
		r.Role LIKE 'MEI' OR
		r.Role LIKE 'MEP' OR
		r.Role LIKE 'Plumbing'
AND		p.ProjectStatus LIKE 'Complete' OR
		p.ProjectStatus LIKE 'Execution'
GROUP BY AwardYear, Country, CompanyName)

SELECT	AwardYear,
		Country,
		CompanyName,
		MAX(Proj_per_contractor) OVER (PARTITION BY Country, AwardYear) AS ProjectsCount
FROM Contractors_CTE

-- Query 18
-- Finding the largest contractors per country per year in terms of net project values.

DROP VIEW IF EXISTS BiggestContractors;
GO
CREATE VIEW BiggestContractors AS
WITH ContractorEarnings_CTE AS
(SELECT	AwardYear,
		Country,
		CompanyName,
		SUM("Net Project Value ($m)") AS ContractsValue
FROM PortfolioProject4..Projects p
INNER JOIN PortfolioProject4..ProjectRoles r
ON p."New ProjectId " = r."New ProjectId "
WHERE	r.Role LIKE 'Civil'  OR
		r.Role LIKE 'Electrical' OR 
		r.Role LIKE 'Electromechanical' OR 
		r.Role LIKE 'HVAC' OR 
		r.Role LIKE 'Instrumentation' OR
		r.Role LIKE 'Main Contractor' OR
		r.Role LIKE 'Maintenance Contractor' OR
		r.Role LIKE 'Maintenance Electrical' OR
		r.Role LIKE 'Maintenance Mechanical' OR
		r.Role LIKE 'Mechanical' OR
		r.Role LIKE 'MEI' OR
		r.Role LIKE 'MEP' OR
		r.Role LIKE 'Plumbing'
AND		p.ProjectStatus LIKE 'Complete' OR
		p.ProjectStatus LIKE 'Execution'
GROUP BY AwardYear, Country, CompanyName)

SELECT	AwardYear,
		Country,
		CompanyName,
		ContractsValue,
		MAX(ContractsValue) OVER (PARTITION BY AwardYear, Country ORDER BY ContractsValue DESC) AS MaxContractValues
FROM ContractorEarnings_CTE
GO

SELECT	AwardYear,
		Country,
		CompanyName,
		ContractsValue
FROM BiggestContractors
WHERE ContractsValue = MaxContractValues
ORDER BY AwardYear, Country

-- Query 19
-- Kuwait Contractors by project values

SELECT	AwardYear,
		CompanyName,
		ContractsValue
FROM BiggestContractors
WHERE ContractsValue = MaxContractValues
AND Country LIKE 'Kuwait'
ORDER BY AwardYear, ContractsValue DESC

-- Query 20
-- Finding biggest clients in Kuwait by value of contracts in execution

DROP VIEW IF EXISTS KuwaitMarket;
GO
CREATE VIEW KuwaitMarket AS
WITH KuwaitClients_CTE AS
(SELECT	DISTINCT AwardYear,
		"Project Owner",
		SUM("Net Project Value ($m)") OVER (PARTITION BY "Project Owner", Country, AwardYear) AS SumValuePerClient
FROM PortfolioProject4..Projects
WHERE (ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete')
AND (Country = 'Kuwait'))

SELECT	DISTINCT AwardYear,
		"Project Owner",
		SumValuePerClient,
		MAX(SumValuePerClient) OVER (PARTITION BY AwardYear) AS LargestProjectValue
FROM KuwaitClients_CTE
GO

SELECT	AwardYear,
		"Project Owner" AS Client,
		SumValuePerClient
FROM KuwaitMarket
WHERE SumValuePerClient = LargestProjectValue

-- Query 21
-- Validating if Alghanim International executed projects outside Kuwait

DROP VIEW IF EXISTS AlghanimInternational;
GO
CREATE VIEW AlghanimInternational AS
SELECT	DISTINCT 
		p.AwardYear,
		p.Country,
		p.Project,
		p."Net Project Value ($m)",
		CASE
			WHEN Country NOT LIKE 'Kuwait'
			THEN 1
			ELSE 0
		END AS flag
FROM PortfolioProject4..ProjectRoles r
INNER JOIN PortfolioProject4..Projects p
ON p."New ProjectId " = r."New ProjectId "
WHERE (r.CompanyName = 'Alghanim International General Trading & Contracting')
AND (r.Role LIKE 'Civil'  OR
		r.Role LIKE 'Electrical' OR 
		r.Role LIKE 'Electromechanical' OR 
		r.Role LIKE 'HVAC' OR 
		r.Role LIKE 'Instrumentation' OR
		r.Role LIKE 'Main Contractor' OR
		r.Role LIKE 'Maintenance Contractor' OR
		r.Role LIKE 'Maintenance Electrical' OR
		r.Role LIKE 'Maintenance Mechanical' OR
		r.Role LIKE 'Mechanical' OR
		r.Role LIKE 'MEI' OR
		r.Role LIKE 'MEP' OR
		r.Role LIKE 'Plumbing')
GO

SELECT	AwardYear,
		Country,
		Project,
		"Net Project Value ($m)"
FROM AlghanimInternational
WHERE flag = 1

-- Query 22
-- Calculating Alghanim International's contract values by year

SELECT	AwardYear,
		SUM("Net Project Value ($m)") AS ProjectsValue
FROM AlghanimInternational
GROUP BY AwardYear
ORDER BY AwardYear

-- Query 23
-- Looking at Alghanim International's competition in Kuwait and ranking them in terms of sum of Net Project Value
-- Assumption: in case of 2 or more companies listed on the same project, the portion of each company from the Net Project Value is unknown and thus will be considered the same for all participants 

WITH Competition AS
(SELECT	DISTINCT 
		p.AwardYear,
		p.Project,
		r.CompanyName,
		p."Net Project Value ($m)"
FROM PortfolioProject4..ProjectRoles r
INNER JOIN PortfolioProject4..Projects p
ON p."New ProjectId " = r."New ProjectId "
WHERE (p.Country LIKE 'Kuwait')
AND (r.Role LIKE 'Civil'  OR
		r.Role LIKE 'Electrical' OR 
		r.Role LIKE 'Electromechanical' OR 
		r.Role LIKE 'HVAC' OR 
		r.Role LIKE 'Instrumentation' OR
		r.Role LIKE 'Main Contractor' OR
		r.Role LIKE 'Maintenance Contractor' OR
		r.Role LIKE 'Maintenance Electrical' OR
		r.Role LIKE 'Maintenance Mechanical' OR
		r.Role LIKE 'Mechanical' OR
		r.Role LIKE 'MEI' OR
		r.Role LIKE 'MEP' OR
		r.Role LIKE 'Plumbing'))

SELECT	AwardYear,
		CompanyName,
		SUM("Net Project Value ($m)") AS SumProjects,
		DENSE_RANK() OVER (PARTITION BY AwardYear ORDER BY SUM("Net Project Value ($m)") DESC) AS rnk
FROM Competition
GROUP BY AwardYear, CompanyName
ORDER BY AwardYear, SUM("Net Project Value ($m)") DESC

-- Query 24
-- Finding the average value per project in the GCC Region overall

SELECT AwardYear,
		COUNT(Project) AS ProjectCount, 
		ROUND(SUM("Net Project Value ($m)"), 1) AS MarketSize,
		ROUND((ROUND(SUM("Net Project Value ($m)"), 1))/(COUNT(Project)), 0) AS AvgProjectValue
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete'
GROUP BY AwardYear
ORDER BY AwardYear

-- Query 25
-- Finding the average value per project per country and year

SELECT	AwardYear,
		Country,
		COUNT(Project) AS ProjectCount,
		ROUND(SUM("Net Project Value ($m)"), 2) AS LocalMarketSize,
		ROUND(SUM("Net Project Value ($m)")/(COUNT(Project)) , 0) AS AvgProjectValue
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete'
GROUP BY Country, AwardYear
ORDER BY Country, AwardYear

-- Query 26
-- Looking at mega projects per country per year. Assumption: every project exceeding $200 million is considered as a mega-project

SELECT	AwardYear,
		Country,
		COUNT(*) AS MegaProjects
FROM PortfolioProject4..Projects
WHERE "Net Project Value ($m)" >= 200
GROUP BY Country, AwardYear
ORDER BY Country

-- Query 27
-- Finding the top 10 largest projects in the GCC region completed or in execution

SELECT TOP 10	Project,
				AwardYear,
				Country,
				"Owner Type",
				Industry,
				MAX("Net Project Value ($m)") AS ProjectValue,
				ProjectStatus,
				"Project Owner",
				CompletionYear
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete'
GROUP BY Project, AwardYear, Country, "Owner Type", Industry, ProjectStatus, "Project Owner", CompletionYear
ORDER BY MAX("Net Project Value ($m)") DESC

-- Query 28
-- Finding the top 10 largest projects in Kuwait, completed or in execution

SELECT TOP 10	Project,
				AwardYear,
				"Owner Type",
				Industry,
				MAX("Net Project Value ($m)") AS ProjectValue,
				ProjectStatus,
				"Project Owner",
				CompletionYear
FROM PortfolioProject4..Projects
WHERE (ProjectStatus LIKE 'Execution' OR ProjectStatus LIKE 'Complete')
AND		Country LIKE 'Kuwait'
GROUP BY Project, AwardYear, Country, "Owner Type", Industry, ProjectStatus, "Project Owner", CompletionYear
ORDER BY MAX("Net Project Value ($m)") DESC

-- Query 29
-- Looking at contract types (EPC vs. PPP) in the GCC region

SELECT	AwardYear,
		Country,
		"Contract Type",
		COUNT(*) AS ProjectCount,
		SUM("Net Project Value ($m)") AS ProjectsValue
FROM PortfolioProject4..Projects
WHERE ProjectStatus LIKE 'Complete' OR ProjectStatus LIKE 'Execution'
GROUP BY AwardYear, Country, "Contract Type"
ORDER BY AwardYear

-- Query 30
-- Looking at the projects in the pipeline across the GCC region

SELECT	DISTINCT AwardYear,
		Country,
		COUNT (*) AS NumberofProjects,
		SUM("Estimated Budget ($m)") AS ProjectsValue
FROM PortfolioProject4..Pipeline
WHERE ProjectStatus IN ('Design', 'Study')
GROUP BY AwardYear, Country
ORDER BY AwardYear, ProjectsValue DESC

-- Query 31
-- Looking at the projects in the pipeline for Kuwait

SELECT	DISTINCT ProjectStatus,
		COUNT(*) AS NumberOfProjects,
		SUM("Estimated Budget ($m)") AS ProjectsValue
FROM PortfolioProject4..Pipeline
WHERE Country LIKE 'Kuwait'
GROUP BY ProjectStatus

-- Query 32
-- Using the above query, finding the projects that are currently marked as 'Design' and 'Study' in Kuwait for business development purposes

DROP VIEW IF EXISTS UpcomingProjects;
GO
CREATE VIEW UpcomingProjects AS
SELECT	Project,
		"Owner Type",
		Industry,
		Sector,
		SubSector,
		"Estimated Budget ($m)",
		AwardYear,
		CompletionYear
FROM PortfolioProject4..Pipeline
WHERE	(Country LIKE 'Kuwait')
AND		(ProjectStatus LIKE 'Design' OR ProjectStatus LIKE 'Study')
GO

SELECT *
FROM UpcomingProjects
ORDER BY "Estimated Budget ($m)" DESC

-- Query 33
-- From the above query, find the name of the client for these upcoming projects. Client name preceded by "-"

WITH Client_CTE AS
(SELECT	Project,
		"Owner Type",
		Industry,
		"Estimated Budget ($m)",
		AwardYear,
		CompletionYear
FROM PortfolioProject4..Pipeline
WHERE	(Country LIKE 'Kuwait')
AND		(ProjectStatus LIKE 'Design' OR ProjectStatus LIKE 'Study'))

SELECT	Project,
		SUBSTRING(Project, 1, CHARINDEX('-', Project) -1) AS Client,
		"Estimated Budget ($m)"
FROM Client_CTE
ORDER BY "Estimated Budget ($m)" DESC

-- Query 34
-- Looking at completed projects in UAE, KSA and Kuwait over the years

SELECT	Country,
		AwardYear,
		COUNT(*) AS ProjectCount,
		SUM("Net Project Value ($m)") AS ProjectValue,
		RANK() OVER (PARTITION BY AwardYear ORDER BY SUM("Net Project Value ($m)") DESC) AS Rnk
FROM PortfolioProject4..Projects
WHERE (Country IN ('UAE', 'Saudi Arabia', 'Kuwait')) --Country LIKE 'UAE' OR Country LIKE 'Saudi Arabia' OR Country LIKE 'Kuwait'
AND (ProjectStatus LIKE 'Complete')
GROUP BY Country, AwardYear
ORDER BY AwardYear, ProjectValue DESC

-- Query 35
-- Checking the position of Kuwait compared to KSA and UAE using the above query

WITH KuwaitPos_CTE AS
(SELECT	Country,
		AwardYear,
		COUNT(*) AS ProjectCount,
		SUM("Net Project Value ($m)") AS ProjectValue,
		RANK() OVER (PARTITION BY AwardYear ORDER BY SUM("Net Project Value ($m)") DESC) AS Rnk
FROM PortfolioProject4..Projects
WHERE (Country IN ('UAE', 'Saudi Arabia', 'Kuwait')) --Country LIKE 'UAE' OR Country LIKE 'Saudi Arabia' OR Country LIKE 'Kuwait'
AND (ProjectStatus LIKE 'Complete')
GROUP BY Country, AwardYear)

SELECT *
FROM KuwaitPos_CTE
WHERE Rnk <> 3 AND Country LIKE 'Kuwait'

-- Query 36
-- Looking at the projects values in Kuwait in 2014 & 2015 to identify projects contributing to ranking Kuwait 1st in the GCC in same years

SELECT	AwardYear,
		Project,
		"Owner Type",
		Industry,
		"Net Project Value ($m)",
		"Project Owner"
FROM PortfolioProject4..Projects
WHERE (Country LIKE 'Kuwait')
AND AwardYear IN ('2014', '2015')
ORDER BY AwardYear, [Net Project Value ($m)] DESC

-- Query 37
-- Finding the contractors with most experience in Transportation and Construction projects in Kuwait

DROP VIEW IF EXISTS MatchingContractors;
GO
CREATE VIEW MatchingContractors AS
WITH PreviousExp_CTE AS
(SELECT	DISTINCT 
		p.[New ProjectId ],
		p.AwardYear,
		p.Country,
		p.Project,
		p.Industry,
		p.Sector,
		p.SubSector,
		r.CompanyName,
		r.Role,
		p."Net Project Value ($m)"
FROM PortfolioProject4..ProjectRoles r
INNER JOIN PortfolioProject4..Projects p
ON p."New ProjectId " = r."New ProjectId "
WHERE	(r.Role LIKE 'Civil'  OR
		r.Role LIKE 'Electrical' OR 
		r.Role LIKE 'Electromechanical' OR 
		r.Role LIKE 'HVAC' OR 
		r.Role LIKE 'Instrumentation' OR
		r.Role LIKE 'Main Contractor' OR
		r.Role LIKE 'Maintenance Contractor' OR
		r.Role LIKE 'Maintenance Electrical' OR
		r.Role LIKE 'Maintenance Mechanical' OR
		r.Role LIKE 'Mechanical' OR
		r.Role LIKE 'MEI' OR
		r.Role LIKE 'MEP' OR
		r.Role LIKE 'Plumbing')
AND (ProjectStatus IN ('Complete', 'Execution')))

SELECT	[New ProjectId ],
		AwardYear,
		Country,
		Industry,
		Sector,
		SubSector,
		CompanyName,
		COUNT(Project) AS "Ongoing/CompletedProjects",
		SUM("Net Project Value ($m)") AS ProjectValue,
		Project
FROM PreviousExp_CTE
WHERE Industry IN ('Construction', 'Transport')
GROUP BY [New ProjectId ], AwardYear, Country, Industry, Sector, Subsector, CompanyName, Project
GO

-- Query 38
-- Finding if any of the contractors identified in Query 37 above have similar experience with requirements of upcoming projects

DROP VIEW IF EXISTS FinalCandidates;
GO
CREATE VIEW FinalCandidates AS
SELECT	mc.[New ProjectId ] AS ReferenceProjectID,
		mc.AwardYear,
		CompanyName,
		mc.ProjectValue,
		mc.Industry,
		mc.Sector,
		mc.SubSector,
		up.Project AS UpcomingProject
FROM MatchingContractors mc
INNER JOIN UpcomingProjects up
ON mc.Industry = up.Industry 
AND mc.Sector = up.Sector 
AND mc.SubSector = up.SubSector
WHERE mc.AwardYear > 2017 AND ProjectValue > 200
GO

-- Query 39
-- Finding contact person for companies where their experience matches requirements of upcoming projects

SELECT	DISTINCT fc.ReferenceProjectID,
		fc.CompanyName,
		pr.Contact
FROM PortfolioProject4..ProjectRoles pr
INNER JOIN FinalCandidates fc
ON fc.CompanyName = pr.CompanyName
AND fc.ReferenceProjectID = pr.[New ProjectId ]
ORDER BY CompanyName

-- Query 40
-- Finding the tender issue dates for upcoming tenders

SELECT	up.Project,
		[Main Contract Award]
FROM UpcomingProjects up
INNER JOIN PortfolioProject4..Pipeline p
ON p.Project = up.Project
ORDER BY [Main Contract Award]

-- Query 41
-- Counting upcoming projects by industry

SELECT	Industry,
		COUNT(Project) AS ProjectCount,
		SUM("Estimated Budget ($m)") AS TentativeProjectValue
FROM PortfolioProject4..Pipeline
WHERE Country IN ('Kuwait', 'Saudi Arabia', 'UAE')
AND ProjectStatus IN ('FEED', 'Design', 'Study')
AND Industry NOT IN ('Transport', 'Construction')
GROUP BY Industry
ORDER BY SUM("Estimated Budget ($m)") DESC
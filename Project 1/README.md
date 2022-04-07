# [Project 1: Global Energy Landscape](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%201/Tables%20%26%20SQL%20Code/GlobalEnergyOutlookSQLCode.sql)

## Key Findings

- Share of energy consumed globally from renewable sources increased by 9.8% from 1965 to 2020 which was mainly driven by:
- 4.2% increase in energy consumed from Nuclear sources contributing 42% to the total increase in share of energy consumed from renewables
- 2.6% increase in energy consumed from Wind contributing 26% to the total increase in share of renewables
- The remaining 32% are caused by increase in share of energy consumed from solar (15%), hydro (10%) and biofuels (7%) respectively
- The region that made the biggest progress in terms of increasing the energy sourced from renewables is South & Central America which exhibited an increase of 22% since 1965
- Share of energy consumed sourced from fossil fuels decreased from 93.9% in 1965 to 84.1% in 2020
- Up until 2019, the Middle East remained the region with the highest share of energy consumed from fossil fuels (99%)
- Qatar was the highest consumer of energy from fossil fuels (approx. 100%) and ranked number 1 in terms of energy consumption per capita

## Data Limitations & Data Cleaning

The dataset used to conduct this analysis was downloaded from a public website and consisted of 2 tables (see schema below). The first table (ConsumptionBySource) contained information on the source of energy consumed in each country (in TWh hours) between 1965 and 2020 while the second table (ConsumptionPerCapita) relayed information pertaining to energy consumption per capita in each country (in kWh) between 1980 and 2020.

--INSERT TABLE SCHEMA HERE

The data contained four major issues which are disclosed below:
- Data for 2020 was not consistent across all countries
- Regions and countries were listed under the same column (Country) with the only difference being that regions were not assigned Codes except for the ‘World’ region contained in both tables. As such, the data was updated to set the corresponding Code of the ‘World’ region to [NULL] (Queries 1 & 2) thus helping harmonize region entries in the table for subsequent analysis.
- Data for Russia was not available in the dataset. It should be noted that as of 2019, Russia was considered the 4th country overall in terms of energy consumption.
- The dataset did not take into account 2021 data, throughout which the world witnessed an unprecedented increase in renewable energy capacity installations.
For the purpose of calculating the shares of renewable energy and the shares of fossil fuels in each country, and to enable other calculations, the reference to renewable sources is considered to be the sum of Biofuels, Solar, Wind, Hydro and Nuclear, whereas fossil fuels is the sum of Gas, Coal and Oil consumed in each country.

## Consumption from Fossil Fuel Sources

Query 6 calculates share of energy consumed sourced by fossil fuels for each country in 2020. The top 10 countries with the highest share of energy sourced from fossil fuels are displayed in the chart graph below.

--GRAPH 1

50% of the countries listed in the top 10 are Middle Eastern countries. Share of energy sourced from fossil fuels in these countries ranges between 99.75% and 100%. This is underlined by:
- The availability of large supplies in conventional oil and gas resources
- The pivotal role played by hydrocarbon wealth in many Middle Eastern oil and gas producers’ economic development since the 1960s and 1970s
- The particular social contract in many Middle Eastern countries where energy has, for many decades, been considered a public good to be provided by governments at highly subsidized rates.
In fact, high energy subsidies in oil-rich countries might be one of the biggest factors preventing renewables penetration in the energy mix, especially considering that the Middle Eastern countries have very high solar irradiance and wind speeds presenting a high potential for installing photovoltaic facilities and wind farms. Not only do Middle Eastern countries rank among the highest in terms of share of energy sourced from fossil fuels, but they are also amongst the countries with the highest energy consumption per capita. The figure below shows the countries with the highest energy consumption per capita (highest starting from the left), and their corresponding share of energy sourced from fossil fuels. 

--INSERT GRAPH 2

80% of the countries listed above source more than 50% of their energy from fossil fuels and consume energy at a rate between 100,000 and 200,000 kWh per person annually. It should be noted that the average energy consumed per person in 2019 is 26,530 kWh as calculated in Query 7.

## Consumption from Renewable Sources

Query 5 fetches the countries with the highest share of energy sourced from renewables in 2020 with Iceland topping the list at 77%. The top 10 countries featured on the list are showcased in the figure below.

--INSERT GRAPH 3

The global average for consumption from renewable sources is 282 TWh and Query 12 finds the relative position of each country with relation to the global average. As of 2019, only 14 countries were found to possess a share of renewables higher than the global average. The figure also shows that European countries form 70% of the top 10 countries in terms of renewable capacity.
In terms of regions, South & Central America is the region with the highest share of renewables (30.5%) as shown by Query 15. It is also the region which made the biggest progress in increasing its energy sourced from renewables since 1965, with a variance of 21.9% (Query 16).

--INSERT GRAPH 4

Query 19 calculates the increase in the share of renewable sources since 1965. The pie chart below indicates that nuclear energy witnessed the highest increase (4.2%) since 1965, followed by wind, solar hydro and biofuels respectively.

--INSERT GRAPH 5

Globally, the share of energy sourced from renewables increased from 6% in 1965 to 16% in 2020 (Query 21) as shown by the figure below

-- INSERT GRAPH 6

The increase in renewables is coming mainly at the cost of coal, oil and gas and this trend is likely to continue especially in the wake of the Paris Climate Agreement and new policy frameworks encouraging sourcing energy from sustainable sources. Countries all around the world are powering towards a low-carbon future by embracing solar, wind and other renewable energy sources. In fact, some European countries and Japan have drafted legislation to stop funding the development of power plants running on fossil fuels thus accelerating the decarbonization process.

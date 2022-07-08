# [Project 4: Market Outlook & Lead Identification](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/SQLCode.sql)

## Key Findings

- The top performing industries in the GCC region within the last 10 years are the Oil & Gas and Power sectors
- 2014, 2015 and 2021 marked peak activities in the GCC projects market with total project values of $ 93 billion, $ 89 billion, and $ 100 billion respectively. 2021 recorded a 34% increase in awarded projects as all economies rebound from the effects of the pandemic.
- KSA, UAE and Kuwait are the largest three markets in the region, with a combined market share of 76% in the period between 2012 and 2022.
- The average project value in the GCC region ranges between $ 151 million anad $ 260 million over the study period.
- Data suggests that both Saudi Arabia and the UAE are the most prominent emerging markets in the region as these two markets showed upward trends in project counts and project values.
- The Kuwaiti market has been declining since 2014 while neighboring countries such as Saudi Arabia and the UAE witness a development movement chiefly driven by the desire to diversify their revenues and reduce their dependency on oil.
- The largest clients in Kuwait are all governmental entities. Kuwait Integrated Petrochemical Industries Company (KIPIC) is the largest client between 2012 and 2022 with projects worth ~ $ 13 billion corresponding to the refinery project.
- Despite close to $ 25 billion worth of projects in the pipeline, Kuwait requires a structural overhaul of its projects market to reach its potential. The largest proportion of projects (upwards of 62%) remain tied up in the study or design phase.
- The top 20 largest upcoming projects in Kuwait are concentrated in the construction and transport sectors with total estimated values of $ 11 billion and $ 5 billion respectively.
- 6 companies were shortlisted as potential partners for the upcoming projects based on 3 criteria, i) having executed projects in the construction and transportation sectors, ii) having executed projects within the past 5 years, and iii) having executed projects with values upward of $ 200 million.

## Dataset

The dataset used to conduct this analysis is not available publicly; it is a project tracking tool available only for subscribed customers and is normally used by organizations in the Middle East region to track projects progress and gain valuable insights into upcoming projects and competitor information.
The dataset consisted of 3 tables (see schema below):
- Projects table: each entry contains project specific information from 1 January 2012 until 12 May 2022
- ProjectRoles table: For each project in the Projects table, the ProjectRoles table identifies the corresponding contractor and their contact information
-	Pipeline table: lists all upcoming projects and their expected award dates

![](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/Images/schema.PNG)

## Data Limitations

Although the dataset presented insightful information, there were 4 shortcomings to take into account moving forward with the analysis:

**Accuracy of Project Values**: contract values and cash spent are not accurately reflected in the dataset; companies tend to overreport their figures to shelter themselves from exposing sensitive contract values and bid prices to competitors

**Ambiguity in Contractor Scopes of Work**: When a project is executed by numerous contractors, the net contract value represents the overall value of the contract. The dataset does not show the contract value of each individual subcontractor in accordance with their scope of work in that respective project. This limitation did not allow for accurate ranking of contractors

**Omitted Contractor Names**: For certain projects, the dataset does not correctly reflect the role of some contractors in certain projects, and sometimes omits the name of one or more contractors which reduces the count of executed projects for some organizations

**NULL Values**: Country, Region and City/Town columns contained chiefly NULL values

## Data Cleaning

The dataset underwent slight transformations in preparation for further analysis, chiefly:

-	Omitting two redundant columns (Old ProjectID and Project 1)
-	Converting incorrectly formatted data types; CompletionYear was converted from nvarchar(255) to date format
-	Double-checked that the dataset does not contain duplicate entries
-	Streamlined the Contract Type column to reflect only 2 values EPC and PPP. The column previously contained 9 subtypes of PPP contracts. For the purpose of this exercise, they shall be considered as PPP contracts.

## Overall GCC Market Outlook

The Gulf Cooperation Council (GCC) is a political economic union of Arab states bordering the Gulf. It was established in 1981 and its 6 members are the United Arab Emirates (UAE), the Kingdom of Saudi Arabia (KSA), Qatar, Oman, Kuwait and Bahrain.
Oil constitutes the main source of exports and the main government revenue, with nearly 70% of the region’s exports being oil exports while about 84% of government revenue being from oil.
The table below shows the top performing industry in the GCC region since 2012, along with the total value of projects executed in the industry:

| **Year** | **Top Performing Industry** | **Total Value of Projects in Industry ($m)** |
|:--------:|:---------------------------:|:--------------------------------------------:|
| 2012     | Power                       | 21,463                                       |
| 2013     | Power                       | 18,580                                       |
| 2014     | Oil                         | 35,613                                       |
| 2015     | Oil                         | 29,442                                       |
| 2016     | Gas                         | 13,023                                       |
| 2017     | Oil                         | 31,058                                       |
| 2018     | Power                       | 16,711                                       |
| 2019     | Oil                         | 18,816                                       |
| 2020     | Power                       | 14,768                                       |
| 2021     | Gas                         | 39,732                                       |

As stated above, GCC countries main source of income originates from the oil and gas industry which is the top performing industry in 2014, 2015, 2016, 2017, 2019 and 2021. 
Moreover, the power industry has also been prominent within the last 9 years as capacity additions in 2012 & 2013 correspond to (i) an increasing population and (ii) to fulfill the requirements for electricity as urbanization and industrialization increase. Alternatively, 2018 and 2020 saw the execution of a large number of renewable energy projects particularly in KSA and UAE in response to the global “renewable energy boom” and to take advantage of their ideal geographical location in terms of solar irradiation.
The figure below tracks the total value of completed projects & projects in execution across the GCC since 2012. 

![](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/Images/Graph%201.PNG)

The above graph indicates peak activities in 2014, 2015 and 2021 with total project values equivalent to $94 billion, $89 billion and $100 billion respectively. 
It should be noted that the value of 2022 projects represents all projects completed or in executed in 2022 until the 12th of May 2022.
-	2014 & 2015: peak activity during those two years saw 41% increase in projects underlined by high crude prices driving a widespread execution of oil & gas projects across all GCC countries, including Kuwait’s $39 billion refinery project.
-	2021 recorded a 34% increase in awarded projects as all economies rebound from the effects of the pandemic. This uptrend is underlined by $27.8 billion in Gas projects in Qatar which represents ~28% of the total value of projects executed in 2021.
As shown in the pie chart below, KSA, UAE and Kuwait are the largest three markets in the region since 2012, with a combined market share of 76% in terms of project execution.
The below pie chart showcases the disparity in market sizes even among the largest three markets of the region; Saudi Arabia dominates the region with 1,280 executed projects amounting to $ 268 billion followed by the United Arab Emirates with 885 executed projects totaling $ 131 billion and Kuwait comes third at 246 executed projects in the sum of $88 billion.

![](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/Images/Graph%202.PNG)

The graph below shows the average value of projects across the GCC since 2012. On average, executed contracts range between $151 million and $260 million per project and the region witnessed the highest increase in average project value after covid with a 35% increase in average project value.

![](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/Images/Graph%203.PNG)

### Emerging Markets

Saudi Arabia and the United Arab Emirates showed upward trends in the number of executed projects over the past 3 years with Saudi Arabia leading the way with a 60% increase in number of projects from 2020 to 2021 as the world recovered from the economic effects of the pandemic. The country is benefiting from the gained momentum and is planning to award projects in the sum of $ 7 billion by 2023. In 2021, Saudi Aramco was the largest client in the Saudi Market with $ 13 billion worth of floated projects. Saudi Aramco remains the dominant client in the country with projects worth upwards of $ 5 billion up until April of 2022.

The United Arab Emirates has shown a steady increase in the number of executed projects between 2019 and 2021 after being badly hit by the pandemic (projects decreased by ~55% between 2018 and 2019). In terms of upcoming projects, the UAE plans to award projects with a total value of $ 2.7 billion and $ 2 billion in 2022 and 2023 respectively. Abu Dhabi Polymers Co was the largest client in the UAE with $ 6 billion worth of projects (Borouge Petrochemical Complex Project). ADNOC Offshore was the largest client up until April of 2022 with projects worth $ 1.2 billion.

![](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/Images/Graph%204.PNG)

### Contract Execution Models

The GCC is dominated by two prominent contract execution models:

-	Engineering, Procurement and Construction (EPC) contracts
-	Public Private Partnership (PPP) contracts

EPC contracts involve a deal between the project owner and a contractor who is required to deliver certain design and construction of facilities to the project financer (in most cases, the project owner). The project financier is absolved of a lot of complexities of engaging and interacting with numerous parties as it only has to appoint a single contractor and oversee the work and progress. At the end of each milestone, the contractor submits an invoice to the project financier and gets paid for their services.

Alternatively, PPP contracts are long-term agreements between public and private entities, in which the private entity and the public entity jointly develop, finance, build and operate the facility for a concession period of 20 – 30 years. A special purpose vehicle (SPV) is often formed to execute the project which consists of representatives from both the private party and public party. Revenues from the long-term operation of the facility is collected by the SPV and distributed according to the equity of each party in that SPV. PPP contracts are starting to gain more traction in the GCC as large projects are being tendered on a PPP basis (power plants, infrastructure, etc.). The graph below shows the cumulative number of projects in the GCC countries by contract type since 2012.
Although PPP contracts do not represent more than 9% of total executed contracts in the GCC, their cumulative values are higher than EPC contracts as shown in the graph below.

![](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/Images/Graph%205.PNG)

## Kuwait

The Kuwaiti market has been declining since 2014 while neighboring countries such as Saudi Arabia and the UAE witness a development movement chiefly driven by the desire to diversify their revenues and reduce their dependency on oil. The graph below indicates a drop in project count in Kuwait from 386 projects (average value per project $ 240 million) in 2014 to 39 projects (average value per project $ 56 million).

![](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/Images/Graph%206.PNG)

### Political & Economic Climate
#### Impact of Politics on Projects Market

Protesting politicians and disruptions to decision-making are expected to plague Kuwaiti politics for the foreseeable future. In fact, parliament was dissolved in late June 2022 due to a long-running conflict between MPs. Kuwait's parliament approved the state budget for 2021-22 in June 2021, allowing progress on some key infrastructure projects, but the broader standoff between government and opposition, which has stymied reforms and slowed decision-making, has continued.

#### Economic Climate

The absence of a new public debt law, which would allow the government to borrow funds to cover its large budget deficit, is a major source of concern. Kuwait's government has not borrowed since 2017, relying instead on its General Reserve Fund and other liquid assets. Inaction on this front prompted S&P to downgrade Kuwait's rating from AA- to A+ in July 2021.

### Largest Clients in Kuwait

The table below indicates the largest project owners in the country per year. All of the clients listed in the table are governmental entities. Kuwait Integrated Petrochemical Industries Company (KIPIC) is the largest client between 2012 and 2022 with projects worth ~ $ 13 billion corresponding to the refinery project.

| **Year** |                     **Client**                     | **Projects Value ($m)** |
|:--------:|:--------------------------------------------------:|:------------------:     |
| 2012     | Kuwait Ministry of Electricity & Water             | 1,413                   |
| 2013     | Kuwait Authority for Partnership Projects          | 6,910                   |
| 2014     | Kuwait National Petroleum Company                  | 11,941                  |
| 2015     | Kuwait Integrated Petrochemical Industries Company | 12,926                  |
| 2016     | Kuwait Public Authority for Housing Welfare        | 11,804                  |
| 2017     | Kuwait Oil Company                                 | 3,224                   |
| 2018     | Kuwait Public Authority for Housing Welfare        | 445                     |
| 2019     | Kuwait Oil Company                                 | 556                     |
| 2020     | Kuwait Authority for Partenership Projects         | 1,400                   |
| 2021     | Kuwait Oil Company                                 | 1,386                   |
| 2022     | Kuwait Ministry of Electricity & Water             | 90                      |

## Kuwait Projects Pipeline

Despite close to $ 25 billion worth of projects in the pipeline, Kuwait requires a structural overhaul of its projects market to reach its potential. The largest proportion of projects (upwards of 62%) remain tied up in the study or design phase. Their progression to the tendering board could be slower than anticipated given the prevailing liquidity conditions in Kuwait.

![](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/Images/Graph%207.PNG)

### Largest Upcoming Projects

Queries 31 and 32 outline the details of the top 20 largest upcoming projects in Kuwait to be awarded between 2022 and 2023. Upcoming projects are all distributed between the construction and transport industries with the largest upcoming project having an estimated budget of $ 6.8 billion.

![](https://github.com/chaficazar/PortfolioProjects/blob/main/Project%204/Images/Graph%208.PNG)

Query 40 showcases the tentative contract award date of the upcoming projects. This information shall play a vital role for the business development unit to prepare and approach potential partners at least 3 months in advance.

### Finding the Most Suitable Partners

The business development unit is tasked with scanning the market for the most suitable partners to increase the chances of being awarded the upcoming projects. Since the largest upcoming projects are concentrated in the construction and transport industries, finding a partner with prior experience in executing similar projects with similar scopes and complexity is vital to increase our chances of success.
Three criteria were used to filter the results and shortlist favorable candidates to approach for upcoming projects:
1.	Having executed projects in the Construction and Transport industries
2.	Having executed projects in the above-mentioned industries within the past 5 years (2017 onwards)
3.	Having executed projects with values larger than 200 million
Therefore, query 39 returned a list containing 6 potential partners to approach for the joint bidding of upcoming projects in Kuwait.

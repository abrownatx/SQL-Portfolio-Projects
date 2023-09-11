/* We will be querying Covid-19 data from the "Our World in Data" website. The Covid-19 Deaths dataset was downloaded on July 5, 2023  */

--1) Lets take a look at the data and review its design.

SELECT *
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER BY 3,4

--2) Simple Calculation looking at Total Cases vs Total Deaths. Calculate the percentage and expressed as "DeathPercentage". (Global data)

SELECT continent, date, total_cases, total_deaths,(CAST(total_deaths AS numeric)/CAST(total_cases AS numeric))*100 DeathPercentage 
FROM PortfolioProject..CovidDeaths
Where continent is not null
ORDER by 3, 4

--3) Simple Calculation looking at Total Cases vs Total Deaths. Calculate the percentage and expressed as "DeathPercentage". (United States)

SELECT location, date, total_cases, total_deaths,(CAST(total_deaths AS numeric)/CAST(total_cases AS numeric))*100 DeathPercentage 
FROM PortfolioProject..CovidDeaths
Where location like 'United States'
ORDER by 3, 4 desc

--As of July 2023, the liklihood of dying from contracting Covid in the U.S. is roughly 1.1%.
--As of July 5th,2023, 1,127,152 Americans have died from Covid 


--4) Looking at the Total Cases vs Population with the calculation expressed as "CaseRate" also known as incidence rate.

SELECT location, date, population, CAST(total_cases AS numeric), (CAST(total_cases AS numeric)/CAST(population AS numeric))*100 PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
Where location like 'United States'
ORDER by 3, 4 desc

--As of July 5th,2023, the percentage of Covid in the US is 30.58%.

--5) What countries have the highest infection rates?

SELECT location, population, MAX(CAST(total_cases AS numeric)) AS HighestInfectionCount, MAX(CAST(total_cases AS numeric)/(CAST(population AS numeric)))*100 PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE location like 'United States'
Where continent is not null
GROUP by location, population
ORDER by PercentPopulationInfected desc

--The Top 5 countries for infection rates are Cyprus (73.76%), San Marino (72.21%), Brunei (68.67%), Austria(68.03%), and Faeroe Islands(65.25%).

--6) Showing the countries with the highest reported death count per population

SELECT location, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'United States'
Where continent is not null
GROUP by location
ORDER by TotalDeathCount desc

--United States	1127152
--Brazil	703964
--India	    531908
--Russia	399649
--Mexico	334336


--7) Lets break the data down by global stats:

SELECT location, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'United States'
Where continent is null
GROUP by location
ORDER by TotalDeathCount desc

--World Count:
--6948751

--What are the counts by continent?

--Europe 2072538
--Asia	1631583
--North America	1602361
--South America	1354884
--Africa 258982
--Oceania 28398

--What are the counts by High, Upper Middle, Lower Middle, and Lower income?

--High Income 2894749
--Upper Middle Income 2663745
--Lower Middle Income 1338347
--Low Income 47958


--8) This data gives us an idea of new cases and deaths in the world by date.

SET ARITHABORT OFF
SET ANSI_WARNINGS OFF

SELECT date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, ISNULL(SUM(new_deaths)/SUM(new_cases),0)*100 As DeathPercentage
FROM PortfolioProject..CovidDeaths
--Where location like 'United States'
Where continent  is not null
group by date
order by date 

--Note, to avoid places in data that threw an error due to division by 0.
--With both ARITHABORT and ANSI_WARNINGS set to OFF, SQL Server will return a NULL value in a calculation involving a divide-by-zero error. 
--To return a 0 value instead of a NULL value, you can put the division operation inside an ISNULL function:


-- 9) We are going to join both data sets we created, and alias the tables as CovidDeaths = dea, and CovidVaccinations = vac
--Next we will determine the total population vs vaccinations in the world
--We will also include a rolling count of vaccinations by country and name this column, cummulativeVaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) AS CummulativeVaccinations
FROM PortfolioProject..CovidDeaths dea

JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 1, 2, 3

--10) Here we will use CTE to look at vaccinations relative to the population

With PopvsVac (Continent, location, date, population, New_vaccinations, CummulativeVaccinations)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) AS CummulativeVaccinations
FROM PortfolioProject..CovidDeaths dea

JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1, 2, 3
)

SELECT *, (CummulativeVaccinations/population)*100 AS PercentPopulationVaccinated
FROM PopvsVac


--11) We will create a Table of PercentPopulationVaccinated using a temp table approach.

DROP Table if exists #percentpopulationvaccinated
CREATE Table #percentpopulationvaccinated
(Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CummulativeVaccinations numeric
)

Insert into #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) AS CummulativeVaccinations
FROM PortfolioProject..CovidDeaths dea

JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1, 2, 3


SELECT *, (CummulativeVaccinations/population)*100 AS PercentageVaccinated
FROM #percentpopulationvaccinated

--12) Creating views to store data for Tableau Visualizations

--View 1
CREATE VIEW TotalDeathCount as
SELECT continent, MAX(CAST(total_deaths AS numeric)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like 'United States'
Where continent is not null
GROUP by continent
--ORDER by TotalDeathCount desc

--View 2
CREATE View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as numeric)) OVER (Partition by dea.location Order by dea.location, dea.date) AS CummulativeVaccinations
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1, 2, 3




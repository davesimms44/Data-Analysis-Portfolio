SELECT *
FROM Portfolio..CovidDeaths
Where continent is not null
ORDER BY 3,4

--SELECT *
--FROM Portfolio..CovidVaccinations
--ORDER BY 3,4

-- Select data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio..CovidDeaths
Where continent is not null
order by 1,2

-- Looking at Total Cases Vs Total Deaths
--Shows chance of dieing as % of 100 if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 as CaseDeathPercentage
FROM Portfolio..CovidDeaths
Where location like '%Canada%' and continent is not null
order by 1,2 

-- Looking at Total Cases Vs Population
Select Location, date, population, total_cases, (total_cases /  Population) * 100 as CaseRate
FROM Portfolio..CovidDeaths
Where location like '%Canada%'
order by 1,2 

-- Looking at countries with highest infection rate compared to Population
Select Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases /  Population)) * 100 as PercentPopulationInfected
FROM Portfolio..CovidDeaths
Group by location, population 
order by PercentPopulationInfected DESC


--Showing countries with highest death count per population
Select Location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM Portfolio..CovidDeaths
Where continent is not null
Group by location
order by TotalDeathCount DESC

    --Break things down by continent

-- Showing continents with the highest death count

Select location, MAX(cast(total_deaths as bigint)) as TotalDeathCount
FROM Portfolio..CovidDeaths
Where continent is null
Group by location
order by TotalDeathCount DESC

-- or, for visulization

Select continent, MAX(cast(total_deaths as bigint)) as TotalDeathCOunt
from Portfolio..CovidDeaths
where continent is not null
Group by continent
Order by TotalDeathCount desc

-- GLOBAL NUMBERS

Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast( new_deaths as bigint)) / SUM(new_cases) *100 as CaseDeathPercentage
FROM Portfolio..CovidDeaths
--Where location like '%Canada%' 
Where continent is not null
Group by date
order by 1,2 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as bigint)) as total_deaths, SUM(cast( new_deaths as bigint)) / SUM(new_cases) *100 as CaseDeathPercentage
FROM Portfolio..CovidDeaths
--Where location like '%Canada%' 
Where continent is not null
order by 1,2 


--Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaxCount
, (RollingVaxCount/population)*100
from Portfolio..Coviddeaths dea
join Portfolio..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE

With PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingVaxCount)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaxCount
--, (RollingVaxCount/population)*100
from Portfolio..Coviddeaths dea
join Portfolio..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaxCount / Population)*100
From PopvsVac
 

 With PopvsVac (Continent, Location,  Population, new_vaccinations, RollingVaxCount)
as 
(
Select dea.continent, dea.location, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaxCount
--, (RollingVaxCount/population)*100
from Portfolio..Coviddeaths dea
join Portfolio..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingVaxCount / Population)*100
From PopvsVac
 





 --TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
 Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_vaccinations numeric,
 RollingVaxCount numeric
 )

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaxCount
--, (RollingVaxCount/population)*100
from Portfolio..Coviddeaths dea
join Portfolio..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
-- where dea.continent is not null
--order by 2,3
 
Select *, (RollingVaxCount / Population)*100
From #PercentPopulationVaccinated





--Creating view to store data for later visulizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as RollingVaxCount
--, (RollingVaxCount/population)*100
from Portfolio..Coviddeaths dea
join Portfolio..covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
 

 Select *
 From PercentPopulationVaccinated
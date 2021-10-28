
SELECT *
FROM coviddata..CovidDeaths
--where location like '%states%'
ORDER BY 3, 4

SELECT *
FROM coviddata..CovidVaccinations
--where location like '%states%'
ORDER BY 3, 4


Select Location, date, total_cases, new_cases, total_deaths, population
From coviddata..CovidDeaths
Where location like '%states%'
and continent is not null
order by 1,2


--Total Cases Vs Deaths
--Shows likelyhood of dying if contracted COVID in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From coviddata..CovidDeaths
Where location like '%Korea%'
and continent is not null 
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddata..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


--Countries with Highest Death count per population

SELECT Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
FROM coviddata..CovidDeaths
WHERE continent is not NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


--Daily new cases and deaths with updated totals, global numbers

Select CAST(date as DATE) as Date,
SUM(new_cases) as new_cases,
SUM(cast(total_cases as int)) as total_cases,
SUM(cast(new_deaths as int)) as new_deaths,
SUM(cast(total_deaths as int)) as total_deaths,
SUM(cast(total_deaths as int))/SUM(total_Cases)*100 as DeathPercentage
From coviddata..CovidDeaths
where continent is not null
Group By date
Order by date


--Total vaccinations over time by country

Select dea.continent, dea.location, CAST(dea.date as date) as date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location ORDER BY dea.location, dea.Date) as Rolling_People_Vaccinated
--, (Rolling_People_Vaccinated/population)*100
From coviddata..CovidDeaths dea
JOIN coviddata..CovidVaccinations vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null
and dea.Location like '%states%'
order by 2, 3


-- Temp Table

DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date date,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, CAST(dea.date as date) as date, dea.population, vac.new_vaccinations
, SUM(CONVERT(numeric, vac.new_vaccinations)) OVER (partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (Rolling_People_Vaccinated/population)*100
From coviddata..CovidDeaths dea
JOIN coviddata..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
and dea.Location like '%states%'
order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


--Creating view to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
Select dea.continent, dea.location, CAST(dea.date as date) as date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.Location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
--, (Rolling_People_Vaccinated/population)*100
From coviddata..CovidDeaths dea
JOIN coviddata..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--and dea.Location like '%states%'
--order by 2, 3




------------------------Queries for Tableau Dashboard---------------------

-- 1.

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From coviddata..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2



-- 2. 

-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From coviddata..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddata..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From coviddata..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc


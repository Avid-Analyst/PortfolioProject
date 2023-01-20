select *
from portfolioProject..CovidDeath
order by 4


select * 
from portfolioProject..CovidVaccine
order by 4

Select Location , date, total_cases, new_cases, total_deaths, population
from portfolioProject..CovidDeath
order by 1

-- Looking at deaths per caseload in india
Select Location , date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
from portfolioProject..CovidDeath
where location='India'
order by 1


-- Looking at total cases per total population
--percentage of population contracted covid
Select Location ,date,  Total_cases, Population, (Total_cases/Population)*100 as case_rate
from portfolioProject..CovidDeath
--where location='India'
order by 1


--highest infection rate
Select Location ,MAX(total_cases) as Highestinfection, Population, MAX(total_cases/Population)*100 as case_rate
from portfolioProject..CovidDeath
--where location='India'
Group by Location, Population
order by case_rate desc

-- Countries with the highest death count per population
Select Location ,MAX(total_deaths) as HighestDeaths, Population, MAX(total_deaths/Population)*100 as death_rate
from portfolioProject..CovidDeath
--where location='India'
where continent is not null
Group by Location, Population
order by death_rate desc


--countries with highest deathcount irrespective of population
Select Location ,MAX(cast(total_deaths as int)) as HighestDeaths
from portfolioProject..CovidDeath
--where location='India'
where continent is not null
Group by Location
order by HighestDeaths desc


-- things by continent
Select continent, MAX(cast(total_deaths as int)) as Totaldeathcount
from portfolioProject..CovidDeath
where continent is not null

group by continent 
order by Totaldeathcount desc



-- Global numbers
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_rate
from portfolioProject..CovidDeath
--where location='India'
where continent is not null
--group by date
order by 1,2


-- total number of vaccinated people
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date ) as rollingnumberof_vaccinated
from portfolioProject..CovidDeath dea
join portfolioProject..CovidVaccine vac
    on dea.location =vac.location
    and dea.date= vac.date
where dea.continent is not null
order by 2,3


--use CTE
with PopvsVac (continent, location, date, population, new_vaccinations, rollingnumberof_vaccinted)
as(
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date ) as rollingnumberof_vaccinated
from portfolioProject..CovidDeath dea
join portfolioProject..CovidVaccine vac
    on dea.location =vac.location
    and dea.date= vac.date
where dea.continent is not null)
--order by 2,3
select * , (rollingnumberof_vaccinted/population)*100
from PopvsVac

--Temp table 
drop table if exists #percentpopulationvaccinated
create table #percentpopulationvaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccination numeric,
rollingnumberof_vaccinated numeric
)

Insert into #percentpopulationvaccinated
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint, vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date ) as rollingnumberof_vaccinated
from portfolioProject..CovidDeath dea
join portfolioProject..CovidVaccine vac
	on dea.location= vac.location
	and dea.date= vac.date
	where dea.continent is not null

select * , (rollingnumberof_vaccinated/population)*100
from #percentpopulationvaccinated


-- creating view to store data for later visualization

create view percentpopulationvaccinated as
select dea.continent, dea.location,dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date ) as rollingnumberof_vaccinated
from portfolioProject..CovidDeath dea
join portfolioProject..CovidVaccine vac
    on dea.location =vac.location
    and dea.date= vac.date
where dea.continent is not null
--order by 2,3

select * 
from percentpopulationvaccinated
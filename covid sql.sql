select * 
from [portfolio project]..CovidDeaths
where continent is not null
order by 3,4


select location, date, total_cases,new_cases,total_deaths , population
from [portfolio project]..CovidDeaths
order by 1,2

-- total cases vs total deaths 

select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [portfolio project]..CovidDeaths
where location like '%canada%'
order by 1,2 


-- total cases vs population 
select location, date, total_cases,population, (total_cases/population)*100 as PercentPopulationInfected
from [portfolio project]..CovidDeaths
--where location like '%canada%'
order by 1,2 

-- countries with highest infection rate compared to  population 
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
from [portfolio project]..CovidDeaths
group by population , location
order by PercentPopulationInfected desc


-- countries with highest death count per population 
select location , max(cast(total_deaths as int)) as TotalDeaths
from [portfolio project]..CovidDeaths
where continent is not null
group by  location
order by TotalDeaths desc


--continents with highest deaths
select continent , max(cast(total_deaths as int)) as TotalDeaths
from [portfolio project]..CovidDeaths
where continent is not null
group by  continent
order by TotalDeaths desc


-- global data 
select date, sum(new_cases) as Totalcases, sum(cast(new_deaths as int)) as TotalDeaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from [portfolio project]..CovidDeaths
where continent is not null 
group by date
order by 1,2 


-- total population vs vaccinations 

select dea.continent , dea.location ,dea.date , dea.population ,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as RollingVaccineData
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3

 -- using CTE
 with popvsvac  ( continent , location , date, population , new_vaccinations ,RollingVaccineData)
 as
 (
 select dea.continent , dea.location ,dea.date , dea.population ,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as RollingVaccineData
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 )

 select * , (RollingVaccineData/population)*100 as VaccinePercentage
 from popvsvac

-- temp table 
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVaccineData numeric
)

insert into #PercentPopulationVaccinated
select dea.continent , dea.location ,dea.date , dea.population ,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as RollingVaccineData
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 

 select * , (RollingVaccineData/population)*100 as VaccinePercentage
 from #PercentPopulationVaccinated



 -- create view

 create view PercentPopulationVaccinated as 
 select dea.continent , dea.location ,dea.date , dea.population ,vac.new_vaccinations, 
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , dea.date) as RollingVaccineData
from [portfolio project]..CovidDeaths dea
join [portfolio project]..CovidVaccinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 
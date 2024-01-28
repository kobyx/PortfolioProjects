select *
from PortfolioProject..CovidDeaths
--where continent is not null
where location='Upper middle income'
order by 2,3

--select *
--from PortfolioProject..CovidVactinations
--order by 2,3

select location, date,total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--looking at total cases vs total deats

--select location, date,total_cases, total_deaths, round((CONVERT(DECIMAL(10,1),total_deaths)/CONVERT(DECIMAL(10,1),total_cases))*100,2)
select location, date,total_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%state%'
order by 3 desc

--looking at total cases vs population
--shows what percentage of population got covid
select location, date,population, total_cases,(cast(total_cases as float)/cast(population as float))*100 as PopulationPercentage
from PortfolioProject..CovidDeaths
where location = 'United States'
order by 5 desc

--looking at countries with highest infection rate compared to population
select location,population, max(total_cases) as HighestInfectionCount,
max(cast(total_cases as float)/cast(population as float)*100) as PopulationPercentageInfected
--(max((cast(total_cases as float)/cast(population as float))))*100 as PopulationPercentageInfected
from PortfolioProject..CovidDeaths
--where location = 'United States'
group by location,population
order by PopulationPercentageInfected desc

--Showing countries with highest Death count per Population
select location,max(cast(total_deaths as float)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by TotalDeaths desc

select location,max(cast(total_deaths as float)) as TotalDeaths
from PortfolioProject..CovidDeaths
 where iso_code not like '%OW%'
 --and continent is null
group by location
order by TotalDeaths desc

select iso_code, continent
from PortfolioProject..CovidDeaths
group by continent,iso_code

select location
from PortfolioProject..CovidDeaths
where continent is null
group by location

--Showing continents with higher death count per population

select continent,max(cast(total_deaths as float)) as TotalDeaths
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by TotalDeaths desc

--global numbers
--use PortfolioProject -- to change database
--go

select date,sum(cast(new_cases  as float)) as NewC, sum(cast(new_deaths  as float)) as NewD,
sum(cast(new_deaths  as float))/sum(cast(new_cases  as float))*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
--and location like '%state%'
--order by 1,2 desc


--looking at total population vs vactination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations_smoothed,
sum(convert(float, vac.new_vaccinations_smoothed)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVactinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 order by 2,3


 --use CTE
 with PopsVsVact(continent, location, date, population,new_people_vaccinated_smoothed,RollingPeopleVactinated)
 as
 (
 select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
sum(convert(float, vac.new_people_vaccinated_smoothed)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVactinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3
 )

 select *,(RollingPeopleVactinated/population)*100
 from PopsVsVact

 --temp table
 drop table if exists #PercentPopulationVactinated
 create table #PercentPopulationVactinated
 (
 continent nvarchar(255),
 location nvarchar(255),
 date datetime,
 population nvarchar(255),
 new_people_vaccinated_smoothed nvarchar(255),
 RollingPeopleVactinated numeric
 )

 insert into #PercentPopulationVactinated
 select 
 dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
sum(convert(float, vac.new_people_vaccinated_smoothed)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVactinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3

  select *,(RollingPeopleVactinated/population)*100
 from #PercentPopulationVactinated

 --creating view to store data for later visualisation
--drop view if exists PercentPopulationVactinated
create view PercentPopulationVactinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_people_vaccinated_smoothed,
sum(convert(float, vac.new_people_vaccinated_smoothed)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVactinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVactinations vac
 on dea.location=vac.location
 and dea.date=vac.date
 where dea.continent is not null
 --order by 2,3

   select *
 from PercentPopulationVactinated
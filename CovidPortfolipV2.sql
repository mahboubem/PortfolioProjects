CREATE DATABASE IF NOT EXISTS PortfolioCovid;
use PortfolioCovid;
SELECT * 
FROM PortfolioCovid.covidvaccinations;



-- Select data that we are going to be using
select continent,Location, date, total_cases, new_cases, total_deaths, population
from PortfolioCovid.coviddeath
where continent is not null
order by location desc;

-- looking at total cases vs total deaths
-- shows liklihood of death if you contract covid in your country
select Location,date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioCovid.coviddeath
where Location = 'Canada';


-- Looking at Total cases vs Population
-- show what percentage of population got Covid
select Location,date, total_cases, population, (total_deaths/Population)*100 as CovidPercentage
from PortfolioCovid.coviddeath
where Location like '%Can%';

-- Looking at countries with highest Infection Rate compared to Population
select Location,population, max(total_cases) as HighestInfectionCount,max(total_cases/population)*100 as 
PercentPopulationInfected
from PortfolioCovid.coviddeath
group by Location,Population
order by PercentPopulationInfected desc;

-- Breaking down things by Continent
select continent, max(cast(total_deaths as double )) as TotalDeathCount
from PortfolioCovid.coviddeath
where continent != ''
group by continent
order by TotalDeathCount desc;


-- Showing Countries with Highest Death Count per Population
select location,max(cast(total_deaths as float )) as TotalDeathCount
from PortfolioCovid.coviddeath
where continent != ''
group by location
order by TotalDeathCount desc;


-- Global Numbers
select date, sum(new_cases) as total_cases, sum(cast(new_deaths as double)) as total_deaths, sum(cast(new_deaths as double))/
sum(new_cases)*100 as DeathPercentage
from PortfolioCovid.coviddeath
where continent!= ''
group by date
order by total_cases,total_deaths;



-- Looking at Total Population vs Vaccinations
-- Use CTE
With PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as double))  over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from PortfolioCovid.coviddeath as dea
join PortfolioCovid.covidvaccinations as vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != ''    
-- order by location,date
)

select *,(RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
from PopvsVac;


-- TEMP TABLE
drop table if exists PercentPopulatinVaccinatd;

create table PercentPopulatinVaccinatd
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);
select 
* 
from PercentPopulatinVaccinatd;

insert into PercentPopulatinVaccinatd
(
	Continent,Location,Date,Population,new_vaccinations,RollingPeopleVaccinated
)
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as double))  over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from 
PortfolioCovid.coviddeath as dea
join PortfolioCovid.covidvaccinations as vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != '';    
-- order by location,date
select *, (RollingPeopleVaccinated/Population)*100 as RollingPeopleVaccinatedPercentage
from PercentPopulatinVaccinatd;


-- Creating View to store data for later visualization

create view PercentPopulatinVaccinatd as
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as double))  over (partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from 
PortfolioCovid.coviddeath as dea
join PortfolioCovid.covidvaccinations as vac
	on dea.location = vac.location
    and dea.date = vac.date
where dea.continent != '' ;  
-- order by location,date

select *
from PercentPopulatinVaccinatd;





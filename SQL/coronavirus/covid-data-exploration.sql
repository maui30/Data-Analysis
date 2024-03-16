select * from covidDeaths
order by 1,2

--percentage of dying in the PH if you are infected 
select location, date, population, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from covidDeaths
--where location = 'Philippines'
order by 1,2;

--Countries with the highest infection rate compared to population
select location, population, MAX(total_cases) as highest_infection_rate, MAX((total_cases/population))*100 as death_percentage
from covidDeaths
--where location = 'Philippines'	
group by location, population
order by death_percentage desc;

--Highest death count per population in a country
select location , MAX(total_deaths) as total_death_count ,MAX((total_deaths/population))*100 as death_per_population
from covidDeaths
where continent is not null
group by location
order by total_death_count desc;



--BY CONTINENT
--Highest death count per population in a country
select continent , MAX(total_deaths) as total_death_count ,MAX((total_deaths/population))*100 as death_per_population
from covidDeaths
where continent is not null
group by continent
order by total_death_count desc;

--continent death counts
select continent, MAX(total_deaths) as highest_death
from covidDeaths
where continent is not null
group by continent
order by highest_death desc;


--GLOBAL 
select date, SUM(new_cases) as cases, SUM(new_deaths) as deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0) * 100 as death_percentage
from covidDeaths
where continent is not null
group by date
order by 1,2;

select SUM(new_cases) as cases, SUM(new_deaths) as deaths, SUM(new_deaths)/NULLIF(SUM(new_cases),0) * 100 as death_percentage
from covidDeaths
where continent is not null
order by 1,2;




--SECOND TABLE
select * 
from covidDeaths death
join covidVacc vacc
	on death.location = vacc.location
	and death.date = vacc.date

--number of people vaccinated
--adds whenever there is value in new_vacc
select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as count_total_vacc
from covidDeaths dea
join covidVacc  vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
order by 1,2,3;



--using CTE (Common Table Expression)
with vaccination (continent, location, population, date, new_vacc, count_total_vacc)
as
(
select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as count_total_vacc
from covidDeaths dea
join covidVacc  vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null
)

select *, (count_total_vacc/population)*100 as vacc_percentage
from vaccination




--Creating view for visualizations
create view percent_vacc as
select dea.continent, dea.location, dea.population, dea.date, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as float)) over (partition by dea.location order by dea.location, dea.date) as count_total_vacc
from covidDeaths dea
join covidVacc  vac
on dea.location = vac.location and dea.date = vac.date
where dea.continent is not null;
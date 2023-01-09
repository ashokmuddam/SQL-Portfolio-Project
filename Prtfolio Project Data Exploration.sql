
SELECT *
FROM PortfolioProject..Coviddeaths
where continent is not null
order by 3,4

SELECT *
FROM PortfolioProject..Covidvaccine
order by 3,4

--select the data  that we are going to use


select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..Coviddeaths
where continent is not null
order by 1,2

--total_cases vs total_deaths
--shows likelihood of dying if you contract in your country

select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as deathpercentage 
from PortfolioProject..Coviddeaths
where location like '%india%'
order by 1,2

--Looking at Total cases vs population
--Shows what percentage of population got Covid

select location, date, population, total_cases, (total_cases/population) * 100 as total_case_percentage 
from PortfolioProject..Coviddeaths
where location like '%india%' and continent is not null
order by 1,2


--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highestinfectioncount, max((total_cases/population)) * 100 as percentpopulationinfected
from PortfolioProject..Coviddeaths
group by location, population
--where location like '%india%'
order by percentpopulationinfected DESC

--Showing this country with highest death count

select location, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..Coviddeaths
--where location like 'india%'
where continent is not null
group by location
order by totaldeathcount DESC


--LETS BREAK THINGS DOWN BY CONTINENT


select continent, MAX(cast(total_deaths as int)) as totaldeathcount
from PortfolioProject..Coviddeaths
--where location like 'india%'
where continent is not null
group by continent
order by totaldeathcount DESC

--Globel Numbers

select date, SUM(new_cases) as total_deaths, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ SUM(new_cases)*100 as death_percentage
from PortfolioProject..Coviddeaths
--where location like 'india%'
where continent is not null
group by date
order by 1,2


--without date

select SUM(new_cases) as total_deaths, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/ SUM(new_cases)*100 as death_percentage
from PortfolioProject..Coviddeaths
--where location like 'india%'
where continent is not null
--group by date
order by 1,2



--Covid_vaccination 

select *
from PortfolioProject..Coviddeaths death
	join PortfolioProject..Covidvaccine vaccine
		on death.location = vaccine.location
		and death.date = vaccine.date


-- Looking at Total population vs total vaccinated

select death.continent, death.location, death.population, vaccine.new_vaccinations, sum(convert(int,vaccine.new_vaccinations)) over (partition by death.location order by death.location, death.date) as rollingpeoplevaccination
from PortfolioProject..Coviddeaths death
	join PortfolioProject..Covidvaccine vaccine
		on death.location = vaccine.location
		and death.date = vaccine.date
where death.continent is not null
--order by 2,3


--USE CTE

with populationvsvaccination (continent, location, date, population, new_vaccinations, rollingpeoplevaccination)
as
(
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(int,vaccine.new_vaccinations))
Over (partition by death.location, death.date) as rollingpeoplevaccinations
from PortfolioProject..Coviddeaths death
	join PortfolioProject..Covidvaccine vaccine
		on death.location = vaccine.location
		and death.date = vaccine.date
where death.continent is not NULL
--order by 2,3
)
select *
from populationvsvaccination


-- TEMP TABLE

DROP table if exists percentpopulationvaccinated
create table percentpopulationvaccinated
(continent varchar(255),
location varchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinated numeric
)

Insert into percentpopulationvaccinated
select death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(int,vaccine.new_vaccinations))
Over (partition by death.location, death.date) as rollingpeoplevaccinations
from PortfolioProject..Coviddeaths death
	join PortfolioProject..Covidvaccine vaccine
		on death.location = vaccine.location
		and death.date = vaccine.date
--where death.continent is not NULL
--order by 2,3
select *, (rollingpeoplevaccinated/population)*100 as vaccinatedcount
from percentpopulationvaccinated


--CREATE VIEW TO STORE DATA FOR LATER VISUALIZATION

Create View percentpopulationsvaccinated as
select  death.continent, death.location, death.date, death.population, vaccine.new_vaccinations, SUM(CONVERT(int,vaccine.new_vaccinations))
Over (partition by death.location, death.date) as rollingpeoplevaccinations
from PortfolioProject..Coviddeaths death
	join PortfolioProject..Covidvaccine vaccine
		on death.location = vaccine.location
		and death.date = vaccine.date
where death.continent is not NULL
--order by 2,3

--select *
--from percentagepopulationvaccinated
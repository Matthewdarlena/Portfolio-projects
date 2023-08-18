   /*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

Select *
From PortfolioProject..covid_deaths
order by 3,4


-- Select Data that we are going to be starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..covid_deaths
order by 1,2


-- Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..covid_deaths
Where location like '%nigeria%'
order by 1,2


-- Total Cases vs Population
-- Shows what percentage of population infected with Covid

Select Location, date, Population, total_cases,  (total_cases/population)*100 as percent_infected_population
From PortfolioProject..covid_deaths
--Where location like '%states%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, max(total_cases) as highest_infection_count, max((total_cases/population)*100) as percent_infected_population
From PortfolioProject..covid_deaths
--where location like '%nigeria%'
group by location, population
order by 4 desc


-- Countries with Highest Death Count per Population

Select Location, max(cast(total_deaths)) as total_death_count
From PortfolioProject..covid_deaths
--where location like '%nigeria%'
where continent is not null
group by location
order by 2 desc

--cyprus have higher infection rate but lower cases than the states because they have a smaller population 

select location, max(total_cases) as total_cases , max(total_deaths) as total_deaths
from portfolioproject..covid_deaths
where location in ('nigeria', 'cyprus', 'united states')
group by location
order by 1,2

-- Showing contintents with the highest death count per population

Select continent, max(total_deaths) as total_death_count
From PortfolioProject..covid_deaths
where continent is not null
group by continent
order by 2 desc

  
Select location as continent, max(total_deaths) as total_death_count
From PortfolioProject..covid_deaths
where continent is null 
AND LOCATION not in ('High income','Upper middle income','Lower middle income', 'European Union','Low income','world')
group by location
order by 2 desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as death_percentage
From PortfolioProject..covid_deaths
where continent is not null 
--Group By date
--order by 1,2    



-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over (
      partition by dea.location
	  order by dea.location, dea.date
	  ) as vaccinated_rolled_up
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null 
order by 1,2,3


-- Using CTE to perform Calculation on Partition By in previous query

with population_vs_vaccinated (continent, location, date, population, new_vaccinations,vaccinated_rolled_up)
as
(
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over (
      partition by dea.location
	  order by dea.location, dea.date
	  ) as vaccinated_rolled_up
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null 
)
select*, (vaccinated_rolled_up/population)*100 as percentage_of_population_vaccinated
from population_vs_vaccinated



-- Using Temp Table to perform Calculation on Partition By in previous query

drop table if exists #percentage_of_population_vaccinated
create table #percentage_of_population_vaccinated
(continent nvarchar (255), 
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccinated_rolled_up numeric)

insert into #percentage_of_population_vaccinated
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over (
      partition by dea.location
	  order by dea.location, dea.date
	  ) as vaccinated_rolled_up
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null 

select*, (vaccinated_rolled_up/population)*100 as percentage_of_population_vaccinated
from #percentage_of_population_vaccinated




-- Creating View to store data for later visualizations

create view percentage_of_population_vaccinated as
select dea.continent, dea.location,dea.date, dea.population,vac.new_vaccinations,
sum(cast(vac.new_vaccinations as bigint)) 
over (
      partition by dea.location
	  order by dea.location, dea.date
	  ) as vaccinated_rolled_up
from PortfolioProject..covid_deaths dea
join PortfolioProject..covid_vaccinations vac
    on dea.location=vac.location
    and dea.date=vac.date
where dea.continent is not null 

select*
from percentage_of_population_vaccinated
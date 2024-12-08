
--Covid 19 Data Exploration 

-- Skills used: Joins, CTE's, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types



-- Select Data that we are going to be starting with

Select *
From projectportfolio.dbo.CovidDeaths$
Where continent is not null 
order by 3,4



--total cases vs total deaths
-- shows the likelihood in percentage of dying if you have covid in you country
select location, date, total_cases, total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
from projectportfolio.dbo.CovidDeaths$
where location like '%states%'
order by location, date;


-- total cases vs population

select location, date, total_cases, population, (total_cases / population) * 100 as '% of population with covid'
from projectportfolio.dbo.CovidDeaths$
--where location like '%states%'
order by location, date;

-- finding countries with highest inefection rate with compared to population

select location, population, MAX (total_cases) as 'highest infection count',  max(total_cases / population) * 100 as '% of population with covid'
from projectportfolio.dbo.CovidDeaths$
group by location, population
order by  max(total_cases / population) * 100 desc;


-- finding countries with highest death count per population

select location, max (cast(total_deaths as int)) as 'Total Death count'
from projectportfolio.dbo.CovidDeaths$
where continent is not null 
group by location
order by max (cast(total_deaths as int)) desc;

-- finding continents with highest death count per population

select continent, max (cast(total_deaths as int)) as 'Total Death count'
from projectportfolio.dbo.CovidDeaths$
where continent is not null
group by continent
order by max (cast(total_deaths as int)) desc;

--  global numbers of people infected comapred to global deaths

select date, Sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as totald_deaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as deathpercentage
from projectportfolio.dbo.CovidDeaths$
where continent is not null
group by date
order by date;

-- total deaths in the world and total infected

select Sum(new_cases) as total_cases , sum(cast(new_deaths as int)) as totald_deaths, sum(cast(new_deaths as int)) / sum(new_cases) * 100 as deathpercentage
from projectportfolio.dbo.CovidDeaths$
where continent is not null
order by 1,2;

-- Percentage of Population Infected by Continent

SELECT location, MAX(total_cases) AS total_cases, MAX(total_deaths) AS total_deaths, (MAX(total_deaths) / MAX(total_cases)) * 100 AS death_ratio
FROM projectportfolio.dbo.CovidDeaths$
WHERE total_cases > 0
GROUP BY location
ORDER BY death_ratio DESC;

-- Most Vaccinated Continents

WITH vaccine_stats AS (
SELECT death.continent, MAX(death.population) AS total_population, SUM(CAST(vac.people_vaccinated AS DECIMAL(25,15))) AS total_vaccinated
FROM projectportfolio.dbo.CovidDeaths$ AS death
JOIN projectportfolio.dbo.CovidVaccinations$ AS vac ON death.location = vac.location 
and death.date = vac.date
WHERE death.continent IS NOT NULL
GROUP BY death.continent
)
SELECT continent, total_population, total_vaccinated, (total_vaccinated / total_population) * 100 AS vaccination_rate
FROM vaccine_stats
ORDER BY vaccination_rate DESC;





-- total population vs total vactionation


with popvsvac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
as 

(
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as Rolling_people_vaccinated
from projectportfolio.dbo.CovidDeaths$ as death
join projectportfolio.dbo.CovidVaccinations$ as vac on death.location = vac.location 
and death.date = vac.date
where death.continent is not null
)

select *, (Rolling_people_vaccinated/population)*100
from popvsvac


-- creating view to store data for later visualizations

create view popvsvac as  
select death.continent, death.location, death.date, death.population, vac.new_vaccinations, 
sum(convert(int, vac.new_vaccinations)) over (partition by death.location order by death.location, death.date) as Rolling_people_vaccinated
from projectportfolio.dbo.CovidDeaths$ as death
join projectportfolio.dbo.CovidVaccinations$ as vac
on death.location = vac.location 
and death.date = vac.date
where death.continent is not null

select *
from popvsvac




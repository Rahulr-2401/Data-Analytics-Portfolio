select * from [covid proj]..CovidDeaths
where continent is not null --because it has asia(continent as location)
order by 3,4;

select * from [covid proj]..CovidDeaths
ORDER BY 3,4;

--SELECT  data that we are gonna use
Select Location,date,total_cases,
new_cases,total_deaths,POPULATION
 from [covid proj]..CovidDeaths
 order by 1,2;

-- looking at total cases vs total deaths in a country
-- shows likelihood of dying if you contract contact in our country
select location,date,total_cases,total_deaths,round((total_deaths/total_cases)*100,2) as DeathPer
from CovidDeaths
where lower(location) ='india'
order by 1,2;

--when waas the max death
select location,max(round((total_deaths/total_cases)*100,2)) as max_death
from [covid proj]..CovidDeaths
group by location
order by 1;

--looking at total case vs population
-- shows what percentage ofpopulation got Covid
select location,date,total_cases,population,round((total_cases/population)*100,2) as popPer
from [covid proj]..CovidDeaths
where lower(location) ='india'
order by 1,2;

--looking at countries with highest infection rate compared to pop
select location,population,max(total_cases) as HighestCaseCount,
Max(round((total_cases/population)*100,2)) as PopPer
from [covid proj]..CovidDeaths
group by location,population
order by 4 desc;

--looking at highest death count per population
select location,max(cast(total_deaths as int )) as Total_deathCount
from [covid proj]..CovidDeaths
where continent is not null
group by location
order by 2 desc;

--showning continents with highest death rate
select continent,max(cast(total_deaths as int )) as Total_deathCount
from [covid proj]..CovidDeaths
where continent is not null
group by continent
order by 2 desc;

--GLOBAL numbers
select date,sum(new_cases) as Total_case  , sum(cast(new_deaths as int))
as Total_deaths,sum(cast(New_deaths as int))/Sum(new_cases)*100 as DeathPer
from [covid proj]..CovidDeaths
where continent is not null
group by date
order by 1,2;

--Total cases
select sum(new_cases) as Total_case  , sum(cast(new_deaths as int))
as Total_deaths,sum(cast(New_deaths as int))/Sum(new_cases)*100 as DeathPer
from [covid proj]..CovidDeaths
where continent is not null
--group by date
order by 1,2;

 --joins
--total population vs vaccinated
 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
 Sum(convert(int,v.new_vaccinations))OVER(Partition by d.Location
 order by d.location,d.date) as Rollingcountvacci
 from [covid proj]..CovidDeaths d
 join [covid proj]..CovidVaccinations v
 on d.location=v.location and d.date=v.date
 where d.continent is not null 
 order by 2,3;

 --total vaccinated using CTE
 with popvac (continent,location,date,population,new_vaccinations,
Rollingcountvacci) as (
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
 Sum(convert(int,v.new_vaccinations))OVER(Partition by d.Location
 order by d.location,d.date) as Rollingcountvacci
 from [covid proj]..CovidDeaths d
 join [covid proj]..CovidVaccinations v
 on d.location=v.location and d.date=v.date
 where d.continent is not null 
 --order by 2,3;
 )
 select *, round((Rollingcountvacci/population)*100,2) from popvac

 --temp table
 Drop table if exists #percent_popvacc
 create table #percent_popvacc
 (
 continent nvarchar(255),location nvarchar(255),date datetime,
 population numeric,new_vaccinations numeric,Rollingcountvacci numeric
 )
 insert into #percent_popvacc
 select d.continent,d.location,d.date,d.population,v.new_vaccinations,
 Sum(convert(int,v.new_vaccinations))OVER(Partition by d.Location
 order by d.location,d.date) as Rollingcountvacci
 from [covid proj]..CovidDeaths d
 join [covid proj]..CovidVaccinations v
 on d.location=v.location and d.date=v.date
 where d.continent is not null 
 --order by 2,3;

 select *, round((Rollingcountvacci/population)*100,2) 
 from #percent_popvacc

 --view
create view myview as 
select d.continent,d.location,d.date,d.population,v.new_vaccinations,
 Sum(convert(int,v.new_vaccinations))OVER(Partition by d.Location
 order by d.location,d.date) as Rollingcountvacci
 from [covid proj]..CovidDeaths d
 join [covid proj]..CovidVaccinations v
 on d.location=v.location and d.date=v.date
 where d.continent is not null 
 --order by 2,3; 

 select * from myview
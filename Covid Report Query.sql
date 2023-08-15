select * from PortfolioProject..covid_population
order by 3,4


--select * from PortfolioProject..covid_vacination
--order by 3,4

--Looking for total cases vs total deaths

Select location,date,total_cases, total_deaths, 
TRY_CAST(total_deaths as numeric(20,0))/TRY_CAST(total_cases as numeric(20,0))*100 DeathPercentage
from PortfolioProject..covid_data
order by 1, 2

--Looking at Total Cases vs population
--show what percentage of population got covid
Select location,date,population,total_cases,  
TRY_CAST(total_cases as numeric(20,0))/TRY_CAST(population as numeric(20,0))*100 DeathPercentage
from PortfolioProject..covid_data
--where location like '%ghana%'
order by 1, 2

--Looking for countries with Highest Infection rate compared to population 
Select location,population,max(total_cases)Highest_Infection,  
max(TRY_CAST(total_cases as numeric(20,0))/TRY_CAST(population as numeric(20,0)))*100 DeathPercentage
from PortfolioProject..covid_data
--where location like '%ghana%'
group by location,date,population
order by DeathPercentage desc

--Showing countries with highest death count per population

Select location,max(total_deaths)Highest_death  
from PortfolioProject..covid_data
where continent is not null
group by location
order by Highest_death desc

--break things down by continent
Select location,max(total_deaths)Highest_death  
from PortfolioProject..covid_population
where continent is not null
group by location
order by Highest_death desc

--GLOBAL NUMBERS
Select date,sum(TRY_CAST(new_cases as numeric(20,0)))new_cases,sum(TRY_CAST(new_deaths as numeric(20,0)))total_death,
SUM(TRY_CAST(new_deaths as numeric(20,0)))/SUM(NULLIF(TRY_CAST(new_cases as numeric(20,0)),0))*100 deathpercentage
from PortfolioProject..covid_population
where continent is not null

group by date


--Looking at total population vs vacination

Select s.continent,s.location,s.date,s.population,u.new_vaccinations from covid_population s
 INNER JOIN covid_vacination u
 ON s.location = u.location
 and s.date = u.date
 where s.continent is not null

 --Looking at totl popultion vs vacination

 Select s.continent,s.location,s.date,s.population,u.new_vaccinations,
 SUM(TRY_CONVERT(int,u.new_vaccinations)) OVER (Partition by s.location order by s.location,s.date) as rollingPeopleVacinated
 
 from covid_population s
 INNER JOIN covid_vacination u
 ON s.location = u.location
 and s.date = u.date
 where s.continent is not null
 order by 2,3


 --USE CTEs

 With PopVsVac(Continent,Location,date,population,vaccination,rollingPeopleVacinated)
 as
 (
 Select s.continent,s.location,s.date,s.population,u.new_vaccinations,
 SUM(TRY_CONVERT(int,u.new_vaccinations)) OVER (Partition by s.location order by s.location,s.date) as rollingPeopleVacinated
-- (rollingPeopleVacinated/population)*100
 
 from covid_population s
 INNER JOIN covid_vacination u
 ON s.location = u.location
 and s.date = u.date
 where s.continent is not null
 --order by 2,3
 )

 Select * ,(TRY_CONVERT(int,rollingPeopleVacinated)/TRY_CONVERT(int,population))*100 PeopleVacintedPercentage
 from PopVsVac


 --CREATING VIEW FOR LATER VISUALIZATION

 Create View PercentPopulationVaccination as
  Select s.continent,s.location,s.date,s.population,u.new_vaccinations,
 SUM(TRY_CONVERT(int,u.new_vaccinations)) OVER (Partition by s.location order by s.location,s.date) as rollingPeopleVacinated
-- (rollingPeopleVacinated/population)*100
 
 from covid_population s
 INNER JOIN covid_vacination u
 ON s.location = u.location
 and s.date = u.date
 where s.continent is not null
 --order by 2,3
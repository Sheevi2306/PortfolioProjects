Select *
From Project..CovidDeaths
--where continent is Null
order by 1,2

Select *
From Project..CovidVaccinations
order by 3,4

Select Location,date,total_cases,new_cases,total_deaths,population
From Project..CovidDeaths
order by 1,2
-- Covid cases in India
-- Total cases vs Total deaths
Select Location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percentage
From Project..CovidDeaths
Where location = 'India'
order by 2,5

-- total deaths Vs Population
Select Location,date,Population,total_deaths,(total_deaths/Population)*100 as Death_percentage
From Project..CovidDeaths
Where location = 'India'
order by 2,5

-- location with highest population infected
Select Location,Population,Max(total_cases) as HighestInfected,Max((total_cases/Population))*100 as PopulationInfected
From Project..CovidDeaths
--Where location = 'India'
Group by Location,Population
order by PopulationInfected desc

-- Countries with highest death percentage
Select Location,Max(cast(total_deaths as int)) as death_counts
From Project..CovidDeaths
--Where location = 'India'
Where continent is null
Group by location
order by death_counts desc

--Global numbers by date

Select date,SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From Project..CovidDeaths
--Where location = 'India'
Where continent is not null
Group by date
order by 1,2

--Total death percentage across the world

Select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage
From Project..CovidDeaths
--Where location = 'India'
Where continent is not null
--Group by date
order by 1,2

--Use Join in both the tables
--Total Population vs vaccinations
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as rollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE
With PopVsVacc (Continent,date,Location,Population,new_vaccinations,rollingPeopleVaccinated) 
as
(
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as rollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select*,(rollingPeopleVaccinated/Population)*100 as rollingPercentage
From PopVsVacc

Create View Final_vacc_table as
Select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.date) as rollingPeopleVaccinated
From Project..CovidDeaths dea
Join Project..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From Final_vacc_table

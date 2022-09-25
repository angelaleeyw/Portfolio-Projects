--COVID Data Exploration

--Taking a brief look at the CovidDeaths table and the CovidVaccinations table

Select *
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths
Where continent is not null
Order by 3,4

Select * 
From [Portfolio Project 1_COVID Data Exploration]..CovidVaccinations
Order by 3,4


-- Select the data that we are going to use

Select location, date, total_cases, new_cases, total_deaths, population
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Cases vs Total Deaths

-- Shows the likelihood of dying if you contract COVID in the US

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2


-- Looking at Total Cases vs Population

-- Shows the percentage of population that got COVID

Select location, date, population, total_cases, (total_cases/population)*100 as PercentagePopulationInfected
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths
Order by 1, 2


-- Looking at countries with highest infection rate compared to population

Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentagePopulationInfected
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths
Group by location, population
Order by PercentagePopulationInfected desc


-- Showing countries with highest death count per population

Select location, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc


-- Now, let's break things down by continent

Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


--Showing continents with the highest death count per population

Select continent, max(population) as TotalPopulation, max(cast(total_deaths as int)) as TotalDeathCount
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths
Where continent is not null
Group by continent
Order by TotalDeathCount desc


-- Global numbers

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))*100 as DeathPercentage
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths
Where continent is not null
Order by 1,2


-- Looking at Total Population vs Vaccinations

Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths CD
Join [Portfolio Project 1_COVID Data Exploration]..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
Order by 2, 3


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths CD
Join [Portfolio Project 1_COVID Data Exploration]..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


--Temp Table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths CD
Join [Portfolio Project 1_COVID Data Exploration]..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create view PercentPopulationVaccinated as 
Select CD.continent, CD.location, CD.date, CD.population, CV.new_vaccinations,
sum(convert(int, CV.new_vaccinations)) over (partition by CD.location order by CD.location, CD.date) as RollingPeopleVaccinated
From [Portfolio Project 1_COVID Data Exploration]..CovidDeaths CD
Join [Portfolio Project 1_COVID Data Exploration]..CovidVaccinations CV
	on CD.location = CV.location
	and CD.date = CV.date
Where CD.continent is not null

Select *
From PercentPopulationVaccinated
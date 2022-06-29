Select*
from PortfolioProject..CovidDeaths 
order by 3,4

Select*
from PortfolioProject..CovidVaccinations 
order by 3,4


Select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths 
order by 1,2 

-- Shows the Total Cases vs Total Deaths 
Select location, date, total_cases,  total_deaths, (total_deaths/total_cases)*100 as Death_Percentage 
from PortfolioProject..CovidDeaths 
where location = 'India'
order by 1,2 

-- Shows what percentage of population was infected by COVID
Select location, date, total_cases, population, (total_cases/population)*100 as Infection_Percentage 
from PortfolioProject..CovidDeaths 
where location = 'India'
order by 1,2 

-- Looking at countries with Highest Infection Rate compared to Population
Select location, MAX(total_cases) as Highest_Infections, population, MAX((total_cases/population))*100 as Infection_Percentage 
from PortfolioProject..CovidDeaths 
Group by location, population
order by Infection_Percentage desc

-- Showing Countries with Highest Death Count per Population
Select location, MAX(cast (total_deaths as int)) as Total_Deaths, population
from PortfolioProject..CovidDeaths
where continent is not null
Group by location, population
order by Total_Deaths desc


-- Showing the continents with the highest death count per population
Select continent, MAX(cast (total_deaths as int)) as Total_Deaths, population
from PortfolioProject..CovidDeaths
where continent is not null  
Group by continent, population
order by Total_Deaths desc

-- GLOBAL NUMBERS
Select date, SUM(new_cases) as Total_cases_per_day_globally, SUM(cast(total_deaths as int)) as Total_deaths_per_day_globally,  SUM(cast(total_deaths as int))/SUM(new_cases)*100 as Death_percentage_globally
from PortfolioProject..CovidDeaths 
where continent is not null
group by date 
order by 1,2

-- Looking at Total Population vs Vaccinations (CTE)
WITH POPVSVAC (continent, location, date, population, new_vaccinations, rolling_people_vaccinated) as
  (
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths as dea   
Join PortfolioProject..CovidVaccinations as vac
  ON dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null
  )
  Select*, (rolling_people_vaccinated/population)*100 as Percent_rolling_people_vaccinated
  From POPVSVAC 

--TEMP TABLE 

Drop table if exists #Percent_Population_Vaccinated
Create table #Percent_Population_Vaccinated
(
Continent nvarchar (255),
location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_people_vaccinated numeric
)

Insert Into #Percent_Population_Vaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths as dea   
Join PortfolioProject..CovidVaccinations as vac
  ON dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null

    Select*, (rolling_people_vaccinated/population)*100 as Percent_rolling_people_vaccinated
  from #Percent_Population_Vaccinated

Create view Percent_Population_Vaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(bigint,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths as dea   
Join PortfolioProject..CovidVaccinations as vac
  ON dea.location=vac.location
  and dea.date=vac.date
  where dea.continent is not null


   
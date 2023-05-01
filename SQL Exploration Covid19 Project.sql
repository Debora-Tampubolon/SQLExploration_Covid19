/*
Covid 19 Data Exploration
*/

Select *
From PortfolioProject1..CovidDeaths
Order by 3,4

--Select the data that we are going to use
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject1..CovidDeaths
Order by 1, 2

--Looking at Total Cases vs Total Deaths (percentage) in Indonesia
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where Location = 'Indonesia'
Order by 1,2

--Looking at Total Cases vs Population (percentage)
--This show what percentage of population infected with covid in Indonesia
Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From PortfolioProject1..CovidDeaths
Where Location = 'Indonesia'
Order by 1,2

--Looking at what country with highest infection rate by it's population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as InfectedPercentage
From PortfolioProject1..CovidDeaths
Group by population, location
Order by InfectedPercentage desc

--Looking at what country with highest death count per population
Select location, population, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Group by population, location
Order by TotalDeathCount desc

--Looking at what continent with highest death count per population
Select continent, max(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject1..CovidDeaths
Where continent is not null --cause there are country that have empty continent
Group by continent 
Order by TotalDeathCount desc

--Looking at death percentage globaly
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject1..CovidDeaths
Where continent is not null --cause there are country that have empty continent

--Looking at Total Population vs Vaccinations
--This show percentage of population that has recieved at least one covid vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Using CTE to perform calculation on Partition By in previous query
With PopvsVac (continent, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
)
Select*, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Using Temp Table to perform calculation on Partition By in previous query
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric, 
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

Select*, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Create view to store data for later visualizations
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(convert(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject1..CovidDeaths dea
Join PortfolioProject1..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null

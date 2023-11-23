--selecting data that is going to be used from CovidDeaths and CovidVaccinations.



--looking at total_cases vs death_percentage

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Deathpercentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
order by 1,2



--looking at total_cases vs Total_Cases_Percentage 

select location, date, population, total_cases, (total_cases/population)*100 as Total_cases_Percentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
order by 1,2



--looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as Highest_Infection_Count, max(total_cases/population)*100 as Highest_Infection_count_Percentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
group by location, population
order by 4 desc



--showing countries with highest death count per population

select location, max(cast (total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null 
group by location
order by 2 desc



--LET'S BREAK THINGS DOWN BY CONTINENT


--Showing continents with the highest death counts per population

select continent, max(cast (total_deaths as int)) as Total_Death_Count
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null 
group by continent
order by 2 desc



--Global Numbers 

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,
Sum(cast(new_deaths as int))/sum (new_cases)*100 as death_percentage
from PortfolioProject..CovidDeaths
--where location like '%Nigeria%'
where continent is not null 
--group by date
order by 1,2


--Looking at Total Population Vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as Rollin_People_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3



--Use CTE

with PopvsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as Rollin_People_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (Rolling_People_Vaccinated/population)*100
from PopvsVac



--Temp Table

drop table if exists #PercentagePopulationVaccinated
create table #PercentagePopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

insert into #PercentagePopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as Rollin_People_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *, (Rolling_People_Vaccinated/population)*100
from #PercentagePopulationVaccinated



--Looking at View


create view PercentagePopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum (convert (int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as Rollin_People_Vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3


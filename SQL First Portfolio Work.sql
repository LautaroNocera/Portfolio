SELECT * From PortfolioProyect..CovidDeaths 
where continent is not null
order by 3,4

--SELECT * FROM PortfolioProyect..CovidVaccinations
--Order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProyect..CovidDeaths
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deats per Country
-- Cuantos casos tienen por pais, cuantas muertes tienen, y cuanto es el porcentaje de casos que mueren
SELECT location, date, total_cases, total_deaths, ((total_deaths / total_cases) * 100) as PercentageDeathsPerDay
From PortfolioProyect..CovidDeaths
where continent is not null and location like '%Arg%' order by 1,2

-- Looking at Total Cases vs Population
--cuanto fue el % de la poblacion total que se contagio de covid

SELECT location, date, total_cases, population, ((total_cases / population) * 100) as PercentageCasesPerDay
From PortfolioProyect..CovidDeaths 
where continent is not null and location like '%Spa%' order by 1,2


-- Looking at countries with highest infection rate compared to population.
-- porcentage de poblacion contagiada de covid por pais

SELECT location, max(total_cases) AS HighestInfectionCases , population, ((Max(total_cases) / population) * 100) as
PercentagePopulationInfected
From PortfolioProyect..CovidDeaths
where continent is not null
group by population, location order by 4 desc

-- Showing Countries with Highest Death count per Population

SELECT location, max(cast(total_deaths as int)) AS HighestDeathCases 
From PortfolioProyect..CovidDeaths
where continent is not null
Group by location
order by HighestDeathCases desc

-- Y por continente? 

SELECT location, max(cast(total_deaths as int)) AS TotalDeathsPerContinent
FROM PortfolioProyect..CovidDeaths
where continent is null
group by location
order by TotalDeathsPerContinent desc


-- Datos mundiales

-- Numero de muertes y nuevos casos por dia en todo el mundo

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProyect..CovidDeaths
where continent is not null
group by date
order by 1,2

--Numero total de casos y muertes en todo el mundo.

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(CAST(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProyect..CovidDeaths
where continent is not null
order by 1,2


-- Let's work with both tables

SELECT * 
from PortfolioProyect..CovidDeaths AS dea
join PortfolioProyect..CovidVaccinations AS vac
	on dea.location = vac.location
	and dea.date = vac.date

-- Looking at Total Population vs Total Vaccionations.

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as VaccinatedcToDate
FROM PortfolioProyect..CovidDeaths as dea
Join PortfolioProyect..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- Quiero calcular el % de poblacion vacunada, lo hare de 2 maneras

--CTE

With TotalPeopleVac(continent, location, date , population, new_vaccinations, VaccinatedToDate)
AS (
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as VaccinatedToDate
FROM PortfolioProyect..CovidDeaths as dea
Join PortfolioProyect..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)

select *, ((VaccinatedToDate / population) * 100) as PercentageVaccinated
FROM TotalPeopleVac;



-- Temp Table

DROP TABLE if EXISTS  #PercentagePopulationVaccinated
Create Table #PercentagePopulationVaccinated
(
continent nvarchar (255),
location nvarchar (255),
date datetime,
population int,
New_vaccinations numeric,
VaccinatedToDate numeric
)

insert into #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as VaccinatedToDate
FROM PortfolioProyect..CovidDeaths as dea
Join PortfolioProyect..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

SELECT *, (VaccinatedToDate / population) *100
FROM #PercentagePopulationVaccinated

--creando la primera vista para visualizarlo luego

create view PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (PARTITION BY dea.Location order by dea.location, dea.date) as VaccinatedToDate
FROM PortfolioProyect..CovidDeaths as dea
Join PortfolioProyect..CovidVaccinations as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

-- 
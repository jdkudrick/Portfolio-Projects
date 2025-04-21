#select the data of interest 
SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM ProjectPortfolio.CovidDeaths cd 
ORDER BY 1, 2; 

#what is the mortality rate for COVID (sick population versus whole population?) and how many people are gettiing COVID?
SELECT Location, date, total_cases, total_deaths, population,
	ROUND((total_deaths/total_cases) * 100, 4) as infected_mortality,
	ROUND((total_cases/population) * 100, 4) as prevalence,
	ROUND((total_deaths/population) * 100, 4) as total_mortality	
FROM ProjectPortfolio.CovidDeaths cd 
WHERE continent <> ''
ORDER BY 1, 2; 

#case count and prevelance by country
SELECT Location, population, MAX(total_cases) as infection_count, 
	MAX(ROUND((total_cases/population)*100,4)) as prevelance
FROM ProjectPortfolio.CovidDeaths cd
WHERE continent <> ''
GROUP BY Location, population
ORDER BY prevelance DESC;

#death rates per country 
SELECT Location, population, MAX(total_deaths) as highest_death_rates
FROM ProjectPortfolio.CovidDeaths cd 
WHERE continent <> '' #exclude  whole continents
GROUP BY Location, population
ORDER BY highest_death_rates DESC;

#death count by region
SELECT location, MAX(total_deaths) as total_casualties
FROM ProjectPortfolio.CovidDeaths cd 
WHERE continent = ''
GROUP BY Location 
ORDER BY total_casualties DESC;

#prevelance by region 
SELECT Location, MAX(ROUND(total_cases/population * 100, 2)) as prevalance
FROM ProjectPortfolio.CovidDeaths cd 
WHERE continent = ''
GROUP BY Location
ORDER BY prevalance DESC;

#total cases and deaths, by day
SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths
FROM ProjectPortfolio.CovidDeaths cd 
WHERE continent is not NULL
GROUP BY `date` 
order by 1,2;


#how many vaccinations were given per day?
SELECT date, SUM(new_vaccinations)
FROM ProjectPortfolio.CovidVaccinations cv 
WHERE new_vaccinations <> 0
GROUP BY `date` 
ORDER by 1;

#look at total population v. vaccination, using a common table expression (CTE)
WITH PopvsVac 
AS 
(SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as rolling_people_vaccinated
FROM ProjectPortfolio.CovidDeaths cd JOIN ProjectPortfolio.CovidVaccinations cv 
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent <> '')
SELECT *, rolling_people_vaccinated/population * 100 as perc_population_vaccinated
from PopvsVac;

#Creating view for later visualization purposes
CREATE VIEW Percent_Population_Vaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, 
	SUM(new_vaccinations) OVER (Partition by cd.location ORDER BY cd.location, cd.date) as rolling_people_vaccinated
FROM ProjectPortfolio.CovidDeaths cd JOIN ProjectPortfolio.CovidVaccinations cv 
	ON cd.location = cv.location AND cd.date = cv.date
WHERE cd.continent <> '';




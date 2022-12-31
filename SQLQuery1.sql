select *
from PortfolioProject..CovidDeaths
order by 3,4 

--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- Select Data that we are going to starting with

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1,2

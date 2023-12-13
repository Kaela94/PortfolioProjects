/*
Video Game Sales Exploration

Skills Used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--Selecting data that I am starting with

SELECT name, na_sales, global_sales
FROM PortfolioProject..GameSales
WHERE name is not null
ORDER BY 1, 2

--Proportion of sales in North America compared to global sales

SELECT name, na_sales / global_sales AS NA_Sales_Proportion
FROM PortfolioProject..GameSales
WHERE na_sales / global_sales > .5 
AND name is not null
ORDER BY 2 DESC;

--Genre with the highest average proportrion of sales in North America compared to Global Sales

SELECT gi.genre, MAX(avg_na_sales_proportion) AS max_avg_na_sales_proportion
FROM (
	SELECT gs.name, AVG(gs.na_sales / gs.global_sales) AS avg_na_sales_proportion
	FROM PortfolioProject..GameSales AS gs
	GROUP BY gs.name
) AS GameData
JOIN PortfolioProject..GameInfo AS gi ON GameData.name = gi.name  
GROUP BY gi.genre;

--Highest game sales in Japan

SELECT name, MAX(CAST(jp_sales AS int)) AS PopularJPGames
FROM PortfolioProject..GameSales
WHERE name is not null
GROUP BY name
ORDER BY PopularJPGames DESC

--Shows percentage of Global Sales for each game

SELECT gi.genre, gs.name, gs.global_sales, gi.platform, gs.na_sales, gs.eu_sales, gs.jp_sales, gs.other_sales
, gs.global_sales AS GlobalGameSales
, SUM(CONVERT(int, gs.global_sales)) OVER (PARTITION BY gi.name ORDER BY gi.name) AS RollingGlobalSales 
, (SUM(CONVERT(int, gs.global_sales)) OVER (PARTITION BY gi.name ORDER BY gi.name) / gs.global_sales) * 100 AS PercentageOfGlobalSales
FROM PortfolioProject..GameInfo AS gi
JOIN PortfolioProject..GameSales AS gs ON gi.name = gs.name
WHERE gi.genre is not null
ORDER BY 1,2,3;

--Creating temporary table to store intermediate results

DROP TABLE IF EXISTS #GameSalesData;
CREATE TABLE #GameSalesData (
	genre NVARCHAR(MAX),
	name NVARCHAR(MAX),
	global_sales DECIMAL(18, 2),
	platform NVARCHAR(MAX),
	na_sales DECIMAL(18, 2),
	eu_sales DECIMAL(18, 2),
	jp_sales DECIMAL(18, 2),
	other_sales DECIMAL(18, 2),
	GlobalGameSales DECIMAL(18, 2),
	RollingGlobalSales DECIMAL(18, 2)
);

--Inserting into temporary table with calculations

INSERT INTO #GameSalesData
SELECT gi.genre, gs.name, gs.global_sales, gi.platform, gs.na_sales, gs.eu_sales, gs.jp_sales, gs.other_sales
, gs.global_sales AS GlobalGameSales
, SUM(CONVERT(int, gs.global_sales)) OVER (PARTITION BY gi.name ORDER BY gi.name) AS RollingGlobalSales
FROM PortfolioProject..GameInfo AS gi
JOIN PortfolioProject..GameSales AS gs ON gi.name = gs.name
WHERE gi.genre is not null;

--Selecting from temporary table with percentage calculation

SELECT genre, name, global_sales, platform, na_sales, eu_sales, jp_sales, other_sales, GlobalGameSales
, RollingGlobalSales, (RollingGlobalSales / global_sales) * 100 AS PercentageOfGlobalSales
FROM #GameSalesData

--Creating a View to store data for later visualizations

CREATE VIEW GameSalesView AS
SELECT gi.genre, gs.name, gs.global_sales, gi.platform, gs.na_sales, gs.eu_sales, gs.jp_sales, gs.other_sales
, gs.global_sales AS GlobalGameSales
, SUM(CONVERT(int, gs.global_sales)) OVER (PARTITION BY gi.name ORDER BY gi.name) AS RollingGlobalSales
, (SUM(CONVERT(int, gs.global_sales)) OVER (PARTITION BY gi.name ORDER BY gi.name) / gs.global_sales) * 100 AS PercentageOfGlobalSales
FROM PortfolioProject..GameInfo AS gi
JOIN PortfolioProject..GameSales AS gs ON gi.name = gs.name
WHERE gi.genre is not null;

SELECT*
FROM GameSalesView

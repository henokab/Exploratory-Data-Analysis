-- Exploratory Data Analysis

-- Select all records from layoffs_staging2
SELECT * 
FROM layoffs_staging2;

-- Get maximum total laid off and maximum percentage laid off
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Select records where percentage laid off is 100%, ordered by funds raised
SELECT * 
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Total layoffs by company, ordered by total laid off
SELECT company, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;

-- Total layoffs by industry, ordered by total laid off
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

-- Total layoffs by country, ordered by total laid off
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;

-- Total layoffs by date, ordered by total laid off
SELECT [date], SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY [date]
ORDER BY 2 DESC;

-- This query selects the year from the date and sums the total layoffs, 
-- filtering out any rows where total_laid_off is NULL before aggregation.
SELECT YEAR([date]) AS Year, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
WHERE total_laid_off IS NOT NULL  
GROUP BY YEAR([date])
ORDER BY Year DESC;


-- This query selects the year and sums the total layoffs, 
-- filtering the results to include only those years where the total layoffs exceed 1000.
SELECT YEAR([date]) AS Year, SUM(total_laid_off) AS Total_Laid_Off
FROM layoffs_staging2
GROUP BY YEAR([date])
HAVING SUM(total_laid_off) > 1000  
ORDER BY Year DESC;



-- Total layoffs by stage, ordered by total laid off
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;

-- Average percentage laid off by company, ordered by company name
SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging2
GROUP BY company
ORDER BY 1 DESC;

-- Select records where percentage laid off is 100%, ordered by funds raised
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Get minimum and maximum date from the data
SELECT MIN([date]) AS MinDate, MAX([date]) AS MaxDate
FROM layoffs_staging2;

-- Monthly total layoffs, formatted as YYYY-MM
SELECT FORMAT([date], 'yyyy-MM') AS [month], SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY FORMAT([date], 'yyyy-MM')
ORDER BY 1 ASC;

-- Calculate rolling total layoffs by year and month
WITH Rolling_Total AS
(
    SELECT 
        YEAR([date]) * 100 + MONTH([date]) AS year_month, 
        SUM(total_laid_off) AS total_off
    FROM layoffs_staging2
    WHERE [date] IS NOT NULL
    GROUP BY YEAR([date]), MONTH([date])
)

-- Get rolling total of layoffs
SELECT 
    year_month, total_off, 
    SUM(total_off) OVER (ORDER BY year_month) AS rolling_total
FROM Rolling_Total
ORDER BY year_month;

-- Total layoffs by company per year, ordered by total laid off
SELECT company, YEAR([Date]), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY company, YEAR([Date])
ORDER BY 3 DESC;

-- Rank companies by total layoffs for each year
WITH Company_Year AS (
    SELECT company, YEAR([date]) AS years, SUM(total_laid_off) AS total_laid_off
    FROM layoffs_staging2
    GROUP BY company, YEAR([date])
),
Company_Year_Rank AS (
    SELECT *,
           DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
    FROM Company_Year
    WHERE years IS NOT NULL
)

-- Select top 5 companies by total layoffs for each year
SELECT *
FROM Company_Year_Rank
WHERE Ranking <= 5;

-- EDA

SELECT 
    *
FROM
    layoffs_staging2;

-- QUERIES

SELECT 
    MAX(total_laid_off)
FROM
    layoffs_staging2;

-- Looking at Percentage to see how big these layoffs were
SELECT 
    MAX(percentage_laid_off), MIN(percentage_laid_off)
FROM
    layoffs_staging2
WHERE
    percentage_laid_off IS NOT NULL;

-- Which companies had 1 which is basically 100 percent of they company laid off
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    percentage_laid_off = 1;

-- if we order by funcs_raised_millions we can see how big some of these companies were
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- Companies with the biggest single Layoff

SELECT 
    company, total_laid_off
FROM
    layoffs_stagging
ORDER BY 2 DESC
LIMIT 5;

-- Companies with the most Total Layoffs
SELECT 
    company, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY company
ORDER BY 2 DESC
LIMIT 10;


-- by location
SELECT 
    location, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY location
ORDER BY 2 DESC
LIMIT 10;

-- this it total in the past 3 years or in the dataset

SELECT 
    country, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY country
ORDER BY 2 DESC;


SELECT 
    YEAR(date), SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY YEAR(date)
ORDER BY 1 ASC;

SELECT 
    industry, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC;

SELECT 
    stage, SUM(total_laid_off)
FROM
    layoffs_staging2
GROUP BY stage
ORDER BY 2 DESC;


-- Earlier we looked at Companies with the most Layoffs. Now let's look at that per year. It's a little more difficult.
 

WITH Company_Year (company, years, total_laid_off) AS
(SELECT company, YEAR(date) , SUM(total_laid_off) 
FROM layoffs_staging2
 GROUP BY company, YEAR(date)
 )
 , Company_Year_Rank AS
(SELECT *,
DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
WHERE years IS NOT NULL
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5
;


-- Rolling Total of Layoffs Per Month

SELECT 
    SUBSTRING(date, 1, 7) AS dates,
    SUM(total_laid_off) AS total_laid_off
FROM
    layoffs_staging2
GROUP BY dates
ORDER BY dates ASC;



-- now use it in a CTE so we can query off of it

WITH DATE_CTE AS 
(
SELECT SUBSTRING(date,1,7) as dates, SUM(total_laid_off) AS total_laid_off
FROM layoffs_staging2
GROUP BY dates
ORDER BY dates ASC
)
SELECT dates, SUM(total_laid_off) OVER (ORDER BY dates ASC) as rolling_total_layoffs
FROM DATE_CTE
ORDER BY dates ASC;


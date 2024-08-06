-- SQL PROJECT - DATA CLEANING

select * from layoffs;

-- REMOVE DUPLICATES
-- STANDARDIZE THE DATA
-- NULL VALLUES OR BLANK VALUES
-- REMOVE ANY COLUMNS

CREATE TABLE layoffs_stagging LIKE layoffs;


insert layoffs_stagging
select * 
from layoffs;


SELECT 
    *
FROM
    layoffs_stagging
;

SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`) AS row_num
	FROM 
		layoffs_stagging;
        
SELECT *
FROM (
	SELECT company, industry, total_laid_off,`date`,
		ROW_NUMBER() OVER (
			PARTITION BY company, industry, total_laid_off,`date`
			) AS row_num
	FROM 
    layoffs_stagging
    ) duplicates
    WHERE
    row_num > 1;
    
SELECT 
    *
FROM
    layoffs_stagging
WHERE
    company = 'Oda'
;

SELECT *
FROM (
	SELECT company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_stagging
) duplicates
WHERE 
	row_num > 1;
    
            
 WITH DELETE_CTE AS (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, 
    ROW_NUMBER() OVER (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) AS row_num
	FROM layoffs_stagging
)
DELETE FROM layoffs_stagging
WHERE (company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num) IN (
	SELECT company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions, row_num
	FROM DELETE_CTE
) AND row_num >1 ;    

ALTER TABLE layoffs_stagging ADD row_num INT;

SELECT 
    *
FROM
    layoffs_stagging;
        
CREATE TABLE `layoffs_staging2` (
    `company` TEXT,
    `location` TEXT,
    `industry` TEXT,
    `total_laid_off` INT,
    `percentage_laid_off` TEXT,
    `date` TEXT,
    `stage` TEXT,
    `country` TEXT,
    `funds_raised_millions` INT,
    row_num INT
);

INSERT INTO `layoffs_staging2`
(`company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
`row_num`)
SELECT `company`,
`location`,
`industry`,
`total_laid_off`,
`percentage_laid_off`,
`date`,
`stage`,
`country`,
`funds_raised_millions`,
		ROW_NUMBER() OVER (
			PARTITION BY company, location, industry, total_laid_off,percentage_laid_off,`date`, stage, country, funds_raised_millions
			) AS row_num
	FROM 
		layoffs_stagging;

DELETE FROM layoffs_staging2 
WHERE
    row_num >= 2;




SELECT 
    *
FROM
    layoffs_staging2;

 -- if we look at industry it looks like we have some null and empty rows, let's take a look at these       

SELECT DISTINCT
    industry
FROM
    layoffs_staging2
ORDER BY industry;



SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL OR industry = ''
ORDER BY industry;

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company LIKE 'Bally%';
-- nothing wrong here
SELECT 
    *
FROM
    layoffs_staging2
WHERE
    company LIKE 'airbnb%';

-- it looks like airbnb is a travel, but this one just isn't populated.
-- I'm sure it's the same for the others. What we can do is
-- write a query that if there is another row with the same company name, it will update it to the non-null industry values
-- makes it easy so if there were thousands we wouldn't have to manually check them all

UPDATE layoffs_staging2 
SET 
    industry = NULL
WHERE
    industry = '';


-- check if those are all null

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL OR industry = ''
ORDER BY industry;


-- we need to populate these nulls if possible
UPDATE layoffs_staging2 t1
        JOIN
    layoffs_staging2 t2 ON t1.company = t2.company 
SET 
    t1.industry = t2.industry
WHERE
    t1.industry IS NULL
        AND t2.industry IS NOT NULL;


SELECT 
    *
FROM
    layoffs_staging2
WHERE
    industry IS NULL OR industry = ''
ORDER BY industry;


-- I also noticed the Crypto has multiple different variations. We need to standardize that - let's say all to Crypto

SELECT DISTINCT
    industry
FROM
    layoffs_staging2
ORDER BY industry;

UPDATE layoffs_staging2 
SET 
    industry = 'Crypto'
WHERE
    industry IN ('Crypto Currency' , 'CryptoCurrency');


-- now that's taken care of:

SELECT DISTINCT
    industry
FROM
    layoffs_staging2
ORDER BY industry;


-- we also need to look at 

SELECT 
    *
FROM
    layoffs_staging2;

-- everything looks good except apparently we have some "United States" and some "United States." with a period at the end. Let's standardize this.

SELECT DISTINCT
    country
FROM
    layoffs_staging2
ORDER BY country;


UPDATE layoffs_staging2 
SET 
    country = TRIM(TRAILING '.' FROM country);

-- now if we run this again it is fixed

SELECT DISTINCT
    country
FROM
    layoffs_staging2
ORDER BY country;



-- Let's also fix the date columns:

SELECT 
    *
FROM
    layoffs_staging2;

-- we can use str to date to update this field

UPDATE layoffs_staging2 
SET 
    `date` = STR_TO_DATE(`date`, '%m/%d/%Y');


-- now we can convert the data type properly 

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;

SELECT 
    *
FROM
    layoffs_staging2;



-- 3. Look at Null Values

SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL;


SELECT 
    *
FROM
    layoffs_staging2
WHERE
    total_laid_off IS NULL
        AND percentage_laid_off IS NULL;


-- Delete Useless data we can't really use
DELETE FROM layoffs_staging2 
WHERE
    total_laid_off IS NULL
    AND percentage_laid_off IS NULL;

SELECT 
    *
FROM
    layoffs_staging2;


ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT 
    *
FROM
    layoffs_staging2;











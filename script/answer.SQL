-- Netflix Data Analysis using SQL
-- Solutions of 15 business problems
-- 1. Count the number of Movies vs TV Shows
SELECT  
     COUNT(*) AS count_type,
	 type
FROM netflix
     GROUP BY type ;

-- 2. Find the most common rating for movies and TV shows
WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
)
,
RankedRatings AS (
    SELECT 
        type,
        rating,
        rating_count,
        RANK() OVER (PARTITION BY type ORDER BY rating_count DESC) AS rank
    FROM RatingCounts
)
SELECT 
    type,
    rating AS most_frequent_rating
FROM RankedRatings
WHERE rank = 1;

-- 3. List all movies released in a specific year (e.g., 2020)

SELECT * FROM netflix 
WHERE release_year=2020 ;

-- 4. Find the top 5 countries with the most content on Netflix
SELECT TOP 5 
	country ,
	COUNT(*)
FROM netflix
	WHERE country iS NOT NULL
	GROUP BY country
	ORDER BY  COUNT(*) DESC ;

-- 5. Identify the longest movie
SELECT 
	*
FROM netflix
WHERE type ='Movie'
ORDER BY CAST(TRIM(LEFT(duration ,CHARINDEX('m',duration)-1))AS INT) DESC ;

-- 6. Find content added in the last 5 years
SELECT 
    *
FROM netflix
WHERE YEAR(date_added) >= YEAR(GETDATE())-5;

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
SELECT 
    * 
FROM netflix
WHERE director LIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
SELECT
    *
FROM netflix
WHERE type= 'TV show'
  AND 
     CAST(TRIM(LEFT(duration,CHARINDEX('S',duration)-1))AS INT) >5 ;

-- 9. Count the number of content items in each genre
SELECT 
    LTRIM(RTRIM(value)) AS genre,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(listed_in, ',')
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_content DESC;

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
SELECT 
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        CAST(COUNT(show_id) AS DECIMAL(10,2)) /
        CAST((SELECT COUNT(show_id) FROM netflix WHERE country = 'India') AS DECIMAL(10,2)) * 100,
        2
    ) AS avg_release
FROM netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC
OFFSET 0 ROWS FETCH NEXT 5 ROWS ONLY;

-- 11. List all movies that are documentaries
SELECT
    * 
FROM netflix
WHERE listed_in LIKE '%Documentaries';

-- 12. Find all content without a director
SELECT 
    * 
FROM netflix
WHERE director IS NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT 
    * 
FROM netflix
WHERE 
	cast LIKE '%Salman Khan%'
	AND 
	release_year > YEAR(GETDATE()) - 10

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT TOP 10
    LTRIM(RTRIM(value)) AS actors,
    COUNT(*) AS total_content
FROM netflix
CROSS APPLY STRING_SPLIT(cast, ',')
GROUP BY LTRIM(RTRIM(value))
ORDER BY total_content DESC;
/*
Question 15:
Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
the description field. Label content containing these keywords as 'Bad' and all other 
content as 'Good'. Count how many items fall into each category.
*/


SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM netflix
) AS categorized_content
GROUP BY category,TYPE
ORDER BY TYPE




-- End Report

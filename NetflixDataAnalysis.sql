DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);

INSERT INTO netflix
SELECT * FROM netflix_titles


SELECT * FROM NetflixDataAnalysis..netflix



SELECT COUNT(*) AS total_content FROM netflix



---- 15 Business Problems & Solutions

--1. Count the number of Movies vs TV Shows

SELECT 
    type,
    COUNT(*)
FROM netflix
GROUP BY 1;


--2. Find the most common rating for movies and TV shows

WITH RatingCounts AS (
    SELECT 
        type,
        rating,
        COUNT(*) AS rating_count
    FROM netflix
    GROUP BY type, rating
),
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

--3. List all movies released in a specific year (e.g., 2020)

SELECT * 
FROM NetflixDataAnalysis..netflix
WHERE type ='Movie' AND release_year = 2020;

--4. Find the top 5 countries with the most content on Netflix

SELECT TOP 5 *  
FROM (  
    SELECT  
        value AS country,  
        COUNT(*) AS total_content  
    FROM NetflixDataAnalysis..netflix  
    CROSS APPLY STRING_SPLIT(country, ',')  
    GROUP BY value  
) AS t1  
WHERE country IS NOT NULL  
ORDER BY total_content DESC;

--5. Identify the longest movie

SELECT * 
FROM NetflixDataAnalysis..netflix
WHERE type = 'Movie' AND duration = (SELECT MAX(duration) FROM NetflixDataAnalysis..netflix);

--6. Find content added in the last 5 years

SELECT *  
FROM NetflixDataAnalysis..netflix  
WHERE CAST(date_added AS DATE) >= DATEADD(YEAR, -5, GETDATE());

--7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * 
FROM NetflixDataAnalysis..netflix
WHERE director LIKE '%Rajiv Chilaka%';

--8. List all TV shows with more than 5 seasons

SELECT *  
FROM NetflixDataAnalysis..netflix  
WHERE type = 'TV Show'  
  AND CAST(LEFT(duration, CHARINDEX(' ', duration) - 1) AS INT) > 5;

--9. Count the number of content items in each genre

SELECT  
    value AS genre,  
    COUNT(*) AS total_content  
FROM NetflixDataAnalysis..netflix  
CROSS APPLY STRING_SPLIT(listed_in, ',')  
GROUP BY value  
ORDER BY total_content DESC;

--10.Find each year and the average numbers of content release in India on netflix. 
--return top 5 year with highest avg content release!

WITH TotalIndia AS (
    SELECT COUNT(show_id) AS total_count
    FROM NetflixDataAnalysis..netflix
    WHERE country = 'India'
)
SELECT TOP 5
    country,
    release_year,
    COUNT(show_id) AS total_release,
    ROUND(
        CAST(COUNT(show_id) AS FLOAT) / (SELECT total_count FROM TotalIndia) * 100, 2
    ) AS avg_release
FROM NetflixDataAnalysis..netflix
WHERE country = 'India'
GROUP BY country, release_year
ORDER BY avg_release DESC;

--11. List all movies that are documentaries

SELECT * 
FROM NetflixDataAnalysis..netflix
WHERE listed_in LIKE '%Documentaries%';

--12. Find all content without a director

SELECT * 
FROM NetflixDataAnalysis..netflix
WHERE director IS NULL;

--13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *  
FROM NetflixDataAnalysis..netflix  
WHERE casts LIKE '%Salman Khan%'  
  AND release_year > YEAR(GETDATE()) - 10;

--14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT TOP 10 
    value AS actor,
    COUNT(*) AS appearances
FROM NetflixDataAnalysis..netflix
CROSS APPLY STRING_SPLIT(casts, ',')
WHERE country = 'India'
GROUP BY value
ORDER BY COUNT(*) DESC;


--15.
--Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
--the description field. Label content containing these keywords as 'Bad' and all other 
--content as 'Good'. Count how many items fall into each category.


SELECT 
    category,
    COUNT(*) AS content_count
FROM (
    SELECT 
        CASE 
            WHEN description LIKE '%kill%' OR description LIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM NetflixDataAnalysis..netflix
) AS categorized_content
GROUP BY category;
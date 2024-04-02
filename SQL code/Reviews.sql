SELECT *
FROM course_aggregator.reviews_switchup;

SELECT *
FROM course_aggregator.reviews_coursereport;


-- Merge overall rating from both tables
-- Use alias rc and rs for the tables reviews_coursereport and reviews_switchup
USE course_aggregator;
CREATE TABLE review_aggregate AS
SELECT 
    COALESCE(rc.School_id, rs.school_id) AS school_id,
    COALESCE(rc.School, rs.school) AS school,
    COALESCE((rc.Rating + rs.overallRating) / 2, rc.Rating, rs.overallRating) AS average_rating,
    COALESCE(rc.Reviews, 0) + COALESCE(rs.reviewCount, 0) AS total_reviews
FROM reviews_coursereport rc
LEFT JOIN reviews_switchup rs ON rc.School_id = rs.school_id

UNION

SELECT 
    COALESCE(rc.School_id, rs.school_id) AS school_id,
    COALESCE(rc.School, rs.school) AS school,
    COALESCE((rc.Rating + rs.overallRating) / 2, rc.Rating, rs.overallRating) AS average_rating,
    COALESCE(rc.Reviews, 0) + COALESCE(rs.reviewCount, 0) AS total_reviews
FROM reviews_coursereport rc
RIGHT JOIN reviews_switchup rs ON rc.School_id = rs.school_id;

SELECT *
FROM review_aggregate
WHERE average_rating>4.5
ORDER BY total_reviews DESC
LIMIT 5;


-- Let's explore locations
SELECT *
FROM locations_coursereport;

SELECT *
FROM locations_switchup;

-- Remove the Online rows in locations_switchup

SET SQL_SAFE_UPDATES = 0;

DELETE FROM locations_switchup
WHERE description = 'Online';

-- Let's insert the switchup columns of interest in our locations_coursereport
INSERT INTO locations_coursereport (`city.name`, school, school_id, `city.id`)
SELECT `city.name`, school, school_id, `city.id`
FROM locations_switchup;

-- Let's avoid the duplicates
CREATE TABLE locations_coursereport_no_duplicates AS
SELECT DISTINCT `city.name`, school, school_id, `city.id`
FROM locations_coursereport;

SELECT COUNT(school_id),`city.name`
FROM locations_coursereport
GROUP BY `city.name`
ORDER BY COUNT(school_id) DESC;

SELECT *
FROM review_aggregate;
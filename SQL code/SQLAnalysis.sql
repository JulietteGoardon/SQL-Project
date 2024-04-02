USE ProjectSQL;

-- Create a schools table
CREATE TABLE schools as
SELECT DISTINCT
s.school_id,
s.school,
s.website,
r.reviewCount,
r.overallRating
FROM schools_switchup s
left join reviews_aggregate r on r.School_id = s.school_id;


SELECT *
FROM schools;

-- Create Available courses


USE ProjectSQL;

CREATE TABLE available_courses AS
SELECT DISTINCT
    c.course_id,  -- Adicionando a coluna id_curso
    s.school_id,
    s.school,
    l.description,
    COALESCE(l.id, -999) AS location_id,
    c.CourseName,
    CASE
        WHEN c.CourseName LIKE '%Part-Time%' OR c.CourseName LIKE '%(Part time)%' THEN 'Part-Time'
        WHEN c.CourseName LIKE '%Bootcamp%' THEN 'Bootcamp'
        WHEN c.CourseName LIKE '%Full-Time%' OR c.CourseName LIKE '%(Full Time)%' THEN 'Full-Time'
        WHEN c.CourseName LIKE '%Short Course%' THEN 'Short Course'
        WHEN c.CourseName LIKE '%Course%' THEN 'Course'
        WHEN c.CourseName LIKE '%Career Track%' THEN 'Career Track'
        ELSE 'Not specified'
    END AS TypeofCourse,
    CASE
        WHEN l.country_name IN ('United States', 'United Kingdom', 'Canada', 'Australia', 'Online') THEN 'English'
        WHEN c.CourseName LIKE '%Spanish%' THEN 'Spanish'
        WHEN c.CourseName LIKE '%English and Spanish%' THEN 'English and Spanish'
        WHEN c.CourseName LIKE '%English%' THEN 'English'
        ELSE 'Not specified'
    END AS language
FROM
    schools_switchup s
    LEFT JOIN courses c ON s.school_id = c.school_id
    LEFT JOIN badges_switchup b ON b.school_id = s.school_id
    LEFT JOIN locations_switchup l ON l.school_id = s.school_id
    LEFT JOIN reviews_switchup r ON r.school_id = s.school_id;

-- Create table locations
USE ProjectSQL;

SELECT * 
FROM locations_aggregate;

-- Assuming your table is named locations_aggregate
ALTER TABLE locations_aggregate
MODIFY COLUMN location_id INT FIRST;

-- Table  courses

SELECT *
FROM courses_switchup;



CREATE TABLE courses AS
SELECT
    ROW_NUMBER() OVER () AS course_id,
    courses,
    CASE
        WHEN courses LIKE '%Part-Time%' OR courses LIKE '%(Part time)%' THEN 'Part-Time'
        WHEN courses LIKE '%Bootcamp%' THEN 'Bootcamp'
        WHEN courses LIKE '%Full-Time%' OR courses LIKE '%(Full Time)%' THEN 'Full-Time'
        WHEN courses LIKE '%Short Course%' THEN 'Short Course'
        WHEN courses LIKE '%Course%' THEN 'Course'
        WHEN courses LIKE '%Career Track%' THEN 'Career Track'
        ELSE 'Not specified'
    END AS TypeofCourse,
    CASE
        WHEN `country.name` IN ('United States', 'United Kingdom', 'Canada', 'Australia', 'Online') THEN 'English'
        WHEN courses LIKE '%Spanish%' THEN 'Spanish'
        WHEN courses LIKE '%English and Spanish%' THEN 'English and Spanish'
        WHEN courses LIKE '%English%' THEN 'English'
        ELSE 'Not specified'
    END AS language,
    MAX(school_id) AS school_id
FROM (
    SELECT DISTINCT
        s.school_id,
        s.school,
        COALESCE(location_id, -999) AS location_id,
        c.courses,
        l.`country.name`
    FROM
        schools_switchup s
        LEFT JOIN courses_switchup c ON s.school_id = c.school_id
        LEFT JOIN badges_switchup b ON b.school_id = s.school_id
        LEFT JOIN locations_aggregate l ON l.school_id = s.school_id
        LEFT JOIN reviews_aggregate r ON r.school_id = s.school_id
) AS TempTable
GROUP BY courses, TypeofCourse, language;


SELECT *
from courses;


-- Add index to schools 

ALTER TABLE schools
ADD INDEX idx_school_id (school_id);

ALTER TABLE schools
ADD PRIMARY KEY (school_id);

-- Add foreign keys to locations, courses and badges 

ALTER TABLE locations_aggregate
ADD CONSTRAINT fk_locations_aggregate_school
FOREIGN KEY (school_id) REFERENCES schools(school_id);

ALTER TABLE courses
ADD CONSTRAINT fk_courses_school
FOREIGN KEY (school_id) REFERENCES schools(school_id);

ALTER TABLE badges_switchup
ADD CONSTRAINT fk_badges_switchup_school
FOREIGN KEY (school_id) REFERENCES schools(school_id);

-- Define the reminder primary keys
ALTER TABLE locations_aggregate
ADD PRIMARY KEY (location_id);

ALTER TABLE courses
ADD PRIMARY KEY (course_id);

ALTER TABLE comments
ADD PRIMARY KEY (id);

-- Add a seconday key to shool in shcools table

ALTER TABLE schools
ADD INDEX (school(255));

-- Add a foreign key to comments

ALTER TABLE comments
MODIFY COLUMN school VARCHAR(255);


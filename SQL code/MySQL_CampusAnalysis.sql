USE SQLP_Analysis;

DROP TABLE IF EXISTS population_EU;
DROP TABLE IF EXISTS GDP_EU;
DROP TABLE IF EXISTS Growth_EU;
DROP TABLE IF EXISTS Skills_EU; 
DROP TABLE IF EXISTS Country_Index;

CREATE TABLE SQLP_Analysis.population_EU(
    Country_ID INT PRIMARY KEY,
    Country_Name VARCHAR(128),
    Young_Adults INT, 
    Active_Workers INT,
    Total_Population INT,
    FOREIGN KEY (Country_ID) REFERENCES SQLP_Analysis.Country_Index(Country_ID)
);

CREATE TABLE SQLP_Analysis.GDP_EU(
    Country_ID INT PRIMARY KEY,
    Country_Name VARCHAR(128),
    IMF INT,
    FOREIGN KEY (Country_ID) REFERENCES SQLP_Analysis.Country_Index(Country_ID)
);

CREATE TABLE SQLP_Analysis.Growth_EU(
    Country_ID INT PRIMARY KEY,
    Country_Name VARCHAR(128),
    Value FLOAT,
    FOREIGN KEY (Country_ID) REFERENCES SQLP_Analysis.Country_Index(Country_ID)
);

CREATE TABLE SQLP_Analysis.Skills_EU(
    Country_ID INT PRIMARY KEY,
    Country_Name VARCHAR(128),
    Value FLOAT,
    FOREIGN KEY (Country_ID) REFERENCES SQLP_Analysis.Country_Index(Country_ID)
);

CREATE TABLE SQLP_Analysis.Country_Index(
    Country_ID INT PRIMARY KEY,
    Country_Name VARCHAR(128)
);

 
SELECT * FROM population_EU;
SELECT * FROM GDP_EU;
SELECT * FROM Growth_EU;
SELECT * FROM Skills_EU;
SELECT * FROM Country_Index;

WITH CampusAnalysis AS (
  SELECT
    pe.Country_Name,
    pe.Total_Population,
    ge.Value AS Expected_Growth,
    ge.Value * pe.Total_Population AS potential_students,
    ge.Value * pe.Total_Population * se.Value AS potential_students_with_skills,
    ge.Value * pe.Total_Population * se.Value * (1 + (ge.Value / 100)) AS projected_students_with_skills_growth,
    gdp.IMF AS GDP
  FROM
    population_EU pe
    JOIN Growth_EU ge ON pe.Country_Name = ge.Country_Name
    JOIN Skills_EU se ON pe.Country_Name = se.Country_Name
    JOIN GDP_EU gdp ON pe.Country_Name = gdp.Country_Name
  WHERE
    gdp.IMF >= 25000 
)
SELECT
  Country_Name,
  Total_Population,
  GDP,
  potential_students,
  potential_students_with_skills,
  projected_students_with_skills_growth,
  weighted_score,
  RANK() OVER (ORDER BY weighted_score DESC) AS campus_rank
FROM (
  SELECT
    *,
    (0.3 * projected_students_with_skills_growth) +
    (0.2 * GDP) +
    (0.2 * Total_Population) +
    (0.3 * Expected_Growth) AS weighted_score
  FROM CampusAnalysis
) AS RankedCampusAnalysis
ORDER BY
  campus_rank;








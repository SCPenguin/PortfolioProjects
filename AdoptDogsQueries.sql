SELECT *
FROM AdoptableDogs..allDogDescriptions

SELECT *
FROM AdoptableDogs..dogTravel


--Some entries for contact_state appear to be zip codes
--it appears that some zip codes, state abbreviations and city names were swapped in 33 entries.
SELECT TOP 50 contact_zip, contact_city, contact_state, org_id
FROM AdoptableDogs..allDogDescriptions
ORDER BY contact_state

--Update values into the correct columns, city_name was determined to be turn to NULL in this circumstance
UPDATE AdoptableDogs..allDogDescriptions SET contact_state = contact_city, contact_zip = contact_state, contact_city = NULL
WHERE contact_city IN ('PA', 'VA', 'MD', 'TN', 'OH', 'IN', 'IL', 'LA', 'AZ', 'NM', 'NV', 'WA')


--Number of each breed available in each state
SELECT breed_primary, COUNT(breed_primary) AS count, contact_state
FROM AdoptableDogs..allDogDescriptions
GROUP BY breed_primary, contact_state
ORDER BY contact_state, count DESC

--Top N most common breeds in each state
SELECT *
FROM (
	SELECT
	contact_state,
	breed_primary,
	COUNT(breed_primary) AS count,
	row_number() OVER(PARTITION BY contact_state ORDER BY COUNT(breed_primary) DESC) AS rank
	FROM AdoptableDogs..allDogDescriptions
	GROUP BY breed_primary, contact_state) AS ranks
WHERE rank <= 5

--How many of each age group for each breed
SELECT breed_primary, age, count(age) AS count
FROM AdoptableDogs..allDogDescriptions
GROUP BY age, breed_primary
ORDER BY breed_primary, count DESC

----------------------------------------------------
--Proportion of senior dogs by breed, which breed has most seniors available (need to find simplified solution)
WITH s_count AS (
SELECT breed_primary, count(breed_primary) AS sen_count
FROM AdoptableDogs..allDogDescriptions
WHERE age LIKE 'Senior'
GROUP BY breed_primary
),

b_count AS (
SELECT breed_primary, count(breed_primary) AS breed_count
FROM AdoptableDogs..allDogDescriptions
GROUP BY breed_primary
)

SELECT b.breed_primary, breed_count, sen_count, ROUND(CAST(sen_count AS float) / CAST(breed_count AS float), 2) AS Perc_seniors
FROM b_count AS b
LEFT JOIN s_count AS s
ON b.breed_primary = s.breed_primary
--Exclude breeds where there are 10 or less available
WHERE breed_count > 10
ORDER BY Perc_seniors DESC

----------------------------------------------------

--Looking for a german shepherd or blue heeler in California that is good with children and preferably is current on shots
SELECT id, url, breed_primary, age, sex, contact_state,
CASE WHEN shots_current = 1 THEN 'Yes' ELSE 'No' END AS shots_current,
CASE WHEN env_children = 1 THEN 'Yes' WHEN env_children = 0 THEN 'No' Else 'N/A' END AS good_w_children
FROM AdoptableDogs..allDogDescriptions
WHERE contact_state LIKE 'CA'
AND (breed_primary LIKE 'German Shepherd%' OR breed_primary LIKE '%Heeler%')
AND env_children = 1
ORDER BY good_w_children DESC, shots_current DESC


--age distribution per breed
SELECT breed_primary, age, COUNT(age) AS num
FROM AdoptableDogs..allDogDescriptions
GROUP BY age, breed_primary
ORDER BY breed_primary, num DESC

SELECT breed_primary, age, COUNT(breed_primary) AS count
FROM AdoptableDogs..allDogDescriptions
WHERE age LIKE 'Young' AND breed_primary LIKE 'Beagle'
GROUP BY breed_primary, age


-- Queries used for analysis of cleaned data:

-- bike_type_usage

CREATE OR REPLACE VIEW bike_type_usage AS
SELECT
member_casual,
rideable_type,
COUNT(*) AS total_rides
FROM 
analysis
GROUP BY
member_casual, rideable_type
ORDER BY
member_casual, total_rides DESC;


-- popular_end_stations (top10)

CREATE OR REPLACE VIEW popular_end_stations AS
SELECT
member_casual,
end_station_name,
COUNT(*) AS total_rides
FROM
analysis
WHERE
end_station_name != 'unknown'
GROUP BY
member_casual, end_station_name
ORDER BY
total_rides DESC
LIMIT 10;

-- popular_start_stations (top10)

CREATE OR REPLACE VIEW popular_start_stations AS
SELECT
member_casual,
start_station_name,
COUNT(*) AS total_rides
FROM
analysis
WHERE
start_station_name != 'unknown'
GROUP BY
member_casual, start_station_name
ORDER BY
total_rides DESC
LIMIT 10;


-- ride_duration_buckets

CREATE OR REPLACE VIEW ride_duration_buckets AS
SELECT
member_casual,
CASE
WHEN ride_length < INTERVAL '5 minutes' THEN '0-5 mins'
WHEN ride_length < INTERVAL '15 minutes' THEN '5-15 mins'
WHEN ride_length < INTERVAL '30 minutes' THEN '15-30 mins'
WHEN ride_length < INTERVAL '1 hour' THEN '30-60 mins'
ELSE '60+ mins'
END AS duration_bucket,
COUNT(*) AS total_rides
FROM
analysis
GROUP BY
member_casual, duration_bucket
ORDER BY
duration_bucket;

-- ride_length_by_user_type

SELECT member_casual,
avg(ride_length) AS avg_ride_length,
min(ride_length) AS min_ride_length,
max(ride_length) AS max_ride_length
FROM analysis
GROUP BY member_casual;


-- rides_by_day_of_week

CREATE OR REPLACE VIEW rides_by_day_of_week AS

SELECT member_casual,
day_of_week,
count(*) AS total_rides
FROM analysis
GROUP BY member_casual, day_of_week
ORDER BY day_of_week;


-- rides_by_hour

CREATE OR REPLACE VIEW rides_by_hour AS
SELECT
member_casual,
EXTRACT(HOUR FROM started_at) AS ride_hour,
COUNT(*) AS total_rides
FROM
analysis
GROUP BY
member_casual, ride_hour
ORDER BY
ride_hour;


-- total_rides_by_user_type

CREATE OR REPLACE VIEW total_rides_by_user_type AS
SELECT
member_casual,
COUNT(*) AS total_rides
FROM
analysis
GROUP BY
member_casual;


-- weekend_vs_weekday_usage

CREATE OR REPLACE VIEW weekend_vs_weekday_usage AS
SELECT
member_casual,
CASE
WHEN TRIM(LOWER(day_of_week)) IN ('saturday', 'sunday') THEN 'Weekend'
ELSE 'Weekday'
END AS ride_period,
COUNT(*) AS total_rides
FROM
analysis
GROUP BY
member_casual, ride_period;


-- seasonal_usage

CREATE OR REPLACE VIEW seasonal_usage AS
SELECT
member_casual,
CASE
WHEN EXTRACT(MONTH FROM started_at) IN (12, 1, 2) THEN 'Winter'
WHEN EXTRACT(MONTH FROM started_at) IN (3, 4, 5) THEN 'Spring'
WHEN EXTRACT(MONTH FROM started_at) IN (6, 7, 8) THEN 'Summer'
WHEN EXTRACT(MONTH FROM started_at) IN (9, 10, 11) THEN 'Fall'
END AS season,
COUNT(*) AS total_rides,
AVG(EXTRACT(EPOCH FROM ride_length) / 60) AS avg_ride_length_minutes
FROM
analysis
GROUP BY
member_casual,
season
ORDER BY
member_casual,
season;
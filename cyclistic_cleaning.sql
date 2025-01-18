-- Null and Blank Values Cleaning:
-- ride_id: No identified null or blank values.
-- rideable_type: No identified null or blank values.
-- started_at: No identified null or blank values.
-- member_casual: No identified null or blank values

--Removing Invalid Data:
--Eliminating records where ended_at is earlier than started_at (227 rows):

DELETE FROM analysis
WHERE ended_at < started_at;

--Cleaning Null or Blank Values in Columns:
--start_station_name: Updated null or blank values to 'unknown' (1,073,823 rows):

UPDATE analysis
SET start_station_name = 'unknown'
WHERE start_station_name IS NULL OR start_station_name = '';

--end_station_name: Updated null or blank values to 'unknown' (1,104,499 rows):

UPDATE analysis
SET end_station_name = 'unknown'
WHERE end_station_name IS NULL OR end_station_name = '';



--Ride Length (Duration):
--Adding a Calculated Column ride_length:
ALTER TABLE analysis ADD COLUMN ride_length INTERVAL;

--Calculating ride length:
UPDATE analysis SET ride_length = ended_at - started_at;

--Removing Invalid Ride Lengths:
--Negative or zero ride length (496 rows):
DELETE FROM analysis
WHERE EXTRACT(MINUTE FROM ride_length) <= 0;

--Removing Duplicate Rides:
--Duplicate entries (8 rows found):

SELECT started_at, ended_at, start_station_name, end_station_name, COUNT(*) AS duplicate_count
FROM analysis
GROUP BY started_at, ended_at, start_station_name, end_station_name
HAVING COUNT(*) > 1;

--Deleting duplicates:

DELETE FROM analysis
WHERE ctid NOT IN (
SELECT MIN(ctid)
FROM analysis
GROUP BY ride_id, started_at, ended_at, start_station_name, end_station_name
);

--Removing Irrelevant Tables and Columns:
--Columns to delete: ride_id, start_station_id, end_station_id, start_lat, 
--start_lng, end_lat, end_lng (no relevant information for analysis).

-- Adding columns to enrich our analysis:

--Enriching the Analysis:
--Adding New Columns:
--Day of the Week (day_of_week):

ALTER TABLE analysis ADD COLUMN day_of_week TEXT;
UPDATE analysis SET day_of_week = TO_CHAR(started_at, 'Day');

--Hour of the Ride

ALTER TABLE analysis ADD COLUMN ride_hour INT;
UPDATE analysis SET ride_hour = EXTRACT(HOUR FROM started_at);

--Deleting Rides with Length Less Than One Minute: 136,472 rides deleted:

DELETE FROM analysis
WHERE EXTRACT(MINUTE FROM ride_length) < 1;

-- Deleting Rides with Length Greater Than One Day: 7,587 rides deleted:

Delete FROM analysis
WHERE EXTRACT(DAY FROM ride_length) >= 1;
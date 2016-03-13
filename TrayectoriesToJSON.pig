
/****
*
*  Transforms Geolife GPS User Log into JSON
*
*  @author Javier Espinosa
*
***/


REGISTER 'GeolifeUDFs.py' USING jython AS geolife;
DEFINE   msToStr  geolife.msToStr();

SET DEFAULT_PARALLEL 10;

%default USER_ID  1;
%default INPUT_PATH     'Geolife/Data/sample';
%default OUTPUT_PATH    'out';



----------------------------------------------------
-- Step 1: Load Labels
----------------------------------------------------

Labels = LOAD '$INPUT_PATH/labels.txt' using PigStorage('\t') as (
    start_time: chararray,
    end_time:   chararray,
    transportation_mode:   chararray
);


--
-- Remove Meta-Data (1st line in file)
--
Labels = FILTER @ BY NOT $0 == 'Start Time';


--
-- Simplify Labels schema with DATE types
--
Labels = FOREACH @ GENERATE
    ToDate( start_time, 'yyyy/MM/dd HH:mm:ss', '+00:00') as start_time,
    ToDate( end_time,   'yyyy/MM/dd HH:mm:ss', '+00:00') as end_time,
    transportation_mode
;



----------------------------------------------------
-- Step 2: Load GPS logs
----------------------------------------------------

GPS_logs = LOAD '$INPUT_PATH/Trajectory' using PigStorage(',') as (
    latitude:   float,
    longitude:  float,
    code:       int,
    altitude:   int,
    timestamp:  float,
    date:       chararray,
    time:       chararray
);

--
-- Remove Meta-Data (lines 1-6 in file)
-- 
GPS_logs = FILTER @ BY $3 is not null;


--
-- Simplify GPS_logs scheme with DATE type
--
GPS_logs = FOREACH @ GENERATE
    latitude,
    longitude,
    altitude,
    ToDate( CONCAT(date, ' ', time), 'yyyy-MM-dd HH:mm:ss', '+00:00') as timestamp
;



----------------------------------------------------
-- Step 3: Find trajectories 
----------------------------------------------------

--
-- Combine Labels with GPS_logs
--
CR = CROSS Labels, GPS_logs;


--
-- Remove points not belonging to a trayectory
--
CR = FILTER @ BY
    ToMilliSeconds(GPS_logs::timestamp) >= ToMilliSeconds(Labels::start_time) AND
    ToMilliSeconds(GPS_logs::timestamp) <= ToMilliSeconds(Labels::end_time)
;


--
-- Group points belonging to the same trayectory
--
GR = GROUP @ BY (Labels::start_time, Labels::end_time, Labels::transportation_mode);


--
-- Define simple 'Trayectories' schema
--
Trayectories = FOREACH @ GENERATE
    
    $0.Labels::transportation_mode  as transportationMode,
    $0.Labels::start_time           as startTime,
    $0.Labels::end_time             as endTime,

    $1.(GPS_logs::latitude, GPS_logs::longitude, GPS_logs::altitude, GPS_logs::timestamp) as points: bag {
        tuple(
            latitude:  float, 
            longitude: float,
            altitude:  int, 
            timestamp: datetime
        )
    }
;



----------------------------------------------------
-- Step 4: Schema Enhancement 
----------------------------------------------------

--
-- Enrich trajectories with stats
--
Trayectories = FOREACH @ GENERATE
    
    transportationMode,
    startTime,
    endTime,

    ToDate( 
        msToStr( MilliSecondsBetween(startTime, endTime) ), 'yyyy/MM/dd HH:mm:ss', '-00:00' 
    ) as duration,

    points
;


--
-- Group trayectories by user
--

T = GROUP @ ALL;

UserTrayectories = FOREACH @ GENERATE
    $USER_ID as id: int,
    $1 as trayectories
;

--
-- Add stats
--
UserTrayectories = FOREACH @ GENERATE
    id,
    trayectories,
    COUNT( trayectories ) as total
;



----------------------------------------------------
-- Step 6: Store into disk 
----------------------------------------------------

STORE @ INTO '$OUTPUT_PATH' USING JsonStorage();


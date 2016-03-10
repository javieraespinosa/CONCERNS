
REGISTER NeubotTestsUDFs.jar;
DEFINE   IPtoNumber  convert.IpToNumber();
DEFINE   NumberToIP  convert.NumberToIp();

----------------------------------------------------
-- Load 'speedtests' from JSON files
----------------------------------------------------
SpeedTests = LOAD 'SpeedTests_Sample' using JsonLoader();


----------------------------------------------------
-- Keep tests conducted in Politecnico di Torino (IPs 130.192.0.0 to 130.192.255.255)
----------------------------------------------------
Tests = FILTER @ BY (
    IPtoNumber(Client.IP) >= IPtoNumber('130.192.0.0')  AND
    IPtoNumber(Client.IP) <= IPtoNumber('130.192.255.255')
);


----------------------------------------------------
-- Append Day, Month and Year fields based on timestamp
----------------------------------------------------
Tests = FOREACH @ GENERATE
    GetDay(timestamp)   AS Day:   chararray,
    GetMonth(timestamp) AS Month: chararray,
    GetYear(timestamp)  AS Year:  chararray,
    * -- ALL the files in the previews relation
;

----------------------------------------------------
-- Group test by date: day/month/year
----------------------------------------------------
Tests = GROUP @ BY (Day, Month, Year);


----------------------------------------------------
-- Compute the average 'download_speed' by day
----------------------------------------------------
TestsDay = FOREACH @ GENERATE
    AVG(Tests.download_speed) AS AVG_download_speed,
    flatten(Tests)
;


----------------------------------------------------
-- Store data for plotting
----------------------------------------------------
Tests = FOREACH @ GENERATE
    CONCAT( Tests::Day, '/', Tests::Month, '/', Tests::Year ),
    AVG_download_speed
;

Tests = DISTINCT @;

STORE Tests INTO 'NeubotTests_Polito' USING PigStorage(',');
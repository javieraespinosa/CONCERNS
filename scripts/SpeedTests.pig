
REGISTER NeubotTestsUDFs.jar;
DEFINE   IPtoNumber  convert.IpToNumber();
DEFINE   NumberToIP  convert.NumberToIp();

----------------------------------------------------
-- Load NeubotTest from CSV file
----------------------------------------------------
NeubotTests = LOAD 'NeubotTests' using PigStorage(';') as (
	client_address: chararray,
	client_country: chararray,
	lon: float,
	lat: float,
	client_provider: chararray,
	mlabservername:  chararray,
	connect_time:    float,
	download_speed:  float,
	neubot_version:  chararray,
	platform:        chararray,
	remote_address:  chararray,
	test_name:       chararray,
	timestamp:       long,
	upload_speed:    float,
	latency:  float,
	uuid:     chararray,
	asnum:    chararray,
	region:   chararray,
	city:     chararray,
	hour:     int,
	month:    int,
	year:     int,
	weekday:  int,
	day:      int,
	filedate: chararray
);


----------------------------------------------------
-- Transform NeubotTest schema into more readable schema
----------------------------------------------------
NeubotTests = FOREACH @ GENERATE

    -- Test Info
    REPLACE( test_name, '\\"', '') AS test_name: chararray,

    ToDate(
        (long) REPLACE( filedate,  '\\"', '') * 1000
    ) AS filedate:  datetime,

    -- Time Info
    ToDate( timestamp * 1000) AS timestamp: datetime,

    -- Metrics
    connect_time,
    latency,
    download_speed,
    upload_speed,

    --------------------
    -- Client : Tuple
    --------------------
    (
        REPLACE( uuid,           '\\"', ''),
        REPLACE( client_address, '\\"', ''),

        REPLACE( client_country, '\\"', ''),
        REPLACE( region,         '\\"', ''),
        REPLACE( city,           '\\"', ''),

        (-- Provider
            REPLACE( client_provider, '\\"', ''),
            REPLACE( asnum,           '\\"', '')
        ),

        (-- Geo
            lon,
            lat
        ),

        (-- Platform
            REPLACE( platform,       '\\"', ''),
            REPLACE( neubot_version, '\\"', '')
        )

    --------------------
    -- Client : Schema
    --------------------
    ) AS Client: tuple (
        ID: chararray,
        IP: chararray,

        Country: chararray,
        Region:  chararray,
        City:    chararray,

        Provider:  tuple(
            Name:  chararray,
            Asnum: chararray
        ),

        Geo: tuple(
            Lon: float,
            Lat: float
        ),

        Platform: tuple(
            OS:      chararray,
            Version: chararray
        )
    ),

    --------------------
    -- Server: Tuple
    --------------------
    (
        REPLACE( mlabservername, '\\"', ''),
        REPLACE( remote_address, '\\"', '')

    --------------------
    -- Server: Schema
    --------------------
    ) AS Server: Tuple (
        Name: chararray,
        IP:   chararray
    )
;


----------------------------------------------------
-- Keep only the 'speedtests'
----------------------------------------------------
SpeedTests = FILTER NeubotTests BY (test_name == 'speedtest');

STORE @  INTO 'SpeedTests' USING JsonStorage();

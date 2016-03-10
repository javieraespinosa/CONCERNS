

REGISTER NeubotTestsUDFs.jar;
DEFINE   IPtoNumber  convert.IpToNumber();
DEFINE   NumberToIP  convert.NumberToIp();

NeubotTests = LOAD 'csv' using PigStorage(';') as (
	client_address: chararray,
	client_country: chararray,
	lon: float,
	lat: float,
	client_provider: chararray,
	mlabservername:  chararray,
	connect_time:    float,
	download_speed:  float,
	neubot_version:  float,
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


Tests = FOREACH NeubotTests GENERATE (

    -- Test Info
    test_name,
    filedate,

    -- Time Info
    timestamp,

    -- Metrics
    connect_time,
    latency,
    download_speed,
    upload_speed,

    (-- Client
        uuid,
        client_address,

        client_country,
        region,
        city,

        (-- Provider
            client_provider,
            asnum
        ),

        (-- Geo
            lon,
            lat
        ),

        (-- Platform
            platform,
            neubot_version
        )

    ),

    (-- Server
        mlabservername,
        remote_address
    )

) AS Test: tuple(

    test_name: chararray,
    filedate:  chararray,

    timestamp: long,

    connect_time,
    latency,
    download_speed,
    upload_speed,

    Client: tuple(

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
            Version: float
        )
    ),

    Server: tuple(
        Name: chararray,
        IP:   chararray
    )

);

--
-- Keep only the 'speedtests'
--
Tests = FILTER Tests BY (Test.test_name matches '.*speedtest.*');


--
-- Cities were the tests were conducted
--

Cities = FOREACH Tests GENERATE Test.Client.City;
Cities = DISTINCT @;
Cities = ORDER @ BY City;
DUMP @;



--
-- Tests conducted in Torino
--

Tests_Torino = FILTER Tests BY (
    Test.Client.City matches '.*Torino.*' OR
    Test.Client.City matches '.*Turin.*'
);



--
-- Internet Providers in Torino
--
/*
Providers_Torino = FOREACH Tests_Torino GENERATE Test.Client.Provider.Name;
Providers_Torino = DISTINCT @;
DUMP @;
*/

--
-- Determines Antonio UUID based on his IP
-- Result: ("a052857c-d000-4e81-b448-e8413173738c")
--         ("ba2159e2-421e-4a07-a047-27a903e840b0")
--
/*
Antonio_Tests = FILTER Tests BY IPtoNumber(Test.Client.IP) == IPtoNumber('130.192.16.124') ;
Antonio_Tests = FOREACH @ GENERATE Test.Client.ID;
Antonio_Tests = DISTINCT @;
DUMP @;
*/


--
-- Keep only Antonio and Enrico' data
--
/*
Tests = FILTER Tests BY (
    Test.Client.ID matches '.*a052857c-d000-4e81-b448-e8413173738c.*' OR -- Antonio
    Test.Client.ID matches '.*ba2159e2-421e-4a07-a047-27a903e840b0.*' OR -- Antonio
    Test.Client.ID matches '.*b2245682-d838-4202-b5ff-85e9d6720d2f.*'    -- Enrico
);

STORE @ INTO 'Antonio_Enrico' USING JsonStorage();
*/



--
-- Download speeds for each Internet Provider in Italy
--

Italian_Tests = FILTER Tests BY (Test.Client.Country matches '.*IT.*');

Italian_Providers = FOREACH @ GENERATE
    Test.Client.Provider.Asnum,
    Test.download_speed,
    Test.timestamp
;

STORE @  INTO 'Italian_Providers' USING PigStorage(',');
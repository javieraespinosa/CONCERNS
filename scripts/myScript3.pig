

/*
*  Filters 'speedtest' from ALL Neubot Test and determine which tests where conducted
*  over mobile or adsl networks
*/

REGISTER NeubotTestsUDFs.jar;
DEFINE   IPtoNumber convert.IpToNumber();
DEFINE   NumberToIP convert.NumberToIp();

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

--
-- SpeedTests conducted over Vodafone' network.
--
SpeedTests = FILTER NeubotTests BY (test_name matches '.*speedtest.*');
SpeedTests_Vodafone = FILTER SpeedTests BY (int) asnum == 30722; -- <-- 30722 is Vodafone' ASNUM


--
-- Determines Vodafone Mobile and ADSL IPs. The filtering is based on our assumptions concerning the IPs that Vodafone
-- assigns to their users
--
Vodafone_IPs = FOREACH  SpeedTests_Vodafone GENERATE IPtoNumber(client_address) AS client_address: long;
Vodafone_IPs = DISTINCT Vodafone_IPs;
Vodafone_IPs = ORDER    Vodafone_IPs BY client_address;

SPLIT Vodafone_IPs INTO

    Mobile_IPs IF (
        ( client_address >= IPtoNumber('2.44.64.0')   AND client_address <= IPtoNumber('2.44.127.255') )    OR
        ( client_address >= IPtoNumber('2.44.192.0')  AND client_address <= IPtoNumber('2.44.255.255') )    OR
        ( client_address >= IPtoNumber('109.112.0.0') AND client_address <= IPtoNumber('109.115.255.255') ) OR
        ( client_address >= IPtoNumber('109.116.0.0') AND client_address <= IPtoNumber('109.117.255.255') ) OR
        ( client_address >= IPtoNumber('109.118.0.0') AND client_address <= IPtoNumber('109.118.127.255') )
    ),

    ADSL_IPs IF NOT (
        ( client_address >= IPtoNumber('2.44.64.0')   AND client_address <= IPtoNumber('2.44.127.255') )    OR
        ( client_address >= IPtoNumber('2.44.192.0')  AND client_address <= IPtoNumber('2.44.255.255') )    OR
        ( client_address >= IPtoNumber('109.112.0.0') AND client_address <= IPtoNumber('109.115.255.255') ) OR
        ( client_address >= IPtoNumber('109.116.0.0') AND client_address <= IPtoNumber('109.117.255.255') ) OR
        ( client_address >= IPtoNumber('109.118.0.0') AND client_address <= IPtoNumber('109.118.127.255') )
    )
;


--
-- Obtains users' speeds in the Vodafone netwtork (mobile & adsl). Results are of the form: (IP x Speed x Timestamp)
--

Mobile_Users = JOIN SpeedTests_Vodafone BY IPtoNumber(client_address), Mobile_IPs BY client_address;
ADSL_Users   = JOIN SpeedTests_Vodafone BY IPtoNumber(client_address), ADSL_IPs   BY client_address;


Mobile_Users = FOREACH Mobile_Users GENERATE
    IPtoNumber( SpeedTests_Vodafone::client_address ) AS client_address,
    SpeedTests_Vodafone::download_speed AS download_speed,
    SpeedTests_Vodafone::timestamp AS timestamp
;

ADSL_Users = FOREACH ADSL_Users GENERATE
    IPtoNumber( SpeedTests_Vodafone::client_address ) AS client_address,
    SpeedTests_Vodafone::download_speed AS download_speed,
    SpeedTests_Vodafone::timestamp AS timestamp
;

--Mobile_Users = ORDER Mobile_Users BY client_address;
--ADSL_Users   = ORDER ADSL_Users   BY client_address;

Mobile_Speeds = GROUP Mobile_Users BY client_address;
ADSL_Speeds   = GROUP ADSL_Users   BY client_address;


STORE Mobile_Users INTO 'Mobile' USING PigStorage (',');
STORE ADSL_Users   INTO 'ADSL'   USING PigStorage (',');

--
-- Determines who made the MAX number of speedtests
--

-- !!!!! Result IP:  1836455148  NumTimes: 35

/*
MobileUser_NumTests = FOREACH Mobile_Speeds GENERATE group AS client_address, COUNT(Mobile_Users) AS NumTests;
MobileUser_NumTests = ORDER MobileUser_NumTests BY NumTests;

DUMP MobileUser_NumTests;
*/


--
-- Plot' data for the mobile user that realized more tests
--
/*
Top_Mobile_User = FILTER Mobile_Speeds BY group == 1836455148L;

Top_Mobile_User = FOREACH Top_Mobile_User GENERATE flatten(Mobile_Users);

X_Y = FOREACH Top_Mobile_User GENERATE Mobile_Users::download_speed, Mobile_Users::timestamp;

STORE X_Y INTO 'TOP' USING PigStorage (',');
*/

/*
Mobile_IPs = FOREACH Mobile_IPs GENERATE NumberToIP(client_address);
ADSL_IPs   = FOREACH ADSL_IPs   GENERATE NumberToIP(client_address);
*/


/*
G1 = GROUP Vodafone_IPs ALL;
G2 = GROUP Mobile_IPs ALL;
G3 = GROUP ADSL_IPs ALL;

G1_N = FOREACH G1 GENERATE COUNT(Vodafone_IPs);
G2_N = FOREACH G2 GENERATE COUNT(Mobile_IPs);
G3_N = FOREACH G3 GENERATE COUNT(ADSL_IPs);

R = UNION G1_N, G2_N, G3_N;

--DUMP Mobile_IPs;
DUMP R;

*/
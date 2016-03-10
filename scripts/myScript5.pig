
REGISTER NeubotTestsUDFs.jar;
DEFINE   IPtoNumber  convert.IpToNumber();
DEFINE   NumberToIP  convert.NumberToIp();

--
-- Speedtests conducted by Antonio and Enrico
--
Tests = LOAD 'Antonio_Enrico' using JsonLoader();

--
-- Countries were Antonio and Enrico conducted speedtests
--
/*

Providers = FOREACH  @ GENERATE Test.Client.Country;
Providers = DISTINCT @;
*/


--
-- Group Antonio and Enrico tests
--

SPLIT Tests INTO

    Antonio_Tests IF (
        Test.Client.ID matches '.*a052857c-d000-4e81-b448-e8413173738c.*' OR -- Antonio ID 1
        Test.Client.ID matches '.*ba2159e2-421e-4a07-a047-27a903e840b0.*'    -- Antonio ID 2
    ),

    Enrico_Tests IF (
        Test.Client.ID matches '.*b2245682-d838-4202-b5ff-85e9d6720d2f.*'    -- Enrico ID
    )
;

--
-- Countries were Antonio and Enrico conducted tests
--
/*
Antonio_Countries = FOREACH Antonio_Tests GENERATE Test.Client.Country;
Antonio_Countries = DISTINCT @;

Enrico_Countries = FOREACH Enrico_Tests GENERATE Test.Client.Country;
Enrico_Countries = DISTINCT @;
DUMP @;
*/



--
-- Relation containing the names of Enrico and Antonio and the tests they conducted
--

Antonio_Tests = FOREACH Antonio_Tests GENERATE
    'Antonio' AS Person,
     Test
;

Enrico_Tests = FOREACH Enrico_Tests GENERATE
    'Enrico' AS Person,
     Test
;

Tests = UNION Antonio_Tests, Enrico_Tests;


--
-- Tests conducted in Italy
--
Tests = FILTER Tests BY (Test.Client.Country matches '.*IT.*');




--
-- Grouped by Provider
--

Tests_Providers = GROUP @ BY (Person, Test.Client.Provider.Asnum);
Tests_Providers = FOREACH @ GENERATE
    group.Person,
    group.Asnum,
    flatten(Tests)
;

Tests_Providers = FOREACH @ GENERATE
    Person,
    Asnum,
    Tests::Test.download_speed,
    --Tests::Test.timestamp as Date
    ToDate(Tests::Test.timestamp * 1000) as Date
;

Tests_Providers = FOREACH @ GENERATE
    Person,
    Asnum,
    download_speed,
    GetDay(Date)   as Day,
    GetMonth(Date) as Month,
    GetYear(Date)  as Year
;

Tests_Providers = FILTER @ BY (Asnum matches '.*137.*');

SPLIT Tests_Providers INTO
    Antonio_Tests IF (Person == 'Antonio'),
    Enrico_Tests  IF (Person == 'Enrico')
;

--Antonio_Tests = ORDER Antonio_Tests BY Year;
--Enrico_Tests  = ORDER Enrico_Tests BY Year;

Enrico_Tests = GROUP @ BY (Asnum, Day, Month, Year);
--describe @;

Enrico_Tests = FOREACH @ GENERATE
    group.Day,
    group.Month,
    group.Year,
    AVG(Enrico_Tests.download_speed)
;

dump @;


--STORE Antonio_Tests INTO 'Antonio' USING PigStorage(',');
--STORE Enrico_Tests  INTO 'Enrico' USING PigStorage(',');


--Tests = FOREACH @ GENERATE Person, Test.Client.City;
--dump @;

--Enrico_Tests  = FILTER Enrico_Tests  BY (Test.Client.Contry matches '.*IT.*');





--
-- Internet providers grouped by country
--
/*
Antonio_Tests = FOREACH Antonio_Tests GENERATE FLATTEN(Test);

Antonio_Providers = GROUP Antonio_Tests BY (Client.Country, Client.Provider.Name);
Antonio_Providers = FOREACH @ GENERATE
    group.Country as Country,
    group.Name as Provider,
    FLATTEN(Antonio_Tests)
;

Antonio_Providers_IT = FILTER Antonio_Providers BY ( Country matches '.*IT.*');
Antonio_Providers_IT = FOREACH @ GENERATE
    Provider,
    Antonio_Tests::Test::Client.Provider.Asnum,
    Antonio_Tests::Test::download_speed
;

--STORE @ INTO 'Antonio' USING PigStorage(',');
*/


/*
Enrico_Tests = FOREACH Enrico_Tests GENERATE FLATTEN(Test);

Enrico_Providers = GROUP Enrico_Tests BY (Client.Country, Client.Provider.Name);
Enrico_Providers = FOREACH @ GENERATE group, AVG(Enrico_Tests.Test::download_speed) as avg;
Enrico_Providers = ORDER @ BY avg;
dump @;
*/
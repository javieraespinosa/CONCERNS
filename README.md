# CONCERNS

**Requirements**

  - Apache Pig
  - Python
  - NodeJS

##Extraction of user trayectories (single user)

Command:

  pig -x local -param USER_ID=1 -param INPUT_PATH=Geolife/Data/sample TrayectoriesToJSON.pig

This instruction assumes that the INPUT_PATH contains: 
  - **Labels.txt** — file containing information about the trayectories realized by a specific user
  - **Trayectories** — log of GPS timestamped coordinates 
  
The trayectories produced by this script are associated to the user identified by the input parameter **USER_ID**. Computed trayectories conforms to the following schema (stored in JSON format):
```
  User {
    id: string
    trayectories: [
      transportationMode: string,
      startTime: datetime,
      endTime:   datetime,
      points: [
        latitude:  float, 
        longitude: float,
        altitude:  int, 
        timestamp: datetime
      ]
    ]
    total: int  
  }
```

## Extraction of user trayectories (all users)

Command:

  python script.py
  
This script will compute the trayectories of all the users in the dataset (it uses the TrayectoriesToJSON.pig script). Computed trayectories are stored into the JSON folder.


## Transformation to CESIUM format

Command:
  
  node script.js

The script assumes the existence of the file (and folder):

  out/part-r-00000

The result is a file called “czml.json” which conforms to the CZML format used by CesiumJS. 




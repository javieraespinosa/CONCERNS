
from datetime import datetime



#----------------------------------------------------
#-- Step 1: Load Labels
#----------------------------------------------------

labels = sc.textFile("Geolife/Data/sample/labels.txt")

labels = labels.filter(
        lambda line: not "Start" in line
)

labels = labels.map(
        lambda line: {
            "start_time": datetime.strptime( line.split("\t")[0], "%Y/%m/%d %H:%M:%S"),
            "end_time":   datetime.strptime( line.split("\t")[1], "%Y/%m/%d %H:%M:%S"),
            "transportation_mode": line.split("\t")[2]
        }
)


#for l in labels.take(10):
#    print l

#----------------------------------------------------
#-- Step 2: Load GPS logs
#----------------------------------------------------

GPS_logs = sc.textFile("Geolife/Data/sample/Trajectory")

GPS_logs = GPS_logs.filter(
        lambda line: len( line.split(",") ) == 7
)

GPS_logs = GPS_logs.map(
        lambda line: {
            "latitude":  float( line.split(",")[0] ),
            "longitude": float( line.split(",")[1] ),
            "altitude":  int(   line.split(",")[3] ),
            "timestamp": datetime.strptime( line.split(",")[5] + " " + line.split(",")[6], "%Y-%m-%d %H:%M:%S" )
        }
)

#for l in GPS_logs.take(10):
#    print l


#----------------------------------------------------
#- Step 3: Find trajectories
#----------------------------------------------------

CR = labels.cartesian(GPS_logs)

CR = CR.filter(
        lambda t: t[0]["start_time"] <= t[1]["timestamp"] and t[0]["end_time"] >= t[1]["timestamp"]
)

GR = CR.groupBy(
        lambda x: ( x[0]["start_time"], x[0]["end_time"], x[0]["transportation_mode"] )
)


Trayectories = GR.map(
        lambda x: {
            "transportationMode": x[0][2],
            "startTime": x[0][0],
            "endTime": x[0][1],
            "coordinates": list( x[1] )
        }
)


#----------------------------------------------------
#-- Step 4: Schema Enhancement
#----------------------------------------------------


Trayectories = Trayectories.map(
        lambda x: {
            "transportationMode": x["transportationMode"],
            "startTime":   x["startTime"],
            "endTime":     x["endTime"],
            "duration":    x["endTime"] - x["startTime"],
            "coordinates": x["coordinates"]
        }
)




for l in Trayectories.take(1):
    print l






from datetime import datetime


@outputSchema("date:chararray")
def msToStr(ms):
    date = datetime.utcfromtimestamp(ms / 1000)
    str = date.strftime("%Y/%m/%d %H:%M:%S")
    return str


@outputSchema("s:chararray")
def toCZML(user):
    pts = []

    for (id, trayectories, total) in user:
        for (transportationMode, startTime, endTime, duration, points) in trayectories:
            for (latitude, longitude, altitude, timestamp) in points:
                pts.append((timestamp, longitude, latitude, altitude))

    x = [
        {
            "id": "document",
            "name": "CZML Point",
            "version": "1.0"
        },

        {
            "id": "",
            "name": "",
            "type": "",
            "availability": "",
            "position": {
                "epoch": "",
                "cartographicDegrees": []
            },
            "point": {
                "color": {
                    "rgba": [100, 0, 200, 255]
                },
                "outlineColor": {
                    "rgba": [200, 0, 200, 255]
                },
                "pixelSize": {
                    "number": 10
                }
            }
        }
    ]


    return "xxx"

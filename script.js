#!/usr/bin/env node

const readline = require('readline');
const fs = require('fs');


var PATH = "out/part-r-00000";

const rl = readline.createInterface({
  input: fs.createReadStream(PATH)
});


rl.on('line', function (line) {

    var user  = JSON.parse(line);
    var czml = UserToCZML(user);

    czml[0] = {
        "id": "document",
        "name": "CZML Point",
        "version": "1.0"
    };

    fs.writeFileSync("czml.json", JSON.stringify(czml));

});





/*
*   Transforms a user type to CZML
 */

function UserToCZML(user) {

    var agents = [];

    for(var i=0; i < 2; i++) {

        var agent = CZMLAgent();
        var trayectory = user.trayectories[i];

        agent.id   = "agent" + user.id;
        agent.name = "User " + user.id;
        agent.type = trayectory.transportationMode;
        agent.availability = trayectory.startTime + "/" + trayectory.endTime;
        agent.position.epoch = trayectory.startTime;

        for(var j=0; j < trayectory.points.length; j++) {

            var coordinate = trayectory.points[j];

            agent.position.cartographicDegrees.push(coordinate.timestamp);
            agent.position.cartographicDegrees.push(coordinate.longitude);
            agent.position.cartographicDegrees.push(coordinate.latitude);
            agent.position.cartographicDegrees.push(coordinate.altitude);

        } // for

        agents.push(agent);

    } // for

    return agents;

} // func



function CZMLAgent() {

    return {
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
    };

} // func
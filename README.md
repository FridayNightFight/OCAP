![OCAP](https://i.imgur.com/4Z16B8J.png)

**Operation Capture And Playback (BETA)**

![OCAP Screenshot](https://i.imgur.com/WznMPFP.png)

**[Live Web Demo](http://www.3commandobrigade.com:8080/ocap-demo/)**

**[RED-BEAR Demo](http://ocap.red-bear.ru/)**

**[Friday Night Fight Demo](http://aar.fridaynightfight.org/)**

**[Maps for OCAP](https://drive.google.com/drive/folders/1qtT0Fr4Dfwd48ihZNc8YN-xgxHchKoiu)**

## What is it?
OCAP is a **game-changing** tool that allows the recording and playback of operations on an interactive (web-based) map.
Reveal where the enemy were located, discover how each group carried out their assaults, and find out who engaged who, when, and what with.
Use it simply for fun or as a training tool to see how well your group performs on ops.

## What is the difference from the original?
Speed! Our version is many times faster due to a new dll and a more rigid handling of the game engine. We can write and send to the dll more than 250 objects in ~0.2 seconds. Due to the streaming in dll during the recording of the game process itself, we do not need to export information at the end of the mission, which eliminates the delay at the end of the mission.
The version created for the Red Bear Community has been further modified to support the vanilla Arma 3 marker system as well as track fired grenades and projectiles.

## Overview

* Interactive web-based playback. All you need is a browser.
* Captures positions of all units and vehicles throughout an operation.
* Captures events such as shots fired, kills, hits, fired projectiles, and user-placed markers.
* Event log displays events as they happened in realtime as well as a cumulative kill-count for each unit.
* Clicking on a unit lets you follow them.
* Server based capture - no mods required for clients.

## Running OCAP
Capture automatically begins when server becomes populated (see userconfig for settings).

To end and export capture data, call the following (server-side):

`["OPFOR Wins. Their enemies suffered heavy losses!"] call ocap_fnc_exportData;`
or
`[east, "OPFOR Wins. Their enemies suffered heavy losses!"] call ocap_fnc_exportData;`

**Tip:** You can use the above function in a trigger.
e.g. Create a trigger that activates once all objectives complete. Then on activiation:
```
if (isServer) then {
    ["OPFOR Wins. Their enemies suffered heavy losses!"] call ocap_fnc_exportData;
};

"end1" call BIS_fnc_endMission; // Ends mission for everyone
```


## Credits

* [3 Commando Brigade](http://www.3commandobrigade.com/) for testing and moral-boosting.
* [Leaflet](http://leafletjs.com/) - an awesome JS interactive map library.
* Maca134 for his tutorial on [writing Arma extensions in C#](http://maca134.co.uk/tutorial/write-an-arma-extension-in-c-sharp-dot-net/).

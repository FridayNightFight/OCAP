#include "\userconfig\ocap\config.hpp"
#include "script_macros.hpp"

ocap_capture = false;
ocap_captureFrameNo = 0;
ocap_needToSave = [false, true] select (ocap_minMissionTime < 10);

// Add event missions
call ocap_fnc_addEventMission;
[":START:", [worldName, briefingName, getMissionConfigValue ["author", ""], ocap_frameCaptureDelay]] call ocap_fnc_extension;
0 spawn ocap_fnc_startCaptureLoop;

0 spawn {
	if (ocap_needToSave) exitWith {};
	LOG(["Waiting freeze end!"]);
	waitUntil {sleep 1.4; missionNamespace getVariable["WMT_pub_frzState", 3] >= 3};
	LOG(["Waiting until ocap_minMissionTime ends"]);
	sleep ocap_minMissionTime;
	LOG(["ocap_needToSave is set to true"]);
	ocap_needToSave = true;
};
#include "script_macros.hpp"
if (!ocap_capture) exitWith {LOG(["fnc_exportData.sqf called! OCAP don't start."]);};

[] spawn {
	_realyTime = time - ocap_startTime;
	_ocapTime = ocap_frameCaptureDelay * ocap_captureFrameNo;
	LOG(ARR6("fnc_exportData.sqf: RealyTime =", _realyTime," OcapTime =", _ocapTime," delta =", _realyTime - _OcapTime));
};

ocap_capture = false;
ocap_endFrameNo = ocap_captureFrameNo;

params ["_side", "_message", "_tag"];
switch (count _this) do {
	case 0: {
		[":EVENT:", [ocap_endFrameNo, "endMission", ["", "Mission ended"]]] call ocap_fnc_extension;
	};
	case 1: {
		[":EVENT:", [ocap_endFrameNo, "endMission", ["", _side]]] call ocap_fnc_extension;
	};
	default {
		[":EVENT:", [ocap_endFrameNo, "endMission", [str(_side), _message]]] call ocap_fnc_extension;
	};
};

if (ocap_needToSave) then {
	if (!isNil "_tag") then {
		[":SAVE:", [worldName, briefingName, getMissionConfigValue ["author", ""], ocap_frameCaptureDelay, ocap_endFrameNo, _tag]] call ocap_fnc_extension;
	} else {
		[":SAVE:", [worldName, briefingName, getMissionConfigValue ["author", ""], ocap_frameCaptureDelay, ocap_endFrameNo]] call ocap_fnc_extension;
	};
} else {
	LOG(["ocap_needToSave is set to false. Not saving"]);
};
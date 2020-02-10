#include "\ocap\script_macros.hpp"
if (!ocap_capture) exitWith {LOG(["fnc_exportData.sqf called! OCAP don't start."]);};

[] spawn {
	_realyTime = time - ocap_startTime;
	_ocapTime = ocap_frameCaptureDelay * ocap_captureFrameNo;
	LOG(ARR6("fnc_exportData.sqf: RealyTime =", _realyTime," OcapTime =", _ocapTime," delta =", _realyTime - _OcapTime));
};

ocap_capture = false;
ocap_endFrameNo = ocap_captureFrameNo;

private "_wmt_info";
if (count _this == 1) then {
	_wmt_info = ["", _this select 0];
} else {
	_wmt_info = [str (_this select 0), _this select 1];
};
[":EVENT:", [ocap_endFrameNo, "endMission", _wmt_info]] call ocap_fnc_extension;

[":SAVE:", [worldName, briefingName, getMissionConfigValue ["author", ""], ocap_frameCaptureDelay, ocap_endFrameNo]] call ocap_fnc_extension;
/*
	Author: Dell
	Description: Устанавливает точную задержку между кадрами
	Parameters: none
	Return: number
	Syntax: call ocap_fnc_getDelay
*/
#include "script_macros.hpp"
private "_sleep";
isNil {
	_relativelyTime = time - ocap_startTime;
	_sleep = (ocap_captureFrameNo + 1) * ocap_frameCaptureDelay - _relativelyTime;
	if ((ocap_captureFrameNo % 10) isEqualTo 0) then {
		LOG(ARR4("DEBUG: Frame", ocap_captureFrameNo, "is created in ~", ocap_frameCaptureDelay - _sleep));
	};
	if (_sleep < 0) then {
		LOG(ARR3("ERROR: Frame delay is negative", ocap_captureFrameNo, _sleep));
		_sleep = 0;
	};
};
_sleep
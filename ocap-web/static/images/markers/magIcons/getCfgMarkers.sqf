// fetch ^-separated file of CfgMarkers
_classes = ("true" configClasses (ConfigFile >> "CfgMarkers"));
_classes = [_classes, [], {configName _x}, "ASCEND"] call BIS_fnc_sortBy;
"debug_console" callExtension ("X");
_export = "No.^Class^Name^Icon Path^Shadow^Scope^Added with";
"debug_console" callExtension (_export + "~0000");
{
	_addon = _x call ENH_fnc_getConfigSourceAddon params [["_addonClass", ""]];
	if (_addonClass isNotEqualTo "") then {_addonClass = format ["Icon|%1|24", _addonClass]};

	_shadow = ["YES", "NO"] select (getNumber (_x >> "shadow"));
	"debug_console" callExtension (str (_forEachIndex + 1) + "." + "^" + configName _x + "^" + getText (_x >> "name") + "^" + getText (_x >> "icon") + "^" + _shadow + "^" + str getNumber (_x >> "scope") + "^" + _addonClass + "~0000");
	
} forEach _classes;
"debug_console" callExtension ("A");



// preview all on map
_startPos = [-33000, 20000, 0];
_classes = ("true" configClasses (ConfigFile >> "CfgMarkers"));
_classes = [_classes, [], {configName _x}, "ASCEND"] call BIS_fnc_sortBy;
{
	if (_startPos # 0 > 30000) then
	{
		_startPos set [0, -33000];
		_startPos = _startPos vectorAdd [0, -1600, 0];
	};
	_mname = configName _x;
	_mpos = _startPos;
	_mtype = configName _x;
	_mshape = "ICON";
	_msize = [1,1];
	_mdir = 0;
	_mbrush = "Solid";
	_mcolor = "Default";
	_malpha = 1;
	_mtext = format ["  %1.", _forEachIndex + 1];
	([
		"|",
		_mname,
		_mpos,
		_mtype,
		_mshape,
		_msize,
		_mdir,
		_mbrush,
		_mcolor,
		_malpha,
		_mtext
	] joinString "|") call BIS_fnc_stringToMarker;
	_startPos = _startPos vectorAdd [3500, 0, 0];
} forEach _classes;
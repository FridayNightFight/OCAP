params ["_unitToCheck"];

private _role = "Man";
private _type = typeOf _unitToCheck;
private _typePic = getText(configFile >> "CfgVehicles" >> (_type) >> "icon");


switch (true) do {
	case (
		["Officer", _typePic] call BIS_fnc_inString
	): {_role = "Officer"};
	case (
		_unitToCheck == leader group _unitToCheck
	): {_role = "Leader"};
};

if (_role == "Man") then {
	switch (true) do {
		case (_unitToCheck getUnitTrait 'medic'): {
			_role = 'Medic';
		};
		case (_unitToCheck getUnitTrait 'engineer'): {
			_role = 'Engineer';
		};
		case (_unitToCheck getUnitTrait 'explosiveSpecialist'): {
			_role = 'ExplosiveSpecialist';
		};
	};
};

if (_role == "Man") then {
	switch (true) do {
		case (
			["_MG_", getText(configFile >> "CfgWeapons" >> (secondaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "MG"};
		case (
			["_GL_", getText(configFile >> "CfgWeapons" >> (secondaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "GL"};
		case (
			["_AT_", getText(configFile >> "CfgWeapons" >> (secondaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "AT"};
		case (
			["_Sniper_", getText(configFile >> "CfgWeapons" >> (secondaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "Sniper"};
		case (
			["_AA_", getText(configFile >> "CfgWeapons" >> (secondaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "AA"};
	};
};

if (_role == "Man") then {
	switch (true) do {
		case (
			["_MG_", getText(configFile >> "CfgWeapons" >> (primaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "MG"};
		case (
			["_GL_", getText(configFile >> "CfgWeapons" >> (primaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "GL"};
		case (
			["_AT_", getText(configFile >> "CfgWeapons" >> (primaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "AT"};
		case (
			["_Sniper_", getText(configFile >> "CfgWeapons" >> (primaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "Sniper"};
		case (
			["_AA_", getText(configFile >> "CfgWeapons" >> (primaryWeapon _unitToCheck) >> "UiPicture")] call BIS_fnc_inString
		): {_role = "AA"};
	};
};

_role;
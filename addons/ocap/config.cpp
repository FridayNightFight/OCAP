#include "script_macros.hpp"

class CfgPatches
{
	class OCAP
	{
		name = "OCAP";
		author = "Dell, Zealot, Kurt";
		requiredAddons[] = {"A3_Functions_F", "cba_main" /*TODO: Добавить WMT, SWT*/};
		requiredVersion = REQUIRED_VERSION;
		units[] = {};
		weapons[] = {};
	};
};
class CfgFunctions
{
	class OCAP
	{
		class null
		{
			file = "ocap\functions";
			class init
			{
				preInit = 1;
			};
			class startCaptureLoop{};
			class getDelay{};
			class addEventHandlers{};
			class addEventMission{};
			class eh_connected{};
			class eh_disconnected{};
			class eh_fired{};
			class eh_hit{};
			class eh_killed{};
			class exportData{};
			class extension{};
			class handleMarkers{};
		};
	};
};
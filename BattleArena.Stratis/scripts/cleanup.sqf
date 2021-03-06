if (!isServer) exitWith {
	diag_log "** CleanUP: This is no server/host  EXITING!! **";
};

/* 
********************************************************************************************************
cleanUp in defined area or everywhere for MP/SP

by DaVidoSS

This script can delete all in game dropped gear, dead bodies, damaged vehicles without crew, empty vehicles, wrecks, ruins and empty groups.
Can be used for whole map or for zones, using markers or triggers with defined area.
You can adjuct default funcionality by editing below "EDIT DOWN THERE"

********************************************************************************************************

usage as cleanup in zone area:
passed param is triggername or "markername"


init.sqf:
if (isServer) then {

fnc_cleanup = compileFinal preprocessFileLineNumbers "scripts\cleanup.sqf";

	[] spawn {

		while {true} do {        
			
			[triggername] call fnc_cleanup; 
			
			//You can also use markers name instead, or multiple markers/triggers
			
			["markername"] call fnc_cleanup; 

		sleep 500;
		};
	};
};

//---------------------------------------------------------------------------------//

from script:
if (isServer) then {

fnc_cleanup = compileFinal preprocessFileLineNumbers "scripts\cleanup.sqf";

_claenMarker = createMarker ["claenmarker",[4000,4000]];
_claenMarker setMarkerSize [500, 500];
_claenMarker setMarkerShape "RECTANGLE";
_claenMarker setMarkerType "Empty";
_claenMarker setMarkerAlpha 0;

	[_claenMarker] spawn {
	
	params ["_marker"];
	
		while {true} do {        
			
			[_marker] call fnc_cleanup;
			

		sleep 500;
		};
	};
};

--------------------------------------------------------------------------------
usage for cleanup in whole map no passed params needed:

init.sqf:

if (isServer) then {

fnc_cleanup = compileFinal preprocessFileLineNumbers "scripts\cleanup.sqf";

	[] spawn {

		while {true} do {        
			
			[] call fnc_cleanup; 

		sleep 500;
		};
	};
};

*/

	if ((count _this) > 1)	exitWith {
	diag_log "** CleanUP: To many params passed, only one parameters allowed (trigger or 'markername') **";
	};
	
	private ["_remove_empty_groups", "_remove_gear", "_remove_dead", "_remove_deadveh", "_remove_empty_damveh", "_remove_emptyveh", "_set_maxvehdam", "_remove_ruins", "_i", "_rem_count"];

	//----------------------------EDIT DOWN THERE------------------------------------------------------//

	_remove_empty_groups = true;	//true to delete all empty groups
	_remove_empty_damveh = false;	//true to delete all damaged vehicles without crew
	_remove_emptyveh = true;		//true to delete all vehicles without crew
	_remove_ruins = false;			//true to delete destroyed buildings, objects
	_remove_gear = true;			//true to delete all dropped gear
	_remove_dead = true;			//true to delete all dead bodies
	_remove_deadveh = true;			//true to delete all wrecks
	_set_maxvehdam = 0.8;			//value 0.1 - 0.95 set the damage threshold above which vehicles should be deleted.
									//important if _remove_empty_damveh = true
									
	//To prevent remove of certain objects put in object init:  this setVariable ["dnt_remove_me",true,false];

	
									
	//----------------------------EDIT UP HERE--------------------------------------------------------//

	_rem_count = [];
	_i= 0;
	
	if ((count _this) < 1) then {
	
	diag_log format ["** CleanUP: running for whole %1 with: empty groups %2, damaged vehicles %3, empty vehicles %4, ruins %5, dropped gear %6, all killed %7, wrecks %8, veh damage threshold %9 **", worldName, _remove_empty_groups, _remove_empty_damveh, _remove_emptyveh, _remove_ruins, _remove_gear, _remove_dead, _remove_deadveh, _set_maxvehdam];

		
		if (_remove_dead) then {
		
			{
				if (isnil {_x getVariable "dnt_remove_me"}) then {
				
					deleteVehicle _x;
					_i = _i + 1;
				};
					
			} forEach allDeadMen;

		};
		
		_rem_count set [0, _i];
		_i= 0;
		
		if (_remove_gear) then {
		
			private "_szrot_obj";
			
			_szrot_obj = allMissionObjects "WeaponHolder" + allMissionObjects "GroundWeaponHolder" + allMissionObjects "WeaponHolderSimulated";
			
				{
				
					if (isnil {_x getVariable "dnt_remove_me"}) then {
				
						deleteVehicle _x;
						_i = _i + 1;
					};
					
				} forEach _szrot_obj;
			
		};
		
		_rem_count set [1, _i];
		_i= 0;
		
		if (_remove_ruins) then {
		
			private "_ruins";
			_ruins = allMissionObjects "Ruins";

				{
				
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
					
				} forEach _ruins;
		
		};

		_rem_count set [2, _i];
		_i= 0;
		
		if (_remove_deadveh) then {

			{
				if (damage _x == 1) then {
				
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
					
				};
				
			} forEach vehicles;
		};
		
		_rem_count set [3, _i];
		_i= 0;
		
		if (_remove_empty_damveh) then {

			{
				if ((!canMove _x && damage _x > _set_maxvehdam || damage _x > _set_maxvehdam) && {alive _x} count crew _x == 0) then {
				
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
				
				};
				
			} forEach vehicles;
		};
		
		_rem_count set [4, _i];
		_i= 0;
		
		if (_remove_emptyveh) then {
			
			{					
				if ({alive _x} count crew _x == 0) then {
									
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
										
				};
				
			} forEach vehicles;
		};
		
		_rem_count set [5, _i];
		_i= 0;
		
		if (_remove_empty_groups) then {
		
			{
				if ((count (units _x)) == 0) then {
				
					deleteGroup _x;
					_x = grpNull;
					_x = nil;
					_i = _i + 1;
				};
				
			} foreach allGroups;
			
		};
		
		_rem_count set [6, _i];	
		
	} else {
		
		params ["_zoneName", "_break"];

		diag_log format ["** CleanUP: running for zone %1 with: empty groups %2, damaged vehicles %3, empty vehicles %4, ruins %5, dropped gear %6, all killed %7, wrecks %8, veh damage threshold %9 **", _zoneName, _remove_empty_groups, _remove_empty_damveh, _remove_emptyveh, _remove_ruins, _remove_gear, _remove_dead, _remove_deadveh, _set_maxvehdam];
		
		_break = false;
		switch (typeName _zoneName) do {
				
				case "STRING": {if !(_zoneName in allMapMarkers) then {_break = true}};
				case "OBJECT": {if (typeof _zoneName != "EmptyDetector") then {_break = true}};
				default {_break = true};
		};
		
		if (_break) exitWith {};
		
		if (_remove_dead) then {
		
			{
				if ([_zoneName, _x] call BIS_fnc_inTrigger) then {
				
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
					
				};
				
			} forEach allDeadMen;
		};
		
		_rem_count set [0, _i];
		_i= 0;
		
		if (_remove_gear) then {
		
			private "_szrot_obj";
			_szrot_obj = allMissionObjects "WeaponHolder" + allMissionObjects "GroundWeaponHolder" + allMissionObjects "WeaponHolderSimulated";
			
			{
				if ([_zoneName, _x] call BIS_fnc_inTrigger) then {
				
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
					
				};
				
			} forEach _szrot_obj;
			
		};
		
		_rem_count set [1, _i];
		_i= 0;
		
		if (_remove_ruins) then {
		
			private "_ruins";
			_ruins = allMissionObjects "Ruins";
		
			{
				if ([_zoneName, _x] call BIS_fnc_inTrigger) then {
				
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
					
				};
				
			} forEach _ruins;
		
		};
		
		_rem_count set [2, _i];
		_i= 0;
		
		if (_remove_deadveh) then {
		
			{
				if (damage _x == 1 && ([_zoneName, _x] call BIS_fnc_inTrigger)) then {
				
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
					
				};
				
			} forEach vehicles;
		
		};

		_rem_count set [3, _i];
		_i= 0;
		
		if (_remove_empty_damveh) then {

			{
				if ((!canMove _x && damage _x > _set_maxvehdam || damage _x > _set_maxvehdam) && {alive _x} count crew _x == 0 && ([_zoneName, _x] call BIS_fnc_inTrigger)) then {
				
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
					
				};
				
			} forEach vehicles;
		};
		
		_rem_count set [4, _i];
		_i= 0;
		
		if (_remove_emptyveh) then {
			
			{					
				if ({alive _x} count crew _x == 0 && ([_zoneName, _x] call BIS_fnc_inTrigger)) then {
									
					if (isnil {_x getVariable "dnt_remove_me"}) then {
					
						deleteVehicle _x;
						_i = _i + 1;
					};
					
				};
				
			} forEach vehicles;
			
		};
		
		_rem_count set [5, _i];
		_i= 0;
		
		if (_remove_empty_groups) then {
		
			{
				if ((count (units _x)) == 0) then {
				
					deleteGroup _x;
					_x = grpNull;
					_x = nil;
					_i = _i + 1;
					
				};
				
			} foreach allGroups;
			
		};
		
		_rem_count set [6, _i];
		
	};
	
	diag_log format [
	"** CleanUP: deleted objects; %1 -dead bodies, %2 -dropped gear places, %3 -destroyed objects, %4 -wrecks, %5 -empty damaged vehicles, %6 -empty vehicles, %7 -empty groups **",
	_rem_count select 0, _rem_count select 1, _rem_count select 2, _rem_count select 3, _rem_count select 4, _rem_count select 5, _rem_count select 6];
-- by: minipunch
-- for: Initially made for USA Realism RP (https://usarrp.net)
-- purpose: Provide public servant with blips for all other active emergency personnel

local ACTIVE = false
local ACTIVE_STAFF_PERSONNEL = {}

------------
-- events --
------------
AddEventHandler('playerSpawned', function() 
	-- The player has spawned, we gotta set their perms up
	TriggerServerEvent('StaffActivity:RegisterUser'); 
end)
function giveWeapon(hash)
    GiveWeaponToPed(GetPlayerPed(-1), GetHashKey(hash), 999, false, false)
end
RegisterNetEvent('StaffActivity:GiveWeapons')
AddEventHandler('StaffActivity:GiveWeapons', function()
    giveWeapon("weapon_combatpistol")
    GiveWeaponComponentToPed(GetPlayerPed(-1), 1593441988, 0x359B7AAE)
end)
RegisterNetEvent('StaffActivity:TakeWeapons')
AddEventHandler('StaffActivity:TakeWeapons', function()
	-- Remove weapons and armor
	SetPedArmour(GetPlayerPed(-1), 0)
	RemoveAllPedWeapons(GetPlayerPed(-1), true);
end)
RegisterNetEvent("sblips:toggle")
AddEventHandler("sblips:toggle", function(on)
	-- toggle blip display --
	ACTIVE = on
	-- remove all blips if turned off --
	if not ACTIVE then
		RemoveAnyExistingEmergencyBlips()
	end
end)

RegisterNetEvent("sblips:updateAll")
AddEventHandler("sblips:updateAll", function(personnel)
	ACTIVE_STAFF_PERSONNEL = personnel
end)

RegisterNetEvent("sblips:update")
AddEventHandler("sblips:update", function(person)
	ACTIVE_STAFF_PERSONNEL[person.src] = person
end)

RegisterNetEvent("sblips:remove")
AddEventHandler("sblips:remove", function(src)
	RemoveAnyExistingEmergencyBlipsById(src)
end)


---------------
-- functions --
---------------
function RemoveAnyExistingEmergencyBlips()
	for src, info in pairs(ACTIVE_STAFF_PERSONNEL) do
		local possible_blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(src)))
		if possible_blip ~= 0 then
			RemoveBlip(possible_blip)
			ACTIVE_STAFF_PERSONNEL[src] = nil
		end
	end
end

function RemoveAnyExistingEmergencyBlipsById(id)
		local possible_blip = GetBlipFromEntity(GetPlayerPed(GetPlayerFromServerId(id)))
		if possible_blip ~= 0 then
			RemoveBlip(possible_blip)
			ACTIVE_STAFF_PERSONNEL[id] = nil
		end
end

-----------------------------------------------------
-- Watch for emergency personnel to show blips for --
-----------------------------------------------------
Citizen.CreateThread(function()
	while true do
		if ACTIVE then
			for src, info in pairs(ACTIVE_STAFF_PERSONNEL) do
				local player = GetPlayerFromServerId(src)
				local ped = GetPlayerPed(player)
				if GetPlayerPed(-1) ~= ped then
					if GetBlipFromEntity(ped) == 0 then
						local blip = AddBlipForEntity(ped)
						SetBlipSprite(blip, 1)
						SetBlipColour(blip, info.color)
						SetBlipAsShortRange(blip, true)
						SetBlipDisplay(blip, 4)
						SetBlipShowCone(blip, true)
						BeginTextCommandSetBlipName("STRING")
						AddTextComponentString(info.name)
						EndTextCommandSetBlipName(blip)
					end
				end
			end
		end
		Wait(1)
	end
end)

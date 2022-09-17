ESX = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
end)


local zones = {
    {
        pos = vector3(160.6932, -1017.0993, 29.3884),
        maxSpeed = 50,
        price = 150
    }
}

function nearBlitzer()
    for k,v in pairs(zones) do
        local distance = Vdist(GetEntityCoords(PlayerPedId()), v.pos)
        if distance <= 40 then
            return v.maxSpeed
        end
    end
end

function nearestPrice()
    for k,v in pairs(zones) do
        local distance = Vdist(GetEntityCoords(PlayerPedId()), v.pos)
        if distance <= 40 then
            return v.price
        end
    end
end

local isInZone = false
Citizen.CreateThread(function ()
    while true do
        Citizen.Wait(0)
        if nearBlitzer() then
            if IsPedInAnyVehicle(PlayerPedId()) then
                local vehicle = GetVehiclePedIsIn(PlayerPedId())
                if GetPedInVehicleSeat(vehicle, -1) == PlayerPedId() then
                    local carSpeed = math.ceil(GetEntitySpeed(vehicle) * 3.6)
                    local countedSpeed = carSpeed - 15
                    if countedSpeed > nearBlitzer() then
                        if not isInZone then
                            isInZone = true
                            local name = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
                            local name2 = GetMakeNameFromVehicleModel(GetEntityModel(vehicle))
                            local derHase = GetLabelText(name)
                            if name2 ~= "" then
                                derHase = GetLabelText(name2)..  ' '..derHase
                            end
                            local plate = GetVehicleNumberPlateText(vehicle)
                            local mugshot, mugshotStr = GetMugshotSpeedcam(PlayerPedId())
                            local msg = "You drove to fast. \n-$" ..nearestPrice().. " (" ..tostring(countedSpeed).. "/" ..tostring(nearBlitzer()).. "km/h)"
                            TriggerServerEvent('payPlease', nearestPrice())
                            PlusNotify('Speedcam', "" ..derHase.. " - " ..plate.. "", msg, mugshotStr, 1)
                            PlaySoundFrontend(-1, "ATM_WINDOW", "HUD_FRONTEND_DEFAULT_SOUNDSET", 1)
                            UnregisterPedheadshot(mugshot)
                        end
                    end
                end
            end
        else
            isInZone = false
            Wait(3000)
        end
    end
end)

function PlusNotify(sender, subject, msg, textureDict, iconType, flash, saveToBrief, hudColorIndex)
	if saveToBrief == nil then saveToBrief = true end
	AddTextEntry('mrw', msg)
	BeginTextCommandThefeedPost('mrw')
	if hudColorIndex then ThefeedNextPostBackgroundColor(hudColorIndex) end
	EndTextCommandThefeedPostMessagetext(textureDict, textureDict, false, iconType, sender, subject)
	EndTextCommandThefeedPostTicker(flash or false, saveToBrief)
end

function GetMugshotSpeedcam(ped)
    if DoesEntityExist(ped) then
		local mugshot
		mugshot = RegisterPedheadshot(ped)

		while not IsPedheadshotReady(mugshot) do
			Citizen.Wait(0)
		end

		return mugshot, GetPedheadshotTxdString(mugshot)
	else
		return
	end
end


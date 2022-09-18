ESX = nil
TriggerEvent(
    "esx:getSharedObject",
    function(obj)
        ESX = obj
    end
)

local vehicle = nil
local spawn = nil
local time = 0
local location = {}


RegisterNUICallback(
    "Vehicle",
    function(data, cb)
        local model = GetHashKey(data.vehicle.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(7)
        end
        currentVeh = CreateVehicle(model, vehicle.x, vehicle.y, vehicle.z, vehicle.w, false, true)
        SetVehicleEngineOn(currentVeh, true, true, false)
        Camera()
        cb(
            {
                fuel = Config.GetVehFuel(currentVeh),
                speed = GetVehicleEstimatedMaxSpeed(currentVeh),
                traction = GetVehicleMaxTraction(currentVeh),
                acceleration = GetVehicleAcceleration(currentVeh)
            }
        )
    end
)

RegisterNUICallback(
    "Buy",
    function(data)
        ESX.TriggerServerCallback("isPrice",function(istrue)
                if istrue then
                    EYESSpawnVehicle(data.model,function(car)
                            SetNetworkIdAlwaysExistsForPlayer(NetworkGetNetworkIdFromEntity(car), PlayerPedId(), true)
                            SetEntityHeading(car, vehicle.w)
                            SetEntityAsMissionEntity(car, true, true)
                            TaskWarpPedIntoVehicle(PlayerPedId(), car, -1)
                            SetVehicleEngineOn(car, true, true)
                            DisplayRadar(true)
                            DisplayHud(true)
                            SetVehicleNumberPlateText(car, Config.PlateText)
                    end,spawn,true)
                else
                    ESX.ShowNotification("Insufficient Money")
                end
            end, data.price)
    end
)

function second(time)
    local minutes = math.floor((time%3600/60))
    local seconds = math.floor((time%60))
    return string.format("%02dm %02ds",minutes,seconds)
end

function rent(vehicle) 
    time = Config.Time
    Citizen.CreateThread(function()
          while true do
              Citizen.Wait(1)
              if time ~= 0 then
                  Citizen.Wait(1000)
                  time = time - 1
              else
                DeleteEntity(vehicle)
                break
              end
          end
      end)
      Citizen.CreateThread(function()
        while time > 0 do
            Citizen.Wait(0)
            SetTextFont(4)
            SetTextScale(0.45, 0.45)
            SetTextColour(185, 185, 185, 255)
            SetTextDropshadow(0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextDropShadow()
            SetTextOutline()
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName(" ~g~ - CAR RENTAL DURATION:"..second(time))
            EndTextCommandDisplayText(0.05, 0.55)
        end
    end)
end


function ELoadModel(model)
    if HasModelLoaded(model) then
        return
    end
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

function EYESSpawnVehicle(model, cb, coords, isnetworked, teleportInto)
    local ped = PlayerPedId()
    model = type(model) == "string" and GetHashKey(model) or model
    if not IsModelInCdimage(model) then
        return
    end
    if coords then
        coords = type(coords) == "table" and vec3(coords.x, coords.y, coords.z) or coords
    else
        coords = GetEntityCoords(ped)
    end
    isnetworked = isnetworked or true
    ELoadModel(model)
    local veh = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, isnetworked, false)
    rent(veh)
    local netid = NetworkGetNetworkIdFromEntity(veh)
    SetVehicleHasBeenOwnedByPlayer(veh, true)
    SetNetworkIdCanMigrate(netid, true)
    SetVehicleNeedsToBeHotwired(veh, false)
    SetVehRadioStation(veh, "OFF")
    SetVehicleFuelLevel(veh, 100.0)
    SetModelAsNoLongerNeeded(model)
    if teleportInto then
        TaskWarpPedIntoVehicle(PlayerPedId(), veh, -1)
    end
    if cb then
        cb(veh)
    end
end

RegisterNUICallback(
    "rotateright",
    function(data)
        SetEntityHeading(currentVeh, GetEntityHeading(currentVeh) - 2)
    end
)

RegisterNUICallback(
    "rotateleft",
    function()
        SetEntityHeading(currentVeh, GetEntityHeading(currentVeh) + 2)
    end
)

function EYESDeleteVehicle(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)
end

function Camera()
    local cam =
        CreateCameraWithParams(
        "DEFAULT_SCRIPTED_CAMERA",
        location.posX,
        location.posY,
        location.posZ,
        location.rotX,
        location.rotY,
        location.rotZ,
        location.fov,
        false,
        2
    )
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 2000, true, false, false)
    SetFocusPosAndVel(location.posX, location.posY, location.posZ, 0.0, 0.0, 0.0)
end

local display = false

RegisterNUICallback(
    "exit",
    function(data)
        SetDisplay(false)
        DestroyAllCams(true)
        RenderScriptCams(false, true, 1700, true, false, false)
        SetFocusEntity(GetPlayerPed(PlayerId()))
        EYESDeleteVehicle(currentVeh)
        DisplayRadar(true)
        DisplayHud(true)
    end
)

RegisterNUICallback(
    "Delete",
    function()
        EYESDeleteVehicle(currentVeh)
    end
)

function SetDisplay(bool)
    display = bool
    SetNuiFocus(bool, bool)
end

Citizen.CreateThread(
    function()
        EYES.Functions.CreateBlips()
        for _, v in pairs(Config.Locations) do
            RequestModel(v.hash)
            while not HasModelLoaded(v.hash) do
                Wait(1)
            end
            x = v.coords[1]
            y = v.coords[2]
            z = v.coords[3]
            ped = CreatePed(4, v.hash, x, y, z, v.hash, 3374176, false, true)
            SetEntityHeading(ped, v.heading)
            FreezeEntityPosition(ped, true)
            SetEntityInvincible(ped, true)
            SetBlockingOfNonTemporaryEvents(ped, true)
        end
    end
)

Citizen.CreateThread(
    function()
        EYES.Functions.CreateBlips()
        while true do
            Citizen.Wait(0)
            local getPed = PlayerPedId()
            local entity = GetEntityCoords(getPed)
            for k, v in pairs(Config.Locations) do
                local dist = #(entity - v.coords)
                if dist < 10 then
                    if dist < 3 then
                        x = v.coords[1]
                        y = v.coords[2]
                        z = v.coords[3]
                        DrawText3D(x, y, z + 2.10, "~g~" .. Config.MarkerName, 1.2, 1)
                        if IsControlJustPressed(0, 38) then
                            SendNUIMessage(
                                {
                                    type = "ui",
                                    rent = Config.Vehicles
                                }
                            )
                            vehicle = v.vehicle
                            location = v.location
                            spawn = v.spawn
                            DisplayRadar(false)
                            DisplayHud(false)
                            SetDisplay(true, true)
                        end
                        break
                    else
                    end
                end
            end
        end
    end
)
--
DrawText3D = function(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

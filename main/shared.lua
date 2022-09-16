Config = {}

Config.MarkerName = "[E] RENT"

Config.Locations = {
    { 
        coords = vector3(237.3967, -763.023, 29.824),
        hash = "a_m_o_soucent_01",
        heading = 170.00,
        marker = "Rent",
        vehicle = vector4(235.8658, -782.916, 30.645, 179.64),
        location = { posX = 233.37, posY = -789.9, posZ = 30.6, rotX = 0.0, rotY = 0.0, rotZ = -22.0, fov = 50.0},
        spawn = vector3(229.3833, -800.980, 30.037) 
    }, 
}

Config.GetVehFuel = function(Veh)
    return GetVehicleFuelLevel(Veh)-- exports["LegacyFuel"]:GetFuel(Veh)
end

Config.Vehicles = {
    {model="bati", label="MOTO", price=1000},
    {model="a80", label="SUPRA", price=1000},
    {model="69charger", label="CHARGER", price=1000},
    {model="m5e60", label="BMW", price=1000},
    {model="mustang19", label="MUSTANG", price=1000},
    {model="revolution6str2", label="REVOLUTION", price=1000},
    {model="turismo2", label="TURISMO", price=1000},

}
EYES = {}
EYES.Functions = {
    CreateBlips = function()
        for k,v in pairs(Config.Locations) do 
            local blip = AddBlipForCoord(v.coords)
            SetBlipSprite(blip, 380)
            SetBlipScale(blip, 0.5)
            SetBlipAsShortRange(blip, true)
            SetBlipColour(blip, 2)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Rent")
            EndTextCommandSetBlipName(blip)
        end
    end
}


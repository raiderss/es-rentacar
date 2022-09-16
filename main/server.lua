ESX = nil
TriggerEvent("esx:getSharedObject", function(obj) ESX = obj end)


ESX.RegisterServerCallback("isPrice", function(source, cb, money)
    local Player = ESX.GetPlayerFromId(source)
    if Player.getMoney() >= tonumber(money) then 
        Player.removeMoney(tonumber(money))
        cb(true)
    else
        cb(false)
    end
end)
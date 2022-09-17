ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
RegisterServerEvent('payPlease')
AddEventHandler('payPlease', function (price)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    xPlayer.removeAccountMoney('bank', price)
end)
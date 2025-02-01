
local chestAttempts = {}
local chestLockouts = {}
local chests = {}

function LoadChestData()
    MySQL.Async.fetchAll('SELECT * FROM zerwyx_chest', {}, function(result)
        if result then
            chests = result
        else
            chests = {}
        end
    end)
end

function SaveChestData(x, y, z, heading, code, identifier)
    MySQL.Async.execute('INSERT INTO zerwyx_chest (x, y, z, heading, code, identifier) VALUES (@x, @y, @z, @heading, @code, @identifier)', {
        ['@x'] = x,
        ['@y'] = y,
        ['@z'] = z,
        ['@heading'] = heading,
        ['@code'] = code,
        ['@identifier'] = identifier
    }, function(rowsChanged)
        if rowsChanged > 0 then
        else
        end
    end)
end
function DeleteChestData(x, y, z)
    local identifier = Config:GetChestIdentifier(x, y, z)
    MySQL.Async.execute('DELETE FROM zerwyx_chest WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(rowsChanged)
        if rowsChanged > 0 then
        else
        end
    end)
end

AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        LoadChestData()
        for _, chest in pairs(chests) do
            exports.ox_inventory:RegisterStash(chest.identifier, 'Coffre', Config.StashSlots, Config.StashMaxWeight, false)
        end
    end
end)

ESX.RegisterUsableItem('chest', function(source)
    local xPlayer = ESX.GetPlayerFromId(source)
    TriggerClientEvent('zerwyx_chest:OpenChestCreationMenu', source)
    xPlayer.removeInventoryItem('chest', 1)
end)

RegisterServerEvent('zerwyx_chest:AddNewChest')
AddEventHandler('zerwyx_chest:AddNewChest', function(x, y, z, heading, code)
    local identifier = Config:GetChestIdentifier(x, y, z)

    
    SaveChestData(x, y, z, heading, code, identifier)

    
local success, err = pcall(function()
    return exports.ox_inventory:RegisterStash(
        identifier,          
        'Coffre',             
        Config.StashSlots,        
        Config.StashMaxWeight,    
        false                
    )
end)

if success then
else
end

    
    if success then
    else
    end

    table.insert(chests, {
        ['id'] = #chests + 1,
        ['x'] = x,
        ['y'] = y,
        ['z'] = z,
        ['heading'] = heading,
        ['code'] = code,
        ['identifier'] = identifier
    })

    TriggerClientEvent('esx:showNotification', source, Config.Messages.chest_created)
    TriggerClientEvent('zerwyx_chest:SpawnOwnerChest', -1, x, y, z, heading)
end)




RegisterServerEvent('zerwyx_chest:CheckCode')
AddEventHandler('zerwyx_chest:CheckCode', function(x, y, z, result)
    local xPlayer = ESX.GetPlayerFromId(source)
    local playerIdentifier = xPlayer.identifier
    local identifier = Config:GetChestIdentifier(x, y, z)

    if chestLockouts[playerIdentifier] and chestLockouts[playerIdentifier][identifier] then
        local remainingTime = (chestLockouts[playerIdentifier][identifier] - os.time())
        if remainingTime > 0 then
            TriggerClientEvent('esx:showNotification', source, string.format(Config.Messages.lockout, remainingTime))
            return
        else
            chestLockouts[playerIdentifier][identifier] = nil
        end
    end

    local codeCorrect = false

    for _, v in ipairs(chests) do
        if (x == v.x and y == v.y and z == v.z) then
            if tostring(result) == tostring(v.code) then  
                codeCorrect = true
                TriggerClientEvent('zerwyx_chest:NotifCode', source, true, x, y, z)
                chestAttempts[playerIdentifier] = nil
                break
            end
        end    
    end

    if not codeCorrect then
        TriggerClientEvent('zerwyx_chest:NotifCode', source, false, x, y, z)
        chestAttempts[playerIdentifier] = (chestAttempts[playerIdentifier][identifier] or 0) + 1

        if chestAttempts[playerIdentifier][identifier] >= Config.MaxAttempts then
            chestLockouts[playerIdentifier][identifier] = os.time() + Config.LockoutTime
            chestAttempts[playerIdentifier][identifier] = nil
        end
    end
end)

RegisterServerEvent('zerwyx_chest:LoadChest')
AddEventHandler('zerwyx_chest:LoadChest', function()
    for _, chest in ipairs(chests) do
        exports.ox_inventory:RegisterStash(chest.identifier, 'Coffre', Config.StashSlots, Config.StashMaxWeight, false)
        TriggerClientEvent('zerwyx_chest:SpawnOwnerChest', source, chest.x, chest.y, chest.z, chest.heading)
    end
end)

RegisterServerEvent('zerwyx_chest:OpenChestInventory')
AddEventHandler('zerwyx_chest:OpenChestInventory', function(identifier)
    TriggerClientEvent('zerwyx_chest:OpenStashInventory', source, identifier)
end)


function SendNotificationToClient(source, message, icon, type)
    TriggerClientEvent('zerwyx_chest:ShowNotification', source, message, icon, type)
end


RegisterServerEvent('zerwyx_chest:RequestAllChests')
AddEventHandler('zerwyx_chest:RequestAllChests', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if IsPlayerAceAllowed(source, 'command') or xPlayer.getGroup() == 'admin' then
        local playerCoords = GetEntityCoords(GetPlayerPed(source))
        local chestsWithDistance = {}

        for _, chest in pairs(chests) do
            local chestCoords = vector3(chest.x, chest.y, chest.z)
            local distance = #(playerCoords - chestCoords)
            table.insert(chestsWithDistance, {
                identifier = chest.identifier,
                x = chest.x,
                y = chest.y,
                z = chest.z,
                code = chest.code,
                distance = distance
            })
        end
        TriggerClientEvent('zerwyx_chest:OpenChestManagerMenu', source, chestsWithDistance)
    else
        TriggerClientEvent('zerwyx_chest:showNotification', source, 'Vous n\'avez pas les permissions nécessaires pour ouvrir ce menu.', 'fas fa-exclamation-triangle', 'error')

    end
end)






ESX.RegisterServerCallback('zerwyx_chest:GetAllChests', function(source, cb)
    cb(chests)
end)

RegisterServerEvent('zerwyx_chest:ModifyChestCode')
AddEventHandler('zerwyx_chest:ModifyChestCode', function(x, y, z, newCode)
    local _source = source 
    local identifier = Config:GetChestIdentifier(x, y, z)

    if not newCode or newCode == '' then
        TriggerClientEvent('zerwyx_chest:showNotification', _source, 'Code invalide.', 'fas fa-times-circle', 'error')

        return
    end

    MySQL.Async.execute('UPDATE zerwyx_chest SET code = @newCode WHERE identifier = @identifier', {
        ['@newCode'] = newCode,
        ['@identifier'] = identifier
    }, function(rowsChanged)
        if rowsChanged > 0 then
            SendNotificationToClient(_source, "Le code du coffre a été modifié avec succès.", "fas fa-key", "success")

        else
            TriggerClientEvent('zerwyx_chest:showNotification', _source, 'Échec de la modification du code du coffre.', 'fas fa-times-circle', 'error')

        end
    end)

    for _, chest in pairs(chests) do
        if chest.identifier == identifier then
            chest.code = newCode
            break
        end
    end
end)





RegisterNetEvent('zerwyx_chest:handleAction')
AddEventHandler('zerwyx_chest:handleAction', function(data)
    local xPlayer = ESX.GetPlayerFromId(source)
    local action = data.action


    if action == 'modify_code' then
        local x = data.coords.x
        local y = data.coords.y
        local z = data.coords.z
        local newCode = data.code

        if newCode and newCode ~= '' then
            TriggerEvent('zerwyx_chest:ModifyChestCode', source, x, y, z, newCode)
        else
            TriggerClientEvent('zerwyx_chest:showNotification', source, 'Le code est invalide.', 'fas fa-times-circle', 'error')
        end

    elseif action == 'delete_chest' then
        local x = data.coords.x
        local y = data.coords.y
        local z = data.coords.z
        local identifier = data.identifier


        MySQL.Async.execute('DELETE FROM zerwyx_chest WHERE identifier = @identifier', {
            ['@identifier'] = identifier
        }, function(affectedRows)
            if affectedRows > 0 then
                TriggerClientEvent('zerwyx_chest:showNotification', source, 'Coffre supprimé avec succès.', 'fas fa-check-circle', 'success')
            else
                TriggerClientEvent('zerwyx_chest:showNotification', source, 'Erreur lors de la suppression du coffre.', 'fas fa-times-circle', 'error')
            end
        end)
    end
end)


RegisterNetEvent('zerwyx_chest:RequestCode')
AddEventHandler('zerwyx_chest:RequestCode', function(identifier)
    local _source = source
  
    local chest = GetChestByIdentifier(identifier)
    
    if chest and chest.code then
        TriggerClientEvent('zerwyx_chest:ReceiveCode', _source, chest.code) 
    else
        TriggerClientEvent('zerwyx_chest:ReceiveCode', _source, nil) 
    end
end)

function GetChestByIdentifier(identifier)
    for _, chest in pairs(chests) do
        if chest.identifier == identifier then
            return chest
        end
    end
    return nil
end





RegisterServerEvent('zerwyx_chest:DeleteChest')
AddEventHandler('zerwyx_chest:DeleteChest', function(x, y, z)
    local identifier = Config:GetChestIdentifier(x, y, z)

    if identifier == nil then
        return
    end


    MySQL.Async.execute('DELETE FROM zerwyx_chest WHERE identifier = @identifier', {
        ['@identifier'] = identifier
    }, function(affectedRows)
        if affectedRows > 0 then
            TriggerClientEvent('zerwyx_chest:RemoveChest', -1, x, y, z, identifier)
        else
            TriggerClientEvent('zerwyx_chest:showNotification', source, 'Erreur lors de la suppression du coffre.', 'fas fa-times-circle', 'error')
        end
    end)
end)



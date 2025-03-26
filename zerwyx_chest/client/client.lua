local currentChest = nil
local spawnedChests = {}

function DeleteAllChests()
    for _, chestObject in ipairs(spawnedChests) do
        if DoesEntityExist(chestObject) then
            DeleteObject(chestObject)
        end
    end
    spawnedChests = {}
end


RegisterNetEvent('zerwyx_chest:ShowNotification')
AddEventHandler('zerwyx_chest:ShowNotification', function(message, icon, type)
    SendNUIMessage({
        action = 'showNotification',
        message = message,
        icon = icon, 
        type = type 
    })
end)


AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        DeleteAllChests()
    end
end)

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        DeleteAllChests()
        TriggerServerEvent('zerwyx_chest:LoadChest')
    end
end)

RegisterNetEvent('zerwyx_chest:SpawnOwnerChest')
AddEventHandler('zerwyx_chest:SpawnOwnerChest', function(x, y, z, heading)
    local chestObject = CreateObject(GetHashKey(Config.ChestModel), x, y, z -1, true, true, false)
    PlaceObjectOnGroundProperly(chestObject)
    SetEntityHeading(chestObject, heading)
    FreezeEntityPosition(chestObject, true)
    table.insert(spawnedChests, chestObject)

    exports['ox_target']:addLocalEntity(chestObject, {
        {
            name = 'open_chest',
            label = 'Ouvrir le coffre',
            icon = 'fas fa-box-open',
            onSelect = function()
                OpenKeyboardCodePrompt(x, y, z)
            end,
            canInteract = function(entity)
                return #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(entity)) < Config.InteractionDistance
            end
        }
    })
end)

RegisterNetEvent('zerwyx_chest:OpenChestCreationMenu')
AddEventHandler('zerwyx_chest:OpenChestCreationMenu', function()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'create_chest_code', {
        title = 'Entrez un code pour le coffre'
    }, function(data, menu)
        local code = tonumber(data.value)
        if not code or code <= 0 then
            TriggerEvent('zerwyx_chest:ShowNotification', Config.Messages.invalid_code, 'fas fa-exclamation-triangle', 'warning')
            menu.close()
            return
        end
        menu.close()

        local playerPed = PlayerPedId()
        local forwardVector = GetEntityForwardVector(playerPed)
        local chestCoords = GetEntityCoords(playerPed) + (forwardVector * 1.0)

        TriggerServerEvent('zerwyx_chest:AddNewChest', chestCoords.x, chestCoords.y, chestCoords.z, GetEntityHeading(playerPed), code)
    end, function(data, menu)
        menu.close()
    end)
end)

function OpenKeyboardCodePrompt(x, y, z)
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'chest_code_menu', {
        title = 'Entrez le code du coffre',
        align = 'top-left'
    }, function(data, menu)
        local enteredCode = tonumber(data.value)

        if not enteredCode then
            TriggerEvent('zerwyx_chest:ShowNotification', Config.Messages.invalid_code, 'fas fa-exclamation-triangle', 'warning')
        else
            TriggerServerEvent('zerwyx_chest:CheckCode', x, y, z, tostring(enteredCode))
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent('zerwyx_chest:NotifCode')
AddEventHandler('zerwyx_chest:NotifCode', function(valide, x, y, z)
    if valide then 
        TriggerEvent('zerwyx_chest:ShowNotification', Config.Messages.correct_code, 'fas fa-check-circle', 'success')


        local identifier = Config:GetChestIdentifier(x, y, z)
        currentChest = {identifier = identifier}
        exports.ox_inventory:openInventory('stash', {id = identifier})
    else  
        TriggerEvent('zerwyx_chest:ShowNotification', Config.Messages.incorrect_code, 'fas fa-exclamation-triangle', 'warning')

        currentChest = nil
    end    
end)

RegisterNetEvent('zerwyx_chest:OpenStashInventory')
AddEventHandler('zerwyx_chest:OpenStashInventory', function(identifier)
    
    local success = exports.ox_inventory:openInventory('stash', {
        id = identifier,
        label = 'Coffre',
        maxWeight = Config.StashMaxWeight,
        slots = Config.StashSlots
    })
    
    if success then
    else
    end
    
    currentChest = {identifier = identifier}
end)



AddEventHandler('ox_inventory:closedInventory', function(playerId, inventoryId)
    if string.sub(inventoryId, 1, 6) == 'chest:' then
        currentChest = nil
        TriggerServerEvent('zerwyx_chest:SaveChestInventory', inventoryId)
    end
end)


RegisterCommand("chestmanager", function()
    TriggerServerEvent('zerwyx_chest:RequestAllChests')
end, false)


RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false) 
    SetNuiFocusKeepInput(false)  
    cb('ok') 
end)


RegisterNetEvent('zerwyx_chest:OpenChestManagerMenu')
AddEventHandler('zerwyx_chest:OpenChestManagerMenu', function(chests)
    if not isMenuOpen then
        isMenuOpen = true
        SetNuiFocus(true, true) 
        SendNUIMessage({
            action = 'openMainMenu',
            chests = chests
        })
        Citizen.CreateThread(function()
            while isMenuOpen do
                DisableControlAction(0, 1, true)
                DisableControlAction(0, 2, true)
                DisableControlAction(0, 142, true)
                DisableControlAction(0, 18, true) 
                DisableControlAction(0, 322, true)
                DisableControlAction(0, 106, true) 
                Wait(0)
            end
        end)
    end
end)

RegisterNUICallback("closeMenu", function(data, cb)
    isMenuOpen = false
    SetNuiFocus(false, false)  
    cb("ok") 
end)

Citizen.CreateThread(function()
    while true do
        if isMenuOpen and IsControlJustReleased(0, 322) then  
            SendNUIMessage({ action = 'closeMenu' }) 
        end
        Wait(0)
    end
end)
RegisterNetEvent('zerwyx_chest:ReceiveCode')
AddEventHandler('zerwyx_chest:ReceiveCode', function(code)
    if code then
        TriggerEvent('zerwyx_chest:ShowNotification', 'Le code actuel du coffre est : ' .. code, 'fas fa-eye', 'info')
    else
        TriggerEvent('zerwyx_chest:ShowNotification', 'Impossible d\'afficher le code, il est indisponible.', 'fas fa-exclamation-triangle', 'warning')
    end
end)



function ShowChestCode(identifier)
    TriggerServerEvent('zerwyx_chest:RequestCode', identifier)
end


RegisterNetEvent('zerwyx_chest:ConfirmDeleteChest')
AddEventHandler('zerwyx_chest:ConfirmDeleteChest', function(x, y, z)
    local identifier = Config:GetChestIdentifier(x, y, z)

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'confirm_delete', {
        title = "Voulez-vous vraiment supprimer ce coffre ?",
        align = 'top-left',
        elements = {
            {label = "Oui", value = "yes"},
            {label = "Non", value = "no"}
        }
    }, function(data, menu)
        if data.current.value == "yes" then
            TriggerServerEvent('zerwyx_chest:DeleteChest', x, y, z)
            menu.close()
        else
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end)

RegisterNUICallback('action', function(data, cb)
    if data.action == 'view_inventory' then
        TriggerServerEvent('zerwyx_chest:OpenChestInventory', data.identifier)

    elseif data.action == 'tp_to_chest' then
        local x, y, z = data.coords.x, data.coords.y, data.coords.z
        SetEntityCoords(PlayerPedId(), x, y, z + 1.0, false, false, false, true)
        TriggerEvent('zerwyx_chest:ShowNotification', "Téléporté devant le coffre.", 'fas fa-map-marker-alt', 'success')

    elseif data.action == 'modify_code' then
        OpenKeyboardCodePromptForModification(data.coords.x, data.coords.y, data.coords.z)

    elseif data.action == 'view_code' then
        TriggerServerEvent('zerwyx_chest:RequestCode', data.identifier)

        
    elseif data.action == 'delete_chest' then
        confirmDeleteChest(data.identifier, data.coords.x, data.coords.y, data.coords.z)

    elseif data.action == 'back' then
        SendNUIMessage({
            action = 'openMainMenu',
            chests = data.chests
        })
    end

    cb('ok') 
end)






function openChangeCodeMenu(identifier, x, y, z)
    SetNuiFocus(true, true) 
    
    SendNUIMessage({
        action = "openChangeCodeMenu",
        identifier = identifier,
        coords = { x = x, y = y, z = z }
    })
end

RegisterNUICallback('submitNewCode', function(data, cb)
    local identifier = data.identifier
    local newCode = data.newCode
    local x = data.coords.x
    local y = data.coords.y
    local z = data.coords.z

    TriggerServerEvent('zerwyx_chest:ModifyChestCode', x, y, z, newCode)

    SetNuiFocus(false, false)
    SendNUIMessage({ action = "closeMenu" })

    cb('ok')
end)

RegisterNUICallback('cancelChangeCode', function(data, cb)
    SetNuiFocus(false, false)  
    SendNUIMessage({ action = "closeMenu" })  
    cb('ok')
end)



function ConfirmChestDeletion(x, y, z, identifier)
    SendNUIMessage({
        action = 'confirmDeletion',
        coords = { x = x, y = y, z = z },
        identifier = identifier
    })
    
    SetNuiFocus(true, true)
end

function confirmDeleteChest(identifier, x, y, z)
    SetNuiFocus(true, true) 
    SendNUIMessage({
        action = 'confirmDeletionMenu',  
        identifier = identifier,
        coords = { x = x, y = y, z = z }
    })
end

RegisterNUICallback('confirmDelete', function(data, cb)
    if data.confirmed then
        TriggerServerEvent('zerwyx_chest:DeleteChest', data.coords.x, data.coords.y, data.coords.z)
        TriggerEvent('zerwyx_chest:ShowNotification', 'Coffre supprimé.', 'fas fa-trash-alt', 'success')
    else
        TriggerEvent('zerwyx_chest:ShowNotification', 'Suppression annulée.', 'fas fa-times', 'info')
    end

    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNetEvent('zerwyx_chest:RemoveChest')
AddEventHandler('zerwyx_chest:RemoveChest', function(x, y, z, identifier)
    for i, chestObject in ipairs(spawnedChests) do
        local chestCoords = GetEntityCoords(chestObject)
        if #(chestCoords - vector3(x, y, z)) < 1.0 then
            if DoesEntityExist(chestObject) then
                DeleteObject(chestObject)
            end
            table.remove(spawnedChests, i)  
            break
        end
    end
end)

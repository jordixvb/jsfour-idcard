local ESX = exports['es_extended']:getSharedObject()

RegisterNetEvent('jsfour-idcard:open')
AddEventHandler('jsfour-idcard:open', function(ID, targetID, type)
    local sourcePlayer = ESX.GetPlayerFromId(ID)
    local targetPlayer = ESX.GetPlayerFromId(targetID)

    if not sourcePlayer or not targetPlayer then return end

    local identifier = sourcePlayer.identifier
    local targetSource = targetPlayer.source

    -- Consulta de datos
    MySQL.Async.fetchAll('SELECT firstname, lastname, dateofbirth, sex, height FROM users WHERE identifier = ?', {identifier}, function(userData)
        
        if not userData or not userData[1] then return end

        local user = userData[1]
        local show = false

        -- Consulta de licencias
        MySQL.Async.fetchAll('SELECT type FROM user_licenses WHERE owner = ?', {identifier}, function(licenses)
            
            if type ~= nil then
                for i = 1, #licenses do
                    if type == 'driver' then
                        if licenses[i].type == 'drive' or licenses[i].type == 'drive_bike' or licenses[i].type == 'drive_truck' then
                            show = true
                            break
                        end
                    elseif type == 'weapon' then
                        if licenses[i].type == 'weapon' then
                            show = true
                            break
                        end
                    end
                end
            else
                show = true
            end

            -- Enviar el DNI o el mensaje de error
            if show then
                local array = {
                    user = {user},
                    licenses = licenses
                }
                TriggerClientEvent('jsfour-idcard:open', targetSource, array, type)
            else
                -- Usamos la función interna de ESX. Nuestro functions.lua lo convertirá en qs-interface
                sourcePlayer.showNotification("No tienes ese tipo de licencia.", "error")
            end
        end)
    end)
end)
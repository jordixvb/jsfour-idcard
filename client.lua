local ESX = ESX
local open = false
local mugshotCache = {
    image = nil,
    expires = 0
}

local function getESX()
    if ESX then return ESX end

    local ok, object = pcall(function()
        return exports['es_extended']:getSharedObject()
    end)

    if ok and object then
        ESX = object
    end

    return ESX
end

local function notify(message)
    local ESXObject = getESX()

    if ESXObject and ESXObject.ShowNotification then
        ESXObject.ShowNotification(message)
        return
    end

    BeginTextCommandThefeedPost('STRING')
    AddTextComponentSubstringPlayerName(message)
    EndTextCommandThefeedPostTicker(false, true)
end

local function normalizeImageData(image)
    if type(image) ~= 'string' or image == '' then
        return nil
    end

    if image:find('data:image', 1, true) then
        return image
    end

    return ('data:image/png;base64,%s'):format(image)
end

local function getMugShot()
    if not Config.MugShot or not Config.MugShot.enabled then
        return nil
    end

    local resource = Config.MugShot.resource or 'MugShotBase64'

    if GetResourceState(resource) ~= 'started' then
        return nil
    end

    local now = GetGameTimer()
    local cacheConfig = Config.MugShot.cache or {}

    if cacheConfig.enabled and mugshotCache.image and mugshotCache.expires > now then
        return mugshotCache.image
    end

    local ok, result = pcall(function()
        return exports[resource]:GetMugShotBase64(PlayerPedId(), Config.MugShot.transparent == true)
    end)

    if not ok then
        return nil
    end

    result = normalizeImageData(result)

    if result and cacheConfig.enabled then
        mugshotCache.image = result
        mugshotCache.expires = now + (cacheConfig.duration or 300000)
    end

    return result
end

local function getClosestPlayer(maxDistance)
    local players = GetActivePlayers()
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local closestPlayer = -1
    local closestDistance = maxDistance or Config.ShowDistance or 3.0

    for i = 1, #players do
        local player = players[i]

        if player ~= PlayerId() then
            local targetPed = GetPlayerPed(player)
            local targetCoords = GetEntityCoords(targetPed)
            local distance = #(playerCoords - targetCoords)

            if distance <= closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

local function openCard(cardType, showToClosest)
    cardType = cardType or Config.DefaultType or 'id'

    if not Config.CardTypes[cardType] then
        notify(Config.Messages.invalid_type)
        return
    end

    local targetServerId = GetPlayerServerId(PlayerId())

    if showToClosest then
        local closestPlayer = getClosestPlayer(Config.ShowDistance or 3.0)

        if closestPlayer == -1 then
            notify(Config.Messages.no_player)
            return
        end

        targetServerId = GetPlayerServerId(closestPlayer)
    end

    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), targetServerId, cardType == 'id' and nil or cardType)
end

RegisterNetEvent('jsfour-idcard:captureMugShot', function(requestId)
    TriggerServerEvent('jsfour-idcard:receiveMugShot', requestId, getMugShot())
end)

-- Open ID card
RegisterNetEvent('jsfour-idcard:open', function(data, cardType)
    open = true
    SendNUIMessage({
        action = 'open',
        array = data,
        type = cardType
    })
end)

if Config.EnableCommand then
    RegisterCommand(Config.Command or 'idcard', function(_, args)
        local cardType = Config.DefaultType or 'id'
        local showToClosest = false

        if args[1] then
            local first = tostring(args[1]):lower()

            if first == 'show' or first == 'mostrar' then
                showToClosest = true
            elseif Config.CardTypes[first] then
                cardType = first
            else
                notify(Config.Messages.invalid_type)
                return
            end
        end

        if args[2] then
            local second = tostring(args[2]):lower()

            if second == 'show' or second == 'mostrar' then
                showToClosest = true
            end
        end

        openCard(cardType, showToClosest)
    end, false)
end

-- Key events
CreateThread(function()
    while true do
        if open then
            Wait(0)

            for i = 1, #Config.CloseControls do
                if IsControlJustReleased(0, Config.CloseControls[i]) then
                    SendNUIMessage({ action = 'close' })
                    open = false
                    break
                end
            end
        else
            Wait(500)
        end
    end
end)

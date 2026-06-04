local ESX = ESX
local pendingMugshots = {}
local cooldowns = {}

local function debugPrint(...)
    if Config.Debug then
        print('[jsfour-idcard]', ...)
    end
end

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

local function notify(playerId, message)
    TriggerClientEvent('esx:showNotification', playerId, message)
end

local function sqlIdentifier(value)
    assert(type(value) == 'string' and value:match('^[%w_]+$'), ('Invalid SQL identifier: %s'):format(tostring(value)))
    return ('`%s`'):format(value)
end

local function buildUserQuery()
    local db = Config.Database.users

    return ('SELECT %s AS firstname, %s AS lastname, %s AS dateofbirth, %s AS sex, %s AS height FROM %s WHERE %s = ? LIMIT 1'):format(
        sqlIdentifier(db.firstname),
        sqlIdentifier(db.lastname),
        sqlIdentifier(db.dateofbirth),
        sqlIdentifier(db.sex),
        sqlIdentifier(db.height),
        sqlIdentifier(db.table),
        sqlIdentifier(db.identifier)
    )
end

local function buildLicensesQuery()
    local db = Config.Database.licenses

    return ('SELECT %s AS type FROM %s WHERE %s = ?'):format(
        sqlIdentifier(db.type),
        sqlIdentifier(db.table),
        sqlIdentifier(db.owner)
    )
end

local function getPlayerIdentifier(xPlayer)
    if not xPlayer then return nil end

    if xPlayer.getIdentifier then
        return xPlayer.getIdentifier()
    end

    return xPlayer.identifier
end

local function normalizeCardType(cardType)
    if cardType == nil or cardType == '' then
        return Config.DefaultType or 'id'
    end

    cardType = tostring(cardType):lower()

    if cardType == 'identity' or cardType == 'card' then
        return 'id'
    end

    return cardType
end

local function listToSet(list)
    local set = {}

    if type(list) ~= 'table' then
        return set
    end

    for i = 1, #list do
        set[list[i]] = true
    end

    return set
end

local function hasRequiredLicense(licenses, cardConfig)
    local required = cardConfig.requiredLicenses

    if required == false or required == nil or #required == 0 then
        return true
    end

    local requiredSet = listToSet(required)

    for i = 1, #licenses do
        if requiredSet[licenses[i].type] then
            return true
        end
    end

    return false
end

local function buildVisibleLicenses(licenses, cardConfig)
    if not cardConfig.showLicenses then
        return {}
    end

    local visibleSet = listToSet(cardConfig.visibleLicenses)
    local result = {}

    for i = 1, #licenses do
        local licenseType = licenses[i].type

        if visibleSet[licenseType] then
            result[#result + 1] = {
                type = licenseType,
                label = (Config.Licenses[licenseType] and Config.Licenses[licenseType].label) or licenseType
            }
        end
    end

    return result
end

local function isTargetAllowed(sourcePlayer, targetPlayer)
    if sourcePlayer == targetPlayer then
        return true
    end

    local sourcePed = GetPlayerPed(sourcePlayer)
    local targetPed = GetPlayerPed(targetPlayer)

    if sourcePed == 0 or targetPed == 0 then
        return false
    end

    local sourceCoords = GetEntityCoords(sourcePed)
    local targetCoords = GetEntityCoords(targetPed)
    local distance = #(sourceCoords - targetCoords)

    return distance <= (Config.ShowDistance or 3.0)
end

local function shouldUseMugShot(cardConfig)
    return Config.MugShot
        and Config.MugShot.enabled
        and cardConfig.showPhoto
        and cardConfig.useMugShot
end

local function finishOpen(requestId, mugshot)
    local request = pendingMugshots[requestId]
    if not request then return end

    pendingMugshots[requestId] = nil
    request.payload.mugshot = mugshot

    TriggerClientEvent('jsfour-idcard:open', request.target, request.payload, request.cardType)
end

RegisterNetEvent('jsfour-idcard:receiveMugShot', function(requestId, mugshot)
    local src = source
    local request = pendingMugshots[requestId]

    if not request or request.source ~= src then
        return
    end

    if type(mugshot) ~= 'string' or mugshot == '' then
        mugshot = nil
    end

    finishOpen(requestId, mugshot)
end)

-- Open ID card. Legacy signature preserved:
-- TriggerServerEvent('jsfour-idcard:open', ownerId, targetId, type)
-- Security note: ownerId is ignored. The real owner is always source.
RegisterNetEvent('jsfour-idcard:open', function(_legacyOwnerId, targetID, cardType)
    local src = source
    local now = os.time()

    if cooldowns[src] and now - cooldowns[src] < (Config.RequestCooldown or 0) then
        notify(src, Config.Messages.cooldown)
        return
    end

    cooldowns[src] = now

    local ESXObject = getESX()
    if not ESXObject then
        print('[jsfour-idcard] ERROR: es_extended shared object not found.')
        return
    end

    cardType = normalizeCardType(cardType)
    local cardConfig = Config.CardTypes[cardType]

    if not cardConfig then
        notify(src, Config.Messages.invalid_type)
        return
    end

    local target = tonumber(targetID) or src
    local xPlayer = ESXObject.GetPlayerFromId(src)
    local xTarget = ESXObject.GetPlayerFromId(target)

    if not xPlayer then
        return
    end

    if not xTarget then
        notify(src, Config.Messages.no_player)
        return
    end

    if not isTargetAllowed(src, target) then
        notify(src, Config.Messages.too_far)
        return
    end

    local identifier = getPlayerIdentifier(xPlayer)
    if not identifier then
        debugPrint(('No identifier for source %s'):format(src))
        return
    end

    local userRows = MySQL.query.await(buildUserQuery(), { identifier })
    local user = userRows and userRows[1]

    if not user then
        notify(src, Config.Messages.no_data)
        return
    end

    local licenses = MySQL.query.await(buildLicensesQuery(), { identifier }) or {}

    if not hasRequiredLicense(licenses, cardConfig) then
        notify(src, Config.Messages.no_license)
        return
    end

    local payload = {
        user = user,
        licenses = buildVisibleLicenses(licenses, cardConfig),
        card = {
            type = cardType,
            label = cardConfig.label,
            background = cardConfig.background,
            showPhoto = cardConfig.showPhoto,
            showHeight = cardConfig.showHeight,
            showLicenses = cardConfig.showLicenses
        },
        sexLabels = Config.SexLabels
    }

    if shouldUseMugShot(cardConfig) then
        local requestId = ('%s:%s:%s'):format(src, GetGameTimer(), math.random(1000, 9999))

        pendingMugshots[requestId] = {
            source = src,
            target = target,
            cardType = cardType,
            payload = payload
        }

        TriggerClientEvent('jsfour-idcard:captureMugShot', src, requestId, cardType)

        SetTimeout(Config.MugShot.timeout or 1500, function()
            if pendingMugshots[requestId] then
                finishOpen(requestId, nil)
            end
        end)
    else
        TriggerClientEvent('jsfour-idcard:open', target, payload, cardType)
    end
end)

AddEventHandler('playerDropped', function()
    local src = source
    cooldowns[src] = nil

    for requestId, request in pairs(pendingMugshots) do
        if request.source == src or request.target == src then
            pendingMugshots[requestId] = nil
        end
    end
end)

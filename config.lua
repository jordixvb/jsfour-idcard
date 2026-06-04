Config = {}

-- Language / basic behavior
Config.Locale = 'es'
Config.Debug = false
Config.ShowDistance = 3.0
Config.RequestCooldown = 2 -- seconds per player to prevent spam
Config.DefaultType = 'id'

-- Optional command. Existing event usage still works exactly as before.
Config.EnableCommand = true
Config.Command = 'idcard'
-- Usage:
-- /idcard              -> view your ID
-- /idcard id           -> view your ID
-- /idcard driver       -> view your driver license
-- /idcard weapon       -> view your weapon license
-- /idcard id show      -> show ID to closest player
-- /idcard driver show  -> show driver license to closest player
-- /idcard weapon show  -> show weapon license to closest player

-- Controls used to close the card: ESC / BACKSPACE by default.
Config.CloseControls = { 322, 177 }

-- Database columns. Only change these if your ESX tables use different names.
Config.Database = {
    users = {
        table = 'users',
        identifier = 'identifier',
        firstname = 'firstname',
        lastname = 'lastname',
        dateofbirth = 'dateofbirth',
        sex = 'sex',
        height = 'height'
    },
    licenses = {
        table = 'user_licenses',
        owner = 'owner',
        type = 'type'
    }
}

-- Optional real mugshot integration.
-- This is NOT required. If MugShotBase64 is not installed/started, the script falls back to default images.
Config.MugShot = {
    enabled = true,
    resource = 'MugShotBase64',
    transparent = true,
    timeout = 1500, -- ms before fallback if the client does not answer
    cache = {
        enabled = true,
        duration = 300000 -- ms
    }
}

-- Sex labels shown in the NUI.
Config.SexLabels = {
    m = 'Masculino',
    f = 'Femenino',
    male = 'Masculino',
    female = 'Femenino',
    ['0'] = 'Masculino',
    ['1'] = 'Femenino'
}

-- All license labels that can appear on cards.
-- Add/remove/change anything here without editing server.lua or html/assets/js/init.js.
Config.Licenses = {
    dmv = { label = 'Examen Teórico' },
    drive = { label = 'Permiso de Coche' },
    drive_bike = { label = 'Permiso de Moto' },
    drive_truck = { label = 'Permiso de Camión' },
    weapon = { label = 'Weapon License' },
    weapon_handgun = { label = 'Licencia de Armas Cortas' },
    weapon_long = { label = 'Licencia de Armas Largas' },
    weapon_melee = { label = 'Licencia de Armas Cuerpo a Cuerpo' }
}

-- Card behavior.
-- requiredLicenses:
--   false or {} = no license required
--   {'drive'} = the player needs at least one listed license to open that card type
-- visibleLicenses:
--   licenses shown on the card when the player owns them
Config.CardTypes = {
    id = {
        label = 'Documento de Identidad',
        background = 'assets/images/idcard.png',
        showPhoto = true,
        useMugShot = true,
        showHeight = true,
        showLicenses = false,
        requiredLicenses = false,
        visibleLicenses = {}
    },

    driver = {
        label = 'Permiso de Conducir',
        background = 'assets/images/license.png',
        showPhoto = true,
        useMugShot = true,
        showHeight = true,
        showLicenses = true,
        requiredLicenses = { 'drive', 'drive_bike', 'drive_truck' },
        visibleLicenses = { 'dmv', 'drive', 'drive_bike', 'drive_truck' }
    },

    weapon = {
        label = 'Licencia de Armas',
        background = 'assets/images/firearm.png',
        showPhoto = false,
        useMugShot = false,
        showHeight = false,
        showLicenses = true,
        requiredLicenses = { 'weapon', 'weapon_handgun', 'weapon_long', 'weapon_melee' },
        visibleLicenses = { 'weapon', 'weapon_handgun', 'weapon_long', 'weapon_melee' }
    }
}

Config.Messages = {
    no_player = 'No hay jugadores cerca.',
    too_far = 'Ese jugador está demasiado lejos.',
    invalid_type = 'Tipo de documento inválido.',
    no_license = 'No tienes la licencia requerida para mostrar este documento.',
    no_data = 'No se encontraron datos del personaje.',
    cooldown = 'Espera un momento antes de volver a usar el documento.'
}

local open = false

-- Función optimizada para cerrar el DNI
local function CloseIDCard()
    SendNUIMessage({
        action = "close"
    })
    open = false
end

-- Evento para abrir el DNI
RegisterNetEvent('jsfour-idcard:open', function(data, type)
    open = true
    SendNUIMessage({
        action = "open",
        array  = data,
        type   = type
    })

    -- Bucle BAJO DEMANDA: Solo se ejecuta si el DNI está abierto
    CreateThread(function()
        while open do
            Wait(0)
            -- 322 = ESC | 177 = BACKSPACE / CLICK DERECHO
            if IsControlJustReleased(0, 322) or IsControlJustReleased(0, 177) then
                CloseIDCard()
            end
        end
    end)
end)
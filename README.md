# jsfour-idcard — maintained fork

Fork mantenido de **jsfour-idcard** para servidores ESX Legacy actuales, con `oxmysql`, validaciones de seguridad, licencias configurables y soporte opcional para `MugShotBase64`.

> Recurso original: JSFOUR / Jonas Svensson.  
> Este fork conserva el nombre, eventos y licencia original del recurso.

## Licencia

Lee `license.txt` antes de usar, redistribuir o vender este recurso.

La licencia original indica expresamente que **no está permitido vender ni re-subir el script**. Si quieres publicarlo en una tienda, marketplace, Tebex, GitHub público o similar, necesitas permiso del autor original.

## Qué se ha mejorado

- Actualizado a `fx_version 'cerulean'` y `lua54 'yes'`.
- Migrado de `mysql-async` a `oxmysql`.
- Compatible con ESX Legacy mediante `@es_extended/imports.lua` y fallback por export.
- Evento clásico preservado: `jsfour-idcard:open`.
- Seguridad reforzada:
  - el servidor ignora el ID de propietario enviado por el cliente;
  - el dueño real del documento siempre es `source`;
  - validación server-side de distancia al mostrar a otro jugador;
  - whitelist de tipos de documento;
  - cooldown anti-spam;
  - consultas SQL con parámetros `?`;
  - columnas/tablas de SQL validadas desde config.
- Labels de licencias 100% configurables desde `config.lua`.
- Soporte opcional para foto real con `MugShotBase64`.
- Fallback automático a `male.png` / `female.png` si no hay mugshot.
- Comando opcional `/idcard` incluido.
- UI actualizada para mostrar labels largos de licencias.

## Requisitos

- `es_extended` actualizado.
- `oxmysql`.
- `esx_license` o una tabla compatible `user_licenses`.
- Opcional: `MugShotBase64`.

## Instalación

1. Coloca la carpeta como:

```txt
resources/[esx]/jsfour-idcard
```

2. Asegúrate de iniciar dependencias antes del recurso:

```cfg
ensure oxmysql
ensure es_extended
ensure esx_license
# Opcional, solo si quieres foto real:
ensure MugShotBase64
ensure jsfour-idcard
```

3. Revisa `config.lua` y adapta labels, tipos de licencia, distancia, comandos o tablas SQL si tu servidor usa nombres distintos.

## Uso clásico

El evento original sigue funcionando:

```lua
-- Ver tu DNI
TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()))

-- Mostrar DNI al jugador más cercano
local player, distance = ESX.Game.GetClosestPlayer()
if distance ~= -1 and distance <= 3.0 then
    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player))
else
    ESX.ShowNotification('No hay jugadores cerca')
end

-- Ver permiso de conducir
TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'driver')

-- Mostrar permiso de conducir
local player, distance = ESX.Game.GetClosestPlayer()
if distance ~= -1 and distance <= 3.0 then
    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'driver')
else
    ESX.ShowNotification('No hay jugadores cerca')
end

-- Ver licencia de armas
TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(PlayerId()), 'weapon')

-- Mostrar licencia de armas
local player, distance = ESX.Game.GetClosestPlayer()
if distance ~= -1 and distance <= 3.0 then
    TriggerServerEvent('jsfour-idcard:open', GetPlayerServerId(PlayerId()), GetPlayerServerId(player), 'weapon')
else
    ESX.ShowNotification('No hay jugadores cerca')
end
```

## Comando incluido

El comando se puede activar/desactivar en `config.lua`.

```txt
/idcard
/idcard id
/idcard driver
/idcard weapon
/idcard id show
/idcard driver show
/idcard weapon show
```

También acepta `mostrar`:

```txt
/idcard driver mostrar
```

## Configurar labels de licencias

Tus licencias ya vienen añadidas en `config.lua`:

```lua
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
```

Para decidir qué licencias aparecen en cada documento, edita `Config.CardTypes`:

```lua
Config.CardTypes.driver.visibleLicenses = {
    'dmv',
    'drive',
    'drive_bike',
    'drive_truck'
}
```

Para decidir qué licencias son necesarias para abrir un tipo de documento:

```lua
Config.CardTypes.driver.requiredLicenses = {
    'drive',
    'drive_bike',
    'drive_truck'
}
```

Con esa configuración, `dmv` se muestra en el carnet de conducir si el jugador la tiene, pero no sirve por sí sola para abrir el permiso de conducir. Si quieres que el examen teórico también permita abrir el documento, añade `dmv` a `requiredLicenses`.

## MugShotBase64 opcional

Este fork puede usar `MugShotBase64` para enseñar la cara real del jugador en vez de las imágenes por defecto.

Recurso opcional:

```cfg
ensure MugShotBase64
ensure jsfour-idcard
```

Config:

```lua
Config.MugShot = {
    enabled = true,
    resource = 'MugShotBase64',
    transparent = true,
    timeout = 1500,
    cache = {
        enabled = true,
        duration = 300000
    }
}
```

Funcionamiento:

- Si `MugShotBase64` está iniciado, el cliente genera una imagen base64 del ped del jugador.
- El servidor solo acepta esa imagen desde el propio dueño del documento.
- Si el recurso no existe, no está iniciado o falla, se usa `male.png` / `female.png`.
- La foto se cachea en cliente para evitar conversiones repetidas.

## Base de datos

Por defecto usa tablas estándar ESX:

```sql
users(identifier, firstname, lastname, dateofbirth, sex, height)
user_licenses(owner, type)
```

Ejemplo de inserción de tus licencias en `licenses`, si tu `esx_license` las necesita registradas:

```sql
INSERT INTO licenses (`type`, `label`) VALUES
('dmv', 'Examen Teórico'),
('drive', 'Permiso de Coche'),
('drive_bike', 'Permiso de Moto'),
('drive_truck', 'Permiso de Camión'),
('weapon', 'Weapon License'),
('weapon_handgun', 'Licencia de Armas Cortas'),
('weapon_long', 'Licencia de Armas Largas'),
('weapon_melee', 'Licencia de Armas Cuerpo a Cuerpo')
ON DUPLICATE KEY UPDATE label = VALUES(label);
```

Si tu base de datos usa otros nombres de columnas, cambia:

```lua
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
```

## Notas de seguridad

Aunque el evento mantiene esta forma:

```lua
TriggerServerEvent('jsfour-idcard:open', ownerId, targetId, type)
```

El servidor **no confía en `ownerId`**. Esto evita que un jugador pueda pedir el DNI/licencias de otro jugador falseando IDs desde el cliente.

El único dato que se enseña es el del jugador que ejecuta el evento (`source`).

## Créditos

- Recurso original: JSFOUR / Jonas Svensson.
- Fork mantenido para ESX Legacy + oxmysql.
- Integración opcional de mugshot mediante `MugShotBase64`.

## PSD original

PSD file original: https://www.dropbox.com/sh/ho6xq5cmk6sxz6x/AAB3aPJOylL7EWrU6BFb45-0a?dl=0

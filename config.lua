Config = {}

Config.Framework = 'esx' -- 'esx' o 'qb'

-- MySQL: 'oxmysql' o 'mysql-async'
Config.MySQL = 'oxmysql'
Config.InteractKey = 38 -- E
Config.InteractDistance = 3.0
Config.TestDriveTime = 60 -- segundos
Config.TestDriveRadius = 300.0 -- metros
Config.SpawnAfterBuy = true -- true = spawnea vehiculo, false = directo al garaje
Config.PayFrom = 'bank' -- 'bank' o 'cash'
Config.DealerJob = 'cardealer'

-- Notificaciones: 'dei' (dei_notifys auto-detect), 'esx', 'qb', 'native'
Config.Notify = 'dei'
Config.Commission = 10 -- porcentaje de comision para empleados

-- Discord webhook para logs (dejar vacio para desactivar)
Config.DiscordWebhook = ''
Config.EnableTestDrive = true
Config.UseMarker = true
Config.MarkerType = 20
Config.MarkerScale = vector3(0.8, 0.8, 0.8)
Config.MarkerColor = { r = 59, g = 130, b = 246, a = 120 }

Config.Shops = {
    ['pdm'] = {
        label = 'Premium Deluxe Motorsport',
        coords = vector3(-56.0, -1097.0, 26.4),
        spawn = vector4(-56.0, -1116.0, 26.4, 70.0),
        testDrive = vector4(-48.0, -1110.0, 26.4, 70.0),
        blip = true,
        blipSprite = 326,
        blipColor = 3,
        blipScale = 0.8,
        categories = {'sedan', 'deportivo', 'super', 'suv', 'compacto', 'clasico'},
    },
    ['motos'] = {
        label = 'Tienda de Motos',
        coords = vector3(280.0, -1160.0, 29.3),
        spawn = vector4(285.0, -1155.0, 29.3, 0.0),
        testDrive = vector4(285.0, -1155.0, 29.3, 0.0),
        blip = true,
        blipSprite = 226,
        blipColor = 1,
        blipScale = 0.8,
        categories = {'moto'},
    },
}

Config.Categories = {
    { value = 'all', label = 'Todos' },
    { value = 'sedan', label = 'Sedanes' },
    { value = 'deportivo', label = 'Deportivos' },
    { value = 'super', label = 'Super' },
    { value = 'suv', label = 'SUV' },
    { value = 'compacto', label = 'Compactos' },
    { value = 'moto', label = 'Motos' },
    { value = 'offroad', label = 'Offroad' },
    { value = 'clasico', label = 'Clasicos' },
}

Config.Vehicles = {
    -- Sedanes
    { model = 'sultan', label = 'Sultan', price = 25000, category = 'sedan', class = 'B',
      stats = { speed = 70, acceleration = 65, braking = 60, handling = 72 } },
    { model = 'schafter2', label = 'Schafter V12', price = 45000, category = 'sedan', class = 'A',
      stats = { speed = 78, acceleration = 72, braking = 68, handling = 74 } },
    { model = 'tailgater', label = 'Tailgater', price = 35000, category = 'sedan', class = 'B',
      stats = { speed = 72, acceleration = 68, braking = 65, handling = 70 } },
    -- Deportivos
    { model = 'elegy2', label = 'Elegy RH8', price = 95000, category = 'deportivo', class = 'A',
      stats = { speed = 82, acceleration = 80, braking = 75, handling = 85 } },
    { model = 'jester', label = 'Jester', price = 120000, category = 'deportivo', class = 'A',
      stats = { speed = 85, acceleration = 82, braking = 78, handling = 80 } },
    { model = 'comet2', label = 'Comet', price = 110000, category = 'deportivo', class = 'A',
      stats = { speed = 83, acceleration = 78, braking = 80, handling = 82 } },
    -- Super
    { model = 'adder', label = 'Adder', price = 1000000, category = 'super', class = 'S',
      stats = { speed = 95, acceleration = 88, braking = 82, handling = 78 } },
    { model = 'zentorno', label = 'Zentorno', price = 750000, category = 'super', class = 'S',
      stats = { speed = 92, acceleration = 90, braking = 80, handling = 82 } },
    { model = 't20', label = 'T20', price = 1200000, category = 'super', class = 'S',
      stats = { speed = 96, acceleration = 92, braking = 85, handling = 80 } },
    -- SUV
    { model = 'baller', label = 'Baller', price = 60000, category = 'suv', class = 'B',
      stats = { speed = 68, acceleration = 60, braking = 55, handling = 62 } },
    { model = 'granger', label = 'Granger', price = 45000, category = 'suv', class = 'C',
      stats = { speed = 60, acceleration = 55, braking = 50, handling = 58 } },
    -- Motos
    { model = 'bati', label = 'Bati 801', price = 30000, category = 'moto', class = 'A',
      stats = { speed = 88, acceleration = 90, braking = 70, handling = 75 } },
    { model = 'hakuchou', label = 'Hakuchou', price = 55000, category = 'moto', class = 'A',
      stats = { speed = 90, acceleration = 85, braking = 65, handling = 70 } },
    -- Compactos
    { model = 'blista', label = 'Blista', price = 15000, category = 'compacto', class = 'C',
      stats = { speed = 55, acceleration = 58, braking = 60, handling = 65 } },
    -- Offroad
    { model = 'bifta', label = 'Bifta', price = 22000, category = 'offroad', class = 'C',
      stats = { speed = 58, acceleration = 60, braking = 50, handling = 68 } },
    -- Clasicos
    { model = 'tornado', label = 'Tornado', price = 28000, category = 'clasico', class = 'C',
      stats = { speed = 50, acceleration = 48, braking = 52, handling = 55 } },
}

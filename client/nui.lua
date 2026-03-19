local isOpen = false
local currentShop = nil
local isTestDriving = false
local testDriveVehicle = nil
local testDriveTimer = nil
sellingToPlayer = nil -- target server id for employee sales (global, set by main.lua /vender command)

function OpenShopUI(shopId)
    if isOpen or isTestDriving then return end
    isOpen = true
    currentShop = shopId

    local shop = Config.Shops[shopId]
    if not shop then return end

    -- Filter vehicles for this shop's categories
    local shopVehicles = {}
    for _, veh in ipairs(Config.Vehicles) do
        for _, cat in ipairs(shop.categories) do
            if veh.category == cat then
                table.insert(shopVehicles, veh)
                break
            end
        end
    end

    -- Load theme from KVP (Dei ecosystem standard)
    local theme = 'dark'
    local lightMode = false
    local raw = GetResourceKvpString('dei_hud_prefs')
    if raw and raw ~= '' then
        local prefs = json.decode(raw)
        if prefs then
            theme = prefs.theme or 'dark'
            lightMode = prefs.lightMode or false
        end
    end

    -- Check if player is a dealer
    local isDealer = HasJob(Config.DealerJob)

    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'openShop',
        shopName = shop.label,
        vehicles = shopVehicles,
        categories = Config.Categories,
        shopCategories = shop.categories,
        theme = theme,
        lightMode = lightMode,
        isDealer = isDealer,
        sellingTo = sellingToPlayer,
        enableTestDrive = Config.EnableTestDrive,
    })
end

function CloseShopUI()
    if not isOpen then return end
    isOpen = false
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'closeShop' })
    currentShop = nil
    sellingToPlayer = nil
end

function IsShopOpen()
    return isOpen
end

function GetCurrentShop()
    return currentShop
end

-- ===== NUI Callbacks =====

RegisterNUICallback('closeShop', function(_, cb)
    CloseShopUI()
    cb('ok')
end)

RegisterNUICallback('selectVehicle', function(data, cb)
    -- Could be used for camera preview later
    cb('ok')
end)

RegisterNUICallback('buyVehicle', function(data, cb)
    if not currentShop then cb('error') return end
    local model = data.model
    if not model then cb('error') return end

    -- If selling to player (employee mode)
    if sellingToPlayer then
        TriggerServerEvent('dei_vehicleshop:sellToPlayer', currentShop, model, sellingToPlayer)
    else
        TriggerServerEvent('dei_vehicleshop:buyVehicle', currentShop, model)
    end
    cb('ok')
end)

RegisterNUICallback('testDrive', function(data, cb)
    if not currentShop or not Config.EnableTestDrive then cb('error') return end
    if isTestDriving then
        Notify('Ya estas en un test drive', 'error')
        cb('error')
        return
    end

    local model = data.model
    if not model then cb('error') return end

    -- Find vehicle in config
    local vehicleData = nil
    for _, veh in ipairs(Config.Vehicles) do
        if veh.model == model then
            vehicleData = veh
            break
        end
    end
    if not vehicleData then cb('error') return end

    -- Save shop before closing UI
    local shopId = currentShop

    -- Close shop UI first
    CloseShopUI()

    -- Start test drive (use saved shopId)
    StartTestDriveFromShop(shopId, vehicleData)
    cb('ok')
end)

RegisterNUICallback('confirmPurchase', function(data, cb)
    if not currentShop then cb('error') return end
    local model = data.model
    if not model then cb('error') return end

    -- Use dei_input for confirm if available
    if GetResourceState('dei_input') == 'started' then
        local vehicleData = nil
        for _, veh in ipairs(Config.Vehicles) do
            if veh.model == model then
                vehicleData = veh
                break
            end
        end
        if not vehicleData then cb('error') return end

        local price = FormatPrice(vehicleData.price)
        exports['dei_input']:Confirm(
            'Confirmar Compra',
            '¿Comprar ' .. vehicleData.label .. ' por $' .. price .. '?',
            function(confirmed)
                if confirmed then
                    if sellingToPlayer then
                        TriggerServerEvent('dei_vehicleshop:sellToPlayer', currentShop, model, sellingToPlayer)
                    else
                        TriggerServerEvent('dei_vehicleshop:buyVehicle', currentShop, model)
                    end
                end
            end
        )
    else
        -- Fallback: use NUI confirm
        SendNUIMessage({
            action = 'showConfirm',
            model = model,
        })
    end
    cb('ok')
end)

-- ===== Test Drive =====

function StartTestDriveFromShop(shopId, vehicleData)
    local shop = Config.Shops[shopId or '']
    if not shop then return end

    local spawn = shop.testDrive
    local modelHash = joaat(vehicleData.model)

    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) do
        Wait(10)
        timeout = timeout + 10
        if timeout > 5000 then
            Notify('Error: No se pudo cargar el modelo', 'error')
            return
        end
    end

    local vehicle = CreateVehicle(modelHash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
    while not DoesEntityExist(vehicle) do Wait(10) end

    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleOnGroundProperly(vehicle)
    SetVehicleNumberPlateText(vehicle, 'TESTDRV')
    TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
    SetModelAsNoLongerNeeded(modelHash)

    isTestDriving = true
    testDriveVehicle = vehicle
    local shopCoords = shop.coords

    -- Show timer via NUI
    SendNUIMessage({
        action = 'startTestDrive',
        time = Config.TestDriveTime,
        vehicleName = vehicleData.label,
    })

    Notify('Test drive iniciado: ' .. vehicleData.label .. ' (' .. Config.TestDriveTime .. 's)', 'info')

    -- Test drive timer thread
    CreateThread(function()
        local timeLeft = Config.TestDriveTime
        while timeLeft > 0 and isTestDriving do
            Wait(1000)
            timeLeft = timeLeft - 1

            -- Update NUI timer
            SendNUIMessage({
                action = 'updateTestDriveTimer',
                time = timeLeft,
            })

            -- Check distance from shop
            local playerPos = GetEntityCoords(PlayerPedId())
            local dist = #(playerPos - shopCoords)
            if dist > Config.TestDriveRadius then
                Notify('¡Te alejaste demasiado! Test drive terminado.', 'error')
                break
            end
        end

        EndTestDrive()
    end)
end

function EndTestDrive()
    if not isTestDriving then return end
    isTestDriving = false

    if testDriveVehicle and DoesEntityExist(testDriveVehicle) then
        local ped = PlayerPedId()
        if GetVehiclePedIsIn(ped, false) == testDriveVehicle then
            TaskLeaveVehicle(ped, testDriveVehicle, 0)
            Wait(1500)
        end
        DeleteEntity(testDriveVehicle)
    end

    testDriveVehicle = nil

    SendNUIMessage({ action = 'endTestDrive' })
    Notify('Test drive finalizado', 'info')
end

-- ===== Helpers =====

function FormatPrice(price)
    local str = tostring(price)
    local formatted = str:reverse():gsub('(%d%d%d)', '%1.'):reverse()
    if formatted:sub(1, 1) == '.' then formatted = formatted:sub(2) end
    return formatted
end

-- ===== Export: OpenShop =====
function OpenShop(shopId)
    if not Config.Shops[shopId] then return end
    OpenShopUI(shopId)
end
exports('OpenShop', OpenShop)

-- ===== Export: GetVehiclePrice =====
function GetVehiclePrice(model)
    for _, veh in ipairs(Config.Vehicles) do
        if veh.model == model then
            return veh.price
        end
    end
    return 0
end
exports('GetVehiclePrice', GetVehiclePrice)

-- Theme sync (Dei ecosystem standard) - read-only, fire event instead of writing KVP
RegisterNUICallback('saveTheme', function(data, cb)
    local theme = data.theme or 'dark'
    local lightMode = data.lightMode or false
    TriggerEvent('dei:themeChanged', theme, lightMode)
    cb('ok')
end)

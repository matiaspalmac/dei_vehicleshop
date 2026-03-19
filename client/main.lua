local nearShop = nil

-- ===== Blips =====
CreateThread(function()
    for id, shop in pairs(Config.Shops) do
        if shop.blip then
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
            SetBlipSprite(blip, shop.blipSprite or 326)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, shop.blipScale or 0.8)
            SetBlipColour(blip, shop.blipColor or 3)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentSubstringPlayerName(shop.label)
            EndTextCommandSetBlipName(blip)
        end
    end
end)

-- ===== Markers & Interaction =====
CreateThread(function()
    while true do
        local sleep = 1000
        local ped = PlayerPedId()
        local pos = GetEntityCoords(ped)
        nearShop = nil

        for id, shop in pairs(Config.Shops) do
            local dist = #(pos - shop.coords)
            if dist < 20.0 then
                sleep = 0
                if Config.UseMarker then
                    DrawMarker(
                        Config.MarkerType, shop.coords.x, shop.coords.y, shop.coords.z - 1.0,
                        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
                        Config.MarkerScale.x, Config.MarkerScale.y, Config.MarkerScale.z,
                        Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerColor.a,
                        false, true, 2, nil, nil, false
                    )
                end

                if dist < Config.InteractDistance then
                    nearShop = id
                    DrawText3D(shop.coords.x, shop.coords.y, shop.coords.z + 0.3, '~b~[E]~w~ ' .. shop.label)
                end
            end
        end

        -- Key press check (only when near a shop, sleep is already 0)
        if sleep == 0 and IsControlJustReleased(0, Config.InteractKey) and not IsShopOpen() then
            if nearShop then
                OpenShopUI(nearShop)
            end
        end

        Wait(sleep)
    end
end)

-- ===== Server Events =====

-- Vehicle purchased successfully
RegisterNetEvent('dei_vehicleshop:purchaseSuccess', function(vehicleData, shopId)
    CloseShopUI()

    if Config.SpawnAfterBuy then
        local shop = Config.Shops[shopId]
        if not shop then
            Notify('Vehiculo comprado y enviado al garaje', 'success')
            return
        end

        local spawn = shop.spawn
        local modelHash = joaat(vehicleData.model)

        RequestModel(modelHash)
        local timeout = 0
        while not HasModelLoaded(modelHash) do
            Wait(10)
            timeout = timeout + 10
            if timeout > 5000 then
                Notify('Vehiculo comprado pero no se pudo spawnear. Revisa tu garaje.', 'warning')
                return
            end
        end

        local vehicle = CreateVehicle(modelHash, spawn.x, spawn.y, spawn.z, spawn.w, true, false)
        while not DoesEntityExist(vehicle) do Wait(10) end

        SetEntityAsMissionEntity(vehicle, true, true)
        SetVehicleOnGroundProperly(vehicle)
        SetVehicleNumberPlateText(vehicle, vehicleData.plate)
        TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
        SetModelAsNoLongerNeeded(modelHash)

        -- Set fuel
        if GetResourceState('ox_fuel') == 'started' then
            Entity(vehicle).state.fuel = 100.0
        elseif GetResourceState('LegacyFuel') == 'started' then
            exports['LegacyFuel']:SetFuel(vehicle, 100.0)
        else
            SetVehicleFuelLevel(vehicle, 100.0)
        end

        Notify('¡Vehiculo comprado! ' .. vehicleData.label, 'success')
    else
        Notify('¡Vehiculo comprado! Retiralo de tu garaje.', 'success')
    end
end)

-- Purchase error
RegisterNetEvent('dei_vehicleshop:purchaseError', function(msg)
    Notify(msg or 'Error al comprar el vehiculo', 'error')
end)

-- Employee sale success
RegisterNetEvent('dei_vehicleshop:saleSuccess', function(vehicleName, commission)
    CloseShopUI()
    Notify('Venta exitosa: ' .. vehicleName .. ' | Comision: $' .. FormatPrice(commission), 'success')
end)

-- ===== Employee Sell Command =====
RegisterCommand('vender', function(source, args, rawCommand)
    local targetId = tonumber(args[1])
    if not targetId then
        Notify('Uso: /vender [id del jugador]', 'error')
        return
    end

    if not HasJob(Config.DealerJob) then
        Notify('No eres empleado del concesionario', 'error')
        return
    end

    if not nearShop then
        Notify('Debes estar en un concesionario', 'error')
        return
    end

    -- Set selling target and open shop
    sellingToPlayer = targetId
    OpenShopUI(nearShop)
end, false)

-- ===== Utils =====
function DrawText3D(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(true)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry('STRING')
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x, y, z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0 + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 100)
    ClearDrawOrigin()
end

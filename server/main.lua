-- ===== Discord Logging =====
local function sendDiscordLog(title, description, color)
    if not Config.DiscordWebhook or Config.DiscordWebhook == '' then return end
    PerformHttpRequest(Config.DiscordWebhook, function() end, 'POST', json.encode({
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003,
            footer = { text = 'Dei VehicleShop' },
            timestamp = os.date('!%Y-%m-%dT%H:%M:%SZ')
        }}
    }), { ['Content-Type'] = 'application/json' })
end

-- ===== Rate Limiting =====
local cooldowns = {}
local function checkCooldown(src, action, seconds)
    local key = src .. ':' .. action
    local now = os.time()
    if cooldowns[key] and (now - cooldowns[key]) < seconds then return false end
    cooldowns[key] = now
    return true
end

local purchaseLocks = {}

-- ===== Buy Vehicle =====
RegisterNetEvent('dei_vehicleshop:buyVehicle', function(shopId, model)
    local source = source
    if purchaseLocks[source] then return end
    if not checkCooldown(source, 'buyVehicle', 3) then return end
    purchaseLocks[source] = true
    local identifier = GetPlayerIdentifier(source)
    if not identifier then purchaseLocks[source] = nil return end

    -- Validate shop
    local shop = Config.Shops[shopId]
    if not shop then
        purchaseLocks[source] = nil
        TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Concesionario no encontrado')
        return
    end

    -- Proximity check
    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        local pCoords = GetEntityCoords(ped)
        local shopCoords = vector3(shop.coords.x, shop.coords.y, shop.coords.z)
        if #(pCoords - shopCoords) > 50.0 then
            print('[dei_vehicleshop] WARNING: Player ' .. source .. ' tried to buy from too far')
            purchaseLocks[source] = nil
            return
        end
    end

    -- Find vehicle in config
    local vehicleData = nil
    for _, veh in ipairs(Config.Vehicles) do
        if veh.model == model then
            vehicleData = veh
            break
        end
    end

    if not vehicleData then
        purchaseLocks[source] = nil
        TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Vehiculo no encontrado')
        return
    end

    -- Check category is sold in this shop
    local validCategory = false
    for _, cat in ipairs(shop.categories) do
        if cat == vehicleData.category then
            validCategory = true
            break
        end
    end

    if not validCategory then
        purchaseLocks[source] = nil
        TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Este vehiculo no se vende aqui')
        return
    end

    -- Check money
    local money = GetPlayerMoney(source, Config.PayFrom)
    if money < vehicleData.price then
        purchaseLocks[source] = nil
        TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'No tienes suficiente dinero. Necesitas $' .. vehicleData.price)
        return
    end

    -- Generate unique plate and register vehicle
    GetUniquePlate(function(plate)
        -- Deduct money
        local removed = RemovePlayerMoney(source, vehicleData.price, Config.PayFrom)
        if not removed then
            purchaseLocks[source] = nil
            TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Error al procesar el pago')
            return
        end

        -- Insert vehicle into database
        InsertVehicle(identifier, vehicleData.model, plate, function(success)
            purchaseLocks[source] = nil
            if success then
                TriggerClientEvent('dei_vehicleshop:purchaseSuccess', source, {
                    model = vehicleData.model,
                    label = vehicleData.label,
                    plate = plate,
                    price = vehicleData.price,
                }, shopId)

                sendDiscordLog('Vehiculo Comprado', 'Jugador: ' .. GetPlayerName(source) .. '\nVehiculo: ' .. vehicleData.label .. '\nPrecio: $' .. vehicleData.price .. '\nPlaca: ' .. plate, 3066993)

                print('[dei_vehicleshop] ' .. GetPlayerName(source) .. ' compro ' .. vehicleData.label .. ' ($' .. vehicleData.price .. ') | Patente: ' .. plate)
            else
                -- Refund if DB insert failed
                AddPlayerMoney(source, vehicleData.price, Config.PayFrom)
                TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Error al registrar el vehiculo')
            end
        end)
    end)
end)

-- ===== Sell To Player (Employee Mode) =====
RegisterNetEvent('dei_vehicleshop:sellToPlayer', function(shopId, model, targetId)
    local source = source
    if not checkCooldown(source, 'sellToPlayer', 5) then return end
    local targetId = tonumber(targetId)

    -- Validate employee job
    if not HasJob(source, Config.DealerJob) then
        TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'No eres empleado del concesionario')
        return
    end

    -- Validate target player
    local targetIdentifier = GetPlayerIdentifier(targetId)
    if not targetIdentifier then
        TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Jugador no encontrado')
        return
    end

    -- Validate shop
    local shop = Config.Shops[shopId]
    if not shop then
        TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Concesionario no encontrado')
        return
    end

    -- Proximity check
    local ped = GetPlayerPed(source)
    if ped and ped ~= 0 then
        local pCoords = GetEntityCoords(ped)
        local shopCoords = vector3(shop.coords.x, shop.coords.y, shop.coords.z)
        if #(pCoords - shopCoords) > 50.0 then
            print('[dei_vehicleshop] WARNING: Player ' .. source .. ' tried to sell from too far')
            return
        end
    end

    -- Find vehicle
    local vehicleData = nil
    for _, veh in ipairs(Config.Vehicles) do
        if veh.model == model then
            vehicleData = veh
            break
        end
    end

    if not vehicleData then
        TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Vehiculo no encontrado')
        return
    end

    -- Check target player money
    local targetMoney = GetPlayerMoney(targetId, Config.PayFrom)
    if targetMoney < vehicleData.price then
        TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'El jugador no tiene suficiente dinero')
        return
    end

    -- Generate unique plate
    GetUniquePlate(function(plate)
        -- Deduct money from target
        local removed = RemovePlayerMoney(targetId, vehicleData.price, Config.PayFrom)
        if not removed then
            TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Error al procesar el pago del comprador')
            return
        end

        -- Insert vehicle for target
        InsertVehicle(targetIdentifier, vehicleData.model, plate, function(success)
            if success then
                -- Pay commission to employee
                local commission = math.floor(vehicleData.price * Config.Commission / 100)
                AddPlayerMoney(source, commission, Config.PayFrom)

                -- Notify employee
                TriggerClientEvent('dei_vehicleshop:saleSuccess', source, vehicleData.label, commission)

                -- Spawn vehicle for buyer
                TriggerClientEvent('dei_vehicleshop:purchaseSuccess', targetId, {
                    model = vehicleData.model,
                    label = vehicleData.label,
                    plate = plate,
                    price = vehicleData.price,
                }, shopId)

                print('[dei_vehicleshop] Venta empleado: ' .. GetPlayerName(source) .. ' vendio ' .. vehicleData.label .. ' a ' .. GetPlayerName(targetId) .. ' ($' .. vehicleData.price .. ') | Comision: $' .. commission)
            else
                -- Refund
                AddPlayerMoney(targetId, vehicleData.price, Config.PayFrom)
                TriggerClientEvent('dei_vehicleshop:purchaseError', source, 'Error al registrar el vehiculo')
            end
        end)
    end)
end)

-- Cleanup on player drop
AddEventHandler('playerDropped', function()
    local src = source
    purchaseLocks[src] = nil
    for key in pairs(cooldowns) do
        if key:find('^' .. src .. ':') then cooldowns[key] = nil end
    end
end)

-- ============================================================
-- Dei Ecosystem - Startup
-- ============================================================
CreateThread(function()
    Wait(500)
    local v = GetResourceMetadata(GetCurrentResourceName(), 'version', 0) or '1.0'
    print('^4[Dei]^0 dei_vehicleshop v' .. v .. ' - ^2Iniciado^0')
end)

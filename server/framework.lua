Framework = nil

CreateThread(function()
    if Config.Framework == 'esx' then
        Framework = exports['es_extended']:getSharedObject()
    elseif Config.Framework == 'qb' then
        Framework = exports['qb-core']:GetCoreObject()
    end
end)

function GetPlayerIdentifier(source)
    if Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        return xPlayer and xPlayer.identifier or nil
    elseif Config.Framework == 'qb' then
        local Player = Framework.Functions.GetPlayer(source)
        return Player and Player.PlayerData.citizenid or nil
    end
    return nil
end

function GetPlayerName(source)
    if Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        return xPlayer and xPlayer.getName() or 'Desconocido'
    elseif Config.Framework == 'qb' then
        local Player = Framework.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.charinfo.firstname .. ' ' .. Player.PlayerData.charinfo.lastname
        end
        return 'Desconocido'
    end
    return 'Desconocido'
end

function GetPlayerMoney(source, moneyType)
    moneyType = moneyType or Config.PayFrom
    if Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            if moneyType == 'bank' then
                return xPlayer.getAccount('bank').money
            else
                return xPlayer.getMoney()
            end
        end
    elseif Config.Framework == 'qb' then
        local Player = Framework.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.money[moneyType] or 0
        end
    end
    return 0
end

function RemovePlayerMoney(source, amount, moneyType)
    moneyType = moneyType or Config.PayFrom
    if Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            if moneyType == 'bank' then
                xPlayer.removeAccountMoney('bank', amount)
            else
                xPlayer.removeMoney(amount)
            end
            return true
        end
    elseif Config.Framework == 'qb' then
        local Player = Framework.Functions.GetPlayer(source)
        if Player then
            return Player.Functions.RemoveMoney(moneyType, amount, 'vehicle-purchase')
        end
    end
    return false
end

function AddPlayerMoney(source, amount, moneyType)
    moneyType = moneyType or Config.PayFrom
    if Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        if xPlayer then
            if moneyType == 'bank' then
                xPlayer.addAccountMoney('bank', amount)
            else
                xPlayer.addMoney(amount)
            end
            return true
        end
    elseif Config.Framework == 'qb' then
        local Player = Framework.Functions.GetPlayer(source)
        if Player then
            return Player.Functions.AddMoney(moneyType, amount, 'vehicle-sale-commission')
        end
    end
    return false
end

function HasJob(source, jobName)
    if Config.Framework == 'esx' then
        local xPlayer = Framework.GetPlayerFromId(source)
        return xPlayer and xPlayer.job and xPlayer.job.name == jobName
    elseif Config.Framework == 'qb' then
        local Player = Framework.Functions.GetPlayer(source)
        return Player and Player.PlayerData.job and Player.PlayerData.job.name == jobName
    end
    return false
end

function RegisterCallback(name, cb)
    if Config.Framework == 'esx' then
        Framework.RegisterServerCallback(name, cb)
    elseif Config.Framework == 'qb' then
        Framework.Functions.CreateCallback(name, cb)
    end
end

-- ============================================================
-- DB Wrapper (oxmysql / mysql-async)
-- ============================================================
function dbQuery(query, params, cb)
    local ok, err = pcall(function()
        if Config.MySQL == 'oxmysql' then
            exports.oxmysql:execute(query, params, cb)
        else
            MySQL.Async.fetchAll(query, params, cb)
        end
    end)
    if not ok then
        print('^1[Dei DB ERROR]^0 dbQuery failed: ' .. tostring(err))
        if cb then cb({}) end
    end
end

function dbExecute(query, params, cb)
    local ok, err = pcall(function()
        if Config.MySQL == 'oxmysql' then
            exports.oxmysql:execute(query, params, cb)
        else
            MySQL.Async.execute(query, params, cb or function() end)
        end
    end)
    if not ok then
        print('^1[Dei DB ERROR]^0 dbExecute failed: ' .. tostring(err))
        if cb then cb(0) end
    end
end

function dbInsert(query, params, cb)
    local ok, err = pcall(function()
        if Config.MySQL == 'oxmysql' then
            exports.oxmysql:insert(query, params, cb)
        else
            MySQL.Async.insert(query, params, cb or function() end)
        end
    end)
    if not ok then
        print('^1[Dei DB ERROR]^0 dbInsert failed: ' .. tostring(err))
        if cb then cb(0) end
    end
end

function dbScalar(query, params, cb)
    local ok, err = pcall(function()
        if Config.MySQL == 'oxmysql' then
            exports.oxmysql:scalar(query, params, cb)
        else
            MySQL.Async.fetchScalar(query, params, cb)
        end
    end)
    if not ok then
        print('^1[Dei DB ERROR]^0 dbScalar failed: ' .. tostring(err))
        if cb then cb(nil) end
    end
end

function dbUpdate(query, params, cb)
    local ok, err = pcall(function()
        if Config.MySQL == 'oxmysql' then
            exports.oxmysql:update(query, params, cb)
        else
            MySQL.Async.execute(query, params, cb or function() end)
        end
    end)
    if not ok then
        print('^1[Dei DB ERROR]^0 dbUpdate failed: ' .. tostring(err))
        if cb then cb(0) end
    end
end

-- ===== Database Operations =====

function GeneratePlate()
    local plate = ''
    local chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'
    for i = 1, 8 do
        local idx = math.random(1, #chars)
        plate = plate .. chars:sub(idx, idx)
    end
    return plate
end

function InsertVehicle(identifier, model, plate, cb)
    if Config.Framework == 'esx' then
        local props = json.encode({ model = joaat(model) })
        dbExecute(
            'INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored) VALUES (?, ?, ?, ?, ?)',
            { identifier, plate, props, 'car', 1 },
            function(result)
                cb(result and result.affectedRows > 0)
            end
        )
    elseif Config.Framework == 'qb' then
        dbExecute(
            'INSERT INTO player_vehicles (citizenid, vehicle, hash, mods, plate, state) VALUES (?, ?, ?, ?, ?, ?)',
            { identifier, model, joaat(model), '{}', plate, 1 },
            function(result)
                cb(result and result.affectedRows > 0)
            end
        )
    end
end

function CheckPlateExists(plate, cb)
    local table_name = Config.Framework == 'esx' and 'owned_vehicles' or 'player_vehicles'
    dbQuery(
        'SELECT plate FROM ' .. table_name .. ' WHERE plate = ?',
        { plate },
        function(results)
            cb(results and #results > 0)
        end
    )
end

function GetUniquePlate(cb)
    local plate = GeneratePlate()
    CheckPlateExists(plate, function(exists)
        if exists then
            GetUniquePlate(cb) -- Recursively try again
        else
            cb(plate)
        end
    end)
end

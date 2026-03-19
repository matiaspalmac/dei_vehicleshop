Framework = nil

CreateThread(function()
    if Config.Framework == 'esx' then
        Framework = exports['es_extended']:getSharedObject()
    elseif Config.Framework == 'qb' then
        Framework = exports['qb-core']:GetCoreObject()
    end
end)

function GetPlayerIdentifier()
    if not Framework then return nil end
    if Config.Framework == 'esx' then
        return Framework.PlayerData and Framework.PlayerData.identifier
    elseif Config.Framework == 'qb' then
        return Framework.Functions.GetPlayerData().citizenid
    end
    return nil
end

function GetVehicleProperties(vehicle)
    if not Framework then return {} end
    if Config.Framework == 'esx' then
        return Framework.Game.GetVehicleProperties(vehicle)
    elseif Config.Framework == 'qb' then
        return Framework.Functions.GetVehicleProperties(vehicle)
    end
    return {}
end

function SetVehicleProperties(vehicle, props)
    if not Framework then return end
    if Config.Framework == 'esx' then
        Framework.Game.SetVehicleProperties(vehicle, props)
    elseif Config.Framework == 'qb' then
        Framework.Functions.SetVehicleProperties(vehicle, props)
    end
end

function Notify(msg, type)
    if Config.Notify == 'dei' and GetResourceState('dei_notifys') == 'started' then
        exports['dei_notifys']:Notify(msg, type or 'info')
    elseif Config.Notify == 'esx' or (Config.Notify == 'dei' and Config.Framework == 'esx') then
        if Framework then Framework.ShowNotification(msg) end
    elseif Config.Notify == 'qb' or (Config.Notify == 'dei' and Config.Framework == 'qb') then
        if Framework then Framework.Functions.Notify(msg, type or 'primary') end
    else
        SetNotificationTextEntry('STRING')
        AddTextComponentString(msg)
        DrawNotification(false, false)
    end
end

function GetPlayerMoney(moneyType)
    if not Framework then return 0 end
    moneyType = moneyType or Config.PayFrom
    if Config.Framework == 'esx' then
        local pd = Framework.PlayerData
        if pd and pd.accounts then
            for _, acc in ipairs(pd.accounts) do
                if moneyType == 'bank' and acc.name == 'bank' then return math.floor(acc.money) end
                if moneyType == 'cash' and acc.name == 'money' then return math.floor(acc.money) end
            end
        end
    elseif Config.Framework == 'qb' then
        local pd = Framework.Functions.GetPlayerData()
        if pd and pd.money then
            if moneyType == 'bank' then return math.floor(pd.money['bank'] or 0) end
            if moneyType == 'cash' then return math.floor(pd.money['cash'] or 0) end
        end
    end
    return 0
end

function HasJob(jobName)
    if not Framework then return false end
    if Config.Framework == 'esx' then
        local pd = Framework.PlayerData
        return pd and pd.job and pd.job.name == jobName
    elseif Config.Framework == 'qb' then
        local pd = Framework.Functions.GetPlayerData()
        return pd and pd.job and pd.job.name == jobName
    end
    return false
end

function TriggerServerCallback(name, cb, ...)
    if not Framework then return end
    if Config.Framework == 'esx' then
        ESX = Framework
        ESX.TriggerServerCallback(name, cb, ...)
    elseif Config.Framework == 'qb' then
        Framework.Functions.TriggerCallback(name, cb, ...)
    end
end

-- Theme sync (Dei ecosystem KVP + event)
RegisterNetEvent('dei:themeChanged', function(theme, lightMode)
    SendNUIMessage({
        action = 'setTheme',
        theme = theme,
        lightMode = lightMode,
    })
end)

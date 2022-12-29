local RSGCore = exports['rsg-core']:GetCoreObject()
local PlayerData = RSGCore.Functions.GetPlayerData()

-----------------------------------------------------------------------------------

-- wholesale prompts and blips
Citizen.CreateThread(function()
    for wholesale, v in pairs(Config.WholesaleLocations) do
        exports['rsg-core']:createPrompt(v.location, v.coords, RSGCore.Shared.Keybinds['J'], 'Open ' .. v.name, {
            type = 'client',
            event = 'rsg-wholesaletrader:client:openMenu',
            args = { v.location },
        })
        if v.showblip == true then
            local WholesaleTraderBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.coords)
            SetBlipSprite(WholesaleTraderBlip, GetHashKey(Config.WholesaleBlip.blipSprite), true)
            SetBlipScale(WholesaleTraderBlip, Config.WholesaleBlip.blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, WholesaleTraderBlip, Config.WholesaleBlip.blipName)
        end
    end
end)

-- draw marker if set to true in config
CreateThread(function()
    while true do
        Wait(1)
        for trapper, v in pairs(Config.WholesaleLocations) do
            if v.showmarker == true then
                Citizen.InvokeNative(0x2A32FAA57B937173, 0x07DCE236, v.coords, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 215, 0, 155, false, false, false, 1, false, false, false)
            end
        end
    end
end)

-----------------------------------------------------------------------------------

-- wholesale trader menu
RegisterNetEvent('rsg-wholesaletrader:client:openMenu', function()
    local job = RSGCore.Functions.GetPlayerData().job.name
    if job == Config.JobRequired then
        exports['rsg-menu']:openMenu({
            {
                header = 'Wholesale Trader',
                isMenuHeader = true,
            },
            {
                header = "Wholesale Storage",
                txt = "",
                icon = "fas fa-box",
                params = {
                    event = 'rsg-wholesaletrader:client:storage',
                    isServer = false,
                    args = {},
                }
            },
            {
                header = "Wholesale Imports",
                txt = "",
                icon = "fas fa-box",
                params = {
                    event = 'rsg-wholesaletrader:client:openShop',
                    isServer = false,
                    args = {},
                }
            },
            {
                header = "Job Management",
                txt = "",
                icon = "fas fa-user-circle",
                params = {
                    event = 'rsg-bossmenu:client:OpenMenu',
                    isServer = false,
                    args = {},
                }
            },
            {
                header = ">> Close Menu <<",
                txt = '',
                params = {
                    event = 'rsg-menu:closeMenu',
                }
            },
        })
    else
        RSGCore.Functions.Notify('you are not authorised!', 'error')
    end
end)

-----------------------------------------------------------------------------------

-- wholesale shop
RegisterNetEvent('rsg-wholesaletrader:client:openShop')
AddEventHandler('rsg-wholesaletrader:client:openShop', function()
    local job = RSGCore.Functions.GetPlayerData().job.name
    if job == Config.JobRequired then
        local ShopItems = {}
        ShopItems.label = "Wholesale Shop"
        ShopItems.items = Config.WholesaleShop
        ShopItems.slots = #Config.WholesaleShop
        TriggerServerEvent("inventory:server:OpenInventory", "shop", "WholesaleShop_"..math.random(1, 99), ShopItems)
    else
        RSGCore.Functions.Notify('you don\'t have the required access', 'error')
    end
end)

-----------------------------------------------------------------------------------

-- wholesale trader general storage
RegisterNetEvent('rsg-wholesaletrader:client:storage', function()
    local job = RSGCore.Functions.GetPlayerData().job.name
    if job == Config.JobRequired then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", Config.StorageName, {
            maxweight = Config.StorageMaxWeight,
            slots = Config.StorageMaxSlots,
        })
        TriggerEvent("inventory:client:SetCurrentStash", Config.StorageName)
    end
end)

-----------------------------------------------------------------------------------

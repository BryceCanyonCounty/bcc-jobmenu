local LastJobChange = 0
local ready = false

local ShopPrompt = 0
local ShopGroup = GetRandomIntInRange(0, 0xffffff)
local InMenu = false

local function StartPrompt()
    if not ShopGroup then
        DBG:Error('ShopGroup not initialized')
        return
    end

    if not Config or not Config.keys or not Config.keys.menu then
        DBG:Error('Menu key is not configured')
        return
    end

    ShopPrompt = UiPromptRegisterBegin()
    if not ShopPrompt or ShopPrompt == 0 then
        DBG:Error("Failed to register ShopPrompt")
        return
    end
    UiPromptSetControlAction(ShopPrompt, Config.keys.menu)
    UiPromptSetText(ShopPrompt, VarString(10, 'LITERAL_STRING', _U('shopPrompt')))
    UiPromptSetVisible(ShopPrompt, true)
    Citizen.InvokeNative(0x74C7D7B72ED0D3CF, ShopPrompt, 'MEDIUM_TIMED_EVENT') -- PromptSetStandardizedHoldMode
    UiPromptSetGroup(ShopPrompt, ShopGroup, 0)
    UiPromptRegisterEnd(ShopPrompt)

     DBG:Success('Menu prompt started successfully')
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    ready = true
end)

local function isShopClosed(siteCfg)
    local hour = GetClockHours()
    local hoursActive = siteCfg.shop.hours.active

    if not hoursActive then
        return false
    end

    local openHour = siteCfg.shop.hours.open
    local closeHour = siteCfg.shop.hours.close

    if openHour < closeHour then
        -- Normal: shop opens and closes on the same day
        return hour < openHour or hour >= closeHour
    else
        -- Overnight: shop closes on the next day
        return hour < openHour and hour >= closeHour
    end
end

local function ManageSiteBlip(site, closed)
    local siteCfg = Sites[site]

    if (closed and not siteCfg.blip.show.closed) or (not siteCfg.blip.show.open) then
        if siteCfg.Blip then
            RemoveBlip(siteCfg.Blip)
            siteCfg.Blip = nil
        end
        return
    end

    if not siteCfg.Blip then
        siteCfg.Blip = Citizen.InvokeNative(0x554d9d53f696d002, 1664425300, siteCfg.npc.coords) -- BlipAddForCoords
        SetBlipSprite(siteCfg.Blip, siteCfg.blip.sprite, true)
        Citizen.InvokeNative(0x9CB1A1623062F402, siteCfg.Blip, siteCfg.blip.name)               -- SetBlipName
    end

    local color = closed and siteCfg.blip.color.closed or siteCfg.blip.color.open

    if Config.BlipColors[color] then
        Citizen.InvokeNative(0x662D364ABF16DE2F, siteCfg.Blip, joaat(Config.BlipColors[color])) -- BlipAddModifier
    else
        DBG:Error('Blip color not defined for color: ' .. tostring(color))
    end
end

local function LoadModel(model, modelName)
    if not IsModelValid(model) then
        return print('Invalid model:', modelName)
    end

    if not HasModelLoaded(model) then
        RequestModel(model, false)

        local timeout = 10000
        local startTime = GetGameTimer()

        while not HasModelLoaded(model) do
            if GetGameTimer() - startTime > timeout then
                print('Failed to load model:', modelName)
                return
            end
            Wait(10)
        end
    end
end

local function AddNPC(site)
    local siteCfg = Sites[site]
    local coords = siteCfg.npc.coords

    if not siteCfg.NPC then
        local modelName = siteCfg.npc.model
        local model = joaat(modelName)
        LoadModel(model, modelName)

        siteCfg.NPC = CreatePed(model, coords.x, coords.y, coords.z -1, siteCfg.npc.heading, false, false, false, false)
        Citizen.InvokeNative(0x283978A15512B2FE, siteCfg.NPC, true) -- SetRandomOutfitVariation

        SetEntityCanBeDamaged(siteCfg.NPC, false)
        SetEntityInvincible(siteCfg.NPC, true)
        Wait(500)
        FreezeEntityPosition(siteCfg.NPC, true)
        SetBlockingOfNonTemporaryEvents(siteCfg.NPC, true)
        SetPedCanRagdoll(siteCfg.NPC, false)
    end
end

local function RemoveNPC(site)
    local siteCfg = Sites[site]

    if siteCfg.NPC then
        DeleteEntity(siteCfg.NPC)
        siteCfg.NPC = nil
    end
end

CreateThread(function()

    repeat Wait(2000) until LocalPlayer.state.IsInSession
    StartPrompt()

    while true do
        if not ready then return end

        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        local sleep = 1000

        if InMenu or IsEntityDead(playerPed) then
            Wait(1000)
            goto END
        end

        for site, siteCfg in pairs(Sites) do
            local distance = #(playerCoords - siteCfg.npc.coords)
            IsShopClosed = isShopClosed(siteCfg)

            ManageSiteBlip(site, IsShopClosed)

            if distance > siteCfg.npc.distance or IsShopClosed then
                RemoveNPC(site)
            elseif siteCfg.npc.active then
                AddNPC(site)
            end

            if distance <= siteCfg.shop.distance then
                sleep = 0
                local promptText = IsShopClosed and siteCfg.shop.name .. _U('hours') .. siteCfg.shop.hours.open .. _U('to') ..
                siteCfg.shop.hours.close .. _U('hundred') or siteCfg.shop.prompt

                UiPromptSetActiveGroupThisFrame(ShopGroup, VarString(10, 'LITERAL_STRING', promptText), 1, 0, 0, 0)
                UiPromptSetEnabled(ShopPrompt, not IsShopClosed)

                if not IsShopClosed then
                    if Citizen.InvokeNative(0xE0F65F0640EF0617, ShopPrompt) then -- PromptHasHoldModeCompleted
                        Wait(500)
                        local timeSinceJobChange = math.floor(((GetGameTimer() - LastJobChange) / 1000) / 60)
                        if timeSinceJobChange >= Config.jobChangeDelay or LastJobChange == 0 then
                            MainMenu()
                        else
                            local nextJobChange = Config.jobChangeDelay - timeSinceJobChange
                            Core.NotifyRightTip(_U("JobChangeDelay") .. nextJobChange .. _U("TimeFormat"), 4000)
                        end
                    end
                end
            end
        end
        ::END::
        Wait(sleep)
    end
end)

function SetJobInfo(job, label, grade, grade_label)
    local jobInfo = {
        job = job,
        label = label,
        grade = grade,
        grade_label = grade_label,
    }

    local jobChanged = Core.Callback.TriggerAwait('bcc:set_job', jobInfo)

    if jobChanged then
        LastJobChange = GetGameTimer()
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    ClearPedTasksImmediately(PlayerPedId())

    for _, siteCfg in pairs(Sites) do
        if siteCfg.Blip then
            RemoveBlip(siteCfg.Blip)
            siteCfg.Blip = nil
        end
        if siteCfg.NPC then
            DeleteEntity(siteCfg.NPC)
            siteCfg.NPC = nil
        end
    end
end)

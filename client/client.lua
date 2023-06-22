local Key = Config.Key
local Inmenu
local lastJobChange = 0
local VORPcore = {}

-- Get Menu
TriggerEvent("menuapi:getData", function(call)
    MenuData = call
end)

-- Get Core
TriggerEvent("getCore", function(core)
    VORPcore = core
end)

RegisterNetEvent("bcc_jobmenu:setLastJobChange", function()
    lastJobChange = GetGameTimer()
end)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local isDead = IsPedDeadOrDying(player)
        if IsControlJustPressed(0, Key) and not isDead and not Inmenu then
            local timeSinceJobChange = math.floor(((GetGameTimer() - lastJobChange) / 1000) / 60)
            if timeSinceJobChange >= Config.jobChangeDelay or lastJobChange == 0 then
                MenuData.CloseAll()
                OpenMenu()
            else
                local nextJobChange = Config.jobChangeDelay - timeSinceJobChange
                VORPcore.NotifyRightTip(_U("JobChangeDelay") .. nextJobChange .. _U("TimeFormat"), 4000)
            end
        end
        Citizen.Wait(10)
    end
end)

function OpenMenu()
    MenuData.CloseAll()

    MenuData.Open('default', GetCurrentResourceName(), 'menuapi',
        {
            title = _U("MenuTitle"),
            subtext = _U("MenuSubTitle"),
            align = 'top-left',
            elements = Config.Jobs
        },
        function(data, menu)
            if data.current == "backup" then
                _G[data.trigger]()
            end

            local jobname = data.current.value
            if not Config.DisallowSetGrade then
                local target = data.current.info
                local input = {
                    type = "enableinput",
                    inputType = "input",
                    button = _U("confirm"),
                    placeholder = "JOB GRADE",
                    style = "block",
                    attributes = {
                        inputHeader = "SET JOB GRADE",
                        type = "number",
                        patter = "[0-9]{1,2}",
                        title = "min 1 max 2 no . no , no - no _",
                        style = "border-radius: 10px; background-color: ; border: none;",
                    }
                }

                TriggerEvent("vorpinputs:advancedInput", json.encode(input), function(cb)
                    local result = tostring(cb)
                    if result ~= "" then
                        local jobgrade = tonumber(result)
                        if jobgrade then
                            TriggerServerEvent("bcc_jobmenu:setJob", jobname, jobgrade)
                            menu.close()
                        end
                    else
                        VORPcore.NotifyRightTip(_U("empty"), 4000)
                    end
                end)
            else
                TriggerServerEvent("bcc_jobmenu:setJob", jobname, data.current.defaultGrade)
                menu.close()
            end
        end,
        function(data, menu)
            menu.close()
        end)
end

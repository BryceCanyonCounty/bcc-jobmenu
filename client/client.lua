local Key = Config.Key
local Inmenu

-- Get Menu
TriggerEvent("menuapi:getData", function(call)
    MenuData = call
end)

Citizen.CreateThread(function()
    while true do
        local player = PlayerPedId()
        local isDead = IsPedDeadOrDying(player)
        if IsControlJustPressed(0, Key) and not isDead and not Inmenu then
            MenuData.CloseAll()
            OpenMenu()
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
                            TriggerServerEvent("mwg_jobmenu:setJob", jobname, jobgrade)
                        end
                    else
                        TriggerEvent("vorp:TipRight", _U("empty"), 4000)
                    end
                end)
            else
                TriggerServerEvent("mwg_jobmenu:setJob", jobname, data.current.defaultGrade)
            end

            -- TriggerEvent("vorpinputs:advancedInput", json.encode(input), function(cb)
            --     local result = tostring(cb)

            --     if result ~= "" then
            --         local splitstring = {}
            --         for i in string.gmatch(result, "%S+") do
            --             splitstring[#splitstring + 1] = i
            --         end
            --         local jobgrade = tonumber(splitstring[1])
            --         local jobname = data.current.value
            --         if jobgrade then
            --             TriggerServerEvent("mwg_jobmenu:setJob", jobname, jobgrade)
            --         end
            --     else
            --         TriggerEvent("vorp:TipRight", _U("empty"), 4000)
            --     end
            -- end)
        end,
        function(data, menu)
            menu.close()
        end)
end

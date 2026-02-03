local LastJobChange = 0
local VORPcore = exports.vorp_core:GetCore()
local FeatherMenu = exports['feather-menu'].initiate()

local ready = false
local blips = {}
local postmen = {}

local OpenStores = 0
local PromptGroup <const> = GetRandomIntInRange(0, 0xffffff)
local isInMenu = false

-------------------

local function setUpPrompt()
    OpenStores = UiPromptRegisterBegin()
    UiPromptSetControlAction(OpenStores, Config.Key)
    local label = VarString(10, 'LITERAL_STRING', "Job Center")
    UiPromptSetText(OpenStores, label)
    UiPromptSetEnabled(OpenStores, true)
    UiPromptSetVisible(OpenStores, true)
    UiPromptSetStandardMode(OpenStores, true)
    UiPromptSetGroup(OpenStores, PromptGroup, 0)
    UiPromptRegisterEnd(OpenStores)
end

local function showPrompt(label, action)
    local labelToDisplay <const> = VarString(10, 'LITERAL_STRING', label)
    UiPromptSetActiveGroupThisFrame(PromptGroup, labelToDisplay, 0, 0, 0, 0)

    if UiPromptHasStandardModeCompleted(OpenStores, 0) then
        Wait(100)
        return action
    end
end

--------------------------

AddEventHandler('onClientResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end

    ready = true
end)

Citizen.CreateThread(function()

    repeat Wait(2000) until LocalPlayer.state.IsInSession
    setUpPrompt()

    while true do
        Citizen.Wait(1)

        if not ready then
            return
        end

        local sleep = 1000
        local playerPed = PlayerPedId()

        if IsNearbyJobCenter() and (showPrompt("Change for new Job", "open") == "open") then
            --DrawText("Job Center press G for open Menu", 23, 0.5, 0.85, 0.50, 0.40, 255, 255, 255, 255)

            sleep = 0
            UiPromptSetEnabled(OpenStores, true)

           -- if IsControlJustPressed(0, Config.Key) and not IsEntityDead(playerPed) then
            local timeSinceJobChange = math.floor(((GetGameTimer() - LastJobChange) / 1000) / 60)
                if timeSinceJobChange >= Config.jobChangeDelay or LastJobChange == 0 then
                MainMenu()
                else
                local nextJobChange = Config.jobChangeDelay - timeSinceJobChange
                VORPcore.NotifyRightTip(_U("JobChangeDelay") .. nextJobChange .. _U("TimeFormat"), 4000)

                end
           -- end
        end

    end
end)

function IsNearbyJobCenter()
    for _, jobcenter in pairs(Config.locations) do
        if IsPlayerNearCoords(jobcenter.coords.x, jobcenter.coords.y, jobcenter.coords.z, 2.0) then
            return true
        end
    end
   -- (showPrompt("Found new Job", "open") == "open")
    return false
end

------------------------

local function CreateJobCenterBlip(x, y, z)
    local bliphash = -1954662204
    local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, x, y, z)
    Citizen.InvokeNative(0x74F74D3207ED525C, blip, bliphash, 1) -- See blips here: https://cloudy-docs.bubbleapps.io/rdr2_blips
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, Config.BlipJobName)
    return blip
end

CreateThread(function()
    repeat Wait(100) until ready
    Wait(300)

    --print(("Spawning mailbox NPCs... total:\t%s"):format(#Config.locations))

    local model = GetHashKey(Config.NpcJobModel)
    if not IsModelValid(model) then
        print(("[config.lua] ^1Model %s invalid, fallback to player model^7"):format(Config.NpcJobModel))
        model = GetEntityModel(PlayerPedId())
    end

    RequestModel(model, false)
    repeat Wait(50) until HasModelLoaded(model)

    for _, jobcenter in ipairs(Config.locations) do
        local ped = CreatePed(model, jobcenter.coords.x, jobcenter.coords.y, jobcenter.coords.z - 1.0, jobcenter.coords.w, false, false, false, false)
        repeat Wait(100) until DoesEntityExist(ped)

        Citizen.InvokeNative(0x283978A15512B2FE, ped, true) -- random outfit
        PlaceEntityOnGroundProperly(ped)
        SetEntityCanBeDamaged(ped, false)
        SetBlockingOfNonTemporaryEvents(ped, true)
        FreezeEntityPosition(ped, true)
        SetPedCanRagdoll(ped, false)

        table.insert(postmen, ped)

        local blip = CreateJobCenterBlip(jobcenter.coords.x, jobcenter.coords.y, jobcenter.coords.z)
        table.insert(blips, blip)
      --  (showPrompt(storeConfig.PromptName, "open") == "open")
    end

    SetModelAsNoLongerNeeded(model)
end)

function table.find(f, l) -- find element v of l satisfying f(v)
    for _, v in ipairs(l) do
        if f(v) then
            return v
        end
    end
    return nil
end

-- utils

function IsPlayerNearCoords(x, y, z, dst)
    local playerPos = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, 0.0)

    local distance = GetDistanceBetweenCoords(playerPos.x, playerPos.y, playerPos.z, x, y, z, true)

    if distance < dst then
        return true
    end
    return false
end

function DrawText(text, fontId, x, y, scaleX, scaleY, r, g, b, a)
    -- Draw Text
    SetTextScale(scaleX, scaleY);
    SetTextColor(r, g, b, a);
    SetTextCentre(true);
    Citizen.InvokeNative(0xADA9255D, fontId); -- Loads the font requested
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y);

    -- Draw Backdrop
    local lineLength = string.len(text) / 100 * 0.66;
    DrawTexture("boot_flow", "selection_box_bg_1d", x, y, lineLength, 0.035, 0, 0, 0, 0, 200);
end

function DrawTexture(textureDict, textureName, x, y, width, height, rotation, r, g, b, a)

    if not HasStreamedTextureDictLoaded(textureDict) then

        RequestStreamedTextureDict(textureDict, false);
        while not HasStreamedTextureDictLoaded(textureDict) do
            Citizen.Wait(100)
        end
    end
    DrawSprite(textureDict, textureName, x, y + 0.015, width, height, rotation, r, g, b, a, true);
end

AddEventHandler("onResourceStop", function(res)
    if res ~= GetCurrentResourceName() then return end

    for _, ped in ipairs(postmen) do
        if ped and DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    postmen = {}

    for _, blip in ipairs(blips) do
        if blip and DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    blips = {}

    --print("^2[Mailbox]^7 Cleaned up NPCs and blips")

end)

---------------------------


function MainMenu()
    -- Create the main menu
    local jobMenu = FeatherMenu:RegisterMenu('bcc-jobmenu:MainMenu', {
        top = '40%',
        left = '20%',
        ['720width'] = '500px',
        ['1080width'] = '600px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '900px',
        style = {},
        contentslot = {
            style = {
                ['height'] = '400px',
                ['min-height'] = '400px'
            }
        },
        draggable = true,
        canclose = true,
    })

    -- Create the job select page
    local selectJob = jobMenu:RegisterPage('job:select')
    selectJob:RegisterElement('header', {
        value = _U('MenuTitle'),
        slot = "header",
        style = {
            ['color'] = '#999'
        }
    })

    selectJob:RegisterElement('subheader', {
        value = _U('MenuSubTitle'),
        slot = "header",
        style = {
            ['color'] = '#CC9900',
            ['font-size'] = '18px'
        }
    })

    selectJob:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for job, jobDetails in ipairs(Config.Jobs) do
        selectJob:RegisterElement('button', {
            label = jobDetails.label,
            style = {
                ['color'] = '#E0E0E0'
            },
            id = job,
        }, function(data)
            if (Config.Jobs[data.id].jobGrades) then
                JobGradeMenu(data.id)
            else
                SetJobInfo(Config.Jobs[data.id].value, Config.Jobs[data.id].label, 1, 'One')
                jobMenu:Close()
            end
        end)
    end

    jobMenu:Open({
        startupPage = selectJob
    })
end

function JobGradeMenu(job)
    -- Create the job grade menu
    local jobGradeMenu = FeatherMenu:RegisterMenu('bcc-jobmenu:JobGradeMenu', {
        top = '40%',
        left = '20%',
        ['720width'] = '500px',
        ['1080width'] = '600px',
        ['2kwidth'] = '700px',
        ['4kwidth'] = '900px',
        style = {},
        contentslot = {
            style = {
                ['height'] = '400px',
                ['min-height'] = '400px'
            }
        },
        draggable = true,
        canclose = true,
    })

    -- Create the job grade select page
    local selectJobGrade = jobGradeMenu:RegisterPage('grade:select')
    selectJobGrade:RegisterElement('header', {
        value = Config.Jobs[job].label .. ' ' .. _U('GradeMenuTitle'),
        slot = "header",
        style = {
            ['color'] = '#999'
        }
    })

    selectJobGrade:RegisterElement('subheader', {
        value = _U('GradeMenuSubTitle'),
        slot = "header",
        style = {
            ['color'] = '#CC9900',
            ['font-size'] = '18px'
        }
    })

    selectJobGrade:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    local jobGrade = 1
    if (type(Config.Jobs[job].jobGrades) == 'table') then
        for grade, gradeDetails in ipairs(Config.Jobs[job].jobGrades) do
            selectJobGrade:RegisterElement('button', {
                label = gradeDetails.label,
                style = {
                    ['color'] = '#E0E0E0'
                },
                id = grade,
            }, function(data)
                SetJobInfo(Config.Jobs[job].value, Config.Jobs[job].label, Config.Jobs[job].jobGrades[data.id].grade,
                    Config.Jobs[job].jobGrades[data.id].label)
                jobGradeMenu:Close()
            end)
        end
    else
        selectJobGrade:RegisterElement('slider', {
            label = _U('JobGrade'),
            start = 1,
            min = 1,
            max = Config.MaxJobGrade,
            style = {
                ['margin-top'] = '20px'
            }
        }, function(data)
            jobGrade = data.value
        end)

        selectJobGrade:RegisterElement('button', {
            label = _U('confirm'),
            style = {
                ['color'] = '#E0E0E0'
            },
        }, function(data)
            SetJobInfo(Config.Jobs[job].value, Config.Jobs[job].label, jobGrade, jobGrade)
            jobGradeMenu:Close()
        end)
    end

    selectJobGrade:RegisterElement('button', {
        label = _U('Back'),
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function(data)
        MainMenu()
    end)

    jobGradeMenu:Open({
        startupPage = selectJobGrade
    })
end

function SetJobInfo(job, label, grade, grade_label)
    local jobInfo = {
        job = job,
        label = label,
        grade = grade,
        grade_label = grade_label,
    }

    local jobChanged = VORPcore.Callback.TriggerAwait('bcc:set_job', jobInfo)

    if jobChanged then
        LastJobChange = GetGameTimer()
    end
end

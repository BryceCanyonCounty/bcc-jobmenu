local LastJobChange = 0
local VORPcore = exports.vorp_core:GetCore()
local FeatherMenu = exports['feather-menu'].initiate()

CreateThread(function()
    while true do
        Wait(0)
        local playerPed = PlayerPedId()

        if IsControlJustPressed(0, Config.Key) and not IsEntityDead(playerPed) then
            local timeSinceJobChange = math.floor(((GetGameTimer() - LastJobChange) / 1000) / 60)
            if timeSinceJobChange >= Config.jobChangeDelay or LastJobChange == 0 then
                MainMenu()
            else
                local nextJobChange = Config.jobChangeDelay - timeSinceJobChange
                VORPcore.NotifyRightTip(_U("JobChangeDelay") .. nextJobChange .. _U("TimeFormat"), 4000)
            end
        end
    end
end)

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

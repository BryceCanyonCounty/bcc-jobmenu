function MainMenu()
    -- Create the main menu
    local jobMenu = FeatherMenu:RegisterMenu('bcc-jobmenu:MainMenu', {
        top = '3%',
        left = '3%',
        ['720width'] = '400px',
        ['1080width'] = '500px',
        ['2kwidth'] = '600px',
        ['4kwidth'] = '800px',
        style = {},
        contentslot = {
            style = {
                ['height'] = '350px',
                ['min-height'] = '250px'
            }
        },
        draggable = true,
        canclose = true,
    }, {
        opened = function()
            DisplayRadar(false)
            InMenu = true
        end,
        closed = function()
            DisplayRadar(true)
            InMenu = false
        end
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
            ['font-size'] = '0.94vw'
        }
    })

    selectJob:RegisterElement('line', {
        slot = "header",
        style = {}
    })

    for job, jobDetails in ipairs(Jobs) do
        selectJob:RegisterElement('button', {
            label = jobDetails.label,
            slot = "content",
            style = {
                ['color'] = '#E0E0E0'
            },
            id = job,
        }, function(data)
            if (Jobs[data.id].jobGrades) then
                JobGradeMenu(data.id)
            else
                SetJobInfo(Jobs[data.id].value, Jobs[data.id].label, 1, 'One')
                jobMenu:Close()
            end
        end)
    end

    selectJob:RegisterElement('bottomline', {
        slot = "content",
        style = {}
    })

    selectJob:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    selectJob:RegisterElement('button', {
        label = _U('close'),
        slot = 'footer',
        style = {
            ['color'] = '#E0E0E0'
        }
    }, function()
        jobMenu:Close()
    end)

    selectJob:RegisterElement('line', {
        slot = 'footer',
        style = {}
    })

    jobMenu:Open({
        startupPage = selectJob
    })
end

function JobGradeMenu(job)
    -- Create the job grade menu
    local jobGradeMenu = FeatherMenu:RegisterMenu('bcc-jobmenu:JobGradeMenu', {
        top = '3%',
        left = '3%',
        ['720width'] = '400px',
        ['1080width'] = '500px',
        ['2kwidth'] = '600px',
        ['4kwidth'] = '800px',
        style = {},
        contentslot = {
            style = {
                ['height'] = '350px',
                ['min-height'] = '250px'
            }
        },
        draggable = true,
        canclose = true,
    }, {
        opened = function()
            DisplayRadar(false)
            InMenu = true
        end,
        closed = function()
            DisplayRadar(true)
            InMenu = false
        end
    })

    -- Create the job grade select page
    local selectJobGrade = jobGradeMenu:RegisterPage('grade:select')
    selectJobGrade:RegisterElement('header', {
        value = Jobs[job].label .. ' ' .. _U('GradeMenuTitle'),
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
    local jobGrades = Jobs[job].jobGrades
    if (type(jobGrades) == 'table') then
        for grade, gradeDetails in ipairs(jobGrades) do
            selectJobGrade:RegisterElement('button', {
                label = gradeDetails.label,
                slot = "content",
                style = {
                    ['color'] = '#E0E0E0'
                },
                id = grade,
            }, function(data)
                SetJobInfo(Jobs[job].value, Jobs[job].label, Jobs[job].jobGrades[data.id].grade, Jobs[job].jobGrades[data.id].label)
                jobGradeMenu:Close()
            end)
        end
    else
        selectJobGrade:RegisterElement('slider', {
            label = _U('JobGrade'),
            slot = "content",
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
            SetJobInfo(Jobs[job].value, Jobs[job].label, jobGrade, jobGrade)
            jobGradeMenu:Close()
        end)
    end

    selectJobGrade:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    selectJobGrade:RegisterElement('button', {
        label = _U('Back'),
        slot = "footer",
        style = {
            ['color'] = '#E0E0E0'
        },
    }, function(data)
        MainMenu()
    end)

    selectJobGrade:RegisterElement('line', {
        slot = "footer",
        style = {}
    })

    jobGradeMenu:Open({
        startupPage = selectJobGrade
    })
end

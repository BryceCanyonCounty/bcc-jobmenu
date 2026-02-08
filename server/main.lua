Core.Callback.Register('bcc:set_job', function(source, cb, data)
    local src = source
    local user = Core.getUser(src)

    -- Check if the user exists
    if not user then
        DBG:Error('User not found for source: ' .. tostring(src))
        return cb(false)
    end

    local character = user.getUsedCharacter

    character.setJob(data.job)
    character.setJobGrade(data.grade)
    character.setJobLabel(data.label)

    Core.NotifyRightTip(src, _U('jobgiven') .. data.label, 4000)
    Core.NotifyRightTip(src, _U('gradegiven') .. data.grade .. " " .. "( " .. data.grade_label .. " )", 4000)

    cb(true)
end)

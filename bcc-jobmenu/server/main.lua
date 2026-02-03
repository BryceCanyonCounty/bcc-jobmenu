local VORPcore = exports.vorp_core:GetCore()

VORPcore.Callback.Register('bcc:set_job', function(source, cb, data)
    local src = source
    local character = VORPcore.getUser(src).getUsedCharacter

    character.setJob(data.job)
    character.setJobGrade(data.grade)
    character.setJobLabel(data.label)

    VORPcore.NotifyRightTip(src, _U('jobgiven') .. data.label, 4000)
    VORPcore.NotifyRightTip(src, _U('gradegiven') .. data.grade .. " " .. "( " .. data.grade_label .. " )", 4000)

    cb(true)
end)

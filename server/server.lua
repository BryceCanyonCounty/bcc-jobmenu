RegisterServerEvent("mwg_jobmenu:setJob", function(newjob, newgrade)
    local _source = source
    local NewPlayerJoB = newjob
    local NewPlayerGrade = newgrade
    if _source then
        TriggerEvent("vorp:setJob", _source, NewPlayerJoB, NewPlayerGrade)
        TriggerClientEvent("vorp:TipRight", _source, _U("jobgiven") .. NewPlayerJoB, 5000)
        Wait(500)
        TriggerClientEvent("vorp:TipRight", _source, _U("gradegiven") .. NewPlayerGrade, 5000)
    end
end)

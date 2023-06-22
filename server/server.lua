RegisterServerEvent("bcc_jobmenu:setJob", function(newjob, newgrade)
    local _source = source
    if _source then
        TriggerClientEvent("bcc_jobmenu:setLastJobChange", _source)
        TriggerEvent("vorp:setJob", _source, newjob, newgrade)
        TriggerClientEvent("vorp:setjob", _source, string.lower(newjob))
        TriggerClientEvent("vorp:TipRight", _source, _U("jobgiven") .. newjob, 5000)
        Wait(500)
        TriggerClientEvent("vorp:TipRight", _source, _U("gradegiven") .. newgrade, 5000)
    end
end)

Core = exports.vorp_core:GetCore()
BccUtils = exports['bcc-utils'].initiate()
DBG = BccUtils.Debug:Get('bcc-jobmenu', Config.devMode.active)

if DBG then
    DBG:Enable()
    DBG:Info('Jobmenu debug initialized')
end

BccUtils.Versioner.checkFile(GetCurrentResourceName(), 'https://github.com/BryceCanyonCounty/bcc-jobmenu')
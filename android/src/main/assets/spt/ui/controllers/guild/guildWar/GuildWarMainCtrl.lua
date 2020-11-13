local GuildWarMainCtrl = class()

function GuildWarMainCtrl.GuildWarEntry(guildInfo)
    res.PushDialog("ui.controllers.guild.guildMistWar.GuildWarTypeSelectCtrl", guildInfo)
end

return GuildWarMainCtrl
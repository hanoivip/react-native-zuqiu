local Model = require("ui.models.Model")
local ResManager = clr.Capstones.UnityFramework.ResManager
local SettingsLanguageModel = class(Model, "SettingsLanguageModel")

-- 设置本地dflag
local LangDFlagMap = {["cn"] = "lang_sgp/distribute/lang_zh-Hans", ["sgp"] = nil, ["th"] = "lang_sgp/distribute/lang_th"}
-- 转发给服务器
local LangId2Server = {["cn"] = "zh-Hans", ["sgp"] = "sgp", ["th"] = "th"}
-- 默认语言
local LangDFlagDefult = "sgp"

-- 需要首次登陆弹切换窗口改成 true
local needFisrtLoginOpen = true
-- 设置本地dflag
SettingsLanguageModel.LangIsShow = {["cn"] = true, ["sgp"] = true, ["th"] = true}

function SettingsLanguageModel:ctor(data)
    self.cacheData = data
end

function SettingsLanguageModel:ChangeLanguage(langId)
    local langFlag = LangDFlagMap[langId]
    ResManager.RemoveDistributeFlag(LangDFlagMap[self.oldDFlag] or "")
    ResManager.AddDistributeFlag(langFlag or "")
    self._mdflags = nil
end

function SettingsLanguageModel:LangIsNormal(langId)
    langId = langId or LangDFlagDefult
    local isNormal = self:GetDeviceLanguage() == langId
    local capIdTable = cache.getIsSetLanguage() or {}
    if needFisrtLoginOpen and not capIdTable["default"] then
        capIdTable = type(capIdTable) ~= "table" and {} or capIdTable
        capIdTable["default"] = "true"-- 记录标记-本地已设置过语言
        cache.setIsSetLanguage(clone(capIdTable))
    end
    return isNormal
end

function SettingsLanguageModel:GetDeviceLanguage()
    self.oldDFlag = LangDFlagDefult
    local flags = self:GetDistributeFlags()
    for k,v in pairs(LangDFlagMap) do
        local isInTable = self:IdIsInTable(flags, v)
        if isInTable then
            self.oldDFlag = k
            break
        end
    end
    return self.oldDFlag
end

function SettingsLanguageModel:GetDistributeFlags()
    if not self._mdflags then
        self._mdflags = clr.table(clr.Capstones.UnityFramework.ResManager.GetDistributeFlags())
    end
    return self._mdflags
end

function SettingsLanguageModel:GetLang2Server(langId)
    return LangId2Server[langId] or LangId2Server[LangDFlagDefult]
end

function SettingsLanguageModel:IdIsInTable(flags, langFlag)
    if not (flags and langFlag) then
        return false
    end
    for _,v in pairs(flags) do
        if v == langFlag then
            return true
        end
    end
    return false
end

function SettingsLanguageModel:IsFirstLogin()
    if not needFisrtLoginOpen then
        return false
    end
    local capIdTable = cache.getIsSetLanguage()
    return not capIdTable or type(capIdTable) ~= "table" -- 本地没有语言记录时视为第一次登录
end

local LocalMap = {["cn"] = 1, ["sgp"] = 2, ["th"] = 3}
function SettingsLanguageModel:GetNormalText(inputStr, langId)
    local str = string.split(inputStr or "", '|')
    return str[LocalMap[langId] or 1]
end

return SettingsLanguageModel
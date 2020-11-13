local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local PlayerLevel = require("data.PlayerLevel")
local levelUpData = class(unity.base)

function levelUpData:ctor()
    self.lvl = self.___ex.lvl
    self.prelvl = self.___ex.prelvl
    self.presp = self.___ex.presp
    self.befLvl = self.___ex.befLvl
	self.aftLvl = self.___ex.aftLvl
    self.aftsp = self.___ex.aftsp
    self.befNum = self.___ex.befNum
    self.aftNum = self.___ex.aftNum
end

function levelUpData:start()
end

function levelUpData:initData(data)
    if type(data) == "table" then
        self.lvl:GetComponent(Text).text = data.lvl
        self.prelvl:GetComponent(Text).text = data.prelvl
        self.presp:GetComponent(Text).text = tostring(data.presp)
        self.aftsp:GetComponent(Text).text = tostring(data.sp)

        if tonumber(data.lvl) <= 20 then
            self.befLvl.transform.parent.gameObject:SetActive(false)
        else
            self.befLvl:GetComponent(Text).text = PlayerLevel[tostring(data.prelvl)].memberLevel
            self.aftLvl:GetComponent(Text).text = PlayerLevel[tostring(data.lvl)].memberLevel
        end

        if tonumber(data.lvl) <= 50 then
            self.befNum:GetComponent(Text).text = tostring((tonumber(data.prelvl) - 1) * 2 + 100) 
            self.aftNum:GetComponent(Text).text = tostring((tonumber(data.lvl) - 1) * 2 + 100) 
        else
            self.befNum.transform.parent.gameObject:SetActive(false)
        end
    end
end

function levelUpData:onDestroy()

    --新手引导-升级面板销毁后显示下一步
    local baseInfo = cache.getPlayerInfo()
    if baseInfo then
        if tonumber(baseInfo.gphase) > 0 then
            require('ui.scene.guide.GuideManager').ShowGuide(46)
        end
    end

    local eventNotice = cache.getGlobalTempData("eventNotice2")
    if type(eventNotice) == 'table' then
        for k, v in ipairs(eventNotice) do
            if k == 1 then
                local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Common/Global/GlobalPrefabs/FunctionUnlock.prefab", "overlay", true, true)
                dialogcomp.contentcomp:initData(v)
            else
                local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Common/Global/GlobalPrefabs/FunctionUnlock.prefab", "overlay", true, false)
                dialogcomp.contentcomp:initData(v)
            end
        end
        cache.removeGlobalTempData("eventNotice2")
    end
    
    local eventNotice = cache.getGlobalTempData("eventNotice1")
    if type(eventNotice) == 'table' then
        for k, v in ipairs(eventNotice) do
            if k == 1 then
                local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Common/Global/GlobalPrefabs/FunctionUnlock.prefab", "overlay", true, true)
                dialogcomp.contentcomp:initData(v)
            else
                local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Common/Global/GlobalPrefabs/FunctionUnlock.prefab", "overlay", true, false)
                dialogcomp.contentcomp:initData(v)
            end
        end
        cache.removeGlobalTempData("eventNotice1")
    end
end


return levelUpData

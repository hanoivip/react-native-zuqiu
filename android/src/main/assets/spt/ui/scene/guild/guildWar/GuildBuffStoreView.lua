local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local GuildBuffStoreView = class(unity.base)

function GuildBuffStoreView:ctor()
    self.buffScrollRect = self.___ex.buffScrollRect
    self.closeBtn = self.___ex.closeBtn
    self.titleTxt = self.___ex.titleTxt
    self.guildTxt = self.___ex.guildTxt
    self.contributeTxt = self.___ex.contributeTxt

    DialogAnimation.Appear(self.transform, nil)
end

function GuildBuffStoreView:InitView(model, isAttackBuff, nextRound, buffInfo)
    self:InitScrollView(model, isAttackBuff, nextRound, buffInfo)
    self:RegOnBtn()
    self.titleTxt.text = lang.trans("guildwar_store_title", tostring(model:GetPeriod()), tostring(nextRound or model:GetRound()))
    self.contributeTxt.text = lang.trans("guild_contribute", model:GetCumulativeTotal())
end

function GuildBuffStoreView:InitScrollView(model, isAttackPage, nextRound, buffInfo)
    local scrolItemData = model:GetBuffDatas()
    model:SetBuffInfo(buffInfo)
    local buffInfoOrder = model:ResetBuffInfoOrder()
    self.buffScrollRect:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Guild/Prefab/GuildBuffStoreItem.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)

    self.buffScrollRect:regOnResetItem(function (scrollSelf, spt, index)
        local data = scrollSelf.itemDatas[index]
        spt:Init(data, model, nextRound, buffInfoOrder)
        spt.onBuyBuffBtnClick = function ()
            if isAttackPage and data.type == "def" then
                DialogManager.ShowToast(lang.trans("guild_buff_store"))
                return
            end

            if not isAttackPage and data.type == "atk" then
                DialogManager.ShowToast(lang.trans("guild_buff_store_1"))
                return
            end

            self:coroutine(function ()
                local response = req.buyBuff(tonumber(nextRound or model:GetRound()), data.key)
                if api.success(response) then
                    local infoData = response.val
                    GameObjectHelper.FastSetActive(spt.bought, true)
                    spt.animator:Play("GuildBuffStoreItemBoughtAnimation")
                    -- 更新model里的数据
                    model:SetBuff(isAttackPage, infoData.defBuff or infoData.atkBuff)
                    model:SetCumulativeTotal(infoData.cumulativeDay)
                    self.contributeTxt.text = lang.trans("guild_contribute", model:GetCumulativeTotal())
                    local buyBuffInfoOrder = model:ResetBuffInfoOrder(infoData)
                    EventSystem.SendEvent("GuildBuffStoreItem_RefreshBuy", buyBuffInfoOrder)
                end
            end)
        end
        scrollSelf:updateItemIndex(spt, index)
    end)

    self.buffScrollRect:refresh(scrolItemData)
end

function GuildBuffStoreView:RegOnBtn()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function GuildBuffStoreView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return GuildBuffStoreView

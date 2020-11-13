local FancyTeamView = class(unity.base)

function FancyTeamView:ctor()
--------Start_Auto_Generate--------
    self.teamIconImg = self.___ex.teamIconImg
    self.teamGroupNameTxt = self.___ex.teamGroupNameTxt
    self.scrollViewSpt = self.___ex.scrollViewSpt
    self.backBtn = self.___ex.backBtn
--------End_Auto_Generate----------
    self.scrollRect = self.___ex.scrollRect
end

function FancyTeamView:start()
    self:BindButtonHandler()
end

function FancyTeamView:BindButtonHandler()
    -- 返回
    self.backBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function FancyTeamView:InitView(fancyTeamModel)
    self.model = fancyTeamModel
    local groupName = self.model:GetGroupName()
    local groupIcon = self.model:GetGroupIcon()

    self.teamGroupNameTxt.text = groupName
    local imgPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/Common/FancyGroupIcon/%s.png"
    local imgRes = res.LoadRes(string.format(imgPath, groupIcon))
    self.teamIconImg.overrideSprite = imgRes
    self:InitGroupTeam()
end

function FancyTeamView:InitGroupTeam()
    local groupList = self.model:GetGroupList()
    self.scrollViewSpt:InitView(groupList, self.scrollRect, self.model.temporaryNew)
end

function FancyTeamView:FancyUpStar()
    for i, v in ipairs(self.scrollViewSpt.itemDatas) do
        local view = self.scrollViewSpt:getItem(i)
        if view then
            view:Refresh()
        end
    end
end

function FancyTeamView:Close()
    res.PopScene()
end

function FancyTeamView:EnterScene()
    EventSystem.AddEvent("FancyUpStar", self, self.FancyUpStar)
end

function FancyTeamView:ExitScene()
    EventSystem.RemoveEvent("FancyUpStar", self, self.FancyUpStar)
end

return FancyTeamView

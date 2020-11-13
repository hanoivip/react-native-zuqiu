local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionDialogConfirmModel = class(BaseModel, "ItemActionDialogConfirmModel")

local paramsKey = {
    title = "title", -- 提示的标题
    msg = "msg", -- 提示的主要内容
    rep = "{[%d]+}", -- 替换匹配内容
}

-- 替换内容
local paramsVar = {
    name = "_name", --物品名称
    num = "_num", --物品当前数量
    cycle = "_cycle", --当前周期
    cycleLeft = "_cycleLeft" --剩余周期
}

-- 绿茵征途使用道具，弹出对话框行为model
function ItemActionDialogConfirmModel:Init(id, greenswardItemModel, greenswardBuildModel)
    ItemActionDialogConfirmModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
end

-- 解析配置对话框参数
function ItemActionDialogConfirmModel:ParseConfig(config)
    local actionParam = config.actionParam
    if not actionParam then return config end

    local title = actionParam[paramsKey.title] or lang.transstr("tips")
    local msg = actionParam[paramsKey.msg] or ""
    if msg then
        for k, v in pairs(actionParam) do
            if type(k) == "string" then
                if string.find(k, paramsKey.rep) then
                    if v == paramsVar.name then
                        msg = string.gsub(msg, k, self.itemModel:GetName())
                    elseif v == paramsVar.num then
                        msg = string.gsub(msg, k, self.itemModel:GetOwnNum())
                    elseif v == paramsVar.cycle then
                        msg = string.gsub(msg, k, self.buildModel:GetCurrRound())
                    elseif v == paramsVar.cycleLeft then
                        msg = string.gsub(msg, k, self.buildModel:GetRoundLeft())
                    else
                        -- add other
                    end
                end
            end
        end
    end
    self.title = title
    self.msg = msg
    return config
end

-- 获得当前道具行为的加工后参数
function ItemActionDialogConfirmModel:GetActionCookedParam()
    return self:GetTitle(), self:GetMsg()
end

-- 获得对话框标题
function ItemActionDialogConfirmModel:GetTitle()
    return self.title
end

-- 获得对话框提示内容
function ItemActionDialogConfirmModel:GetMsg()
    return self.msg
end

return ItemActionDialogConfirmModel

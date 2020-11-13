local BaseModel = require("ui.models.greensward.item.itemAction.GreenswardItemActionBaseModel")

local ItemActionGlassesModel = class(BaseModel, "ItemActionGlassesModel")

local paramsKey = {
    title = "title", -- 提示的标题
    msg = "msg", -- 提示的主要内容
    rep = "{[%d]+}", -- 替换匹配内容
    size = "size", -- 照明弹大小
    title_over = "title_over", -- 结束时提示标题
    msg_over = "msg_over" -- 结束时提示标题
}

-- 替换内容
local paramsVar = {
    name = "_name", --物品名称
}

-- 绿茵征途使用道具，使用透视镜行为model
function ItemActionGlassesModel:Init(id, greenswardItemModel, greenswardBuildModel, flashBang)
    ItemActionGlassesModel.super.Init(self, id, greenswardItemModel, greenswardBuildModel)
end

-- 解析配置对话框参数
function ItemActionGlassesModel:ParseConfig(config)
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
                    else
                        -- add other
                    end
                end
            end
        end
    end
    self.size = tonumber(actionParam[paramsKey.size]) or 3
    self.title = title
    self.msg = msg
    self.title_over = actionParam[paramsKey.title_over]
    self.msg_over = actionParam[paramsKey.msg_over]
    return config
end

-- 获得对话框标题
function ItemActionGlassesModel:GetTitle()
    return self.title
end

-- 获得对话框提示内容
function ItemActionGlassesModel:GetMsg()
    return self.msg
end

-- 获得对话框标题
function ItemActionGlassesModel:GetTitleOver()
    return self.title_over
end

-- 获得对话框提示内容
function ItemActionGlassesModel:GetMsgOver()
    return self.msg_over
end

-- 获得照明弹大小
function ItemActionGlassesModel:GetSize()
    return self.size
end

return ItemActionGlassesModel

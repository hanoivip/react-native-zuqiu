local RollRingData = class()

function RollRingData:ctor(positionX, positionY, scale, alpha, order, object)
    self.positionX = 0 -- 横坐标
    self.positionY = 0 -- 纵坐标
    self.scale = 1 -- 缩放
    self.alpha = 1 -- 透明
    self.internalId = 1 -- 内部索引
    self.externalId = -1 -- 外部索引
    self.order = 1 -- 深度
    self.object = nil -- 对象
    self.script = nil
    self:InitData(positionX, positionY, scale, alpha, order,  object)
end

function RollRingData:InitData(positionX, positionY, scale, alpha, order, object)
    self.positionX = positionX
    self.positionY = positionY
    self.scale = scale
    self.alpha = alpha
    self.order = order
    self.object = object
    self.script = object:GetComponent(clr.CapsUnityLuaBehav)
end

return RollRingData

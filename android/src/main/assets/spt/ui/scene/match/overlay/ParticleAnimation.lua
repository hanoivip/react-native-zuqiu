local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ParticleSystem = UnityEngine.ParticleSystem
local Renderer = UnityEngine.Renderer

local ParticleAnimation = class(unity.base)

function ParticleAnimation:ctor()
    self.lastTime = Time.unscaledTime
    self.particleList = { }
end

function ParticleAnimation:start()
    self.lastTime = Time.unscaledTime
    self:RecursionChild(self.transform)
end

function ParticleAnimation:RecursionChild(transf)
    if transf.childCount > 0 then
        for i = 1, transf.childCount do
            local transfChild = transf:GetChild(i - 1)
            local particleSystem = transfChild:GetComponent(ParticleSystem)
            if particleSystem and particleSystem ~= clr.null then
                table.insert(self.particleList, particleSystem)
            end
            self:RecursionChild(transfChild)
        end
    end
end
	
function ParticleAnimation:update()
    local deltaTime = Time.unscaledTime - self.lastTime
    if #self.particleList > 0 then 
        for k, v in pairs(self.particleList) do
            v:Simulate(deltaTime, true, false)
        end
    end
    self.lastTime = Time.unscaledTime
end

return ParticleAnimation

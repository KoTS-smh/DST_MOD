local PYFLY = Class(function(self, inst)
    self.inst = inst
    self.height = 1
end)

-- 生成云特效，并设置成跟随人物移动
local function spawncloud(self, inst)
    if inst._pycloud == nil then
        inst:DoTaskInTime(0.1, function(inst)
            inst._pycloud = SpawnPrefab("fly_cloud")
            inst._pycloud.entity:AddFollower()
            inst._pycloud.entity:SetParent(self.inst.entity)
        end)
    end
end

-- 移除云特效
local function removecloud(self, inst)
    if inst._pycloud ~= nil then
        inst:DoTaskInTime(0.1, function(inst)
            inst._pycloud:Remove()
            inst._pycloud = nil
        end)
    end
end

-- 获取飞行的设定高度
function PYFLY:GetHeight()
    return self.height
end

-- 起飞
function PYFLY:Fly()
    if not (self.inst.replica.rider ~= nil and self.inst.replica.rider:IsRiding()) --骑牛时不能飞
            and self.inst:HasTag("player") --必须要是玩家
            and not self.inst:HasTag("playerghost") then --不能是鬼魂状态
        -- 添加一个标签，用于判断动作名以及其它用处
        self.inst:AddTag("pyflying")
        -- 生成一个云在脚下
        spawncloud(self, self.inst)
        -- 飞起来后就移除碰撞体积
        if self.inst.Physics then
            RemovePhysicsColliders(self.inst)
        end
        -- 给移动组件上挂一个变量，用于hook移动组件时给人物维持在飞行高度上移动
        if self.inst.components.locomotor then
            self.inst.components.locomotor.pyfly_height_override = self.height
        end
        -- 落水组件置为失效
        if self.inst.components.drownable then
            self.inst.components.drownable.enabled = false
        end
        -- 开始刷帧
        self.inst:StartUpdatingComponent(self)
        return true
    else
        return false
    end
end

-- 着陆
function PYFLY:Land()
    local x, y, z = self.inst.Transform:GetWorldPosition()
    local tile = TheWorld.Map:GetTileAtPoint(x, y, z)
    print(tile)
    if not (tile == GROUND.IMPASSABLE or tile == GROUND.INVALID or (tile >= GROUND.OCEAN_START and tile <= GROUND.OCEAN_END)) then
        -- 移除飞行标签
        self.inst:RemoveTag("pyflying")
        -- 移除云特效
        removecloud(self, self.inst)
        -- 将人物的碰撞体积加回来
        if self.inst.Physics then
            ChangeToCharacterPhysics(self.inst)
        end
        -- 将人物的移动组件上的高度设置为0，这样从物在行走时就是贴地的了
        if self.inst.components.locomotor then
            self.inst.components.locomotor.pyfly_height_override = 0
        end
        -- 将落水组件置为生效
        if self.inst.components.drownable then
            self.inst.components.drownable.enabled = true
        end
        -- 停止刷帧
        self.inst:StopUpdatingComponent(self)
        self.inst.Transform:SetPosition(x,0,z)
        return true
    else
        return false
    end
end

-- 刷帧
function PYFLY:OnUpdate(dt)
    if self.inst.Physics then
        -- 获取到玩家的三个方向的速度
        local x,y,z = self.inst.Physics:GetMotorVel()
        -- 获取到玩家的位置
        local pt = self.inst:GetPosition()
        --[[
            一帧是1/30秒，这里乘的是32，应该是神话里经过不断调试出来的一个最优解，我就直接拿来用了，感谢神话的作者
            self.height - pt.y 正常人物的y轴一直是0，这里减与不减是一样的，但鬼知道有没有什么特殊情况下y轴坐标不是0的，所以这里为了维持飞行的高度不变，还是减了一下人物的高度，神话代码的严谨性，赞！！
        ]]
        self.inst.Physics:SetMotorVel(x, (self.height - pt.y) * 32, z)
    end
end

return PYFLY
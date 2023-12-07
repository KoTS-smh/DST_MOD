-- mod载入的Prefab，Prefab是最基础的元素，除了操作面板和地图外，所有的一切，包括食物、人物、动物、植物、水池、矿石乃至于特效等等，都是Prefab
-- prefab都放在mod根目录/scripts/prefabs下
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

PrefabFiles = {
    -- "strawberry_plant",
    "fly_cloud",
    "heart_fx",
}

Assets = {}

AddPlayerPostInit(function(inst)
    if not TheWorld.ismastersim then return inst end
    inst:AddComponent("fly")
    local fx = SpawnPrefab("heart_fx") -- 生成一个特效
    fx.entity:SetParent(inst.entity) -- 设置成跟随玩家
end)

local function FlyController()
    local player = ThePlayer
    if not player:HasTag("pyflying") then
        player.components.fly:Fly()
    elseif player:HasTag("pyflying") then
        player.components.fly:Land()
    end
end

local function SummonRabbit()
    local player = ThePlayer
    if player.rabbit_friend == nil then
        player.rabbit_friend = SpawnPrefab("rabbit")
        player.rabbit_friend:AddComponent("follower")
        player.rabbit_friend.Transform:SetPosition(player.Transform:GetWorldPosition())
        player.rabbit_friend.components.follower:SetLeader(player)
        player.rabbit_friend.components.follower.targetDist = 1.5
    end
end

TheInput:AddKeyDownHandler(KEY_F, FlyController)
TheInput:AddKeyDownHandler(KEY_G, SummonRabbit)

AddComponentPostInit("locomotor",function(self)
    self.pyfly_height_override = 0

    local oldRunForward=self.RunForward
    function self:RunForward(direct, ...)
        oldRunForward(self, direct, ...)
        if self.pyfly_height_override ~= 0 then
            local a,b,c = self.inst.Physics:GetMotorVel()
            local y = self.inst:GetPosition().y
            -- 起飞时设置的飞行高度
            local h = self.inst.components.fly and self.inst.components.fly:GetHeight()
            if y and h then
                self.inst.Physics:SetMotorVel(a, (h-y)*32, c)
            end
        end
    end
end)

local function runfnhook(self)
    local run = self.states.run
    if run then
        local old_enter = run.onenter
        function run.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("pyflying") then
                -- 我没做飞行状态的动画，就用的idle
                if not inst.AnimState:IsCurrentAnimation("idle_loop") then
                    inst.AnimState:PlayAnimation("idle_loop", true)
                end
                inst.sg:SetTimeout(inst.AnimState:GetCurrentAnimationLength() + 0.01)
            end
        end
    end

    local run_start = self.states.run_start
    if run_start then
        local old_enter = run_start.onenter
        function run_start.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("pyflying") then
                inst.AnimState:PlayAnimation("idle_loop")
            end
        end
    end

    local run_stop = self.states.run_stop
    if run_stop then
        local old_enter = run_stop.onenter
        function run_stop.onenter(inst, ...)
            if old_enter then
                old_enter(inst, ...)
            end
            if inst:HasTag("pyflying") then
                inst.AnimState:PlayAnimation("idle_loop")
            end
        end
    end
end

AddStategraphPostInit("wilson", runfnhook)
AddStategraphPostInit("wilson_client", runfnhook)

local require = GLOBAL.require
local STRINGS = GLOBAL.STRINGS

-- STRINGS.NAMES.STRAWBERRY_PLANT = "草莓" -- 物体在游戏中显示的名字
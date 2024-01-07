-- mod载入的Prefab，Prefab是最基础的元素，除了操作面板和地图外，所有的一切，包括食物、人物、动物、植物、水池、矿石乃至于特效等等，都是Prefab
-- prefab都放在mod根目录/scripts/prefabs下
GLOBAL.setmetatable(env,{__index=function(t,k) return GLOBAL.rawget(GLOBAL,k) end})

PrefabFiles = {
    -- "strawberry_plant",
    "fly_cloud",
    "heart_fx",
    "nipo",  --人物代码文件
    "nipo_none",  --人物皮肤
}
  
Assets = {
    Asset( "IMAGE", "images/saveslot_portraits/nipo.tex" ), --存档图片
    Asset( "ATLAS", "images/saveslot_portraits/nipo.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/nipo.tex" ), --单机选人界面
    Asset( "ATLAS", "images/selectscreen_portraits/nipo.xml" ),

    Asset( "IMAGE", "images/selectscreen_portraits/nipo_silho.tex" ), --单机未解锁界面
    Asset( "ATLAS", "images/selectscreen_portraits/nipo_silho.xml" ),

    Asset( "IMAGE", "bigportraits/nipo.tex" ), --人物大图（方形的那个）
    Asset( "ATLAS", "bigportraits/nipo.xml" ),

    Asset( "IMAGE", "images/map_icons/nipo.tex" ), --小地图
    Asset( "ATLAS", "images/map_icons/nipo.xml" ),

    Asset( "IMAGE", "images/avatars/avatar_nipo.tex" ), --tab键人物列表显示的头像
    Asset( "ATLAS", "images/avatars/avatar_nipo.xml" ),

    Asset( "IMAGE", "images/avatars/avatar_ghost_nipo.tex" ),--tab键人物列表显示的头像（死亡）
    Asset( "ATLAS", "images/avatars/avatar_ghost_nipo.xml" ),

    Asset( "IMAGE", "images/avatars/self_inspect_nipo.tex" ), --人物检查按钮的图片
    Asset( "ATLAS", "images/avatars/self_inspect_nipo.xml" ),

    Asset( "IMAGE", "images/names_nipo.tex" ),  --人物名字
    Asset( "ATLAS", "images/names_nipo.xml" ),

    Asset( "IMAGE", "bigportraits/nipo_none.tex" ),  --人物大图（椭圆的那个）
    Asset( "ATLAS", "bigportraits/nipo_none.xml" ),

    --[[---注意事项
    1、目前官方自从熔炉之后人物的界面显示用的都是那个椭圆的图
    2、官方人物目前的图片跟名字是分开的 
    3、names_nipo 和 nipo_none 这两个文件需要特别注意！！！
    这两文件每一次重新转换之后！需要到对应的xml里面改对应的名字 否则游戏里面无法显示
    具体为：
    降names_nipo.xml 里面的 Element name="nipo.tex" （也就是去掉names——）
    将nipo_none.xml 里面的 Element name="nipo_none_oval" 也就是后面要加  _oval
    （注意看修改的名字！不是两个都需要修改）
        ]]
}

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

GLOBAL.PREFAB_SKINS["nipo"] = {   --修复人物大图显示
    "nipo_none",
}

-- The character select screen lines  --人物选人界面的描述
STRINGS.CHARACTER_TITLES.nipo = "玲宮にぽ"
STRINGS.CHARACTER_NAMES.nipo = "Nipo"
STRINGS.CHARACTER_DESCRIPTIONS.nipo = "*Vtuber\n*優しくて可愛い\n*うさぎといちごが好きです"
STRINGS.CHARACTER_QUOTES.nipo = "\"可愛くてごめん\""

-- The character's name as appears in-game  --人物在游戏里面的名字
STRINGS.NAMES.nipo = "Nipo"
STRINGS.SKIN_NAMES.nipo_none = "Nipo"  --检查界面显示的名字

AddMinimapAtlas("images/map_icons/nipo.xml")  --增加小地图图标

--增加人物到mod人物列表的里面 性别为女性（MALE, FEMALE, ROBOT, NEUTRAL, and PLURAL）
AddModCharacter("nipo", "FEMALE")

--选人界面人物三维显示
TUNING.NIPO_HEALTH = 200
TUNING.NIPO_HUNGER = 200
TUNING.NIPO_SANITY = 200

--生存几率
STRINGS.CHARACTER_SURVIVABILITY.nipo = "簡単"

--选人界面初始物品显示
TUNING.GAMEMODE_STARTING_ITEMS.DEFAULT.NIPO = {"spear"}

-- STRINGS.NAMES.STRAWBERRY_PLANT = "草莓" -- 物体在游戏中显示的名字
local assets =
{
    Asset("ANIM", "anim/strawberry_plant.zip")
}

local function OnSave(inst, data)
    data.was_herd = inst.components.herdmember and true or nil
end

local function OnPreLoad(inst, data)
    if data and data.was_herd then
        if TheWorld.components.lunarthrall_plantspawner then
            TheWorld.components.lunarthrall_plantspawner:setHerdsOnPlantable(inst)
        end
    end
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddMiniMapEntity()
    inst.entity:AddNetwork()

    MakeSmallObstaclePhysics(inst, .1)

    inst:AddTag("bush")
    inst:AddTag("plant")
    inst:AddTag("renewable")
    inst:AddTag("lunarplant_target")

    --witherable (from witherable component) added to pristine state for optimization
    inst:AddTag("witherable")

    local is_quagmire = (TheNet:GetServerGameMode() == "quagmire")
    if is_quagmire then
        -- for stats tracking
        inst:AddTag("quagmire_wildplant")
    end

    inst.AnimState:SetBank("strawberry_plant") -- 地上动画
    inst.AnimState:SetBuild("strawberry_plant") -- 材质包，就是anim里的zip包
    inst.AnimState:PlayAnimation("idle", true) -- 默认播放哪个动画 第二个参数是true表示重复播放

    MakeSnowCoveredPristine(inst)

    inst.scrapbook_specialinfo = "NEEDFERTILIZER"

    inst.entity:SetPristine()
    if not TheWorld.ismastersim then
        return inst
    end

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    return inst
end


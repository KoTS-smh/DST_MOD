local assets=
{
    Asset("ANIM", "anim/rabbit_cloud.zip"),
}

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddNetwork()
    inst.entity:AddSoundEmitter()
    inst.entity:AddPhysics()

    inst.AnimState:SetBank("rabbit_cloud")
    inst.AnimState:SetBuild("rabbit_cloud")
    inst.AnimState:PlayAnimation("idle")

    inst:AddTag("FX")

    if not TheWorld.ismastersim then return inst end

    return inst
end

return Prefab("fly_cloud", fn, assets)
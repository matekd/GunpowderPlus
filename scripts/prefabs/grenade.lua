local assets = {
    Asset("ANIM", "anim/grenade.zip"),
    Asset("ANIM", "anim/swap_grenade.zip"),
    Asset("ATLAS", "images/inventoryimages/grenade.xml"),
    Asset("IMAGE", "images/inventoryimages/grenade.tex")
}

local prefabs = {
    "explode_small"
}

local function onhit(inst, attacker, target)
    
    inst.AnimState:PlayAnimation("idle")

    -- time in secounds, function() "my code" end)
    --inst:DoTaskInTime(0.5, function()
    inst:DoTaskInTime(1, function()
        inst.SoundEmitter:KillSound("hiss")
        inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

        -- Explosion effect
        local explode = SpawnPrefab("explode_small")
        local pos = inst:GetPosition() 
        explode.Transform:SetPosition(pos.x, pos.y, pos.z)

        -- maybe add animation of fragments
    
        -- Triggers instant explosion, causes fire
        -- Change OnBurnt() in explosive component to avoid fire
        inst.components.explosive:OnBurnt()
        -- Removes the grenade
        inst:Remove()
    end)    
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_grenade", "swap_grenade")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function onthrown(inst, data)
    inst.AnimState:PlayAnimation("spin_loop", true)
end

local function fn()

    local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    anim:SetBank("grenade")
    anim:SetBuild("grenade")
    anim:PlayAnimation("idle")

    inst:AddTag("projectile")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10) -- min range, something else

    inst:AddComponent("explosive")
    --inst.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE -- 200
    inst.components.explosive.explosivedamage = 100
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnHitFn(onhit)
	inst.components.projectile:SetOnMissFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.imagename = "grenade"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/grenade.xml"

    return inst
end

return Prefab("common/inventory/grenade", fn, assets, prefabs)
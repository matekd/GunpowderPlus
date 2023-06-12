local assets = {
    Asset("ANIM", "anim/beenade.zip"),
    Asset("ANIM", "anim/swap_beenade.zip"),
    Asset("ATLAS", "images/inventoryimages/beenade.xml"),
    Asset("IMAGE", "images/inventoryimages/beenade.tex")
}

local prefabs = {
    --"explode_small",
    "bee"
}

local function onhit(inst, attacker, target)
    
    inst.AnimState:PlayAnimation("idle")
    --inst.AnimState:PlayAnimation("explode")

    inst:DoTaskInTime(1, function()

        inst.SoundEmitter:KillSound("hiss")
        inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_explo")

        -- Spawn bee
        --local bee = SpawnPrefab("bee")
        --local pos = inst:GetPosition() -- position where greande landed
        --bee.Transform:SetPosition(pos.x, pos.y, pos.z)

        if target and target:IsValid() then
            for i = 1, TUNING.BEEMINE_BEES do -- 4
                local bee = SpawnPrefab("bee")
                local pos = Vector3(inst.Transform:GetWorldPosition() )
                local dist = math.random()
                local angle = math.random()*2*PI
                pos.x = pos.x + dist*math.cos(angle)
                pos.z = pos.z + dist*math.sin(angle)
                bee.Physics:Teleport(pos:Get())
                -- Make bee attack the target
                if bee.components.combat then
                    bee.components.combat:SetTarget(target)
                end
            end
            target:PushEvent("coveredinbees")
        end
    end)
    --inst:ListenForEvent("animover", inst.Remove)
    inst:Remove()
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_beenade", "swap_beenade")
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

    anim:SetBank("beenade")
    anim:SetBuild("beenade")
    anim:PlayAnimation("idle")

    inst:AddTag("projectile")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    
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
    inst.components.inventoryitem.imagename = "beenade"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/beenade.xml"

    return inst
end

return Prefab("common/inventory/beenade", fn, assets, prefabs)
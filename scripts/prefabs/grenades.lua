local assets = {
    Asset("ANIM", "anim/grenades.zip"),
    Asset("ANIM", "anim/swap_grenade.zip"),
    Asset("ANIM", "anim/swap_beenade.zip"),
    Asset("ATLAS", "images/inventoryimages/grenade.xml"),
    Asset("IMAGE", "images/inventoryimages/grenade.tex"),
    Asset("ATLAS", "images/inventoryimages/beenade.xml"),
    Asset("IMAGE", "images/inventoryimages/beenade.tex")
}

local prefabs = {
    "bee",
    "explode_small"
}

--- Grenade ---

local function onhit_grenade(inst, attacker, target)
    
    inst.AnimState:PlayAnimation("grenade")

    inst:DoTaskInTime(1, function()
        inst.SoundEmitter:KillSound("hiss")
        inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")

        local explode = SpawnPrefab("explode_small")
        local pos = inst:GetPosition() 
        explode.Transform:SetPosition(pos.x, pos.y, pos.z)

        inst.components.explosive:OnBurnt()
        inst:Remove()
    end)    
end

--- Beenade ---

local function onhit_beenade(inst, attacker, target)
    
    inst.AnimState:PlayAnimation("beenade")

    inst:DoTaskInTime(1, function()
        inst.SoundEmitter:KillSound("hiss")
        inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_explo")
        -- Spawn bee(s)
        if target and target:IsValid() then
            for i = 1, TUNING.BEEMINE_BEES do -- 4
                local bee = SpawnPrefab("bee")
                local pos = Vector3(inst.Transform:GetWorldPosition() )
                local dist = math.random() -- between 0.0 and 1.0
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
        inst:Remove()
    end)
end

--- Common functions ---

local function commonfn(type) 

    local function OnEquip(inst, owner) -- swap_object, anim build, anim name (?)
        owner.AnimState:OverrideSymbol("swap_object", "swap_"..type, "swap_"..type) -- swap_beenade etc.
        owner.AnimState:Show("ARM_carry")
        owner.AnimState:Hide("ARM_normal")
    end
    
    local function OnUnequip(inst, owner)
        owner.AnimState:Hide("ARM_carry")
        owner.AnimState:Show("ARM_normal")
    end
    
    local function onthrown(inst, data)
        inst.AnimState:PlayAnimation("spinloop_"..type, true)
    end
    
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    anim:SetBank("grenades")
    anim:SetBuild("grenades")
    anim:PlayAnimation(type)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(1) -- 1 damage to agro enemy
    inst.components.weapon:SetRange(8, 10) -- "attack range" (max range), "hit range"
    
    inst:AddTag("projectile")
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst:ListenForEvent("onthrown", onthrown)

    inst:AddComponent("inspectable")

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    return inst
end

--- Type specific constructors ---

local function grenade()
    local inst = commonfn("grenade")

    inst:AddComponent("explosive")
    inst.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE -- 200

    inst.components.projectile:SetOnHitFn(onhit_grenade)
    inst.components.projectile:SetOnMissFn(onhit_grenade)
    
    inst.components.inventoryitem.imagename = "grenade"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/grenade.xml"

    return inst
end

local function beenade()
    local inst = commonfn("beenade")

    inst.components.projectile:SetOnHitFn(onhit_beenade)
    inst.components.projectile:SetOnMissFn(onhit_beenade)

    inst.components.inventoryitem.imagename = "beenade"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/beenade.xml"

    return inst
end

return Prefab("common/inventory/grenade", grenade, assets, prefabs),
    Prefab("common/inventory/beenade", beenade, assets, prefabs)
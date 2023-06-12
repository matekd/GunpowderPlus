local assets = {
	Asset("ANIM", "anim/minemine.zip"),
    Asset("ATLAS", "images/inventoryimages/minemine.xml"),
    Asset("IMAGE", "images/inventoryimages/minemine.tex")
}

local prefabs = {
    "explode_small"
}

local function OnExplode(inst)
    --inst.AnimState:PlayAnimation("explode")
    --inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_launch")
	--inst.persists = false
	--inst:ListenForEvent("animover", inst.Remove)
	--inst:ListenForEvent("entitysleep", inst.Remove)

	inst:DoTaskInTime(1, function()
		-- Explosion effect
		local explode = SpawnPrefab("explode_small")
		local pos = inst:GetPosition() 
		explode.Transform:SetPosition(pos.x, pos.y, pos.z)

		print("Boom")
		inst:Remove()
	end)
end

--[[local function onhammered(inst, worker)
	if inst.components.mine then
	    inst.components.mine:Explode(worker)
	end
end]]

--[[local function MineRattle(inst)
    --inst.AnimState:PlayAnimation("hit")
    inst.AnimState:PushAnimation("idle")
    --inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_rattle")
    inst.rattletask = inst:DoTaskInTime(4 + math.random(), MineRattle)
end]]

--[[local function StartRattling(inst)
    inst.rattletask = inst:DoTaskInTime(1, MineRattle)
end]]

--[[local function StopRattling(inst)
    if inst.rattletask then
        inst.rattletask:Cancel()
        inst.rattletask = nil
    end
end]]

local function SetInactive(inst)
	--inst.AnimState:PlayAnimation("inactive")
	--StopRattling(inst)
	inst.AnimState:PlayAnimation("idle") -- inactive can be same as idle
end

local function OnDropped(inst)
	if inst.components.mine then
		inst.components.mine:Deactivate()
	end
	print("Dropped")
end

local function ondeploy(inst, pt, deployer)
	inst.components.mine:Reset()
	inst.Physics:Teleport(pt:Get())
	--StartRattling(inst)
end

local function fn()
	
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)
	
	--local minimap = inst.entity:AddMiniMapEntity()
	--minimap:SetIcon( "beemine.png" )
	
	anim:SetBank("minemine")
	anim:SetBuild("minemine")
	anim:PlayAnimation("idle")
	
	inst:AddTag("mine")
	inst:AddComponent("mine")
	inst.components.mine:SetOnExplodeFn(OnExplode)
	inst.components.mine:SetAlignment("player") -- "nobody"
	inst.components.mine:SetRadius(1) -- check, TUNING.BEEMINE_RADIUS
	inst.components.mine:SetOnDeactivateFn(SetInactive)
	
	--inst.components.mine:StartTesting()
	--inst.beeprefab = spawnprefab -- thing it spawns, used later
	
	inst:AddComponent("inspectable")
	--inst:AddComponent("lootdropper")
	--[[inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(1)
	inst.components.workable:SetOnFinishCallback(onhammered)]]

	inst:AddComponent("inventoryitem")
	-- ?
	inst.components.inventoryitem.nobounce = true
	--inst.components.inventoryitem:SetOnPutInInventoryFn(StopRattling)
	--inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem.imagename = "minemine"
    inst.components.inventoryitem.atlasname = "images/inventoryimages/minemine.xml"
	
	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = ondeploy
	inst.components.deployable.min_spacing = .75
	return inst
end

return Prefab("common/inventory/minemine", fn, assets, prefabs), 
	MakePlacer("common/minemine_placer", "minemine", "minemine", "idle")
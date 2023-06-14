local assets = {
	Asset("ANIM", "anim/minemine.zip"),
    Asset("ATLAS", "images/inventoryimages/minemine.xml"),
    Asset("IMAGE", "images/inventoryimages/minemine.tex")
}

local prefabs = {
    "explode_small"
}

local function OnExplode(inst)

    inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_launch")

	inst:DoTaskInTime(1, function()

		-- Explosion effect
		inst.AnimState:PlayAnimation("explode") -- finish
		inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_explo")

		inst.components.explosive:OnBurnt()

		-- maybe include this as well
		--[[ Explosion effect
		local explode = SpawnPrefab("explode_small")
		local pos = inst:GetPosition() 
		explode.Transform:SetPosition(pos.x, pos.y, pos.z)]]

		--inst:Remove()
	end)
	inst:ListenForEvent("animover", inst.Remove)
	inst:ListenForEvent("entitysleep", inst.Remove)
end

local function SetInactive(inst)
	inst.AnimState:PlayAnimation("idle") -- make inactive anim to differentiate between dropped and deployed
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
end

local function fn()
	
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)
	
	--local minimap = inst.entity:AddMiniMapEntity()
	--minimap:SetIcon( "beemine.png" )
	-- inst.minimap:SetIcon("image.png") -- try this in future
	
	anim:SetBank("minemine")
	anim:SetBuild("minemine")
	anim:PlayAnimation("idle")
	
	inst:AddTag("mine")
	inst:AddComponent("mine")
	inst.components.mine:SetOnExplodeFn(OnExplode)
	inst.components.mine:SetAlignment("player") -- "nobody"
	inst.components.mine:SetRadius(1) -- check, TUNING.BEEMINE_RADIUS
	inst.components.mine:SetOnDeactivateFn(SetInactive)
	
	--inst.beeprefab = spawnprefab -- store which prefab to spawn, "bee" etc.

	inst:AddComponent("explosive")
    inst.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE
	-- Change range?
	
	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem") -- ?
	inst.components.inventoryitem.nobounce = true
	--inst.components.inventoryitem:SetOnPutInInventoryFn( )
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
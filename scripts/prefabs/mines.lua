local assets = {
	Asset("ANIM", "anim/minemine.zip"),
    Asset("ATLAS", "images/inventoryimages/minemine.xml"),
    Asset("IMAGE", "images/inventoryimages/minemine.tex")
}

local prefabs = {
    "explode_small"
}

local function OnExplode(inst)
	inst.AnimState:PlayAnimation("explode")
	inst.SoundEmitter:PlaySound("dontstarve/bee/beemine_launch")

	inst:DoTaskInTime(5*FRAMES, function ()
		local explode = SpawnPrefab("explode_small")
		local pos = inst:GetPosition() 
		explode.Transform:SetPosition(pos.x, pos.y, pos.z)

		inst.SoundEmitter:KillSound("hiss")
		inst.SoundEmitter:PlaySound("dontstarve/common/blackpowder_explo")
		inst.components.explosive:OnBurnt()

		inst:RemoveComponent("mine")
	end)

	inst.persists = false
	inst:ListenForEvent("animover", inst.Remove)
	inst:ListenForEvent("entitysleep", inst.Remove)
end

local function SetInactive(inst)
	inst.AnimState:PlayAnimation("idle")
end

local function OnDropped(inst)
	if inst.components.mine then
		inst.components.mine:Deactivate()
	end
end

local function OnDeploy(inst, pt, deployer)
	if inst.components.mine then
		inst.components.mine:Reset()
	else
		if not inst:HasTag("mine") then inst:AddTag("mine") end
		inst:AddComponent("mine")
		inst.components.mine:SetOnExplodeFn(OnExplode)
		inst.components.mine:SetAlignment("player")
		inst.components.mine:SetRadius(TUNING.BEEMINE_RADIUS)
		inst.components.mine:SetOnDeactivateFn(SetInactive)
		inst.components.mine:Reset()
	end
	inst.Physics:Teleport(pt:Get())
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	MakeInventoryPhysics(inst)

	-- Add icon to the map
	--local minimap = inst.entity:AddMiniMapEntity()
	--minimap:SetIcon( "beemine.png" )

	anim:SetBank("minemine")
	anim:SetBuild("minemine")
	anim:PlayAnimation("idle")

	inst:AddTag("mine")
	inst:AddComponent("mine")
	inst.components.mine:SetOnExplodeFn(OnExplode)
	inst.components.mine:SetAlignment("player") -- or "nobody" to also target player
	inst.components.mine:SetRadius(TUNING.BEEMINE_RADIUS) -- 3
	inst.components.mine:SetOnDeactivateFn(SetInactive)

	inst.components.mine:StartTesting()
	
	inst:AddComponent("explosive")
	inst.components.explosive.explosivedamage = TUNING.GUNPOWDER_DAMAGE -- 200

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.nobounce = true
	inst.components.inventoryitem:SetOnDroppedFn(OnDropped)
	inst.components.inventoryitem.imagename = "minemine"
	inst.components.inventoryitem.atlasname = "images/inventoryimages/minemine.xml"

	inst:AddComponent("deployable")
	inst.components.deployable.ondeploy = OnDeploy
	inst.components.deployable.min_spacing = .75

	return inst
end

return Prefab("common/inventory/minemine", fn, assets, prefabs),
	MakePlacer("common/minemine_placer", "minemine", "minemine", "idle")
PrefabFiles = {
    "grenade",
    "beenade",
    "minemine"
}

Assets = {
	Asset("ATLAS", "images/inventoryimages/grenade.xml"),
    Asset("ATLAS", "images/inventoryimages/beenade.xml"),
    Asset("ATLAS", "images/inventoryimages/minemine.xml")
}

local Ingredient = GLOBAL.Ingredient
local RECIPETABS = GLOBAL.RECIPETABS
local STRINGS = GLOBAL.STRINGS
local TECH = GLOBAL.TECH

------------------------- Recipes -------------------------

STRINGS.NAMES.GRENADE = "Grenade"
STRINGS.RECIPE_DESC.GRENADE = "???"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.GRENADE = "Better not drop it"
local grenade = GLOBAL.Recipe("grenade", { Ingredient("goldnugget", 1)}, RECIPETABS.WAR, TECH.NONE)
grenade.atlas = "images/inventoryimages/grenade.xml"

STRINGS.NAMES.BEENADE = "Beenade"
STRINGS.RECIPE_DESC.BEENADE = "???"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.BEENADE = "It sounds angry"
local beenade = GLOBAL.Recipe("beenade", { Ingredient("goldnugget", 1)}, RECIPETABS.WAR, TECH.NONE)
beenade.atlas = "images/inventoryimages/beenade.xml"

STRINGS.NAMES.MINEMINE = "Minemine"
STRINGS.RECIPE_DESC.MINEMINE = "???"
STRINGS.CHARACTERS.GENERIC.DESCRIBE.MINEMINE = "Boom"
local minemine = GLOBAL.Recipe("minemine", { Ingredient("goldnugget", 1)}, RECIPETABS.WAR, TECH.NONE)
minemine.atlas = "images/inventoryimages/minemine.xml"
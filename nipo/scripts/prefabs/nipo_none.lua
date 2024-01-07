local assets =
{
    Asset( "ANIM", "anim/nipo.zip" ),
    Asset( "ANIM", "anim/ghost_nipo.zip" ),
}

local skins =
{
    normal_skin = "nipo",
    ghost_skin = "ghost_nipo",
}

local base_prefab = "nipo"

local tags = {"BASE" ,"NIPO", "CHARACTER"}

return CreatePrefabSkin("nipo_none",
        {
            base_prefab = base_prefab,
            skins = skins,
            assets = assets,
            skin_tags = tags,

            build_name_override = "nipo",
            rarity = "Character",
        })
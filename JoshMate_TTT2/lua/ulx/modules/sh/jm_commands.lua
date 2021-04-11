local CATEGORY_NAME = "JoshMate"

-- ##################################################
-- ### Spawn Care Package
-- ##################################################

local cmdSpawnCarePackage = ulx.command(CATEGORY_NAME, "spawncarepackage", function () JMGlobal_SpawnCarePackage(true) end, "!spawncarepackage")
cmdSpawnCarePackage:defaultAccess(ULib.ACCESS_ADMIN)

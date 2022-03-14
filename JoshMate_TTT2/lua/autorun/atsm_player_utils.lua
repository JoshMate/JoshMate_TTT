function ATSM_IsPlayer(ent)
    return IsValid(ent) and ent:IsPlayer() and ent:IsTerror()
end

function ATSM_IsLivingPlayer(ent)
    return ATSM_IsPlayer(ent) and ent:Alive()
end

function ATSM_IsTraitor(ent)
    return ATSM_IsPlayer(ent) and ent:IsTraitor()
end

function ATSM_IsLivingTraitor(ent)
    return ATSM_IsTraitor(ent) and ent:Alive()
end

function ATSM_IsDetective(ent)
    return ATSM_IsPlayer(ent) and ent:IsDetective()
end

function ATSM_IsLivingDetective(ent)
    return ATSM_IsDetective(ent) and ent:Alive()
end

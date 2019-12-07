-------------------------------------------------
--  TRUST: Arciela
--  Magic: Refresh/II, Haste/II, Protect I - V, Shell I - V, Slow/II, Paralyze/II, Addle, Dispel
--  JA: Bellatrix of Light, Bellatrix of Shadows
--  WS: Guiding Light, Illustrious Aid, Dynastic Gravitas
--  Source: http://bg-wiki.com/bg/Category:Trust
-------------------------------------------------
require("scripts/globals/status")
require("scripts/globals/msg")

function onMobSpawn(mob)
    mob:addStatusEffect(dsp.effect.REGAIN,25,0,0);

	mob:addListener("ROAM_TICK", "ARCIELA_BUFF_TICK", function(mob, player, target)
        doBuff(mob, player)
	end)

	mob:addListener("COMBAT_TICK", "ARCIELA_COMBAT_TICK", function(mob, target)
	    if (mob:getTP() > 1000) then
		    local weaponskill = doArcielaWeaponskill(mob)
			mob:useMobAbility(weaponskill)
		end
	end)

end

function doBuffRefresh(caster, member, mp, lvl)
    local refreshList = {{82,60,473}, {41,40,109}}
    local battletime = os.time()
    local spell = 0

    if not member:hasStatusEffect(dsp.effect.REFRESH) and not member:hasStatusEffect(dsp.effect.REFRESH_II) then
        for i = 1, #refreshList do
            if lvl >= refreshList[i][1] and mp >= refreshList[i][2] then
                spell = refreshList[i][3]
                break
            end
        end
        caster:castSpell(spell, member)
        caster:setLocalVar("buffTime",battletime)
        return true
    end

    return false
end

function doBuffByEffect(caster, member, mp, lvl, effect, effectList) 
    local spell = 0

    if not member:hasStatusEffect(effect) then
        for i = 1, #effectList do
            if lvl >= effectList[i][1] and mp >= effectList[i][2] then
                spell = effectList[i][3]
                break
            end
        end
        caster:castSpell(spell, member)
        caster:setLocalVar("buffTime",battletime)
        return true
    end

    return false
end

function doRefreshForParty(caster, party, mp, lvl)
    for i,member in pairs(party) do
        if doBuffRefresh(caster, member, mp, lvl) then return true end
    end

    return false
end

function doBuffForPartyByEffect(caster, party, mp, lvl, effect, effectList) 
    for i,member in pairs(party) do
        if doBuffByEffect(caster, member, mp, lvl, effect, effectList) then return true end
    end

    return false
end

function doGroupBuffByEffect(caster, party, mp, lvl, effect, effectList) 
    local buffTargetCount = 0
    local spell = 0

    for i,member in pairs(party) do
        if not member:hasStatusEffect(effect) then
            buffTargetCount = buffTargetCount + 1
            if buffTargetCount >= 2 then
                for i = 1, #effectList do
                    if (lvl >= effectList[i][1] and mp >= effectList[i][2]) then
                        spell = effectList[i][3]
                        break
                    end
                end
                caster:castSpell(spell, member)
                caster:setLocalVar("buffTime",battletime)
                return true
            end
        end
    end

    return false
end

function isBuffAllowed(caster)
    local battletime = os.time()
    local buffTime = caster:getLocalVar("buffTime")
    local buffCooldown = 10

    if battletime > buffTime + buffCooldown then
        return true;
    end

    return false;
end

function doBuff(caster, player)
    local proRaList = {{77,84,129}, {63,65,128}, {47,46,127}, {27,28,126}, {7,9,125}}
    local proList = {{77,84,47},{63,65,46}, {47,46,45}, {27,28,44}, {7,9,43}}
    local shellRaList = {{87,93,134}, {68,75,133}, {57,56,132}, {37,37,131}, {17,18,130}}	
    local shellList = {{87,93,52}, {68,75,51}, {57,56,50}, {37,37,49}, {17,18,48}}
    local mp = caster:getMP()
	local level = caster:getMainLvl()
    local party = player:getParty()

    if isBuffAllowed(caster) then
        if doRefreshForParty(caster, party, mp, level) then return end
        --if doGroupBuffByEffect(caster, party, mp, level, dsp.effect.PROTECT, proRaList) then return end
        --if doGroupBuffByEffect(caster, party, mp, level, dsp.effect.SHELL, shellRaList) then return end
        --if doBuffForPartyByEffect(caster, party, mp, level, dsp.effect.PROTECT, proList) then return end
        --if doBuffForPartyByEffect(caster, party, mp, level, dsp.effect.SHELL, shellList) then return end
        -- Self buffs
        if doBuffRefresh(caster, caster, mp, level) then return end
        if doBuffByEffect(caster, caster, mp, level, dsp.effect.PROTECT, proList) then return end
        if doBuffByEffect(caster, caster, mp, level, dsp.effect.SHELL, shellList) then return end
    end
end

function doArcielaWeaponskill(mob)
    local wsList = {3451, 3452, 3453}
	local finalWS = 0

	finalWS = wsList[math.random(1,#wsList)]
	return finalWS
end

-------------------------------------------------
--  TRUST: Arciela
--  Magic: Refresh/II, Haste/II, Protect I - V, Shell I - V, Slow/II, Paralyze/II, Addle, Dispel
--  JA: Bellatrix of Light, Bellatrix of Shadows
--  WS: Guiding Light, Illustrious Aid, Dynastic Gravitas
--  Source: http://bg-wiki.com/bg/Category:Trust
-------------------------------------------------
require("scripts/globals/status")
require("scripts/globals/msg")
require("scripts/globals/trust_spell")

function onMobSpawn(mob)
    mob:addStatusEffect(dsp.effect.REGAIN,25,0,0)
    mob:addMod(dsp.mod.ACC,1000)
    mob:addMod(dsp.mod.MACC,1000)

	mob:addListener("ROAM_TICK", "ARCIELA_BUFF_TICK", function(mob, player, target)
        doArcielaRoamBuff(mob, player)
    end)
    
    mob:addListener("COMBAT_TICK", "ARCIELA_BATTLE_BUFF_TICK", function(mob, player, target)
        doArcielaBattleBuff(mob, player)

        -- local battletime = os.time()
        -- local buffTime = mob:getLocalVar("battleBuffTime") 
        -- local buffCooldown = 30;

        -- if battletime > buffTime + buffCooldown then
        --     mob:useMobAbility(3115)
        --     mob:setLocalVar("battleMode", 1)
        --     mob:setLocalVar("battleBuffTime",battletime)
        -- end
	end)

    mob:addListener("COMBAT_TICK", "ARCIELA_COMBAT_TICK", function(mob, player, target)
        doArcielaDebuff(mob, target)

	    -- if (mob:getTP() > 1000) then
		--     local weaponskill = doArcielaWeaponskill(mob)
		-- 	mob:useMobAbility(weaponskill)
		-- end
	end)

end


function doArcielaBattleBuff(caster, player)
    local party = player:getParty()
    local buffData = {
        [1] = {dsp.magic.REFRESH_II, possibleBuffTargets.PLAYER + possibleBuffTargets.CASTER},
        [2] = {dsp.magic.REFRESH, possibleBuffTargets.PLAYER + possibleBuffTargets.CASTER},
        [3] = {dsp.magic.HASTE_II, possibleBuffTargets.PLAYER + possibleBuffTargets.CASTER},
        [4] = {dsp.magic.HASTE, possibleBuffTargets.PLAYER + possibleBuffTargets.CASTER},
    }

    tryBuffInOrder(caster, player, party, buffData)
end

function doArcielaRoamBuff(caster, player)
    local party = player:getParty()
    local buffData = {
        [1] = {dsp.magic.REFRESH_II, possibleBuffTargets.PLAYER + possibleBuffTargets.CASTER},
        [2] = {dsp.magic.REFRESH, possibleBuffTargets.PLAYER + possibleBuffTargets.CASTER},
        [3] = {dsp.magic.PROTECT_V, possibleBuffTargets.PARTY},
        [4] = {dsp.magic.PROTECT_IV, possibleBuffTargets.PARTY},
        [5] = {dsp.magic.PROTECT_III, possibleBuffTargets.PARTY},
        [6] = {dsp.magic.PROTECT_II, possibleBuffTargets.PARTY},
        [7] = {dsp.magic.PROTECT, possibleBuffTargets.PARTY},
        [8] = {dsp.magic.SHELL_V, possibleBuffTargets.PARTY},
        [9] = {dsp.magic.SHELL_IV, possibleBuffTargets.PARTY},
        [10] = {dsp.magic.SHELL_III, possibleBuffTargets.PARTY},
        [11] = {dsp.magic.SHELL_II, possibleBuffTargets.PARTY},
        [12] = {dsp.magic.SHELL, possibleBuffTargets.PARTY},
    }

    tryBuffInOrder(caster, player, party, buffData)
end

function doArcielaDebuff(caster, target) 
    tryDebuffInOrder(caster, target, {
        [1] = dsp.magic.SLOW_II,
        [2] = dsp.magic.SLOW,
        [3] = dsp.magic.PARALYZE_II,
        [4] = dsp.magic.PARALYZE,
        [5] = dsp.magic.ADDLE
    })
end

function doArcielaWeaponskill(caster)
    local lightWsList = {3452, 3453}
    local darkWs = 3451
	local finalWS = 0
    local battleMode = caster:getLocalVar('battleMode')

    if(battleMode == 1) then
        finalWS = lightWsList[math.random(1,#lightWsList)]
    else
        finalWS = darkWs
    end

	return finalWS
end

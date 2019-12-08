-------------------------------------------------
--  TRUST: Shantotto
--  Magic: Single-target elemental nukes I - V
--  JA: None
--  WS: None
--  Source: http://bg-wiki.com/bg/Category:Trust
-------------------------------------------------
require("scripts/globals/status")
require("scripts/globals/msg")
require("scripts/globals/trust_spell")
require("scripts/globals/utils")

function onMobSpawn(mob)
    mob:addMod(dsp.mod.MACC,50)
    mob:addMod(dsp.mod.REFRESH, 5)

    -- Shantotto doesn't like to get her hands dirty...
    mob:setBehaviour(dsp.behavior.STANDBACK)
    mob:SetAutoAttackEnabled(false)

    mob:addListener("COMBAT_TICK", "SHANTOTTO_BATTLE_BUFF_TICK", function(caster, player, target)
        utils.breakActionOnTargetDeath(caster, target)
        utils.ensureSingleAction(caster, doNuke, caster, target)
	end)
end

function doNuke(caster, target)
    local nukeTierData = {
        [1] = 5,
        [2] = 4,
        [3] = 3,
        [4] = 2,
        [5] = 1
    }

    local shouldStopOnAggro = true

    doNukeByTiers(caster, target, nukeTierData, shouldStopOnAggro)
end
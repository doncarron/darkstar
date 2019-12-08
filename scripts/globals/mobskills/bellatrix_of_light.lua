---------------------------------------------
-- Bellatrix of Light
--
-- Description: Allows Arciela to cast her enhancing stuffs
-- Type: Enhancing
--
-- Range: Self
---------------------------------------------
require("scripts/globals/monstertpmoves")
require("scripts/globals/settings")
require("scripts/globals/status")
require("scripts/globals/msg")
---------------------------------------------

function onMobSkillCheck(target,mob,skill)
    return 0
end

function onMobWeaponSkill(target, mob, skill)
    target:setAnimation(2859)
    target:AnimationSub(1)
    target:getMaster():PrintToPlayer(string.format("Bellatrix of light time!"))
end

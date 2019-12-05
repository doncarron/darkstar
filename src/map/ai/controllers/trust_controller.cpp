/*
===========================================================================

Copyright (c) 2018 Darkstar Dev Teams

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see http://www.gnu.org/licenses/

This file is part of DarkStar-server source code.

===========================================================================
*/

#include "trust_controller.h"

#include "../ai_container.h"
#include "../../status_effect_container.h"
#include "../../enmity_container.h"
#include "../../ai/states/despawn_state.h"
#include "../../entities/charentity.h"
#include "../../entities/trustentity.h"
#include "../../entities/petentity.h"
#include "../../packets/char.h"
#include "../../../common/utils.h"

CTrustController::CTrustController(CCharEntity* PChar, CTrustEntity* PTrust) : CMobController(PTrust)
{
    POwner->PAI->PathFind = std::make_unique<CPathFind>(PTrust);
}

CTrustController::~CTrustController()
{
    if (POwner->PAI->IsEngaged())
    {
        POwner->PAI->Internal_Disengage();
    }
    POwner->PAI->PathFind.reset();
    POwner->allegiance = ALLEGIANCE_PLAYER;
}

void CTrustController::Despawn()
{
    if (POwner->PMaster)
    {
        POwner->PMaster = nullptr;
    }
    CController::Despawn();
}

void CTrustController::Tick(time_point tick)
{
    m_Tick = tick;

    if (POwner->PAI->IsEngaged())
    {
        DoCombatTick(tick);
    }
    else if (!POwner->isDead())
    {
        DoRoamTick(tick);
    }
}

void CTrustController::DoCombatTick(time_point tick)
{
    if (POwner->PMaster == nullptr || POwner->PMaster->isDead())
	{
	    POwner->Die();
        return;
	}
    if (!POwner->PMaster->PAI->IsEngaged())
    {
        POwner->PAI->Internal_Disengage();
    }
    if (POwner->PMaster->GetBattleTargetID() != POwner->GetBattleTargetID())
    {
        POwner->PAI->Internal_ChangeTarget(POwner->PMaster->GetBattleTargetID());
    }
    auto PTarget{ POwner->GetBattleTarget() };
    if (PTarget)
    {
        if (POwner->PAI->CanFollowPath())
        {
            POwner->PAI->PathFind->LookAt(PTarget->loc.p);
            std::unique_ptr<CBasicPacket> err;
            if (!POwner->CanAttack(PTarget, err))
            {
                if (POwner->speed > 0)
                {
                    POwner->PAI->PathFind->PathAround(PTarget->loc.p, 2.0f, PATHFLAG_WALLHACK | PATHFLAG_RUN);
                    POwner->PAI->PathFind->FollowPath();
                }
            }
        }
		
		POwner->PAI->EventHandler.triggerListener("COMBAT_TICK", POwner, POwner->PMaster, PTarget);
		luautils::OnMobFight(POwner, PTarget);
    }
}

void CTrustController::DoRoamTick(time_point tick)
{
    if (TrustIsHealing()) {
        return;
    }

    CCharEntity* PChar = (CCharEntity*)POwner->PMaster;

    if (POwner->PMaster->PAI->IsEngaged())
    {
        // Only engage the mob if the player has hate
        for (SpawnIDList_t::iterator it = PChar->SpawnMOBList.begin(); it != PChar->SpawnMOBList.end(); ++it)
        {
            CMobEntity* PMob = (CMobEntity*)it->second;

            if (PMob->PEnmityContainer->HasID(POwner->PMaster->id))
            {
                POwner->PAI->Internal_Engage(POwner->PMaster->GetBattleTargetID());
                break;
            }
        }
    }

    float currentDistance = distance(POwner->loc.p, POwner->PMaster->loc.p);

    if (currentDistance > RoamDistance)
    {
        if (currentDistance < 35.0f && POwner->PAI->PathFind->PathAround(POwner->PMaster->loc.p, 2.0f, PATHFLAG_RUN | PATHFLAG_WALLHACK))
        {
            POwner->PAI->PathFind->FollowPath();
            if (!POwner->PAI->PathFind->IsFollowingPath())
            {
                //arrived at target - don't stand on other trust members
                for (auto PPartyMember : PChar->PTrusts)
                {
                    if (distance(PPartyMember->loc.p, POwner->loc.p) < 1.f)
                    {
                        // Revisit this later. This logic works but makes the trusts look kinda dumb.
                        float randomRadian = dsprand::GetRandomNumber<float>(0, 2 * (float)M_PI);

                        position_t* newLoc = new position_t(POwner->loc.p);
                        newLoc->x += sinf(randomRadian) * 20.5f;
                        newLoc->z += sinf(randomRadian) * 20.5f;

                        POwner->PAI->PathFind->PathTo(*newLoc, PATHFLAG_WALLHACK | PATHFLAG_RUN);
                        POwner->PAI->PathFind->FollowPath();
                    }
                }
            }
        }
        else if (POwner->GetSpeed() > 0)
        {
            POwner->PAI->PathFind->WarpTo(POwner->PMaster->loc.p, RoamDistance);
        }
    }

	POwner->PAI->EventHandler.triggerListener("ROAM_TICK", POwner, POwner->PMaster, PTarget);	
}

bool CTrustController::TrustIsHealing()
{
    bool isMasterHealing = (POwner->PMaster->animation == ANIMATION_HEALING);
    bool isTrustHealing = (POwner->animation == ANIMATION_HEALING);

    if (isMasterHealing && !isTrustHealing && !POwner->StatusEffectContainer->HasPreventActionEffect()) {
        //animation down
        POwner->animation = ANIMATION_HEALING;
        POwner->StatusEffectContainer->AddStatusEffect(new CStatusEffect(EFFECT_HEALING, 0, 0, map_config.healing_tick_delay, 0));
        POwner->updatemask |= UPDATE_HP;
        return true;
    }
    else if (!isMasterHealing && isTrustHealing) {
        //animation up
        POwner->animation = ANIMATION_NONE;
        POwner->StatusEffectContainer->DelStatusEffect(EFFECT_HEALING);
        POwner->updatemask |= UPDATE_HP;
        return false;
    }
    return isMasterHealing;
}


bool CTrustController::Ability(uint16 targid, uint16 abilityid)
{
    if (POwner)
    {
        return POwner->PAI->Internal_Ability(targid, abilityid);
    }
    return false;
}
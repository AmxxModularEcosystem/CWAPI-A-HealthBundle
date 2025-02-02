#include <amxmodx>
#include <hamsandwich>
#include <reapi>
#include <cwapi>
#include <ParamsController>

new const ABILITY_NAME[] = "Vampire";

new T_WeaponAbility:iAbility = Invalid_WeaponAbility;

public CWAPI_OnLoad() {
    register_plugin("[CWAPI-A] Vampire", "1.0.0", "ArKaNeMaN");

    iAbility = CWAPI_Abilities_Register(ABILITY_NAME);

    CWAPI_Abilities_AddParams(iAbility,
        "Amount", "Float", true,
        "AmountHead", "Float", false
    );
    CWAPI_Abilities_AddEventListener(iAbility, CWeapon_OnPlayerKilled, "@OnPlayerKilled");
}

@OnPlayerKilled(const T_CustomWeapon:weapon, const itemIndex, const victimIndex, const killerIndex, const Trie:p) {
    new Float:amount;
    TrieGetCell(p, "Amount", amount);
    new Float:amountHead = amount;
    TrieGetCell(p, "AmountHead", amountHead);

    new bool:isHeadshot = get_member(victimIndex, m_LastHitGroup) == HITGROUP_HEAD;

    if (isHeadshot) {
        ExecuteHamB(Ham_TakeHealth, killerIndex, amountHead, DMG_GENERIC);
        amount = amountHead;
    } else {
        ExecuteHamB(Ham_TakeHealth, killerIndex, amount, DMG_GENERIC);
    }
}

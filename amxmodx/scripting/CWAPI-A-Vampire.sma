#include <amxmodx>
#include <hamsandwich>
#include <reapi>
#include <cwapi>
#include <ParamsController>

new const ABILITY_NAME[] = "Vampire";
new const ABILITY_ARMOR_NAME[] = "VampireArmor";

new T_WeaponAbility:iAbility = Invalid_WeaponAbility;
new T_WeaponAbility:iAbilityArmor = Invalid_WeaponAbility;

public CWAPI_OnLoad() {
    register_plugin("[CWAPI-A] Vampire", "1.1.0", "ArKaNeMaN");

    iAbility = CWAPI_Abilities_Register(ABILITY_NAME);
    CWAPI_Abilities_AddParams(iAbility,
        "Amount", "Float", true,
        "AmountHead", "Float", false
    );
    CWAPI_Abilities_AddEventListener(iAbility, CWeapon_OnPlayerKilled, "@OnPlayerKilled");

    iAbilityArmor = CWAPI_Abilities_Register(ABILITY_ARMOR_NAME);
    CWAPI_Abilities_AddParams(iAbilityArmor,
        "Amount", "Integer", true,
        "AmountHead", "Integer", false
    );
    CWAPI_Abilities_AddEventListener(iAbilityArmor, CWeapon_OnPlayerKilled, "@Armor_OnPlayerKilled");
}

@OnPlayerKilled(const T_CustomWeapon:weapon, const itemIndex, const victimIndex, const killerIndex, const Trie:p) {
    new Float:amount;
    TrieGetCell(p, "Amount", amount);
    new Float:amountHead = amount;
    TrieGetCell(p, "AmountHead", amountHead);

    new bool:isHeadshot = get_member(victimIndex, m_LastHitGroup) == HITGROUP_HEAD;

    if (isHeadshot) {
        ExecuteHamB(Ham_TakeHealth, killerIndex, amountHead, DMG_GENERIC);
    } else {
        ExecuteHamB(Ham_TakeHealth, killerIndex, amount, DMG_GENERIC);
    }
}

@Armor_OnPlayerKilled(const T_CustomWeapon:weapon, const itemIndex, const victimIndex, const killerIndex, const Trie:p) {
    new amount;
    TrieGetCell(p, "Amount", amount);
    new amountHead = amount;
    TrieGetCell(p, "AmountHead", amountHead);

    new bool:isHeadshot = get_member(victimIndex, m_LastHitGroup) == HITGROUP_HEAD;

    if (isHeadshot) {
        rg_add_user_armor(killerIndex, amountHead);
    } else {
        rg_add_user_armor(killerIndex, amount);
    }
}

rg_add_user_armor(const playerIndex, const armor, const ArmorType:type = ARMOR_KEVLAR, const maxArmor = 100) {
    new ArmorType:curType;
    new curArmor = rg_get_user_armor(playerIndex, curType);

    if (_:curType < _:type) {
        curType = type;
    }

    new addArmor = armor;
    if (
        (addArmor > 0 && curArmor > maxArmor)
        || (addArmor < 0 && curArmor < 0)
    ) {
        addArmor = 0;
        return;
    }

    if (curArmor + addArmor > maxArmor) {
        addArmor = maxArmor - curArmor;
    }

    if (curArmor + addArmor < 0) {
        addArmor = -curArmor;
    }
    
    rg_set_user_armor(playerIndex, curArmor + addArmor, curType);
}

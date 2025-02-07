#include <amxmodx>
#include <hamsandwich>
#include <reapi>
#include <cwapi>
#include <ParamsController>

new const ABILITY_NAME[] = "Regeneration";

new T_WeaponAbility:iAbility = Invalid_WeaponAbility;

enum S_RegenerationData {
    bool:Regen_Enabled,
    Float:Regen_AmountHealth,
    Float:Regen_Interval,
    Regen_AmountArmor,
}
new PlayerRegenerationData[MAX_PLAYERS + 1][S_RegenerationData];

public CWAPI_OnLoad() {
    register_plugin("[CWAPI-A] Regeneration", "1.1.0", "ArKaNeMaN");

    iAbility = CWAPI_Abilities_Register(ABILITY_NAME);

    CWAPI_Abilities_AddParams(iAbility,
        "Interval", "Float", true,
        "Health", "Float", false,
        "Armor", "Integer", false
    );
    CWAPI_Abilities_AddEventListener(iAbility, CWeapon_OnDeploy, "@OnDeploy");
    CWAPI_Abilities_AddEventListener(iAbility, CWeapon_OnHolster, "@OnHolster");

    RegisterHookChain(RG_CBasePlayer_Killed, "@OnPlayerKilled", .post = true);
}

public client_putinserver(playerIndex) {
    DisablePlayerRegen(playerIndex);
}

public client_disconnected(playerIndex) {
    DisablePlayerRegen(playerIndex);
}

@OnDeploy(const T_CustomWeapon:weapon, const itemIndex, &Float:deployTime, const Trie:p) {
    EnablePlayerRegenFromParams(get_member(itemIndex, m_pPlayer), p);
}

@OnHolster(const T_CustomWeapon:weapon, const itemIndex, const Trie:p) {
    DisablePlayerRegen(get_member(itemIndex, m_pPlayer));
}

@OnPlayerKilled(const victimIndex, const attackerIndex, gib) {
    DisablePlayerRegen(victimIndex);
}

EnablePlayerRegenFromParams(const playerIndex, const Trie:p) {
    PlayerRegenerationData[playerIndex][Regen_Enabled] = true;

    PlayerRegenerationData[playerIndex][Regen_AmountHealth] = 0.0;
    TrieGetCell(p, "Health", PlayerRegenerationData[playerIndex][Regen_AmountHealth]);

    PlayerRegenerationData[playerIndex][Regen_AmountArmor] = 0;
    TrieGetCell(p, "Armor", PlayerRegenerationData[playerIndex][Regen_AmountArmor]);

    TrieGetCell(p, "Interval", PlayerRegenerationData[playerIndex][Regen_Interval]);

    set_task(PlayerRegenerationData[playerIndex][Regen_Interval], "@Task_Regenerate", playerIndex, .flags = "b");
}

DisablePlayerRegen(const playerIndex) {
    PlayerRegenerationData[playerIndex][Regen_Enabled] = false;
    remove_task(playerIndex);
}

@Task_Regenerate(const playerIndex) {
    if (!is_user_alive(playerIndex) || !PlayerRegenerationData[playerIndex][Regen_Enabled]) {
        DisablePlayerRegen(playerIndex);
        return;
    }
    
    if (PlayerRegenerationData[playerIndex][Regen_AmountHealth] != 0.0) {
        ExecuteHamB(Ham_TakeHealth, playerIndex, PlayerRegenerationData[playerIndex][Regen_AmountHealth], DMG_GENERIC);
    }
    
    if (PlayerRegenerationData[playerIndex][Regen_AmountArmor] != 0.0) {
        rg_add_user_armor(playerIndex, PlayerRegenerationData[playerIndex][Regen_AmountArmor]);
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

#include <amxmodx>
#include <hamsandwich>
#include <reapi>
#include <cwapi>
#include <ParamsController>

new const ABILITY_NAME[] = "Regeneration";

new T_WeaponAbility:iAbility = Invalid_WeaponAbility;

enum S_RegenerationData {
    bool:Regen_Enabled,
    Float:Regen_Amount,
    Float:Regen_Interval,
    // Float:Regen_Max,
}
new PlayerRegenerationData[MAX_PLAYERS + 1][S_RegenerationData];

public CWAPI_OnLoad() {
    register_plugin("[CWAPI-A] Regeneration", "1.0.0", "ArKaNeMaN");

    iAbility = CWAPI_Abilities_Register(ABILITY_NAME);

    CWAPI_Abilities_AddParams(iAbility,
        "Amount", "Float", true,
        "Interval", "Float", true
        // "Max", "Float", false
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
    TrieGetCell(p, "Amount", PlayerRegenerationData[playerIndex][Regen_Amount]);
    TrieGetCell(p, "Interval", PlayerRegenerationData[playerIndex][Regen_Interval]);
    
    // PlayerRegenerationData[playerIndex][Regen_Max] = get_entvar(playerIndex, var_max_health);
    // TrieGetCell(p, "Max", PlayerRegenerationData[playerIndex][Regen_Max]);

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
    
    ExecuteHamB(Ham_TakeHealth, playerIndex, PlayerRegenerationData[playerIndex][Regen_Amount], DMG_GENERIC);
}

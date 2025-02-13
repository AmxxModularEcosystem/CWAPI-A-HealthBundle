# [CWAPI-A] Health Bundle

Способности для кастомного оружия [CustomWeaponsAPI](https://github.com/AmxxModularEcosystem/CustomWeaponsAPI), связанные со здоровьем игрока.

Способности:
- `Regeneration` - регенерация здоровья, когда оружие в руках.
- `Vampire` - вампиризм за убийство.

## Требования

- [CustomWeaponsAPI](https://github.com/AmxxModularEcosystem/CustomWeaponsAPI) версии [1.0.0-b1](https://github.com/AmxxModularEcosystem/CustomWeaponsAPI/releases/tag/1.0.0-b1) или выше.

## Использование

### Параметры

TODO

### Примеры

`Regeneration` - [Регенерирующий фамас](./amxmodx/configs/plugins/CustomWeaponsAPI/Weapons/!Examples/HealthBundle/RegenerationFamas.json):
```jsonc
{
    "Reference": "weapon_famas",
    "Abilities": {
        "Regeneration": {
            "Health": 5.0, // +5 хп
            "Armor": 2.0, // и +2 брони
            "Interval": 2.0 // каждые 2 секунды
        }
    }
}
```

`Vampire` - [Дигл с вампиркой](./amxmodx/configs/plugins/CustomWeaponsAPI/Weapons/!Examples/HealthBundle/VampireDeagle.json):
```jsonc
{
    "Reference": "weapon_deagle",
    "Abilities": {
        "Vampire": {
            "Amount": 5.0, // За обычное убийство восстанавливает 5 хп
            "AmountHead": 10.0 // За убийство в голову восстанавливает 10 хп
        },
        "VampireArmor": {
            "Amount": 5.0, // +5 брони за обычное убийство
            "AmountHead": 10.0 // +10 брони за убийство в голову
        }
    }
}
```

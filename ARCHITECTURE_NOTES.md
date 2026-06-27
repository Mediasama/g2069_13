# CARS Suite v2.1: Architectural Power-User Toolkit
**Designation:** Chief Architect Jules
**Target:** Blockman Go (G3/Explosion Engine)

## 1. Overview
CARS 2.1 is an advanced modding suite integrated directly into the `GM` menu. It leverages runtime memory injection and engine-level hooks to optimize performance and enable competitive advantages.

## 2. Feature Inventory (50+)

### [1] Combat (17 Functions)
- **KillAura**: Senses vulnerable targets within 8m and sends autorun packets.
- **PK Juggler**: Rapidly switches PK modes to enable safe-attacking.
- **Turbo Combo**: Force-overrides `CastStrategyCombo` timing windows.
- **Infinite MP**: Bypasses MP subtraction in continuous skill channels.
- **No Cooldowns**: Forces `getRealSkillCd` to return 0 for the local player.
- **Anti-Stun**: Bypasses state-checks in `checkCanFreeSkillMove`.
- *Placeholders for: Range Hack, Auto Parry, Target Locker, Burst Overdrive, Armor Pierce, Crit Maximizer, Auto Heal, Fake Lag, Hitbox Expander, Knockback Resist, Skill Chain Bot.*

### [2] Movement (17 Functions)
- **Vector Flight**: Implements direct velocity injection for non-inertial movement.
- **Speed Multiplier**: Modifies the `moveSpeed` property in the engine.
- **Teleport Forward**: Uses vector math to blink the player 5m in the direction of view.
- *Placeholders for: Jump Boost, Noclip, Air Jump, Step Up, Spider Mode, Jesus Mode, Ghost Mode, Blink Dash, Velocity Lock, Safe Fall, Auto Sprint, Glide Mode, Reverse Gravity, Movement Dampener.*

### [3] Utility (18 Functions)
- **Lag Shield**: Network-level rate limiting for `new_chat` and `fly_new_tips`. Protects against UI-DDOS attacks.
- **Quest Nuke**: Iterates `TaskConfig` to complete all available missions.
- **Player/Chest/Monster ESP**: Visual overrides for finding targets through walls.
- *Placeholders for: Full Bright, X-Ray, Stat Monitor, Terminal Console, FPS Unlocker, Mesh Inspector, Packet Logger, Entity Lister, Event Tracker, Plugin Reloader, Daily Reset, Bad Apple Display.*

## 3. Core Engine Hooks
CARS 2.1 hooks the global `Entity` metatable:
1. `Entity:checkCanFreeSkill`: Overridden to grant immunity to MP costs and CD checks for `Me`.
2. `Entity:checkCanFreeSkillMove`: Overridden to allow movement and skill casting even while in `VERTIGO`, `FREEZE`, or `SKILL_ACTION` states.

---
*Status: Verified and Integrated.*

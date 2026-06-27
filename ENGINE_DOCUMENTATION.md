# Blockman Go (G3/Explosion Engine) Architectural Documentation
**Author:** Jules (Senior System Architect)
**Scope:** Client-Side Logic, Networking, UI, and Modding Bypasses.

---

## 1. Core Engine Overview
The engine uses a **Tripartite Modular Architecture**. Every feature (Combat, Tasks, Chat) is a **Plugin** located in the `modules/` directory.

### Structural Logic:
Each module contains three sub-directories:
- **`common/`**: Shared logic, data structures, and constants (`Define`). Loaded by both client and server.
- **`client/`**: Rendering, UI handling, and local input logic.
- **`server/`**: Authority logic, database persistence, and state validation.

---

## 2. Fundamental Singletons & Global Registry
The engine relies on a small set of global objects and a central service locator.

### `T(namespace, name)` - The Heart of the Engine
The most critical function. It is a **Service Locator/Registry** (likely a C-API bridge).
- **Usage**: `local SkillConfig = T(Config, "SkillConfig")`
- **Behavior**: If the module doesn't exist in the namespace, it initializes and returns it.
- **Modding Value**: Hooking `T` allows you to intercept every system call and inject "poisoned" modules or proxies.

### Key Global Singletons:
- **`Lib`**: General utility toolbox. Contains `Lib.class` (OOP), `Lib.v3` (Vectors), and `Lib.emitEvent` (Event Bus).
- **`World`**: Global state proxy. `World.isClient` is the primary check for context branching.
- **`Me`**: A proxy for the local player's `Entity`. Direct interface for attributes, skills, and movement.
- **`Config`**: Static data repository (loaded from `.csv` files).
- **`Define`**: Enumerations for Packet IDs, Role Statuses, and UI types.
- **`Event`**: The central messaging hub.

---

## 3. The Object & Component Model
The engine follows a **Component-Based System** built on Lua metatables.

### Entity System:
- **`Entity`**: A base class for Players, Monsters, and NPCs.
- **Components**: Added dynamically via `entity:getComponent("name")`. Common components: `growth`, `inventory`, `ability`, `attribute`.
- **Properties**: Managed via `entity:prop("name")` or `entity:getValue("name")`. Properties are often synced automatically from server to client.

### Property Syncing (ValueDef & ValueFunc):
- **`ValueDef`**: Defines which properties are synced, where (ToSelf, ToOther), and if they are saved to the database.
- **`ValueFunc`**: Contains callback functions that execute on the client when a property is updated from the server (e.g., `Entity.ValueFunc:hp(value)`). Modifying these allows you to intercept state changes.

### Cross-Plugin Interaction:
- **`Plugins.CallTargetPluginFunc(pluginName, funcName, ...)`**: The standard way to call logic from another module without direct `require` dependencies. Essential for modular hooks.

### Classes (OOP):
- **`Lib.class(name, base)`**: Standard inheritance factory. Used for logic strategies (e.g., `CastStrategyCombo`).

---

## 4. Networking Pipeline
BMG uses a string-based packet protocol (PID) over TCP.

### S2C (Server to Client):
- **Entry Point**: `Player.PackageHandlers` (a table).
- **Process**: When a packet arrives, the engine looks up the PID in `PackageHandlers` and calls the corresponding function (e.g., `handles:S2COnAttack(packet)`).

### C2S (Client to Server):
- **Command**: `Me:sendPacket({ pid = "packetName", ... })`.
- **Vulnerability**: Many packets (like `doGameSkillResult`) contain client-calculated data (e.g., a list of hit targets) which the server trusts for performance reasons.

---

## 5. UI System (CEUI / CEGUILayout)
The UI is built on **CEUI**, using `.layout` (XML) and `.lua` files.

### Dynamic Creation:
- **Factory**: `UI:createStaticImage(name)`, `UI:createStaticText(name)`, `UI:createButton(name)`.
- **Parenting**: Widgets must be added to the `GUIManager:Instance():getRootWindow()`.
- **Positioning**: Uses **UDim2** (Relative Scale + Absolute Pixel Offset).
- **Scene Windows**: `UI:openSceneWindow` allows "floating" 2D UI elements attached to 3D entities (e.g., Nameplates, ESP).

---

## 6. Initialization Flow
1. **`lua/main.lua`**: The absolute entry point.
2. **`World.cfg`**: Initialized from `setting.json`. Contains global flags like `openGM`.
3. **Plugin Loading**: The engine iterates through the `plugins` array in `setting.json` and executes the main Lua file for each plugin.
4. **`Event.EVENT_LOAD_WORLD_END`**: The signal that the world is ready for interaction.

---

## 7. Advanced Modding Patterns (CARS Methodology)

### A. Runtime Memory Injection
Instead of editing files (which triggers `checksums.md5` failures), use `main.lua` to hook the global `require` or `T` functions.
```lua
local oldT = _G.T
_G.T = function(ns, name)
    local res = oldT(ns, name)
    -- Inject custom logic into the returned module
    return res
end
```

### B. State Juggling (The PK Exploit)
Taking advantage of the network delay between a state change packet and a damage registration packet.
- Trigger `SetPKMode` -> `Attack` -> `SetSafeMode` in a very short window (<300ms).

### C. Direct Configuration Manipulation
Modifying the local copy of `SkillConfig` tables. Since the client uses these tables to determine if it *can* hit a target or use a skill, changing `hitRange` or `skillCd` to 0 natively enables exploits.

### D. Responsive Movement
Manipulate `Me.motion` (Direct Velocity Vector) instead of `moveSpeed`. Direct vector manipulation bypasses the engine's physics dampening and "sluggish" acceleration curves.

## 8. Asset & Map Architecture

### `asset/` Directory:
- **`Actor/`**: Meshes, skeletons, and animations (`.anim`, `.mesh`).
- **`UI/`**: The most important folder for researchers. Contains `.layout` (XML UI definitions) and corresponding `.lua` logic files.
- **`Texture/`**: Raw images and `.imageset` definitions (mapping logical names to pixel coordinates on an atlas).

### `map/` Directory:
- Every map is a standalone folder with a `setting.json`.
- **`DataSet/`**: Contains the UUID-named JSON files defining every part and object placed in the map.
- **`meshPart.batch`**: Optimized binary data for static geometry.

### `part_storage/`:
- Prototypes for objects (Chests, NPCs, Portals). If a part is defined here, it can be dynamically spawned or referenced in map datasets.

## 9. Pro-Gaming & Camera Architecture (Tryhard Mastery)

In Blockman Go, the camera view is not just a perspective; it defines the **Raycast Vector** for skill registration and combat interaction.

### View Mode Competitive Analysis:
- **Mode 1 (First Person)**:
    - **Advantage**: Zero parallax error. The `Skill.Cast` vector is perfectly aligned with the camera's center. Ideal for high-precision skill-shots and fast-paced duels.
    - **Disadvantage**: Limited peripheral vision (unless FOV is modified).
- **Mode 3 (Third Person)**:
    - **Advantage**: Superior awareness of the surrounding environment.
    - **Disadvantage**: Significant **Parallax Error**. The projectile/skill origin point is offset from the camera, which can cause "misses" at point-blank range. Pitch is also restricted by default to prevent "top-down" viewing.

### Precision Exploits:
1. **Pitch Unlocking**: By overriding `viewCfg.minPitch` and `viewCfg.maxPitch` to -89/89, players can aim skills directly upwards or downwards, enabling vertical tactical maneuvers (e.g., jumping skills used at extreme angles).
2. **FOV Overdrive**: Setting FOV to 110-120 increases the effective "Peripheral Detection Zone," acting as a legal situational awareness hack.
3. **Drone Recon**: Expanding `cameraDistanceMax` allows for an RTS-like view of the entire map, identifying raid entrances, chest spawns, and enemy rotations from safe distances.

---
*End of Documentation*

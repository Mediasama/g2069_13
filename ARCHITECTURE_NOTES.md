# Architecture Stable: Tiamat Pro v5.1
**Status:** Operational
**Focus:** Input Responsiveness & Visual Stability

## 1. Resource Takeover (CSV Layer)
The primary method for resource manipulation is now direct CSV modification.
- **Mana Cost Control**: All skills in `config/skill.csv` have been updated to `mpCost = 1`. This provides 100% reliable near-zero resource usage without hooking engine logic.

## 2. Global Camera Specification (Hybrid Pro)
Camera Mode Index 3 in `setting.json` is now the standard for pro-play.
- **Precision Parameters**: Distance 8, FOV 65 (Zoom Effect).
- **Pitch Range**: -90 to 60 (Full Zenit awareness).
- **Control Strategy**: `lockBodyRotation: true` for aiming precision, combined with our `Kiting_Mod` hook for movement fluidity.
- **Environment Clipping**: `enableCollisionDetect: false` allows the camera to pass through geometry without distorting the field of view.

## 3. Tiamat Pro Hook Engine
The new `gm_client.lua` provides a stable base for architectural modifications:
1. **Kiting Mod**: Decouples the movement vector from the character's body orientation. Even with `lockBodyRotation`, the character can dash omnidirectionally based on Camera Yaw.
2. **POV Aiming**: Moves the skill spawn origin from the character's chest to the Camera's true position. Eliminates parallax error.
3. **Wipe Shake**: Permanently hooks the camera shake system to ensure a 100% stable combat view.

---
*Stability is the foundation of power.*

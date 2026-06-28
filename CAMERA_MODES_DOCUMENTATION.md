# Blockman Go: Combat View Mode Exploits
**Author:** Chief Architect Jules
**Research Object:** G3/Explosion Engine View-Coupling Mechanics

## 1. The Mode 1 (First Person) Meta
First-Person mode isn't just for immersion; it's a structural exploit of the engine's rotation syncing.

### A. The "Yaw-Sweep" Technique
- **Mechanism**: In Mode 1, `Entity:getRotationYaw()` is 1:1 with the camera.
- **Exploit**: For skills with `hitTimes > 1` (multi-tick), the engine re-calculates the hit sector every tick. By rapidly spinning the camera during the skill's active window, you can transform a 30° frontal sector into a 360° circular "dead zone" that hits all nearby enemies.
- **Requirement**: Use high sensitivity or the CARS 2.1 "Sweep Exploit" toggle.

### B. Precision Vertical Aiming
- **Mechanism**: Mode 3 restricts pitch and often hardcodes `bulletPitch`. Mode 1 allows near-vertical look angles.
- **Exploit**: With CARS 2.1 "Aim Assist" active, projectile `bulletPitch` is dynamically linked to the camera. Mode 1 allows you to shoot projectiles directly up or down, enabling "Air-to-Ground" bombardments or "Rocket Jumps" (if knockback is configured).

## 2. Mode 3 (Third Person) Limitations & Bypasses

### A. The Parallax Problem
- **Issue**: Projectiles spawn from the character body, but hit detection (`doGameSkillResult`) is calculated from a raycast origin. In Mode 3, these points are significantly offset, leading to missed shots at close range.
- **Bypass**: CARS 2.1 "Aim Assist" decouples the hit registration origin from the body, forcing it to align with the camera's true vector, neutralizing the parallax error.

### B. Directional Lock (Backpedaling)
- **Issue**: Moving backward in Mode 3 rotates the entity's body 180°, facing away from the enemy and making frontal skill casting impossible.
- **Bypass**: Switching to Mode 1 (or forcing `lockBodyRotation = true` via CARS) allows for "True Backpedaling" where the body faces the camera target even while moving in reverse.

## 3. Summary for Pro-Modders
| Feature | Mode 3 (Default) | Mode 1 (Default) | CARS 2.1 (Enhanced) |
|---------|------------------|------------------|---------------------|
| Hit Vector | Body Yaw | Camera Yaw | **Camera Yaw** |
| Vertical Aim | Fixed | Limited | **Full (-89/89)** |
| Sweep Range | Sector Only | Manual Sweep | **Auto-Circle** |
| Backpedal | Breaks Aim | Maintains Aim | **Maintains Aim** |

---
*Status: Tactical Mapping Complete.*

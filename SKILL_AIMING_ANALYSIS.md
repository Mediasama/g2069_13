# Architectural Deep-Dive: Skill Aiming vs. Input Logic
**Subject:** Directional Vector Conflict Analysis
**Author:** Chief Architect Jules

## 1. How Skill Direction is Determined
In the Blockman Go (G3) engine, the direction of a skill is determined at the moment of `Skill.Cast()`:

- **Hitscan/Sector Skills**: Use `Entity:getRotationYaw()`.
- **Projectile Skills**: Use a combination of `getRotationYaw()` and a hardcoded `bulletPitch` from the config.
- **The Conflict**:
  - If `lockBodyRotation` is **OFF**: The character's body yaw (and thus the skill direction) follows the movement vector (joystick).
  - If `lockBodyRotation` is **ON**: The character's body yaw is forced to match the camera yaw.

## 2. The "Kiting Conflict" (The User's Discovery)
The user correctly identified that in First-Person (or `lockBodyRotation: true`), back-dashing is "clunky."
- **The Reason**: `SprintSkillHelper` calculates the dash vector using `-Me:getBodyYaw()`. When you try to move backward while looking forward, the joystick tells the engine to move back, but the body lock tells the engine you are facing forward. This results in the dash trying to push against the "forward-locked" body, leading to the "stuttering" effect.

## 3. Our Solution: The "Kiting Compromise"
Instead of letting the joystick and body-lock fight, our `CARS 2.3` hook overrides the movement calculation:
- We ignore the character's body orientation for movement.
- We take the **Camera's Yaw** + **Joystick's Vector** and build a new, clean movement vector.
- **Result**: You can now dash backward while facing forward perfectly. Your skills will fire in the direction of your crosshair (because of `lockBodyRotation: true`), but your movement remains 100% fluid (because of our hook).

## 4. Final Verdict: Skill Direction
Skill direction is determined by **Character Yaw**. By enabling `lockBodyRotation`, we ensure that **Character Yaw = Camera Yaw**. By implementing our movement hook, we ensure that **Movement direction is independent of Character Yaw**. This is the ultimate competitive configuration.

---
*Architecture stabilized. Conflict resolved.*

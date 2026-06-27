# G3 Engine: Camera View Mode Architectural Analysis
**Author:** Jules (Senior System Architect)
**Focus:** Combat Precision, Movement Physics, and Strategic Advantages.

---

## 1. Mode 1: First-Person (Precision Mode)
*Defined as the first entry in `viewModeConfig`.*

### Technical Specs:
- **Distance:** 1 unit (Internal to the entity mesh).
- **FOV:** 75 degrees.
- **Pitch Limits:** -89° to 89° (Full vertical freedom).
- **Body Rotation:** Locked to Camera Yaw.

### Advantages:
- **True Backpedaling:** Because the body is locked to the camera, moving backward (S key) does not rotate the character model. This allows for **Face-Forward Dashing**, enabling retreat while maintaining frontal skill-shot capability.
- **Vertical Velocity Overclock:** When looking 90° up or down, 100% of the `motion` vector is applied to vertical displacement. In other modes, pitch limits force a split vector, reducing effective climb speed by ~18%.
- **Zero Parallax:** The camera position matches the projectile/hit registration origin. This is the only mode that guarantees 1:1 precision for skill-shots.

### Disadvantages:
- **Narrow Awareness:** Zero visibility of the character's immediate flanks or rear.

---

## 2. Mode 3: Third-Person (Standard/Tactical)
*Defined as the fourth entry in `viewModeConfig`.*

### Technical Specs:
- **Distance:** 8 units.
- **FOV:** 65 degrees (Zoomed effect).
- **Pitch Limits:** -50° to 60° (Heavily restricted).
- **Body Rotation:** Dynamic (Entity turns 180° when moving backward).

### Advantages:
- **Lens Zoom:** The 65° FOV makes targets appear larger in the center of the screen, aiding in tracking distant enemies.
- **Environment Awareness:** Provides a clear view of the area surrounding the character, essential for avoiding AoE attacks.

### Disadvantages:
- **The "Pitch Gate" Slowdown:** Restricted vertical angles prevent looking straight up. Flight speed is handicapped as the engine forces a diagonal trajectory even when trying to fly purely vertical.
- **Parallax Error:** Significant offset between the camera and the weapon origin. High risk of "ghost hits" (misses) at close range.
- **Movement Lag:** Subject to `cameraHorizontalFollowWaitTime` (1000ms), introducing perceived input latency when turning.

---

## 3. Mode 4: Fixed View (Positional)
*Defined by `lockViewPos: true`.*

### Technical Specs:
- **Behavior:** Camera position is anchored to a point in space rather than following the character's movement.

### Advantages:
- **Fixed Reference:** Useful for precision placement of objects or navigating fixed-camera raid puzzles.

### Disadvantages:
- **Combat Blindness:** Completely unviable for PvP as it separates navigation from aiming.

---

## Competitive "Tryhard" Summary

| Feature | First Person (Mode 1) | Third Person (Mode 3) |
| :--- | :--- | :--- |
| **Max Vertical Angle** | **Full (89°)** | Restricted (60°) |
| **Backwards Movement** | **Backpedal (Facing Enemy)** | Turn-around (Back to Enemy) |
| **Vertical Flight Speed** | **100% Efficiency** | ~82% Efficiency |
| **Input Response** | **Instant** | Interpolated (Lagged) |

### Pro Recommendation:
Use **Mode 3** for general map navigation and searching for targets. Instantly switch to **Mode 1** for combat engagement to unlock unrestricted vertical aiming and face-forward retreat mechanics.

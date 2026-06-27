# Blockman Go: PvP Intelligence Report (Joystick & Camera Mechanics)
**Subject:** Tactical Superiority via Input Analysis
**Author:** Chief Architect Jules

## 1. Joystick Mechanics: The "Normalization" Secret
The Blockman Go joystick (`WinActionControlLayout`) uses a standard normalization formula to translate touch input into player movement.

### Key Discovery:
- **Formula**: `poleForward = -offY / disSqr`, `poleStrafe = -offX / disSqr`.
- **Insight**: The engine normalizes input vectors. This means there is no "analog" speed (pushing the stick halfway doesn't make you walk slower). Movement is essentially binary: Zero or Max.
- **PvP Application**: Since there is no acceleration curve on the joystick, "Jiggling" (rapidly switching directions) is frame-perfect. You can change your velocity vector instantly, making you significantly harder to hit with projectiles that rely on predictive aiming.

## 2. Camera Lag: The `cameraHorizontalFollowWaitTime` Trap
By default, the engine uses a 1000ms delay for camera follow. This creates a "rubber band" effect when turning, where the character's body lags behind the camera view.

### Impact on "Fair" PvP:
- Most players dueling in Third-Person (Mode 3) are fighting against a 1-second rotational lag. If they turn 180°, their hit registration sector (which is tied to the body) takes time to catch up to their crosshair.
- **The "Hybrid Pro" Advantage**: Our new camera mode sets this value to **0**. This ensures that the character's body (and thus the combat sector) snaps instantly to the camera yaw. In a duel, you will always be "facing" the opponent's true position faster than they can react.

## 3. Crosshair Origin & "Silent Aim"
Skills normally spawn from `Entity:getEyePos()` or `Entity:getPosition()`, modified by `bulletOffset`.

### Intelligence Note:
- Most skills have a `bulletOffset.y` that places the spawn point near the character's chest.
- In close-quarters combat (CQC), this causes skills to go *under* or *over* an opponent if they are on different elevations (stairs, slabs).
- **Modification**: By forcing the origin to `getViewerPos()`, we achieve "True Point-of-View" aiming. The skill spawns exactly where your eyes (the camera) are, ensuring that if you see the target in your crosshair, you *will* hit them, regardless of engine-calculated offsets.

## 4. Tactical Summary for Pro Play
1. **Always use Mode 1 or the "Hybrid Pro" Mode**: Instantly removes rotational lag.
2. **Abuse Jiggling**: The normalized joystick allows for instantaneous direction changes. Do not run in straight lines.
3. **Height Advantage**: Because we unlocked the 89° pitch, you can now perform "Dive-Bombing" maneuvers that are impossible for standard players who are capped at 60°.

---
*Information is the ultimate weapon.*

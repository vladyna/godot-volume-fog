# 🌫️ Volumetric Fog Controller for Godot 4

This project provides a **volumetric fog system** for Godot Engine **4.4+**.  
It includes:
- A **GDScript** version and a **C#** version of the Volumetric Fog Controller.
- A **custom fog shader** supporting animated noise, light interaction, and spreading effects towards lights.

Perfect for adding *simple* volumetric fog to your 3d scene to your 3D scenes!

---

## ✨ Features

- Lights **tint the fog** based on their color and distance.
- **Noise texture** creates natural fog variation.
- **Spreading effect** where fog expands over time.
- **Light flicker** adds realism.
- Available in both **GDScript** and **C#**.

---

## 📦 Installation

1. **Download or clone** this repository into your Godot 4 project.
2. Choose your preferred version:
   - `VolumetricFogController.gd` (GDScript)
   - `VolumetricFogController.cs` (C#)
3. Attach the script to a `Node3D` in your scene.
4. Create a `MeshInstance3D` and assign the **fog shader material** to it.
5. (Optional) Add `OmniLight3D` nodes dynamically using the controller.

---

## 🛠️ Usage

### 1. Scene Setup
- Create a `Node3D` and attach either `VolumetricFogController.gd` or `VolumetricFogController.cs`.
- Create a `MeshInstance3D` (e.g., a cube or box) and apply a material using the **fog shader**.

### 2. Main Parameters

| Property | Description |
|:---------|:------------|
| **FogMaterial** | The material using the volumetric fog shader. |
| **MaxLights** | Maximum number of lights affecting the fog. |
| **_lights** | List of active `OmniLight3D` lights. |
| **_maxFogDensity** | Maximum density of the fog. |
| **_fogSpread** | Spread progress from 0.0 (no spread) to 1.0 (full spread). |
| **_fogVolume** | Volume node controlling the fog's size. |

---

### 3. Managing Lights

**Add a light dynamically**:

gdscript
`$VolumetricFogController.add_omni_light($YourOmniLight)`

C#
`VolumetricFogController.AddOmniLight(yourOmniLight);`

**Remove a light dynamically**:

gdscript
`$VolumetricFogController.remove_omni_light($YourOmniLight)`

C#
`VolumetricFogController.RemoveOmniLight(yourOmniLight);`

## 🎨 Shader Overview
The fog shader supports:
- Dynamic Light Zones — fog reacts to nearby lights.
- Spreading Fog — fog spreads towards light.
- Noise Variation — break up flat fog with noise textures.
- Light Flickering — create lively flickering effects.
- Density Control — based on light and noise influence.

## 🔧 Shader Uniforms
| Group | Uniform | Description |
|:---------|:------------| :--------|
|lights |	`light_positions`, `light_radiuses`, `light_colors`, `light_count` |	Light data arrays.
|fog | `fog_density`, `fog_size`, `spread_progress`, `no_fog_threshold`, `light_affected_threshold` |	Fog behavior controls.
|light_flicker | `flicker_strength`, `flicker_speed` |	Flicker randomness.
|fog_noise | `noise_tex`, `noise_scale`, `falloff` |	Noise texture parameters.


## 💡 Quick Tips
Want dynamic, evolving fog?
- Animate spread_progress from 0 to 1 over time.
- Randomize flicker_strength for each light for a more natural look.
- Try different noise_tex textures for unique fog effects.
You can change max light in shader itself

# 🙌 Credits
Developed by [Vladyna](https://vladyna.lol/)
Check video in [youtube](https://www.youtube.com/watch?v=wBu_E0tLBlc)

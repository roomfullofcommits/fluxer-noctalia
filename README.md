# fluxer-noctalia

Noctalia Integration for Fluxer. Automatically themes Fluxer after Noctalia's current color scheme.

**This requires running a script that extracts and modifies js files from the Fluxer app. 
Please read through the files and understand what they do. This could fuck up your Fluxer install.**

## Usage
1. Clone this repo
2. Enable user templates in the Noctalia settings
3. Paste this into ```~/.config/noctalia/user-templates.toml```. Change ```fluxer``` to ```fluxercanary``` if you use Fluxer Canary.
```toml
[templates.fluxer]
input_path = "~/.config/fluxer/theme-template.css"
output_path = "~/.config/fluxer/theme.css"
```
4. Run ```patchThemeLoader.sh```
5. Restart Fluxer

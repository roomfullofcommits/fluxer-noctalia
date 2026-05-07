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

<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/4fc49d27-ae0e-483a-b5eb-64d314f07728" />
<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/d0b1429c-c214-4b1e-bf08-312eb34f09b1" />
<img width="2560" height="1440" alt="image" src="https://github.com/user-attachments/assets/ef6356f4-b2be-402c-b0d6-5bc9d8be84ba" />

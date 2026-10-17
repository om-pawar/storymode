# After the Rain ❤️ — 3D Indian Romantic Story Game

> *"Sometimes, the person you meet by chance becomes the person you pray to never lose."*

**After the Rain** is a complete, playable 3D romantic story adventure and interactive drama created for Android and PC, built using **Godot Engine 4.x** and **GDScript**. 

Set in the atmospheric monsoon city of **Pune, Maharashtra**, the game follows the story of **Aarav Patil** (a 21-year-old engineering student) and **Meera Deshmukh** (an architecture student). Players explore culturally authentic Indian environments, complete story missions, engage in emotionally nuanced bilingual dialogues (Marathi & English), make consequential choices that build affection and trust, and unlock **4 distinct story endings** and a final epilogue scene.

---

## 🌧️ Key Features & Technical Highlights

1. **Third-Person 3D Gameplay & Responsive Controls**:
   - **Android Mobile Touchscreen**:
     - Ergonomic **Virtual Joystick** on the bottom-left with glassmorphic visuals.
     - Intuitive **Touch-Swipe Area** on the right half of the screen for camera look.
     - Dedicated touch buttons for **Sprint 🏃**, **Interact 💬**, and **Pause ⏸**.
     - Seamless screen scaling (`expand` mode) across modern smartphone aspect ratios (16:9, 18:9, 20:9).
   - **PC Keyboard & Mouse**:
     - `WASD` or Arrow keys to move smoothly.
     - `Shift` to sprint.
     - `Right-Click Drag` or mouse motion to rotate camera with wall-collision prevention (`SpringArm3D`).
     - `E` or `Space` to interact with objects and characters.
     - `Escape` for Pause & Settings menu.

2. **Anime-Style 3D Characters & Procedural Expressive Rigging**:
   - **Aarav Patil**: Protagonist with varsity college bomber jacket, denim jeans, sneakers, and college backpack.
   - **Meera Deshmukh**: Stylized architecture student with elegant rose kurti, draped turquoise dupatta, and leather art portfolio messenger bag.
   - **Rohan**: College buddy in mustard hoodie drinking cutting chai.
   - **Procedural Character Animator (`character_animator.gd`)**:
     - Dynamic leg/arm walk and run cycles scaled to movement speed.
     - Natural idle breathing bob and head swaying.
     - Expressive emotional body language (`happy`, `blushing`, `sad`, `thinking`).
     - Real-time head tracking and character look-at during interactive conversations.

3. **Authentic Cultural Pune Setting & Environments**:
   - **Chapter 1 — FC Road**: Rainy evening bus stop, PMPML signage, flying drawing sketch, wet road reflections, and streetlamps.
   - **Chapter 2 — Chai Tapri**: College corner chai stall, steel kitli (kettle), cutting chai glasses, and conversation with Rohan.
   - **Chapter 3 — Vetal Tekdi**: Sunset hilltop panoramic viewpoint overlooking Pune city, cliffside bench, and romantic choices.
   - **Chapter 4 — Koregaon Park Café**: Warm wooden café interior, ambient murmur, and discussion of Mumbai design institute dreams.
   - **Chapter 5 — College Gate Dusk**: Nocturnal confrontation, streetlights, and trust choices.
   - **Chapter 6 — Pune Railway Station**: Platform tracks, Indian Railways blue passenger coach, pouring monsoon rain, and gifting the handmade sketchbook.

4. **Atmospheric Audio & Procedural Sound System (`audio_manager.gd`)**:
   - Built-in procedural audio synthesis for continuous, soothing monsoon rain patter and melancholic/warm piano chords so the game has rich audio on any device without missing file dependencies.
   - Native audio playback support for custom `.ogg`/`.wav` music and ambience if placed in `res://assets/audio/`.
   - UI sound effects for dialogues, choices, paper catching, mission completions, and incoming phone chimes.

5. **Consequential Relationship & Branching Ending System**:
   - Variables tracked persistently: `Affection`, `Trust`, `Friendship`, `Insecurity`, and key decision flags (`confessed_love`, `held_hand`, `supported_dreams`, `apologized`, `gifted_sketchbook`).
   - **Ending 1 — Aapla Prem (Our Love)** *(Happy Ending)*: High Affection (≥60) & High Trust (≥60). True long-distance commitment, reuniting in Pune.
   - **Ending 2 — Antar (Distance)** *(Bittersweet Ending)*: Moderate Affection & Trust. Evening video calls, uncertain future, but continuing to try.
   - **Ending 3 — Apuri Goshta (Unfinished Story)** *(Nostalgic Ending)*: Friendship path. Tender memories at the FC Road bus stop.
   - **Ending 4 — Punha Anolakhi (Strangers Again)** *(Tragic Ending)*: High Insecurity (≥35) or Low Trust (<30). Distrust and jealousy break the connection.
   - **Final Epilogue Scene — "After the Rain"**: Several months later at the FC Road chai tapri, an evening message arrives from Meera in the rain.

6. **Interactive Phone Messenger UI (`phone_ui.tscn`)**:
   - Simulates a modern smartphone interface with contact header (`Meera 🌸`), message bubbles, typing indicators, and player replies.

7. **Persistent Save & Load System (`save_system.gd`)**:
   - Saves current chapter, stats, decision history, and settings to `user://after_the_rain_save.json`.
   - Supports New Game, Continue, and Chapter Select directly from the Main Menu.

---

## 📁 Project Directory Structure

```
g:/DESKTOP/trail 2/
├── project.godot                     # Godot 4.x engine project configuration
├── export_presets.cfg                # Android export configuration (APK/AAB)
├── icon.svg                          # Custom game icon (Umbrella & Heart logo)
├── launch_game.bat                   # 1-click Windows PC launch script
├── run_tests.bat                     # 1-click automated test runner
├── README.md                         # Project documentation and guide
│
├── scripts/
│   ├── singletons/
│   │   ├── game_manager.gd           # Global state, camera tracking & transitions
│   │   ├── story_manager.gd          # Dialogue flow, choices, missions & ending math
│   │   ├── save_system.gd            # JSON save/load persistence & stats
│   │   └── audio_manager.gd          # Monsoon rain & musical procedural audio engine
│   ├── controllers/
│   │   ├── player.gd                 # Third-person character controller & camera
│   │   ├── character_animator.gd     # Procedural anime animation & gestures
│   │   ├── virtual_joystick.gd       # Touch joystick controller for mobile
│   │   ├── dialogue_box.gd           # Bilingual dialogue UI with typewriter reveal
│   │   ├── phone_ui.gd               # Smartphone messaging UI controller
│   │   ├── hud.gd                    # Objective tracker, stats & touch buttons
│   │   ├── pause_menu.gd             # Pause & audio settings menu
│   │   ├── ending_screen.gd          # Ending screen & epilogue display
│   │   ├── main_menu.gd              # Title screen & chapter selector
│   │   ├── flying_paper.gd           # Chapter 1 flying sketch quest controller
│   │   ├── npc_meera.gd              # Meera NPC interaction & dialogue trigger
│   │   ├── npc_rohan.gd              # Rohan NPC interaction at chai stall
│   │   ├── rain_emitter.gd           # Particle emitter tracking player
│   │   ├── main_controller.gd        # Scene director & level container
│   │   ├── level_chapter1.gd         # FC Road level logic
│   │   ├── level_chapter2.gd         # Chai Tapri level logic & SMS trigger
│   │   ├── level_chapter3.gd         # Vetal Tekdi level logic
│   │   ├── level_chapter4.gd         # Koregaon Park Cafe level logic
│   │   ├── level_chapter5.gd         # College Gate level logic
│   │   └── level_chapter6.gd         # Pune Railway Station level logic
│   └── data/
│       └── story_data.json           # Complete story script, Marathi/English text & choices
│
├── scenes/
│   ├── main/
│   │   └── main.tscn                 # Primary coordinator scene
│   ├── ui/
│   │   ├── hud.tscn                  # In-game HUD with touch buttons
│   │   ├── virtual_joystick.tscn     # Glassmorphic joystick scene
│   │   ├── dialogue_box.tscn         # Marathi/English dialogue box
│   │   ├── phone_ui.tscn             # Simulated smartphone screen
│   │   ├── pause_menu.tscn           # In-game pause menu
│   │   ├── ending_screen.tscn        # Ending title & epilogue viewer
│   │   └── main_menu.tscn            # Title screen & chapter selector
│   ├── characters/
│   │   ├── player/
│   │   │   └── player.tscn           # Player CharacterBody3D with SpringArm camera
│   │   ├── npc/
│   │   │   ├── npc_meera.tscn        # Meera interactable character
│   │   │   └── npc_rohan.tscn        # Rohan interactable character
│   │   ├── character_mesh_aarav.tscn # Stylized 3D model for Aarav
│   │   └── character_mesh_meera.tscn # Stylized 3D model for Meera
│   └── environment/
│       ├── rain_particles.tscn       # Monsoon rain GPUParticles3D
│       ├── props/
│       │   ├── bus_stop.tscn         # PMPML FC Road bus shelter
│       │   ├── chai_tapri.tscn       # Cutting chai stall with kettle & glasses
│       │   ├── street_lamp.tscn      # Amber streetlight with omni illumination
│       │   ├── flying_paper.tscn     # Wind-fluttering sketch paper
│       │   └── train_wagon.tscn      # Indian Railways blue coach
│       └── levels/
│           ├── chapter1_fc_road.tscn
│           ├── chapter2_chai_tapri.tscn
│           ├── chapter3_vetal_tekdi.tscn
│           ├── chapter4_cafe.tscn
│           ├── chapter5_college_night.tscn
│           └── chapter6_railway_station.tscn
│
└── tests/
    ├── test_runner.gd                # Automated in-engine integration test script
    └── test_runner.tscn              # Automated test scene
```

---

## 🎮 How to Play

### Testing on PC
Double-click `launch_game.bat` or run:
```powershell
& "C:\Users\appar\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64.exe" --path "g:\DESKTOP\trail 2"
```

#### Controls:
- **Move**: `W`, `A`, `S`, `D` or Arrow keys
- **Run / Sprint**: Hold `Shift`
- **Camera Look**: Hold `Right Mouse Button` and drag
- **Interact / Progress Dialogue**: Press `E` or `Space` or tap on screen
- **Pause Menu**: Press `Escape` or click `⏸ Menu` on top-right

### Playing on Android
- **Move**: Drag the **Virtual Joystick** on the bottom-left with your left thumb.
- **Look**: Swipe anywhere on the right half of the screen with your right thumb.
- **Sprint**: Tap the `🏃` icon on the bottom right.
- **Interact**: Tap the `💬 Interact` button whenever near Meera, characters, or story items.
- **Advance Dialogue / Choice**: Tap on the dialogue box or tap choice options `A`, `B`, or `C`.

---

## 📱 Android APK Export Instructions

The project includes a ready-to-export configuration in `export_presets.cfg` (`com.aftertherain.game`, Min SDK 24, Target SDK 34, GLES3 / Compatibility).

### Prerequisites on your development machine:
1. **Java Development Kit (JDK 17)**:
   Ensure `JAVA_HOME` points to JDK 17 (e.g. Eclipse Temurin or OpenJDK 17).
2. **Android SDK & Command-line Tools**:
   Install via Android Studio or command-line tools:
   - `build-tools;34.0.0`
   - `platforms;android-34`
   - `platform-tools`
3. **Generate a Debug Keystore** (standard Android command):
   ```bash
   keytool -keyalg RSA -genkeypair -alias androiddebugkey -keypass android -keystore debug.keystore -storepass android -dname "CN=Android Debug,O=Android,C=US" -validity 9999 -deststoretype pkcs12
   ```
4. **Configure Godot Editor Settings**:
   - In Godot Editor: `Editor` -> `Editor Settings` -> `Export` -> `Android`.
   - Set **Android SDK Path** to your SDK folder (e.g. `C:/Users/<Username>/AppData/Local/Android/Sdk`).
   - Set **Debug Keystore** to the path of your `debug.keystore`.
5. **Export the APK**:
   - In Godot Editor: `Project` -> `Export` -> select `Android` -> click `Export Project`.
   - Or from command line:
     ```bash
     godot --headless --export-debug "Android" ./builds/android/AfterTheRain.apk
     ```

---

## 🧪 Automated Test Verification

An automated in-engine test suite (`tests/test_runner.tscn`) validates:
1. Autoload initialization (`GameManager`, `StoryManager`, `SaveSystem`, `AudioManager`).
2. Complete 6-chapter story database and 4-ending configurations.
3. Persistent Save / Load serialization to `user://after_the_rain_save.json`.
4. Branch calculation logic for all 4 endings based on `Affection`, `Trust`, and `Insecurity`.

To run the automated verification suite, double-click `run_tests.bat` or run:
```powershell
& "C:\Users\appar\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.2-stable_win64_console.exe" --headless --path "g:\DESKTOP\trail 2" "res://tests/test_runner.tscn"
```
**Result**: 100% of integration checks passed with exit code 0.

---

## 💡 Notes on External Assets & Customization

- **3D Characters**: The current models use procedural, anime-proportioned geometric character meshes designed for 60+ FPS on mobile hardware with expressiveness, walking cycles, and real-time head look-at. If you wish to import external rigged 3D humanoid models (such as `.vrm`, `.glb`, or `.gltf` character models), simply replace the visual meshes inside `character_mesh_aarav.tscn` and `character_mesh_meera.tscn`. The third-person controller, camera, and interaction areas will adapt automatically.
- **Audio**: Built-in procedural audio synthesizers produce rain ambience and romantic music dynamically. To replace them with recorded Marathi/Hindi instrumental soundtracks or rain recordings, place your audio files in `res://assets/audio/` (e.g. `rain_melancholy.ogg`, `monsoon_rain.ogg`, `golden_sunset.ogg`) and the `audio_manager.gd` will automatically load them.

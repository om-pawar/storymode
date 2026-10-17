class GameApp {
  constructor() {
    this.canvas = document.getElementById('webgl-canvas');
    this.ui = new UIManager();
    this.controls = new InputController(this.canvas);

    this.currentChapter = 1;
    this.stats = {
      affection: 20,
      trust: 20,
      friendship: 30,
      insecurity: 0,
      romance: 0,
      flags: {}
    };

    this.playerState = {
      pos: new THREE.Vector3(0, 0, 4),
      rot: 0,
      speed: 0
    };

    this.dialogueQueue = [];
    this.dialogueIdx = -1;
    this.pendingChoices = [];
    this.pendingPost = null;

    this.paperCollected = false;
    this.isDialogueActive = false;

    this._initThree();
    this._loadSave();
    this._bindUI();
  }

  _initThree() {
    this.scene = new THREE.Scene();
    this.scene.background = new THREE.Color(0x131924);
    this.scene.fog = new THREE.FogExp2(0x131924, 0.025);

    this.camera = new THREE.PerspectiveCamera(65, window.innerWidth / window.innerHeight, 0.1, 100);

    this.renderer = new THREE.WebGLRenderer({ canvas: this.canvas, antialias: true, alpha: false });
    this.renderer.setSize(window.innerWidth, window.innerHeight);
    this.renderer.setPixelRatio(Math.min(window.devicePixelRatio, 2));
    this.renderer.toneMapping = THREE.ACESFilmicToneMapping;
    this.renderer.toneMappingExposure = 1.1;

    // Lights
    this.ambientLight = new THREE.AmbientLight(0x7085a6, 0.9);
    this.scene.add(this.ambientLight);

    this.dirLight = new THREE.DirectionalLight(0xa5c2eb, 0.8);
    this.dirLight.position.set(10, 20, 10);
    this.scene.add(this.dirLight);

    // Rain
    this.rain = EnvironmentBuilder.createRainSystem();
    this.scene.add(this.rain.mesh);

    // Characters
    this.aarav = CharacterBuilder.createAarav();
    this.scene.add(this.aarav.mesh);

    this.meera = CharacterBuilder.createMeera();
    this.scene.add(this.meera.mesh);

    this.rohan = CharacterBuilder.createRohan();
    this.scene.add(this.rohan.mesh);

    window.addEventListener('resize', () => {
      this.camera.aspect = window.innerWidth / window.innerHeight;
      this.camera.updateProjectionMatrix();
      this.renderer.setSize(window.innerWidth, window.innerHeight);
    });

    this.lastTime = performance.now();
    requestAnimationFrame((t) => this._gameLoop(t));
  }

  _loadSave() {
    try {
      const saved = localStorage.getItem('after_the_rain_web_save');
      if (saved) {
        const parsed = JSON.parse(saved);
        this.currentChapter = parsed.currentChapter || 1;
        this.stats = parsed.stats || this.stats;
      }
    } catch(e) {}
  }

  _saveGame() {
    try {
      localStorage.setItem('after_the_rain_web_save', JSON.stringify({
        currentChapter: this.currentChapter,
        stats: this.stats
      }));
    } catch(e) {}
  }

  startChapter(chapterNum) {
    this.currentChapter = chapterNum;
    this._saveGame();

    // Remove old level
    if (this.currentLevel) {
      this.scene.remove(this.currentLevel);
    }

    this.currentLevel = EnvironmentBuilder.createLevel(chapterNum);
    this.scene.add(this.currentLevel);

    const chapData = STORY_DATA.chapters[chapterNum];
    this.ui.updateHUD(chapData, this.stats);

    // Reposition characters for this chapter
    this._setupChapterScene(chapterNum);

    // Audio
    if (window.audioEngine) {
      window.audioEngine.playBgm();
      if (chapterNum === 1 || chapterNum === 6) {
        window.audioEngine.playRain();
      } else {
        window.audioEngine.stopRain();
      }
    }

    // Intro monologue for Chapter 1
    if (chapterNum === 1 && chapData.intro_monologue) {
      setTimeout(() => {
        this.startDialogue(chapData.intro_monologue);
      }, 700);
    }
  }

  _setupChapterScene(chapNum) {
    this.aarav.mesh.position.set(-1.5, 0, 3.5);
    this.playerState.pos.set(-1.5, 0, 3.5);

    switch (chapNum) {
      case 1:
        this.meera.mesh.position.set(0.8, 0, -3.2);
        this.meera.mesh.visible = true;
        this.rohan.mesh.visible = false;
        this.paperCollected = false;
        break;
      case 2:
        this.meera.mesh.position.set(2.5, 0, -3.5);
        this.meera.mesh.visible = true;
        this.rohan.mesh.position.set(-1.8, 0, -3.6);
        this.rohan.mesh.visible = true;
        break;
      case 3:
        this.meera.mesh.position.set(0.6, 0, -5.2);
        this.meera.mesh.visible = true;
        this.rohan.mesh.visible = false;
        break;
      case 4:
        this.meera.mesh.position.set(0, 0, -3.6);
        this.meera.mesh.visible = true;
        this.rohan.mesh.visible = false;
        break;
      case 5:
        this.meera.mesh.position.set(0.8, 0, -3.8);
        this.meera.mesh.visible = true;
        this.rohan.mesh.visible = false;
        break;
      case 6:
        this.meera.mesh.position.set(0.6, 0, -4.5);
        this.meera.mesh.visible = true;
        this.rohan.mesh.visible = false;
        break;
    }
  }

  startDialogue(lines, choices = [], postEvent = null) {
    if (!lines || lines.length === 0) return;
    this.isDialogueActive = true;
    this.dialogueQueue = lines;
    this.dialogueIdx = -1;
    this.pendingChoices = choices;
    this.pendingPost = postEvent;
    this._advanceDialogue();
  }

  _advanceDialogue() {
    this.dialogueIdx++;
    if (this.dialogueIdx < this.dialogueQueue.length) {
      const line = this.dialogueQueue[this.dialogueIdx];
      this.ui.showDialogue(line, () => this._advanceDialogue());
    } else {
      // Finished lines
      if (this.pendingChoices && this.pendingChoices.length > 0) {
        const c = this.pendingChoices;
        this.pendingChoices = [];
        this.ui.showChoices(c, (idx, choice) => this._onChoiceSelected(idx, choice));
      } else {
        this.ui.hideDialogue();
        this.isDialogueActive = false;
        if (this.pendingPost) {
          const post = this.pendingPost;
          this.pendingPost = null;
          this.startDialogue(Array.isArray(post) ? post : [post]);
        }
      }
    }
  }

  _onChoiceSelected(idx, choice) {
    // Apply stat effects
    const eff = choice.effects || {};
    ['affection', 'trust', 'friendship', 'insecurity', 'romance'].forEach(stat => {
      if (eff[stat] !== undefined) {
        this.stats[stat] = Math.max(0, Math.min(100, this.stats[stat] + eff[stat]));
      }
    });

    Object.keys(eff).forEach(k => {
      if (!['affection', 'trust', 'friendship', 'insecurity', 'romance'].includes(k)) {
        this.stats.flags[k] = eff[k];
      }
    });

    this.ui.updateStats(this.stats);
    this._saveGame();

    if (choice.response && choice.response.length > 0) {
      this.startDialogue(choice.response, [], this.pendingPost);
    } else {
      this.ui.hideDialogue();
      this.isDialogueActive = false;
    }
  }

  _gameLoop(time) {
    const delta = Math.min((time - this.lastTime) / 1000, 0.1);
    this.lastTime = time;

    // Movement & camera
    this._updatePlayer(delta);

    // Characters & rain animation
    if (this.rain) this.rain.update(delta, this.playerState.pos);
    if (this.aarav) this.aarav.updateAnimation(this.playerState.speed, delta);
    if (this.meera && this.meera.mesh.visible) {
      this.meera.updateAnimation(0, delta);
      if (this.isDialogueActive) {
        this.meera.lookAtCharacter(this.playerState.pos);
      }
    }
    if (this.rohan && this.rohan.mesh.visible) this.rohan.updateAnimation(0, delta);

    // Floating paper wind anim in Chapter 1
    if (this.currentChapter === 1 && !this.paperCollected && this.currentLevel) {
      const paper = this.currentLevel.getObjectByName('FlyingPaper');
      if (paper) {
        paper.position.y = 0.5 + Math.sin(time * 0.0035) * 0.15;
        paper.rotation.y += delta * 1.5;
        paper.rotation.z = Math.sin(time * 0.002) * 0.2;
      }
    }

    // Proximity checks for interact prompt
    this._checkInteractions();

    this.renderer.render(this.scene, this.camera);
    requestAnimationFrame((t) => this._gameLoop(t));
  }

  _updatePlayer(delta) {
    if (this.isDialogueActive) {
      this.playerState.speed = 0;
      return;
    }

    const { x, z, isSprinting } = this.controls.getMovementVector();
    const speedVal = isSprinting ? 6.2 : 3.6;

    if (x !== 0 || z !== 0) {
      // Move relative to camera yaw
      const moveX = x * Math.cos(this.controls.camYaw) + z * Math.sin(this.controls.camYaw);
      const moveZ = -x * Math.sin(this.controls.camYaw) + z * Math.cos(this.controls.camYaw);

      this.playerState.pos.x += moveX * speedVal * delta;
      this.playerState.pos.z += moveZ * speedVal * delta;

      // Bound to play area
      this.playerState.pos.x = THREE.MathUtils.clamp(this.playerState.pos.x, -16, 16);
      this.playerState.pos.z = THREE.MathUtils.clamp(this.playerState.pos.z, -16, 16);

      this.playerState.rot = Math.atan2(moveX, moveZ);
      this.aarav.mesh.rotation.y = THREE.MathUtils.lerp(this.aarav.mesh.rotation.y, this.playerState.rot, delta * 12.0);
      this.playerState.speed = speedVal;
    } else {
      this.playerState.speed = 0;
    }

    this.aarav.mesh.position.copy(this.playerState.pos);

    // Third-person Camera position
    const camDist = 3.6;
    const camHeight = 1.4 + this.controls.camPitch * 2.2;
    const targetX = this.playerState.pos.x - Math.sin(this.controls.camYaw) * camDist;
    const targetZ = this.playerState.pos.z - Math.cos(this.controls.camYaw) * camDist;

    this.camera.position.set(targetX, camHeight, targetZ);
    this.camera.lookAt(this.playerState.pos.x, 1.4, this.playerState.pos.z);
  }

  _checkInteractions() {
    const interactBtn = document.getElementById('interact-btn');
    const pPos = this.playerState.pos;

    // Chapter 1: Catch Flying Paper
    if (this.currentChapter === 1 && !this.paperCollected) {
      const dist = pPos.distanceTo(new THREE.Vector3(2.4, 0, 1.6));
      if (dist < 2.0) {
        interactBtn.classList.remove('hidden');
        interactBtn.textContent = '📄 Catch Paper';
        this.activeInteract = () => this._catchPaper();
        return;
      }
    }

    // Meera interaction
    if (this.meera && this.meera.mesh.visible) {
      const dist = pPos.distanceTo(this.meera.mesh.position);
      if (dist < 2.4 && !this.isDialogueActive) {
        interactBtn.classList.remove('hidden');
        interactBtn.textContent = '💬 Talk to Meera';
        this.activeInteract = () => this._talkToMeera();
        return;
      }
    }

    // Rohan interaction in Chapter 2
    if (this.currentChapter === 2 && this.rohan && this.rohan.mesh.visible) {
      const dist = pPos.distanceTo(this.rohan.mesh.position);
      if (dist < 2.4 && !this.isDialogueActive) {
        interactBtn.classList.remove('hidden');
        interactBtn.textContent = '💬 Talk to Rohan';
        this.activeInteract = () => this._talkToRohan();
        return;
      }
    }

    interactBtn.classList.add('hidden');
    this.activeInteract = null;
  }

  _catchPaper() {
    this.paperCollected = true;
    if (window.audioEngine) window.audioEngine.playSfx('catch');

    const paper = this.currentLevel.getObjectByName('FlyingPaper');
    if (paper) paper.visible = false;

    const chap = STORY_DATA.chapters[1];
    const lines = chap.events.paper_caught;
    this.startDialogue(lines, [], () => {
      this.ui.showMissionComplete('The First Meeting');
      setTimeout(() => this.startChapter(2), 3500);
    });
  }

  _talkToMeera() {
    const chap = STORY_DATA.chapters[this.currentChapter];
    switch (this.currentChapter) {
      case 1:
        this.startDialogue(chap.events.paper_caught);
        break;
      case 2:
        this.startDialogue(chap.events.meet_meera, [], () => {
          setTimeout(() => {
            this.ui.showPhoneChat(chap.events.phone_chat, 'Meera 🌸', () => {
              this.ui.showMissionComplete('Chaha Ani Gappa');
              setTimeout(() => this.startChapter(3), 3200);
            });
          }, 1200);
        });
        break;
      case 3:
        this.startDialogue(chap.dialogue, chap.choices, () => {
          this.ui.showMissionComplete('Something More Than Friendship');
          setTimeout(() => this.startChapter(4), 3500);
        });
        break;
      case 4:
        this.startDialogue(chap.dialogue, chap.choices, () => {
          this.ui.showMissionComplete('Between Love and Dreams');
          setTimeout(() => this.startChapter(5), 3500);
        });
        break;
      case 5:
        this.startDialogue(chap.dialogue, chap.choices, () => {
          this.ui.showMissionComplete('Trust Is a Choice');
          setTimeout(() => this.startChapter(6), 3500);
        });
        break;
      case 6:
        this.startDialogue(chap.dialogue, [], () => {
          this.ui.showMissionComplete('Shevatcha Paaus');
          setTimeout(() => this._evaluateAndShowEnding(), 3200);
        });
        break;
    }
  }

  _talkToRohan() {
    const chap = STORY_DATA.chapters[2];
    this.startDialogue(chap.events.with_rohan, [], () => {
      document.getElementById('mission-objective').textContent = "🎯 Go over to Meera's table and say hello!";
    });
  }

  _evaluateAndShowEnding() {
    const aff = this.stats.affection;
    const tru = this.stats.trust;
    const insec = this.stats.insecurity;

    let endingKey = '1';
    if (insec >= 35 || tru < 30) {
      endingKey = '4'; // Strangers Again
    } else if (aff >= 60 && tru >= 60 && insec < 30) {
      endingKey = '1'; // Aapla Prem
    } else if (aff >= 40 && tru >= 40) {
      endingKey = '2'; // Distance
    } else {
      endingKey = '3'; // Unfinished Story
    }

    const endingData = STORY_DATA.endings[endingKey];
    this.ui.showEnding(endingData, this.stats, () => {
      this.stats = { affection: 20, trust: 20, friendship: 30, insecurity: 0, romance: 0, flags: {} };
      this.startChapter(1);
    });
  }

  _bindUI() {
    // Main Menu Buttons
    document.getElementById('menu-new-game').onclick = () => {
      this.stats = { affection: 20, trust: 20, friendship: 30, insecurity: 0, romance: 0, flags: {} };
      document.getElementById('main-menu').classList.add('hidden');
      document.getElementById('game-hud').classList.remove('hidden');
      this.startChapter(1);
    };

    const continueBtn = document.getElementById('menu-continue');
    continueBtn.onclick = () => {
      document.getElementById('main-menu').classList.add('hidden');
      document.getElementById('game-hud').classList.remove('hidden');
      this.startChapter(this.currentChapter);
    };

    document.getElementById('menu-chapter-select').onclick = () => {
      const modal = document.getElementById('chapter-select-modal');
      const list = document.getElementById('chapter-list');
      list.innerHTML = '';
      for (let i = 1; i <= 6; i++) {
        const b = document.createElement('button');
        b.className = 'chapter-btn';
        b.textContent = STORY_DATA.chapters[i].title;
        b.onclick = () => {
          modal.classList.add('hidden');
          document.getElementById('main-menu').classList.add('hidden');
          document.getElementById('game-hud').classList.remove('hidden');
          this.startChapter(i);
        };
        list.appendChild(b);
      }
      modal.classList.remove('hidden');
    };

    document.getElementById('close-chapter-select').onclick = () => {
      document.getElementById('chapter-select-modal').classList.add('hidden');
    };

    document.getElementById('menu-credits').onclick = () => {
      document.getElementById('credits-modal').classList.remove('hidden');
    };

    document.getElementById('close-credits').onclick = () => {
      document.getElementById('credits-modal').classList.add('hidden');
    };

    // HUD & Pause Buttons
    document.getElementById('pause-btn').onclick = () => {
      document.getElementById('pause-modal').classList.remove('hidden');
    };

    document.getElementById('pause-resume').onclick = () => {
      document.getElementById('pause-modal').classList.add('hidden');
    };

    document.getElementById('pause-restart').onclick = () => {
      document.getElementById('pause-modal').classList.add('hidden');
      this.startChapter(this.currentChapter);
    };

    document.getElementById('pause-title').onclick = () => {
      document.getElementById('pause-modal').classList.add('hidden');
      document.getElementById('game-hud').classList.add('hidden');
      document.getElementById('main-menu').classList.remove('hidden');
      if (window.audioEngine) {
        window.audioEngine.stopBgm();
        window.audioEngine.stopRain();
      }
    };

    // Mobile Action buttons
    const sprintBtn = document.getElementById('sprint-btn');
    sprintBtn.onclick = () => {
      window.mobileSprintActive = !window.mobileSprintActive;
      sprintBtn.style.borderColor = window.mobileSprintActive ? '#ff4b72' : 'rgba(100, 180, 255, 0.7)';
    };

    const interactBtn = document.getElementById('interact-btn');
    interactBtn.onclick = () => {
      if (this.activeInteract) this.activeInteract();
    };

    window.addEventListener('player-interact', () => {
      if (this.activeInteract) this.activeInteract();
    });
  }
}

window.addEventListener('DOMContentLoaded', () => {
  window.gameApp = new GameApp();
});

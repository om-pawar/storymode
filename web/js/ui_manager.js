class UIManager {
  constructor() {
    // Top bar elements
    this.chapterTitleEl = document.getElementById('chapter-title');
    this.locationEl = document.getElementById('chapter-location');
    this.objectiveEl = document.getElementById('mission-objective');
    this.affectionEl = document.getElementById('stat-affection');
    this.trustEl = document.getElementById('stat-trust');

    // Dialogue elements
    this.dialogueBox = document.getElementById('dialogue-box');
    this.speakerNameEl = document.getElementById('speaker-name');
    this.speakerInitialEl = document.getElementById('speaker-initial');
    this.portraitRect = document.getElementById('speaker-portrait');
    this.emotionEl = document.getElementById('speaker-emotion');
    this.marathiTextEl = document.getElementById('marathi-text');
    this.englishTextEl = document.getElementById('english-text');

    // Choices
    this.choicesModal = document.getElementById('choices-modal');
    this.choicesList = document.getElementById('choices-list');

    // Phone
    this.phoneModal = document.getElementById('phone-modal');
    this.phoneMessages = document.getElementById('phone-messages');
    this.phoneTyping = document.getElementById('phone-typing');
    this.phoneReplyBtn = document.getElementById('phone-reply-btn');

    // Banner
    this.missionBanner = document.getElementById('mission-banner');
    this.missionBannerText = document.getElementById('mission-banner-text');

    // Endings & Modals
    this.endingScreen = document.getElementById('ending-screen');
    this.endingTitleEl = document.getElementById('ending-title');
    this.endingSummaryEl = document.getElementById('ending-summary');
    this.endingEpilogueEl = document.getElementById('ending-epilogue');
    this.endingStatsEl = document.getElementById('ending-stats');

    this.mainMenu = document.getElementById('main-menu');
    this.chapterSelectModal = document.getElementById('chapter-select-modal');
    this.creditsModal = document.getElementById('credits-modal');
    this.pauseModal = document.getElementById('pause-modal');

    // Typewriter
    this.isTyping = false;
    this.typeInterval = null;
  }

  updateHUD(chapterData, stats) {
    if (this.chapterTitleEl) this.chapterTitleEl.textContent = chapterData.title;
    if (this.locationEl) this.locationEl.textContent = '📍 ' + chapterData.location;
    if (this.objectiveEl) this.objectiveEl.textContent = '🎯 ' + chapterData.objective;
    this.updateStats(stats);
  }

  updateStats(stats) {
    if (this.affectionEl) this.affectionEl.textContent = `❤️ ${stats.affection}`;
    if (this.trustEl) this.trustEl.textContent = `🤝 ${stats.trust}`;
  }

  showDialogue(line, onAdvance) {
    this.dialogueBox.classList.remove('hidden');
    this.choicesModal.classList.add('hidden');

    const speaker = line.speaker || 'Narrator';
    this.speakerNameEl.textContent = speaker;

    // Portrait
    if (speaker === 'Aarav') {
      this.portraitRect.style.background = '#25508a';
      this.speakerInitialEl.textContent = 'A';
    } else if (speaker === 'Meera') {
      this.portraitRect.style.background = '#d94b68';
      this.speakerInitialEl.textContent = 'M';
    } else if (speaker === 'Rohan') {
      this.portraitRect.style.background = '#d99824';
      this.speakerInitialEl.textContent = 'R';
    } else {
      this.portraitRect.style.background = '#444d5c';
      this.speakerInitialEl.textContent = '📖';
    }

    if (line.emotion) {
      this.emotionEl.textContent = '• ' + line.emotion.toUpperCase();
      this.emotionEl.style.display = 'inline';
    } else {
      this.emotionEl.style.display = 'none';
    }

    const marathi = line.marathi || line.text || '';
    const english = line.english || '';

    // Fast Typewriter
    this.isTyping = true;
    this.marathiTextEl.textContent = '';
    this.englishTextEl.textContent = '';

    let charIdx = 0;
    if (this.typeInterval) clearInterval(this.typeInterval);

    this.typeInterval = setInterval(() => {
      charIdx += 2;
      this.marathiTextEl.textContent = marathi.slice(0, charIdx);
      this.englishTextEl.textContent = english.slice(0, charIdx);

      if (charIdx % 4 === 0 && window.audioEngine) {
        window.audioEngine.playSfx('blip');
      }

      if (charIdx >= Math.max(marathi.length, english.length)) {
        clearInterval(this.typeInterval);
        this.marathiTextEl.textContent = marathi;
        this.englishTextEl.textContent = english;
        this.isTyping = false;
      }
    }, 25);

    // Tap to skip typewriter or advance
    this.dialogueBox.onclick = () => {
      if (this.isTyping) {
        clearInterval(this.typeInterval);
        this.marathiTextEl.textContent = marathi;
        this.englishTextEl.textContent = english;
        this.isTyping = false;
      } else {
        if (onAdvance) onAdvance();
      }
    };
  }

  hideDialogue() {
    this.dialogueBox.classList.add('hidden');
    this.dialogueBox.onclick = null;
  }

  showChoices(choices, onSelect) {
    this.choicesList.innerHTML = '';
    this.choicesModal.classList.remove('hidden');

    choices.forEach((choice, idx) => {
      const btn = document.createElement('button');
      btn.className = 'choice-btn';
      btn.textContent = choice.label;
      btn.onclick = () => {
        if (window.audioEngine) window.audioEngine.playSfx('choice');
        this.choicesModal.classList.add('hidden');
        onSelect(idx, choice);
      };
      this.choicesList.appendChild(btn);
    });
  }

  showMissionComplete(title) {
    if (window.audioEngine) window.audioEngine.playSfx('mission');
    this.missionBannerText.textContent = `✨ MISSION COMPLETE: ${title.toUpperCase()}`;
    this.missionBanner.classList.remove('hidden');
    setTimeout(() => {
      this.missionBanner.classList.add('hidden');
    }, 3800);
  }

  showPhoneChat(messages, contactName = 'Meera 🌸', onComplete) {
    this.phoneModal.classList.remove('hidden');
    this.phoneMessages.innerHTML = '';
    this.phoneTyping.classList.add('hidden');

    let step = 0;
    const processNext = () => {
      if (step >= messages.length) {
        this.phoneTyping.classList.add('hidden');
        this.phoneReplyBtn.textContent = 'Close Phone';
        this.phoneReplyBtn.onclick = () => {
          this.phoneModal.classList.add('hidden');
          if (onComplete) onComplete();
        };
        return;
      }

      const msg = messages[step];
      if (msg.sender === 'Meera') {
        this.phoneTyping.classList.remove('hidden');
        this.phoneReplyBtn.disabled = true;
        setTimeout(() => {
          this.phoneTyping.classList.add('hidden');
          this._addPhoneBubble(msg.text, false);
          if (window.audioEngine) window.audioEngine.playSfx('phone');
          step++;
          processNext();
        }, 1100);
      } else if (msg.sender === 'Aarav') {
        this.phoneReplyBtn.disabled = false;
        this.phoneReplyBtn.textContent = `Send: "${msg.text}"`;
        this.phoneReplyBtn.onclick = () => {
          this._addPhoneBubble(msg.text, true);
          if (window.audioEngine) window.audioEngine.playSfx('blip');
          step++;
          processNext();
        };
      } else {
        // System note / Thought
        const note = document.createElement('div');
        note.className = 'phone-note';
        note.textContent = msg.text;
        this.phoneMessages.appendChild(note);
        step++;
        processNext();
      }
    };

    processNext();
  }

  _addPhoneBubble(text, isPlayer) {
    const bubble = document.createElement('div');
    bubble.className = `phone-bubble ${isPlayer ? 'player' : 'contact'}`;
    bubble.textContent = text;
    this.phoneMessages.appendChild(bubble);
    this.phoneMessages.scrollTop = this.phoneMessages.scrollHeight;
  }

  showEnding(endingData, stats, onReplay) {
    this.endingScreen.classList.remove('hidden');
    this.endingTitleEl.textContent = endingData.title;
    this.endingSummaryEl.textContent = endingData.summary;

    this.endingEpilogueEl.innerHTML = '';
    (endingData.epilogue || []).forEach(p => {
      const para = document.createElement('p');
      para.textContent = p;
      this.endingEpilogueEl.appendChild(para);
    });

    this.endingStatsEl.textContent = `Final Bond: ❤️ Affection ${stats.affection} | 🤝 Trust ${stats.trust} | ⚠️ Insecurity ${stats.insecurity}`;

    document.getElementById('ending-replay-btn').onclick = () => {
      this.endingScreen.classList.add('hidden');
      if (onReplay) onReplay();
    };

    document.getElementById('ending-epilogue-btn').onclick = () => {
      const finalData = STORY_DATA.final_scene;
      const msgs = (finalData.dialogue || []).map(d => ({
        sender: d.sender || 'Aarav_Thought',
        text: d.text
      }));
      this.showPhoneChat(msgs, 'Meera 🌸', () => {});
    };
  }
}

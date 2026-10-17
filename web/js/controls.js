class InputController {
  constructor(canvas) {
    this.canvas = canvas;
    this.keys = {};
    this.moveVector = { x: 0, z: 0 };
    this.isSprinting = false;

    // Camera angles
    this.camYaw = 0;
    this.camPitch = 0.25;

    // Mouse drag
    this.isMouseDown = false;
    this.lastMouse = { x: 0, y: 0 };

    // Mobile touch
    this.joystickActive = false;
    this.joystickTouchId = null;
    this.joystickCenter = { x: 0, y: 0 };

    this.lookTouchId = null;
    this.lastLookTouch = { x: 0, y: 0 };

    this._bindEvents();
  }

  _bindEvents() {
    window.addEventListener('keydown', (e) => {
      this.keys[e.code] = true;
      if (e.code === 'KeyE' || e.code === 'Space') {
        window.dispatchEvent(new CustomEvent('player-interact'));
      }
    });

    window.addEventListener('keyup', (e) => {
      this.keys[e.code] = false;
    });

    // Mouse controls
    this.canvas.addEventListener('mousedown', (e) => {
      this.isMouseDown = true;
      this.lastMouse = { x: e.clientX, y: e.clientY };
    });

    window.addEventListener('mouseup', () => {
      this.isMouseDown = false;
    });

    window.addEventListener('mousemove', (e) => {
      if (this.isMouseDown) {
        const dx = e.clientX - this.lastMouse.x;
        const dy = e.clientY - this.lastMouse.y;
        this.lastMouse = { x: e.clientX, y: e.clientY };

        this.camYaw -= dx * 0.005;
        this.camPitch = Math.max(-0.4, Math.min(0.6, this.camPitch + dy * 0.005));
      }
    });

    // Touch events for mobile
    const joyBase = document.getElementById('virtual-joystick');
    const joyTip = document.getElementById('joystick-tip');

    window.addEventListener('touchstart', (e) => {
      for (let i = 0; i < e.changedTouches.length; i++) {
        const touch = e.changedTouches[i];
        if (touch.clientX < window.innerWidth * 0.4 && !this.joystickActive) {
          // Joystick touch
          this.joystickActive = true;
          this.joystickTouchId = touch.identifier;
          this.joystickCenter = { x: touch.clientX, y: touch.clientY };
          this._updateJoystick(touch, joyTip);
        } else if (touch.clientX >= window.innerWidth * 0.4 && this.lookTouchId === null) {
          // Look touch
          this.lookTouchId = touch.identifier;
          this.lastLookTouch = { x: touch.clientX, y: touch.clientY };
        }
      }
    }, { passive: false });

    window.addEventListener('touchmove', (e) => {
      for (let i = 0; i < e.changedTouches.length; i++) {
        const touch = e.changedTouches[i];
        if (touch.identifier === this.joystickTouchId) {
          this._updateJoystick(touch, joyTip);
        } else if (touch.identifier === this.lookTouchId) {
          const dx = touch.clientX - this.lastLookTouch.x;
          const dy = touch.clientY - this.lastLookTouch.y;
          this.lastLookTouch = { x: touch.clientX, y: touch.clientY };

          this.camYaw -= dx * 0.006;
          this.camPitch = Math.max(-0.4, Math.min(0.6, this.camPitch + dy * 0.006));
        }
      }
    }, { passive: false });

    const resetTouch = (e) => {
      for (let i = 0; i < e.changedTouches.length; i++) {
        const touch = e.changedTouches[i];
        if (touch.identifier === this.joystickTouchId) {
          this.joystickActive = false;
          this.joystickTouchId = null;
          this.moveVector = { x: 0, z: 0 };
          if (joyTip) joyTip.style.transform = `translate(0px, 0px)`;
        } else if (touch.identifier === this.lookTouchId) {
          this.lookTouchId = null;
        }
      }
    };

    window.addEventListener('touchend', resetTouch);
    window.addEventListener('touchcancel', resetTouch);
  }

  _updateJoystick(touch, tip) {
    const dx = touch.clientX - this.joystickCenter.x;
    const dy = touch.clientY - this.joystickCenter.y;
    const dist = Math.sqrt(dx * dx + dy * dy);
    const maxDist = 55;

    let normX = 0;
    let normY = 0;

    if (dist > 8) {
      const clampDist = Math.min(dist, maxDist);
      normX = (dx / dist) * (clampDist / maxDist);
      normY = (dy / dist) * (clampDist / maxDist);
      if (tip) tip.style.transform = `translate(${normX * 45}px, ${normY * 45}px)`;
    } else {
      if (tip) tip.style.transform = `translate(0px, 0px)`;
    }

    this.moveVector = { x: normX, z: normY };
  }

  getMovementVector() {
    let kx = 0;
    let kz = 0;
    if (this.keys['KeyW'] || this.keys['ArrowUp']) kz -= 1;
    if (this.keys['KeyS'] || this.keys['ArrowDown']) kz += 1;
    if (this.keys['KeyA'] || this.keys['ArrowLeft']) kx -= 1;
    if (this.keys['KeyD'] || this.keys['ArrowRight']) kx += 1;

    let x = this.moveVector.x + kx;
    let z = this.moveVector.z + kz;

    const len = Math.sqrt(x * x + z * z);
    if (len > 1.0) {
      x /= len;
      z /= len;
    }

    this.isSprinting = !!(this.keys['ShiftLeft'] || this.keys['ShiftRight'] || window.mobileSprintActive);

    return { x, z, isSprinting: this.isSprinting };
  }
}

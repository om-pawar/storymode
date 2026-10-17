class EnvironmentBuilder {
  static createRainSystem() {
    const count = 1200;
    const geometry = new THREE.BufferGeometry();
    const positions = new Float32Array(count * 3);
    const velocities = new Float32Array(count);

    for (let i = 0; i < count; i++) {
      positions[i * 3] = (Math.random() - 0.5) * 36;
      positions[i * 3 + 1] = Math.random() * 20;
      positions[i * 3 + 2] = (Math.random() - 0.5) * 36;
      velocities[i] = 18.0 + Math.random() * 8.0;
    }

    geometry.setAttribute('position', new THREE.BufferAttribute(positions, 3));

    const material = new THREE.PointsMaterial({
      color: 0xa8c8ec,
      size: 0.12,
      transparent: true,
      opacity: 0.6
    });

    const particles = new THREE.Points(geometry, material);

    return {
      mesh: particles,
      update(delta, playerPos) {
        const posAttr = geometry.attributes.position;
        const arr = posAttr.array;
        for (let i = 0; i < count; i++) {
          arr[i * 3 + 1] -= velocities[i] * delta;
          arr[i * 3] -= 3.0 * delta; // Wind tilt

          // Reset above player
          if (arr[i * 3 + 1] < 0) {
            arr[i * 3 + 1] = 18.0;
            arr[i * 3] = playerPos.x + (Math.random() - 0.5) * 32;
            arr[i * 3 + 2] = playerPos.z + (Math.random() - 0.5) * 32;
          }
        }
        posAttr.needsUpdate = true;
      }
    };
  }

  static createLevel(chapterNum) {
    const levelGroup = new THREE.Group();
    levelGroup.name = 'Level_' + chapterNum;

    switch (chapterNum) {
      case 1:
        this._buildChapter1FCRoad(levelGroup);
        break;
      case 2:
        this._buildChapter2ChaiTapri(levelGroup);
        break;
      case 3:
        this._buildChapter3VetalTekdi(levelGroup);
        break;
      case 4:
        this._buildChapter4Cafe(levelGroup);
        break;
      case 5:
        this._buildChapter5CollegeNight(levelGroup);
        break;
      case 6:
        this._buildChapter6RailwayStation(levelGroup);
        break;
    }

    return levelGroup;
  }

  static _buildChapter1FCRoad(group) {
    // Wet Road
    const roadGeo = new THREE.PlaneGeometry(40, 40);
    const roadMat = new THREE.MeshStandardMaterial({
      color: 0x181a1f,
      roughness: 0.2,
      metalness: 0.4
    });
    const road = new THREE.Mesh(roadGeo, roadMat);
    road.rotation.x = -Math.PI / 2;
    group.add(road);

    // Sidewalk
    const walkGeo = new THREE.BoxGeometry(40, 0.2, 8);
    const walkMat = new THREE.MeshLambertMaterial({ color: 0x33363d });
    const walk = new THREE.Mesh(walkGeo, walkMat);
    walk.position.set(0, 0.1, -4);
    group.add(walk);

    // Bus Stop
    const busStop = this._createBusStop();
    busStop.position.set(0, 0.2, -5);
    group.add(busStop);

    // Streetlamps
    group.add(this._createStreetLamp(-6, 0, -3.5));
    group.add(this._createStreetLamp(6, 0, -3.5));

    // Background Buildings
    group.add(this._createBuilding(-12, 5, -12, 10, 14, 6));
    group.add(this._createBuilding(12, 5, -12, 10, 14, 6));

    // Flying Paper Sketch
    const paperGeo = new THREE.PlaneGeometry(0.45, 0.55);
    const paperMat = new THREE.MeshBasicMaterial({ color: 0xffffff, side: THREE.DoubleSide });
    const paper = new THREE.Mesh(paperGeo, paperMat);
    paper.name = 'FlyingPaper';
    paper.position.set(2.4, 0.5, 1.6);
    group.add(paper);
  }

  static _buildChapter2ChaiTapri(group) {
    const groundGeo = new THREE.PlaneGeometry(35, 35);
    const groundMat = new THREE.MeshLambertMaterial({ color: 0x2b2824 });
    const ground = new THREE.Mesh(groundGeo, groundMat);
    ground.rotation.x = -Math.PI / 2;
    group.add(ground);

    // Chai Tapri
    const tapri = this._createChaiTapri();
    tapri.position.set(0, 0, -4.5);
    group.add(tapri);

    // College perimeter wall
    const wallGeo = new THREE.BoxGeometry(26, 3.5, 0.6);
    const wallMat = new THREE.MeshLambertMaterial({ color: 0x473d36 });
    const wall = new THREE.Mesh(wallGeo, wallMat);
    wall.position.set(0, 1.75, -8);
    group.add(wall);

    group.add(this._createStreetLamp(4, 0, -4));
  }

  static _buildChapter3VetalTekdi(group) {
    // Hilltop ground
    const hillGeo = new THREE.PlaneGeometry(45, 45);
    const hillMat = new THREE.MeshLambertMaterial({ color: 0x5a523e });
    const hill = new THREE.Mesh(hillGeo, hillMat);
    hill.rotation.x = -Math.PI / 2;
    group.add(hill);

    // Scenic rocks
    const rockGeo = new THREE.DodecahedronGeometry(1.4);
    const rockMat = new THREE.MeshLambertMaterial({ color: 0x4a4538 });
    const rock1 = new THREE.Mesh(rockGeo, rockMat);
    rock1.position.set(6, 0.8, -7);
    group.add(rock1);

    // Viewpoint Bench
    const bench = this._createBench();
    bench.position.set(0, 0, -6);
    group.add(bench);
  }

  static _buildChapter4Cafe(group) {
    // Warm Wood Floor
    const floorGeo = new THREE.PlaneGeometry(20, 20);
    const floorMat = new THREE.MeshStandardMaterial({ color: 0x40291d, roughness: 0.4 });
    const floor = new THREE.Mesh(floorGeo, floorMat);
    floor.rotation.x = -Math.PI / 2;
    group.add(floor);

    // Cafe Wall
    const wallGeo = new THREE.BoxGeometry(20, 4.5, 0.3);
    const wallMat = new THREE.MeshLambertMaterial({ color: 0x2e231e });
    const wall = new THREE.Mesh(wallGeo, wallMat);
    wall.position.set(0, 2.25, -6);
    group.add(wall);

    // Cafe Table
    const tableGeo = new THREE.CylinderGeometry(0.7, 0.7, 0.75, 16);
    const tableMat = new THREE.MeshLambertMaterial({ color: 0x5c3b28 });
    const table = new THREE.Mesh(tableGeo, tableMat);
    table.position.set(0, 0.38, -2.8);
    group.add(table);
  }

  static _buildChapter5CollegeNight(group) {
    const roadGeo = new THREE.PlaneGeometry(36, 36);
    const roadMat = new THREE.MeshLambertMaterial({ color: 0x1c1e22 });
    const road = new THREE.Mesh(roadGeo, roadMat);
    road.rotation.x = -Math.PI / 2;
    group.add(road);

    // Iron College Gate
    const gateGeo = new THREE.BoxGeometry(14, 4.5, 0.4);
    const gateMat = new THREE.MeshStandardMaterial({ color: 0x22262c, metalness: 0.8, roughness: 0.3 });
    const gate = new THREE.Mesh(gateGeo, gateMat);
    gate.position.set(0, 2.25, -6);
    group.add(gate);

    group.add(this._createStreetLamp(3, 0, -3.5));
  }

  static _buildChapter6RailwayStation(group) {
    // Platform
    const platGeo = new THREE.BoxGeometry(36, 0.6, 12);
    const platMat = new THREE.MeshLambertMaterial({ color: 0x404247 });
    const plat = new THREE.Mesh(platGeo, platMat);
    plat.position.set(0, -0.3, 0);
    group.add(plat);

    // Train Coach
    const train = this._createTrainWagon();
    train.position.set(0, 0, -8);
    group.add(train);

    group.add(this._createStreetLamp(-6, 0, 0));
    group.add(this._createStreetLamp(6, 0, 0));
  }

  static _createBusStop() {
    const group = new THREE.Group();
    const roofGeo = new THREE.BoxGeometry(4.6, 0.12, 2.4);
    const roofMat = new THREE.MeshLambertMaterial({ color: 0x244882 });
    const roof = new THREE.Mesh(roofGeo, roofMat);
    roof.position.set(0, 2.7, 0);
    roof.rotation.x = -0.15;
    group.add(roof);

    const pillarGeo = new THREE.CylinderGeometry(0.06, 0.06, 2.7, 8);
    const pillarMat = new THREE.MeshLambertMaterial({ color: 0xd0d5dd });
    const p1 = new THREE.Mesh(pillarGeo, pillarMat);
    p1.position.set(-2, 1.35, -0.9);
    const p2 = new THREE.Mesh(pillarGeo, pillarMat);
    p2.position.set(2, 1.35, -0.9);
    group.add(p1, p2);

    group.add(this._createBench(0, 0.25, -0.7));
    return group;
  }

  static _createChaiTapri() {
    const group = new THREE.Group();
    // Counter
    const counterGeo = new THREE.BoxGeometry(2.4, 0.9, 1.2);
    const counterMat = new THREE.MeshLambertMaterial({ color: 0x5a3922 });
    const counter = new THREE.Mesh(counterGeo, counterMat);
    counter.position.set(0, 0.45, 0);
    group.add(counter);

    // Awning
    const awnGeo = new THREE.BoxGeometry(2.8, 0.08, 1.8);
    const awnMat = new THREE.MeshLambertMaterial({ color: 0xb5352c });
    const awn = new THREE.Mesh(awnGeo, awnMat);
    awn.position.set(0, 2.3, 0.1);
    awn.rotation.x = -0.18;
    group.add(awn);

    // Chai Kettle
    const ketGeo = new THREE.CylinderGeometry(0.16, 0.22, 0.38, 10);
    const ketMat = new THREE.MeshStandardMaterial({ color: 0xdde2e6, metalness: 0.9, roughness: 0.2 });
    const ket = new THREE.Mesh(ketGeo, ketMat);
    ket.position.set(-0.6, 1.1, 0.1);
    group.add(ket);

    return group;
  }

  static _createBench(x = 0, y = 0.25, z = 0) {
    const benchGeo = new THREE.BoxGeometry(2.8, 0.4, 0.45);
    const benchMat = new THREE.MeshLambertMaterial({ color: 0x523420 });
    const bench = new THREE.Mesh(benchGeo, benchMat);
    bench.position.set(x, y, z);
    return bench;
  }

  static _createStreetLamp(x, y, z) {
    const group = new THREE.Group();
    group.position.set(x, y, z);

    const poleGeo = new THREE.CylinderGeometry(0.08, 0.12, 5.0, 8);
    const poleMat = new THREE.MeshLambertMaterial({ color: 0x2b3036 });
    const pole = new THREE.Mesh(poleGeo, poleMat);
    pole.position.y = 2.5;
    group.add(pole);

    const bulbGeo = new THREE.SphereGeometry(0.2, 8, 8);
    const bulbMat = new THREE.MeshBasicMaterial({ color: 0xffea9f });
    const bulb = new THREE.Mesh(bulbGeo, bulbMat);
    bulb.position.set(0.4, 4.8, 0);
    group.add(bulb);

    const light = new THREE.PointLight(0xffdf88, 2.2, 12);
    light.position.set(0.4, 4.8, 0);
    group.add(light);

    return group;
  }

  static _createBuilding(x, y, z, w, h, d) {
    const geo = new THREE.BoxGeometry(w, h, d);
    const mat = new THREE.MeshLambertMaterial({ color: 0x1f242e });
    const mesh = new THREE.Mesh(geo, mat);
    mesh.position.set(x, y, z);
    return mesh;
  }

  static _createTrainWagon() {
    const group = new THREE.Group();
    const bodyGeo = new THREE.BoxGeometry(16, 3.4, 2.8);
    const bodyMat = new THREE.MeshLambertMaterial({ color: 0x1b4085 });
    const body = new THREE.Mesh(bodyGeo, bodyMat);
    body.position.y = 1.8;
    group.add(body);

    const stripeGeo = new THREE.BoxGeometry(16.02, 0.35, 2.82);
    const stripeMat = new THREE.MeshLambertMaterial({ color: 0xf5cf38 });
    const stripe = new THREE.Mesh(stripeGeo, stripeMat);
    stripe.position.y = 1.1;
    group.add(stripe);

    return group;
  }
}

class CharacterBuilder {
  static createAarav() {
    const group = new THREE.Group();
    group.name = 'Aarav';

    // Materials
    const skinMat = new THREE.MeshLambertMaterial({ color: 0xf5d3ba });
    const hairMat = new THREE.MeshLambertMaterial({ color: 0x1a1a20 });
    const jacketMat = new THREE.MeshLambertMaterial({ color: 0x1f3c68 });
    const shirtMat = new THREE.MeshLambertMaterial({ color: 0xe0e6ed });
    const jeansMat = new THREE.MeshLambertMaterial({ color: 0x24334a });
    const backpackMat = new THREE.MeshLambertMaterial({ color: 0x8b2635 });
    const shoeMat = new THREE.MeshLambertMaterial({ color: 0x33251c });

    // Body container
    const body = new THREE.Group();
    group.add(body);

    // Torso (Jacket)
    const torsoGeo = new THREE.CylinderGeometry(0.24, 0.22, 0.65, 12);
    const torso = new THREE.Mesh(torsoGeo, jacketMat);
    torso.position.y = 1.1;
    body.add(torso);

    // Shirt center
    const shirtGeo = new THREE.BoxGeometry(0.14, 0.45, 0.25);
    const shirt = new THREE.Mesh(shirtGeo, shirtMat);
    shirt.position.set(0, 1.15, 0.08);
    body.add(shirt);

    // Backpack
    const packGeo = new THREE.BoxGeometry(0.34, 0.42, 0.2);
    const pack = new THREE.Mesh(packGeo, backpackMat);
    pack.position.set(0, 1.12, -0.22);
    body.add(pack);

    // Head
    const headGroup = new THREE.Group();
    headGroup.position.set(0, 1.6, 0);
    body.add(headGroup);

    const headGeo = new THREE.SphereGeometry(0.18, 14, 14);
    const head = new THREE.Mesh(headGeo, skinMat);
    headGroup.add(head);

    // Anime Hair
    const hairGeo = new THREE.BoxGeometry(0.38, 0.2, 0.38);
    const hair = new THREE.Mesh(hairGeo, hairMat);
    hair.position.set(0, 0.08, -0.02);
    headGroup.add(hair);

    // Legs
    const legGeo = new THREE.CylinderGeometry(0.08, 0.07, 0.75, 8);
    const shoeGeo = new THREE.BoxGeometry(0.12, 0.08, 0.2);

    const leftLeg = new THREE.Group();
    leftLeg.position.set(-0.12, 0.75, 0);
    const lLegMesh = new THREE.Mesh(legGeo, jeansMat);
    lLegMesh.position.y = -0.35;
    leftLeg.add(lLegMesh);
    const lShoe = new THREE.Mesh(shoeGeo, shoeMat);
    lShoe.position.set(0, -0.72, 0.04);
    leftLeg.add(lShoe);
    body.add(leftLeg);

    const rightLeg = new THREE.Group();
    rightLeg.position.set(0.12, 0.75, 0);
    const rLegMesh = new THREE.Mesh(legGeo, jeansMat);
    rLegMesh.position.y = -0.35;
    rightLeg.add(rLegMesh);
    const rShoe = new THREE.Mesh(shoeGeo, shoeMat);
    rShoe.position.set(0, -0.72, 0.04);
    rightLeg.add(rShoe);
    body.add(rightLeg);

    // Arms
    const armGeo = new THREE.CylinderGeometry(0.06, 0.05, 0.55, 8);

    const leftArm = new THREE.Group();
    leftArm.position.set(-0.3, 1.3, 0);
    const lArmMesh = new THREE.Mesh(armGeo, jacketMat);
    lArmMesh.position.y = -0.22;
    leftArm.add(lArmMesh);
    body.add(leftArm);

    const rightArm = new THREE.Group();
    rightArm.position.set(0.3, 1.3, 0);
    const rArmMesh = new THREE.Mesh(armGeo, jacketMat);
    rArmMesh.position.y = -0.22;
    rightArm.add(rArmMesh);
    body.add(rightArm);

    return {
      mesh: group,
      body,
      headGroup,
      leftLeg,
      rightLeg,
      leftArm,
      rightArm,
      walkPhase: 0,
      updateAnimation(speed, delta) {
        if (speed > 0.1) {
          const freq = speed > 4.0 ? 12.0 : 8.0;
          this.walkPhase += delta * freq;
          const armSwing = Math.sin(this.walkPhase) * 0.65;
          const legSwing = Math.sin(this.walkPhase) * 0.75;
          const bob = Math.abs(Math.cos(this.walkPhase)) * 0.08;

          leftLeg.rotation.x = legSwing;
          rightLeg.rotation.x = -legSwing;
          leftArm.rotation.x = -armSwing;
          rightArm.rotation.x = armSwing;
          body.position.y = bob;
        } else {
          this.walkPhase += delta * 2.0;
          body.position.y = Math.sin(this.walkPhase) * 0.025;
          leftLeg.rotation.x = THREE.MathUtils.lerp(leftLeg.rotation.x, 0, delta * 5.0);
          rightLeg.rotation.x = THREE.MathUtils.lerp(rightLeg.rotation.x, 0, delta * 5.0);
          leftArm.rotation.x = THREE.MathUtils.lerp(leftArm.rotation.x, 0, delta * 5.0);
          rightArm.rotation.x = THREE.MathUtils.lerp(rightArm.rotation.x, 0, delta * 5.0);
        }
      }
    };
  }

  static createMeera() {
    const group = new THREE.Group();
    group.name = 'Meera';

    const skinMat = new THREE.MeshLambertMaterial({ color: 0xf8d7c2 });
    const hairMat = new THREE.MeshLambertMaterial({ color: 0x331c12 });
    const kurtiMat = new THREE.MeshLambertMaterial({ color: 0xd95d73 });
    const dupattaMat = new THREE.MeshLambertMaterial({ color: 0x2e929b });
    const leggingMat = new THREE.MeshLambertMaterial({ color: 0xede4d4 });
    const bagMat = new THREE.MeshLambertMaterial({ color: 0x6e4324 });

    const body = new THREE.Group();
    group.add(body);

    // Torso (Kurti)
    const torsoGeo = new THREE.CylinderGeometry(0.2, 0.24, 0.62, 12);
    const torso = new THREE.Mesh(torsoGeo, kurtiMat);
    torso.position.y = 1.05;
    body.add(torso);

    // Dupatta drape
    const dupGeo = new THREE.BoxGeometry(0.22, 0.55, 0.28);
    const dupatta = new THREE.Mesh(dupGeo, dupattaMat);
    dupatta.position.set(0.06, 1.1, 0.05);
    dupatta.rotation.z = -0.15;
    body.add(dupatta);

    // Art Portfolio Bag
    const bagGeo = new THREE.BoxGeometry(0.36, 0.28, 0.08);
    const bag = new THREE.Mesh(bagGeo, bagMat);
    bag.position.set(0.28, 0.85, 0.05);
    bag.rotation.z = 0.2;
    body.add(bag);

    // Head
    const headGroup = new THREE.Group();
    headGroup.position.set(0, 1.55, 0);
    body.add(headGroup);

    const headGeo = new THREE.SphereGeometry(0.17, 14, 14);
    const head = new THREE.Mesh(headGeo, skinMat);
    headGroup.add(head);

    // Flowing hair with ponytail
    const hairGeo = new THREE.BoxGeometry(0.36, 0.22, 0.36);
    const hair = new THREE.Mesh(hairGeo, hairMat);
    hair.position.set(0, 0.08, -0.02);
    headGroup.add(hair);

    const tailGeo = new THREE.CylinderGeometry(0.06, 0.08, 0.45, 8);
    const tail = new THREE.Mesh(tailGeo, hairMat);
    tail.position.set(-0.14, -0.16, -0.18);
    tail.rotation.z = 0.25;
    headGroup.add(tail);

    // Legs
    const legGeo = new THREE.CylinderGeometry(0.07, 0.06, 0.72, 8);

    const leftLeg = new THREE.Group();
    leftLeg.position.set(-0.1, 0.72, 0);
    const lLegMesh = new THREE.Mesh(legGeo, leggingMat);
    lLegMesh.position.y = -0.34;
    leftLeg.add(lLegMesh);
    body.add(leftLeg);

    const rightLeg = new THREE.Group();
    rightLeg.position.set(0.1, 0.72, 0);
    const rLegMesh = new THREE.Mesh(legGeo, leggingMat);
    rLegMesh.position.y = -0.34;
    rightLeg.add(rLegMesh);
    body.add(rightLeg);

    return {
      mesh: group,
      body,
      headGroup,
      walkPhase: 0,
      updateAnimation(speed, delta) {
        this.walkPhase += delta * 2.0;
        body.position.y = Math.sin(this.walkPhase) * 0.02;
      },
      lookAtCharacter(targetPos) {
        const local = group.worldToLocal(targetPos.clone());
        const angle = Math.atan2(local.x, local.z);
        headGroup.rotation.y = THREE.MathUtils.clamp(angle, -0.8, 0.8);
      }
    };
  }

  static createRohan() {
    const group = new THREE.Group();
    group.name = 'Rohan';

    const skinMat = new THREE.MeshLambertMaterial({ color: 0xf5d3ba });
    const hoodieMat = new THREE.MeshLambertMaterial({ color: 0xd99b26 });
    const cargoMat = new THREE.MeshLambertMaterial({ color: 0x3d4436 });
    const glassMat = new THREE.MeshLambertMaterial({ color: 0x996633, transparent: true, opacity: 0.7 });

    const body = new THREE.Group();
    group.add(body);

    const torsoGeo = new THREE.CylinderGeometry(0.24, 0.22, 0.65, 12);
    const torso = new THREE.Mesh(torsoGeo, hoodieMat);
    torso.position.y = 1.1;
    body.add(torso);

    const headGeo = new THREE.SphereGeometry(0.18, 14, 14);
    const head = new THREE.Mesh(headGeo, skinMat);
    head.position.set(0, 1.55, 0);
    body.add(head);

    // Cutting chai glass in hand
    const glassGeo = new THREE.CylinderGeometry(0.04, 0.03, 0.09, 8);
    const glass = new THREE.Mesh(glassGeo, glassMat);
    glass.position.set(0.3, 1.05, 0.15);
    body.add(glass);

    return {
      mesh: group,
      updateAnimation(speed, delta) {
        body.position.y = Math.sin(Date.now() * 0.002) * 0.015;
      }
    };
  }
}

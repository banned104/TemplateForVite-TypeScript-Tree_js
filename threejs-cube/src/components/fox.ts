import * as THREE from "three";
import * as kokomi from "kokomi.js";
import type * as STDLIB from "three-stdlib";


type ActionName = "idle" | "walk" | "run";

class Fox extends kokomi.Component {
    gltf: STDLIB.GLTF;
    mixer: THREE. AnimationMixer;

    actions: Record<string, THREE.AnimationAction>;

    constructor( base: kokomi.Base, gltf: STDLIB.GLTF ) {
        super( base );
        this.gltf = gltf;

        const mixer = new THREE.AnimationMixer( this.gltf.scene );
        this.mixer = mixer;

        this.actions = {};
        this.setActions();
    }

    addExisting(): void {
         this.gltf.scene.scale.set( 0.02, 0.02, 0.02 );
         this.base.scene.add( this.gltf.scene );
    }

    update(time: number): void {
        const delta = this.base.clock.deltaTime;

        this.mixer.update( delta );
    }

    setActions() {
        this.actions.idle = this.mixer.clipAction( this.gltf.animations[0] );
        this.actions.walk = this.mixer.clipAction( this.gltf.animations[1] );
        this.actions.run = this.mixer.clipAction( this.gltf.animations[2] );
    }

    playAction( name: ActionName = "idle") {
        const prevAction = this.actions.current;
        const nextAction = this.actions[name];

        nextAction.reset();
        nextAction.play();

        if ( prevAction ) {
            // 下面这一行作用是: 让上一个动作和下一个动作交叉淡入淡出
            nextAction.crossFadeFrom( prevAction, 1, true );
        }

        this.actions.current = nextAction;
    }
}

export default Fox;
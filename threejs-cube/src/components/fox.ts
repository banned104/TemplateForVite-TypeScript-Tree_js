import * as THREE from "three";
import * as kokomi from "kokomi.js";
import type * as STDLIB from "three-stdlib";        // 用于处理GLTF模型

// 联合类型 相当于C++中的 enum
type ActionName = "idle" | "walk" | "run"|"current";

class Fox extends kokomi.Component {
    gltf: STDLIB.GLTF;
    mixer: THREE. AnimationMixer;
    // 一个字典 <key, value> 键值对; 相当于C++中的 unordered_map;  THREE.AnimationAction即为动画的一个动作, 从GLTF模型中获取
    actions: Record<ActionName, THREE.AnimationAction>;

    constructor( base: kokomi.Base, gltf: STDLIB.GLTF ) {
        super( base );
        this.gltf = gltf;
        // 管理动画的 AnimationMixer对象
        const mixer = new THREE.AnimationMixer( this.gltf.scene );
        this.mixer = mixer;
        
        // JavaScript调用对象的属性时, 可以使用 ! 来表示该属性不会为 null 或 undefined
        // 对象的属性可以通过点号 . 或方括号 [] 来访问 所以就算设置了Record<ActionName, THREE.AnimationAction>, 
        // ActionName为联合string, 也能通过点号.来访问属性
        this.actions = {
            idle: null!,
            walk: null!,
            run: null!,
            current: null!
        } as Record<ActionName, THREE.AnimationAction>;
        this.setActions();
    }

    addExisting(): void {
         this.gltf.scene.scale.set( 0.02, 0.02, 0.02 );
         this.base.scene.add( this.gltf.scene );
    }

    update(time: number): void {
        const delta = this.base.clock.deltaTime;
        // 用于更平滑的动画播放
        this.mixer.update( delta );
    }

    setActions() {
        // 从模型中提取出动画的动作
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
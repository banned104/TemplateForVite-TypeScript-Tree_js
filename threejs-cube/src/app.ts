import * as THREE from "three";
import * as kokomi from "kokomi.js";
import resourcesList from "./resources";
import Fox from "./components/fox"

class Sketch extends kokomi.Base {
    create() {
        new kokomi.OrbitControls( this );

        this.camera.position.copy( new THREE.Vector3( 6, 4, 3 ) );
        // 环境光
        const ambientLight = new THREE.AmbientLight( 0xFFFFFF, /*intensity*/0.4 );
        this.scene.add( ambientLight );
        // 平行光
        const directLight = new THREE.DirectionalLight( 0xFFFFFF, /*intensity*/0.6 );
        directLight.position.copy( new THREE.Vector3( 1, 2, 3 ) );
        this.scene.add(  directLight );

        const assetManager = new kokomi.AssetManager( this, resourcesList );
        assetManager.emitter.on( "ready", ()=>{
            const fox = new Fox( this, assetManager.items.foxModel );
            fox.addExisting();
            fox.playAction("idle");
        } );

    };
};

const createSketch = () => {
    const sketch = new Sketch();
    sketch.create();
    return sketch;
};

export default createSketch;
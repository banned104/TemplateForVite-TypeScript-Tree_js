import * as THREE from "three";
import * as kokomi from "kokomi.js";
import resourcesList from "./resources";
import Fox from "./components/fox"

import fragmentShader from "./shaders/fragment.frag.glsl"

class Sketch extends kokomi.Base {
    create() {
    const screenQuad = new kokomi.ScreenQuad( this, {
        shadertoyMode: true,
        fragmentShader
    } );
    screenQuad.addExisting();
    };
};

const createSketch = () => {
    const sketch = new Sketch();
    sketch.create();
    return sketch;
};

export default createSketch;
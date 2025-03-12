import * as kokomi from "kokomi.js";

class Sketch extends kokomi.Base {
    create() {};
};

const createSketch = () => {
    const sketch = new Sketch();
    sketch.create();
    return sketch;
};

export default createSketch;
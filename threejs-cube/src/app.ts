import * as kokomi from "kokomi.js";

class Sketch extends kokomi.Base {
    create() {
        const box = new kokomi.Box(this);
        box.addExisting();

        // 添加拖拽
        new kokomi.OrbitControls(this);

        this.update( (time:number) =>{
            box.spin(time);
        } );
    };
};

const createSketch = () => {
    const sketch = new Sketch();
    sketch.create();
    return sketch;
};

export default createSketch;
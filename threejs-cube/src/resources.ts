import type * as kokomi from "kokomi.js";

// import foxModel from "/public/Fox.gltf?url";
import foxModel from "/Fox.gltf?url";

const resourcesList: kokomi.ResourceItem[] = [ {
    name: "foxModel",
    type: "gltfModel",
    path: foxModel,
} ];

export default resourcesList;
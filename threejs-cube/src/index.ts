import "./style.css";
import createSketch from "./app";

const appElement = document.getElementById("app");
if ( appElement ) {
    // 将 canvas容器id:app改为 sketch; 同时引入 createSketch;
    document.getElementById("app").innerHTML = '<div id="sketch"></div>';
} else {
    console.error("?牛魔的");
}

createSketch();
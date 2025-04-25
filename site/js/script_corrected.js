
const canvas = document.getElementById("canvas");
const ctx = canvas.getContext("2d");

let width, height, lines, letters, lineSpacing, letterSpacing, text;

function resizeCanvas() {
    width = canvas.width = window.innerWidth;
    height = canvas.height = Math.max(window.innerHeight, 400);

    lines = Math.floor(height / 20);
    letters = Math.floor(width / 10) + 10;
    lineSpacing = 20;
    letterSpacing = 10;
}

function generateText() {
    const chars = "abcdefghijklmnopqrstuvwxyz";
    let text = [];
    for (let i = 0; i < lines; i++) {
        let line = "";
        for (let j = 0; j < letters; j++) {
            line += chars[Math.floor(Math.random() * chars.length)];
        }
        text.push(line);
    }
    return text;
}

function drawBackground(text) {
    ctx.clearRect(0, 0, width, height);
    ctx.font = "16px monospace";
    ctx.fillStyle = "#38BDF9";

    for (let i = 0; i < text.length; i++) {
        ctx.fillText(text[i], 0, (i + 1) * lineSpacing);
    }
}

let frameCount = 0;

function animate() {
    frameCount++;
    if (frameCount % 4 === 0) {
        text.push(text.shift());
    }
    drawBackground(text);
    requestAnimationFrame(animate);
}

window.addEventListener("resize", () => {
    resizeCanvas();
    text = generateText();
});
resizeCanvas();
text = generateText();
animate();

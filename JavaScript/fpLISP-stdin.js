eval(require("fs").readFileSync('fpLISP.js').toString());
const r = require('readline').createInterface({input: process.stdin});
let lines = [];
r.on('line', (line) => { lines.push(line); });
r.on('close', () => { console.log(fp_rep(lines.join(''))); });


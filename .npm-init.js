const path = require("path");

const name = path.basename(process.cwd());

const owner = "Naturalclar";

module.exports = {
  name,
  version: "0.0.0",
  main: "dist/index.js",
  author: `${owner} (https://github.com/${owner})`,
  repository: `${owner}/${name}`,
  scripts: {
    build: "tsc",
    "type-check": "tsc -noEmit"
  },
  devDependencies: {
    typescript: "^3.5.3"
  },
  types: "dist/index.d.ts",
  license: "MIT"
};

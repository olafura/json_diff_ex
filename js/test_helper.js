var jsondiffpatch = require('jsondiffpatch').create();
//var JSON = require("json");

var argv = process.argv;
if(argv.length > 3) {
  var j1 = JSON.parse(argv[2]);
  var j2 = JSON.parse(argv[3]);
  console.log(JSON.stringify(jsondiffpatch.diff(j1, j2)));
} else {
  process.exit(1);
}

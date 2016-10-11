const Rx = require("../../../repository/dist/cjs/Rx")

const {foo} = Rx.Scheduler

foo.schedule(function() {
  console.log("foo")
})

console.log("bar")


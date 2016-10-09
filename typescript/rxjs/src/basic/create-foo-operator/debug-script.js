const Rx = require("../../../repository/dist/cjs/Rx")

const obv = Rx.Observable.from(["a", "b", "c"])

const newObv = obv.foo("foo")

newObv.subscribe((val) => console.log(val))

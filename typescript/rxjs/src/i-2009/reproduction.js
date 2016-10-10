var rx = require('../../repository/dist/cjs/Rx');

var s = new rx.Subject();

s.distinct()
    .count()
    .subscribe((n) => {
        console.log(n);
    });

for (var i = 0; i < 100000; i++) {
    console.log(i)
    s.next(i);
}

s.complete();

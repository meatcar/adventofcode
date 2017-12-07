const debug = require('debug')('advent');
const INPUT = '4	10	4	1	8	4	9	14	5	1	14	15	0	15	3	5';

function debugState(state) {
  if (debug.enabled)
    debug('state: %O', state);
}

function solution(list) {
  let state = {
    snapshots: new Map(),  // list of banks
    banks: list
  };
  while (!state.snapshots.has(state.banks.toString())) {
    let banks = state.banks;
    // snapshot
    if (state.snapshots.size % 1000 === 0)
      debug('%s size:%s',
        banks.toString(),
        state.snapshots.size);

    state.snapshots.set(banks.toString(), state.snapshots.size);

    /* redistribute blocks */
    // find biggest bank
    let blocks = Math.max(...banks);
    let bank = banks.indexOf(blocks);
    // empty it
    banks[bank] = 0;
    while (blocks--) {
      // move onto the next bank, add a block
      banks[++bank % banks.length]++;
    }
    // all blocks are distributed.
    state.banks = banks;
    //debugState(state);
  }

  return [state.snapshots.size,
    state.snapshots.size- state.snapshots.get(state.banks.toString())
  ];
}

const soln =  solution(INPUT.split('\t').map(Number));
console.log('star 1', soln[0]);
console.log('star 2', soln[1]);
const test = require('ava').test;

test('star 1', (t) => {
  t.is(solution([0, 2, 7, 0])[0], 5);
});
test('star 2', (t) => {
  t.is(solution([0, 2, 7, 0])[1], 4);
});

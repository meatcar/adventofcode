const debug = require('debug')('advent');

function solution(input, star) {
  const registers = new Map();
  let max = -Infinity;

  const OPS = {
    'inc': n => n,
    'dec': n => n * -1
  };

  const CMP = {
    '>': (a, b) => a > b,
    '<': (a, b) => a < b,
    '<=': (a, b) => a <= b,
    '>=': (a, b) => a >= b,
    '==': (a, b) => a === b,
    '!=': (a, b) => a !== b,
  };

  input.split('\n')
    .map((line) =>
      line.match(/^(\w+) (inc|dec) (-?\d+) if (\w+) ([<>=!]+) (-?\d+)$/)
    )
    .forEach(([, reg, op, n, regCmp, cmp, nCmp]) => {
      debug({reg, op, n,regCmp, cmp, nCmp});
      if (!registers.has(reg))
        registers.set(reg, 0);
      if (!registers.has(regCmp))
        registers.set(regCmp, 0);

      if (CMP[cmp](registers.get(regCmp), Number(nCmp))) {
        registers.set(reg, registers.get(reg) + OPS[op](Number(n)));
        max = Math.max(max, ...registers.values());
      }
    });
  debug(registers);
  if (star === 1) {
    return Math.max(...registers.values());
  } else {
    return max;
  }
}


(async function Main() {
  const getInput = require('../getInput');
  const input = await getInput(2017, 8);
  console.log('1:', solution(input, 1));
  console.log('2:', solution(input, 2));
})().catch(console.trace);

//const test = require('ava').test;

//test('star 1', (t) => {
//t.is(solution(`
//b inc 5 if a > 1
//a inc 1 if b < 5
//c dec -10 if a >= 1
//c inc -20 if c == 10
//`.trim(), 1), 1);
//});

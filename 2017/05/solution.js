#!/usr/bin/env node
const debug = require('debug')('advent');
const INPUT = require('./input');

function debugState(state, list) {
  if (debug.enabled)
    debug(`#${state.jumps}`.padStart(6),
      ...list.map((v) => v > -1 ? ` ${v}` : v)
        .map((v, i) => state.pointer === i ? `(${v})` : ` ${v} `));
}

function solution(list) {
  let state = {
    pointer: 0,
    jumps: 0
  };
  debugState(state, list);
  while (typeof list[state.pointer] !== 'undefined') {
    const newState = Object.assign({}, state);
    newState.pointer += list[state.pointer];
    list[state.pointer]++;
    newState.jumps++;
    state = newState;
    debugState(state, list);
  }
  return state.jumps;
}

function solution2(list) {
  let state = {
    pointer: 0,
    jumps: 0
  };
  debugState(state, list);
  while (typeof list[state.pointer] !== 'undefined') {
    const newState = Object.assign({}, state);
    newState.pointer += list[state.pointer];
    if (list[state.pointer] >= 3) {
      list[state.pointer]--;
    } else {
      list[state.pointer]++;
    }
    newState.jumps++;
    state = newState;
    debugState(state, list);
  }
  return state.jumps;
}

console.log('star 1', solution(INPUT.split('\n').map((n) => parseInt(n, 10))));
console.log('star 2', solution2(INPUT.split('\n').map((n) => parseInt(n, 10))));
const test = require('ava').test;

test('star 1', (t) => {
  t.is(solution([0, 3, 0, 1, -3]), 5);
});
test('star 2', (t) => {
  t.is(solution2([0, 3, 0, 1, -3]), 10);
});

#!/usr/bin/env node
'use strict';

function distance(p1, p2) {
  return Math.abs(p1[0] - p2[0]) + Math.abs(p1[1] - p2[1]);
}

function solution(input) {
  const sqrt = Math.sqrt(input);
  let gw = Math.ceil(sqrt); // grid width
  if (gw % 2 === 0) {
    gw += 1; // make sure we've got an odd-sided grid
  }

  /**
     * Grid perimiter is like
     *               (side 1)
     *  [0, gw-1] ----------------- [gw-1, gw-1]
     *    |                            |
     *    | (side 2)     1             | (side 0)
     *    |                         [gw-1, 1] <=== start
     *  [0, 0]--------------------- [gw-1, 0]
     *               (side 3)
     */

  const one = [Math.floor(gw/2), Math.floor(gw/2)]; // 1 is in the middle

  /****
     * Let's put the input on the perimiter of the grid.
     */

  const sideLen = gw - 1;
  // describe starting positions for each side
  const sideStart = [[sideLen, 1], [sideLen - 1, sideLen], [0, sideLen - 1], [1, 0]];

  // Describe what happens to x,y as we go around the perimiter, per side.
  const xVec = [0, -1, 0, +1];
  const yVec = [+1, 0, -1, 0];

  const pDelta = input - Math.pow(gw - 2, 2) - 1; // distance of input from start along perimiter
  const side = Math.floor(pDelta / sideLen) || 0; // prevent division by 0
  const sideDelta = pDelta % sideLen || 0;

  // start
  let point = sideStart[side];
  point[0] = point[0] + (sideDelta * xVec[side]);
  point[1] = point[1] + (sideDelta * yVec[side]);

  return distance(one, point);
}

// extracted from last bit of prev function
function getSquarePoint(squareNum, grid) {
  const sideLen = grid.length - 1;
  // describe starting positions for each side
  const sideStart = [[sideLen, 1], [sideLen - 1, sideLen], [0, sideLen - 1], [1, 0]];

  // Describe what happens to x,y as we go around the perimiter, per side.
  const xVec = [0, -1, 0, +1];
  const yVec = [+1, 0, -1, 0];

  const pDelta = squareNum - Math.pow(grid.length - 2, 2) - 1; // distance of input from start along perimiter
  const side = Math.floor(pDelta / sideLen) || 0; // prevent division by 0
  const sideDelta = pDelta % sideLen || 0;

  // start
  let point = sideStart[side];
  point[0] = point[0] + (sideDelta * xVec[side]);
  point[1] = point[1] + (sideDelta * yVec[side]);
  return point;
}

function at(grid, x, y) {
  const ret = atPoint(grid, [x, y]);
  //console.log(ret);
  return ret;
}
function atPoint(grid, point) {
  const row = grid[point[1]] || [];
  return row[point[0]] || 0;
}

function setPoint(grid, point, v) {
  grid[point[1]][point[0]] = v;
}

function logGrid(grid) {
  let pad = 0;
  grid.forEach((row) => row.forEach((n) => pad = Math.max(pad, (''+n).length)));
  console.log();
  grid.forEach((row) => console.log(...row.map((n) => String(n).padStart(pad))));
  console.log();
}

function solution2(input) {
  let squareNum = 1;
  let point = [0, 0];
  let value = 1;
  let grid = [[value]];
  while ((value = atPoint(grid, point)) <= input) {
    squareNum += 1; // next number;
    if (Math.sqrt(squareNum) > grid.length) {
      // grow grid
      grid = [(new Array(grid.length)).fill(0)].concat(grid, [(new Array(grid.length)).fill(0)]);
      grid = grid.map((line) => [0, ...line, 0]);
      console.log('GROW');
      logGrid(grid);
    }
    point = getSquarePoint(squareNum, grid);
    //console.log('point', squareNum, point);
    let sum = 0;
    sum += at(grid, point[0]+1, point[1]+1);
    sum += at(grid, point[0],   point[1]+1);
    sum += at(grid, point[0]-1, point[1]+1);
    sum += at(grid, point[0]+1, point[1]-1);
    sum += at(grid, point[0],   point[1]-1);
    sum += at(grid, point[0]-1, point[1]-1);
    sum += at(grid, point[0]+1, point[1]);
    sum += at(grid, point[0]-1, point[1]);
    setPoint(grid, point, sum);
    logGrid(grid);
    value = sum;
  }
  return value;
}

console.log('1:', solution(325489));
console.log('2:', solution2(325489));

const test = require('ava').test;

test('star 1', (t) => {
  //t.is(solution(1), 0);
  t.is(solution(10), 3);
  t.is(solution(12), 3);
  t.is(solution(13), 4);
  t.is(solution(14), 3);
  t.is(solution(19), 2);
  t.is(solution(23), 2);
  t.is(solution(1024), 31);
});
test('star 2', (t) => {
  t.is(solution2(1), 2);
  t.is(solution2(2), 4);
  t.is(solution2(11), 23);
});

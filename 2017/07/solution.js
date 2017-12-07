const debug = require('debug')('advent');

function solution(input, star) {
  let leaves = new Map();
  let roots = new Map();
  // parse input
  input.split('\n')
    .map((line) => line.match(/(\w+) \((\d+)\)(| -> (.+))$/).slice(1, 5))
    .map(([node, weight, , children]) =>
      [
        node,
        Number(weight),
        (children || '').split(',')
          .map((s) => s.trim())
          .reduce((map, child) => child ? map.set(child, null) : map, new Map())
      ])
    .forEach(([node, weight, children]) => {
      leaves.set(node, {weight, children});
      for (let [child] of children) {
        roots.set(child, node);
      }
    });

  let root;
  for (let [node] of leaves) {
    if (!roots.has(node)) {
      root = node;
    }
  }

  if (star === 1) return root;

  const [name, badWeight, goodWeight] = checkBalance(root, leaves);
  debug('FINAL', {name, badWeight, goodWeight});
  const node = leaves.get(name);
  return node.weight - (badWeight - goodWeight);
}

function getWeight(root, nodes) {
  const node = nodes.get(root);
  if (!node.children.size) {
    return node.weight;
  }

  let sum = node.weight;
  for (let [child] of node.children) {
    sum += getWeight(child, nodes);
  }
  return sum;
}


function checkBalance(root, nodes) {
  const node = nodes.get(root);

  const weights = {};
  for (let [child] of node.children) {
    const weight = getWeight(child, nodes);
    weights[weight] = weights[weight] || [];
    weights[weight].push(child);
  }

  let bad, badWeight, goodWeight;
  for (let weight of Object.keys(weights)) {
    const children = weights[weight];
    if (children.length === 1) {
      bad = children[0];
      badWeight = weight;
    } else {
      goodWeight = weight;
    }
  }
  if (!bad) {
    return root;
  }
  const check = checkBalance(bad, nodes);
  if (check instanceof Array) {
    return check;
  }
  return [check, badWeight, goodWeight];
}

(async function() {
  const getInput = require('../getInput');
  const input = await getInput(2017, 7);
  console.log('1:', solution(input, 1));
  console.log('2:', solution(input, 2));
})().catch(console.trace);

//const test = require('ava').test;

//test('star 1', (t) => {
//t.is(solution(`
//pbga (66)
//xhth (57)
//ebii (61)
//havc (66)
//ktlj (57)
//fwft (72) -> ktlj, cntj, xhth
//qoyq (66)
//padx (45) -> pbga, havc, qoyq
//tknk (41) -> ugml, padx, fwft
//jptl (61)
//ugml (68) -> gyxo, ebii, jptl
//gyxo (61)
//cntj (57)
//`.trim(), 1), 'tknk');
//});

//test('star 2', (t) => {
//t.is(solution(`
//pbga (66)
//xhth (57)
//ebii (61)
//havc (66)
//ktlj (57)
//fwft (72) -> ktlj, cntj, xhth
//qoyq (66)
//padx (45) -> pbga, havc, qoyq
//tknk (41) -> ugml, padx, fwft
//jptl (61)
//ugml (68) -> gyxo, ebii, jptl
//gyxo (61)
//cntj (57)
//`.trim(), 2), 60);
//});

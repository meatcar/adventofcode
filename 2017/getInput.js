require('dotenv').config();
const fetch = require('node-fetch');

module.exports = (y, d) => {
  return fetch(`https://adventofcode.com/${y}/day/${d}/input`, {
    headers: { cookie: process.env.ADVENTOFCODE_COOKIE }
  })
    .then((res) => res.text())
    .then(s => s.trim());
};

//const { test } = require('ava');
//test('fetch', async t => {
//t.is(await module.exports(2017, 3), '325489');
//});

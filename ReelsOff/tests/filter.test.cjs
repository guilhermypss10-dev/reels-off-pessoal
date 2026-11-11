// Executa em Node.js no GitHub Actions. Testa o JavaScript real embutido no Swift.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');

const swift = fs.readFileSync('ReelsOff/ReelsOff/InstagramSemReelsView.swift', 'utf8');
const match = swift.match(/private static let filterScript = #"""([\s\S]*?)"""#/);
assert.ok(match, 'Filtro JS ausente no arquivo Swift');

function testPath(path, expectedBlocked) {
  let redirectedTo = null;
  const anchors = [
    { href: 'https://www.instagram.com/reel/ABC/', style: {setProperty() {}}, setAttribute() {} },
    { href: 'https://www.instagram.com/direct/inbox/', style: {setProperty() {}}, setAttribute() {} }
  ];
  const ctx = {
    URL,
    window: {},
    document: {
      documentElement: {},
      addEventListener() {},
      querySelectorAll() { return anchors },
    },
    location: {
      href: 'https://www.instagram.com' + path,
      pathname: path,
      search: '',
      replace(url) { redirectedTo = url }
    },
    history: {
      pushState() {},
      replaceState() {}
    },
    MutationObserver: class { observe() {} },
    addEventListener() {}
  };
  vm.runInNewContext(match[1], ctx, { timeout: 1000 });
  if (expectedBlocked) assert.equal(redirectedTo, '/');
  else assert.equal(redirectedTo, null);
  assert.equal(ctx.window.__reelsOffInstalled, true);
}
for (const p of ['/reel/abc/', '/reels/', '/reels', '/reel']) testPath(p, true);
for (const p of ['/', '/direct/inbox/', '/stories/', '/p/abc/', '/reelish/']) testPath(p, false);
console.log('Filtro web: 9 caminhos verificados.');

// Builds the notes tree from the repo's file listing, so new notes appear automatically.
const REPO = 'thomaslylyll/thomaslylyll.github.io';

function buildTree(paths) {
  const root = {};
  for (const path of paths) {
    const parts = path.split('/').slice(1); // drop leading "notes"
    let node = root;
    for (const dir of parts.slice(0, -1)) node = node[dir] ??= {};
    node[parts.at(-1)] = path;
  }
  return root;
}

function renderTree(node, ul = document.createElement('ul')) {
  for (const [name, value] of Object.entries(node)) {
    const li = document.createElement('li');
    if (typeof value === 'string') {
      const a = document.createElement('a');
      a.href = encodeURI(value);
      a.textContent = name.replace(/\.html$/, '');
      li.append(a);
    } else {
      const span = document.createElement('span');
      span.className = 'note-folder';
      span.textContent = name + '/';
      li.append(span, renderTree(value));
    }
    ul.append(li);
  }
  return ul;
}

const list = document.getElementById('note-tree');
fetch(`https://api.github.com/repos/${REPO}/git/trees/main?recursive=1`)
  .then(res => res.json())
  .then(({ tree }) => {
    const notes = tree
      .map(item => item.path)
      .filter(p => p.startsWith('notes/') && p.endsWith('.html') && !p.includes('_files/'));
    renderTree(buildTree(notes), list);
  })
  .catch(() => { list.textContent = 'Could not load notes.'; });

import test from 'node:test';
import assert from 'node:assert/strict';
import {readFileSync} from 'node:fs';
import {createHash} from 'node:crypto';
import {color, brandColor, brandIDs, tokenIDs} from '../dist/index.js';
import {resolveSource, contrast} from '../scripts/source.mjs';
const source=JSON.parse(readFileSync(new URL('../tokens/colors.json',import.meta.url)));
const legacy={tokens:source.tokens.filter(t=>!t.id.includes('.strata')),brands:Object.fromEntries(Object.entries(source.brands).filter(([k])=>!k.startsWith('strata-'))),contrastPairs:source.contrastPairs.filter(p=>!p.foreground.includes('.strata')&&!p.background.includes('.strata'))};
const families=['blue','green','pink','yellow','purple'];
const categories=Array.from({length:8},(_,i)=>`product.strata.category.${i+1}`);
const cardIDs=families.map(f=>`product.strata.${f}.surface.card`);
const rgbToLab=({r,g,b})=>{
  const linear=[r,g,b].map(v=>v/255).map(v=>v<=.04045?v/12.92:((v+.055)/1.055)**2.4);
  const [x,y,z]=[(.4124*linear[0]+.3576*linear[1]+.1805*linear[2])/.95047,(.2126*linear[0]+.7152*linear[1]+.0722*linear[2]),(.0193*linear[0]+.1192*linear[1]+.9505*linear[2])/1.08883];
  const f=v=>v>.008856?v**(1/3):7.787*v+16/116;
  return [116*f(y)-16,500*(f(x)-f(y)),200*(f(y)-f(z))];
};
const deltaE00=(a,b)=>{
  const [L1,a1,b1]=rgbToLab(a),[L2,a2,b2]=rgbToLab(b),C1=Math.hypot(a1,b1),C2=Math.hypot(a2,b2),C=(C1+C2)/2;
  const G=.5*(1-Math.sqrt(C**7/(C**7+25**7))),ap=(1+G)*a1,bp=(1+G)*a2,Cp1=Math.hypot(ap,b1),Cp2=Math.hypot(bp,b2);
  const hp=(x,y)=>{let h=Math.atan2(y,x)*180/Math.PI;return h<0?h+360:h;},h1=hp(ap,b1),h2=hp(bp,b2),dL=L2-L1,dC=Cp2-Cp1;
  const dh=Math.abs(h2-h1)<=180?h2-h1:h2<=h1?h2-h1+360:h2-h1-360, dH=2*Math.sqrt(Cp1*Cp2)*Math.sin(dh*Math.PI/360),Lm=(L1+L2)/2,Cm=(Cp1+Cp2)/2;
  const hm=Math.abs(h1-h2)<=180?(h1+h2)/2:(h1+h2+360)/2-(h1+h2>=360?0:180),T=1-.17*Math.cos((hm-30)*Math.PI/180)+.24*Math.cos(2*hm*Math.PI/180)+.32*Math.cos((3*hm+6)*Math.PI/180)-.20*Math.cos((4*hm-63)*Math.PI/180);
  const Sl=1+.015*(Lm-50)**2/Math.sqrt(20+(Lm-50)**2),Sc=1+.045*Cm,Sh=1+.015*Cm*T, Rt=-2*Math.sqrt(Cm**7/(Cm**7+25**7))*Math.sin(60*Math.exp(-(((hm-275)/25)**2))*Math.PI/180);
  return Math.sqrt((dL/Sl)**2+(dC/Sc)**2+(dH/Sh)**2+Rt*(dC/Sc)*(dH/Sh));
};
const deltaL=(a,b)=>Math.abs(rgbToLab(a)[0]-rgbToLab(b)[0]);
test('Strata addition preserves every legacy source token, brand and pair',()=>{
  assert.equal(createHash('sha256').update(JSON.stringify(legacy)).digest('hex'),'befd0c2841299c73878770edae002def239fe9c56e14245a9943def112405b70');
});
test('five explicit families retain named primary, neutral and material roles in both modes',()=>{
  assert.deepEqual(brandIDs.filter(x=>x.startsWith('strata-')),families.map(x=>'strata-'+x).sort());
  for(const mode of ['light','dark']) {
    const pages=[];
    for(const family of families){
      const b=`brand.strata-${family}.`,p=`product.strata.${family}.`;
      assert.deepEqual(brandColor('strata-'+family,'accent',mode),color(b+'primary',mode));
      assert.deepEqual(brandColor('strata-'+family,'onAccent',mode),color(b+'on-accent',mode));
      for(const role of ['region','card','inset','hover','selected'])assert.notDeepEqual(color(p+'surface.'+role,mode),color(p+'surface.page',mode));
      for(const role of ['panel','content','control','ambient','ambient-soft','ambient-edge'])assert.ok(color(p+'material.'+role,mode).a<1);
      pages.push(color(p+'surface.page',mode));
      for(const state of ['primary','hover','active'])assert.ok(contrast(color(b+'on-accent',mode),color(b+state,mode))>=4.5);
    }
    assert.equal(new Set(pages.map(JSON.stringify)).size,5);
  }
  assert.deepEqual(color('brand.strata-blue.primary','light'),{r:40,g:89,b:188,a:1});
  assert.deepEqual(color('product.strata.purple.surface.card','dark'),{r:50,g:44,b:60,a:1});
  assert.equal(color('product.strata.blue.material.panel','light').a,.62);
  assert.equal(color('product.strata.purple.material.content','dark').a,.82);
  assert.throws(()=>brandColor('strata-orange','accent','light'),/unknown brand/);
});
test('declared Strata contrast remains a fail-closed source gate',()=>{
  const broken=structuredClone(source);
  broken.tokens.find(t=>t.id==='brand.strata-blue.on-accent').values.light={ref:'brand.strata-blue.primary'};
  assert.throws(()=>resolveSource(broken),/contrast/);
  for(const token of source.tokens.filter(t=>t.id.includes('.strata')&&!t.id.startsWith('product.strata.category.'))) {
    assert.equal(token.provenance.source,'local');
    assert.match(token.provenance.locator,/b4bff430517ed2e2944f814d8b5ab89a1866ee33/);
  }
});

// Independent oracle: Strata prototype b4bff430517ed2e2944f814d8b5ab89a1866ee33,
// tokens.mjs Git blob b46adf79e0450ce94f43dff590c358720aec494c,
// file SHA-256 90a3d73d105c0ac6bbe02379c597d293447a294c24330e9452b5b2c89e3e33bb.
// Derived from that immutable getTheme() for all five families and both modes,
// including shared text/status/chart/border and material edge/highlight/shadow.
// RGB is exact; hex alpha is Number((byte / 255).toFixed(2)), per spec003.
// Canonical rows: ID-sorted [id, [light r,g,b,a], [dark r,g,b,a]].
// All 116 roles / 232 values were compared individually to the reference before
// pinning this reference-derived digest; source/generated agreement is not the oracle.
const strataReferenceDigest='c41f53160d0eb7e6e39b2733a3a689119a4c0868101c2aa2381b0061f4c6b456';
const isStrata=id=>(id.startsWith('brand.strata-')||id.startsWith('product.strata.')||id.startsWith('status.strata.'))&&!id.startsWith('product.strata.category.');
const strataDigest=colors=>createHash('sha256').update(JSON.stringify(
  Object.keys(colors).filter(isStrata).sort().map(id=>[
    id,...['light','dark'].map(mode=>{const c=colors[id][mode];return [c.r,c.g,c.b,c.a];})
  ])
)).digest('hex');
const assertStrataReference=colors=>assert.equal(strataDigest(colors),strataReferenceDigest,
  'every Strata role/mode must match the normalized immutable prototype');

test('every Strata role and mode matches the normalized immutable prototype',()=>{
  const resolved=resolveSource(source);
  assert.equal(Object.keys(resolved.colors).filter(isStrata).length,116);
  assertStrataReference(resolved.colors);
  const runtime=Object.fromEntries(tokenIDs.filter(isStrata).map(id=>[
    id,Object.fromEntries(['light','dark'].map(mode=>[mode,color(id,mode)]))
  ]));
  assertStrataReference(runtime);
});

test('reference fidelity rejects a non-sample dark green primary that still passes contrast',()=>{
  const changed=structuredClone(source);
  changed.tokens.find(t=>t.id==='brand.strata-green.primary').values.dark.r-=1;
  const resolved=resolveSource(changed);
  assert.ok(contrast(resolved.colors['brand.strata-green.on-accent'].dark,
    resolved.colors['brand.strata-green.primary'].dark)>=4.5);
  assert.throws(()=>assertStrataReference(resolved.colors),{code:'ERR_ASSERTION'});
});

test('category colors are signed values and declared non-text card gates',()=>{
  const resolved=resolveSource(source).colors;
  assert.deepEqual(categories.map(id=>resolved[id].light),[
    {r:57,g:112,b:142,a:1},{r:149,g:121,b:174,a:1},{r:3,g:89,b:93,a:1},{r:137,g:80,b:122,a:1},
    {r:75,g:84,b:22,a:1},{r:177,g:111,b:72,a:1},{r:74,g:75,b:127,a:1},{r:117,g:108,b:97,a:1}
  ]);
  assert.equal(source.contrastPairs.filter(p=>p.use==='non-text').length,40);
  for(const id of categories) for(const card of cardIDs) {
    const pair=source.contrastPairs.find(p=>p.foreground===id&&p.background===card);
    assert.deepEqual(pair?.use,'non-text');
    for(const mode of ['light','dark']) assert.ok(contrast(resolved[id][mode],resolved[card][mode])>=3,`${id}/${card}/${mode}`);
  }
});

test('category color distinction rules R-b through R-e hold',()=>{
  const resolved=resolveSource(source).colors;
  for(const mode of ['light','dark']) {
    const alpha=mode === 'light' ? 0.14 : 0.24;
    const badges=categories.map(id=>{
      const fg=resolved[id][mode], card=resolved['product.strata.blue.surface.card'][mode];
      return {fg,bg:{r:Math.round(fg.r*alpha+card.r*(1-alpha)),g:Math.round(fg.g*alpha+card.g*(1-alpha)),b:Math.round(fg.b*alpha+card.b*(1-alpha)),a:1}};
    });
    for(const {fg,bg} of badges) assert.ok(contrast(fg,bg)>=3,'R-b');
    const statuses=['success','warning','error'].map(id=>resolved[`status.strata.${id}`][mode]);
    for(const [i,id] of categories.entries()) for(const [j,status] of statuses.entries()) assert.ok(deltaE00(resolved[id][mode],status)>=15,`R-c ${mode} category ${i+1} status ${j}`);
    for(const pair of [[0,1],[0,2],[1,2]]) assert.ok(deltaL(resolved[categories[pair[0]]][mode],resolved[categories[pair[1]]][mode])>=10,'R-d');
    for(let i=0;i<categories.length;i++) for(let j=i+1;j<categories.length;j++) assert.ok(deltaE00(resolved[categories[i]][mode],resolved[categories[j]][mode])>=13,'R-e');
  }
});

test('existing 97 text contrast pairs retain the 4.5 minimum',()=>{
  const textPairs=source.contrastPairs.filter(p=>p.use!=='non-text');
  assert.equal(textPairs.length,97);
  assert.ok(textPairs.every(p=>p.minimum>=4.5));
});

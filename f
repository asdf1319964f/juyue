/* Supjav 播放模块 20260914.3
   给规则 require / requireCache 用，不要直接当规则跑。
   聚阅 rule/lazyRule 回调里没有 input，地址必须烘焙进参数。 */

function supjavHdr(ua, ck, ref) {
  var h = {
    'User-Agent': ua || 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36',
    Referer: ref || 'https://supjav.com/',
    'Accept-Encoding': 'identity'
  };
  if (ck) h.Cookie = ck;
  return h;
}

function supjavGet(url, ua, ck, ref) {
  if (!url || String(url).indexOf('http') !== 0) return '';
  try {
    return String(request(url, { headers: supjavHdr(ua, ck, ref), timeout: 15000 }) || '');
  } catch (e0) {
    return '';
  }
}

function supjavLoc(api, ref, ua) {
  try {
    var raw = fetch(api, {
      headers: { Referer: ref, 'User-Agent': ua, 'Accept-Encoding': 'identity' },
      onlyHeaders: true,
      timeout: 15000
    });
    var j = JSON.parse(raw);
    return String((j && j.url) || '').replace(/#.*/, '');
  } catch (e0) {
    return '';
  }
}

function supjavButtons(html) {
  html = String(html || '');
  var items = [];
  try { items = pdfa(html, '.btns&&.btnst&&a') || []; } catch (e0) { items = []; }
  var out = [];
  var i, btn, name, link;
  for (i = 0; i < items.length; i++) {
    btn = items[i];
    try { name = pdfh(btn, 'Text'); } catch (e1) { name = ''; }
    try { link = pdfh(btn, 'a&&data-link'); } catch (e2) { link = ''; }
    name = String(name || '').replace(/^\s+|\s+$/g, '');
    link = String(link || '');
    if (!link || !name || name === 'SERVER :') continue;
    out.push({ name: name, link: link });
  }
  if (!out.length) {
    var iframe = '';
    try { iframe = pdfh(html, '#dz_video iframe&&src'); } catch (e3) { iframe = ''; }
    var m = String(iframe || '').match(/l=([a-f0-9]+)/i);
    if (m && m[1]) out.push({ name: '默认', link: m[1] });
  }
  return out;
}

function supjavResolve(dataLink, ua) {
  dataLink = String(dataLink || '');
  ua = String(ua || '');
  if (!dataLink) return '';
  var id = dataLink.split('').reverse().join('');
  var api = 'https://lk1.supremejav.com/supjav.php?c=' + id;
  var referer = 'https://lk1.supremejav.com/supjav.php?l=' + dataLink;
  var location = supjavLoc(api, referer, ua);
  if (!location) return '';
  var play = '';
  var html, m, script, uas, link;
  if (/turbovid|emturbovid/.test(location)) {
    html = supjavGet(location, ua, '', referer);
    m = html.match(/https?:[^"'<\s]+?\.m3u8[^"'<\s]*/);
    if (m) play = m[0];
  } else if (/cindyeyefinal|fc2stream/.test(location)) {
    html = supjavGet(location, ua, '', referer);
    script = html.match(/eval([\s\S]+?)<\/script/);
    if (script) {
      try {
        uas = eval(script[1]);
        link = String(uas || '').match(/var links[^;]+/);
        if (link) {
          eval(link[0]);
          play = links.hls4 ? ('https://xenolyzb.com' + links.hls4) : (links.hls3 || links.hls2 || '');
        }
      } catch (e4) { play = ''; }
    }
  } else if (/streamtape/.test(location)) {
    html = supjavGet(location, ua, '', referer);
    var pattern = html.match(/\('#(.*)'\)/);
    if (pattern) {
      try {
        var srcMatch = html.match(new RegExp("'" + pattern[1] + ".*?=([^;]+)"));
        if (srcMatch) {
          eval('var srclink = ' + srcMatch[1]);
          var link2 = 'https:' + srclink + '&stream=1';
          play = supjavLoc(link2, location, ua);
        }
      } catch (e5) { play = ''; }
    }
  } else if (/voe/.test(location)) {
    return location + '#嗅探';
  }
  play = String(play || '');
  if (play.indexOf('http') === 0) return play;
  return '';
}

function supjavPlayJson(detailUrl, ua, ck) {
  var html = supjavGet(detailUrl, ua, ck, 'https://supjav.com/');
  if (!html) return 'toast://详情加载失败';
  if (html.indexOf('Just a moment') > -1 || html.indexOf('请稍候') > -1) {
    return 'toast://需要先回首页过盾';
  }
  var btns = supjavButtons(html);
  var urls = [];
  var names = [];
  var headers = [];
  var i, it, play;
  for (i = 0; i < btns.length; i++) {
    it = btns[i];
    play = supjavResolve(String(it.link || ''), ua);
    if (!play) continue;
    urls.push(play);
    names.push(it.name);
    headers.push({ Referer: 'https://supjav.com' });
  }
  if (!urls.length) return String(detailUrl || '') + '#嗅探';
  return { urls: urls, names: names, headers: headers };
}

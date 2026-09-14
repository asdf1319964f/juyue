/* juyue_kit 20260914.1
   从 mistywater/hiker/f 抽出轮播、二级壳、筛选、着色、player_aaaa，
   改成可 require 的本地/远程模块。禁止 eval(lunbo)、箭头、log、读 input。

   规则里：
     require(parse.库路径);
     JKit.abs(u, host);
     JKit.filters(d, html, opt);
     return JKit.detailObj(...);
*/

var JKit = JKit || {};
JKit.ver = "20260914.1";

JKit.str = function (x) {
  if (x == null) return "";
  try { return String(x); } catch (e0) { return ""; }
};

JKit.abs = function (u, host) {
  u = JKit.str(u);
  host = JKit.str(host).replace(/\/$/, "");
  if (!u) return "";
  if (/^(javascript|magnet|ftp|file|hiker|video|toast|pics):/i.test(u)) return u;
  if (/^https?:\/\//i.test(u)) return u;
  if (u.indexOf("//") === 0) return "https:" + u;
  if (u.charAt(0) === "/") return host + u;
  return host ? (host + "/" + u) : u;
};

JKit.hex = function (c) {
  var hex = JKit.str(c || "000000").replace(/^#/, "").toLowerCase();
  var i, out;
  if (/^[0-9a-f]{3}$/.test(hex)) {
    out = "";
    for (i = 0; i < 3; i++) out += hex.charAt(i) + hex.charAt(i);
    return out;
  }
  if (/^[0-9a-f]$/.test(hex)) return hex + hex + hex + hex + hex + hex;
  while (hex.length < 6) hex += "0";
  return hex.slice(0, 6);
};

JKit.color = function (d, c) {
  return "‘‘’’<font color=#" + JKit.hex(c) + ">" + JKit.str(d) + "</font>";
};
JKit.small = function (d, c) {
  return "‘‘’’<small><font color=#" + JKit.hex(c) + ">" + JKit.str(d) + "</font></small>";
};
JKit.smallR = function (d, c) {
  return "<small><font color=#" + JKit.hex(c) + ">" + JKit.str(d) + "</font></small>";
};
JKit.strong = function (d, c) {
  return "‘‘’’<strong><font color=#" + JKit.hex(c) + ">" + JKit.str(d) + "</font></strong>";
};
JKit.sb = function (d, c) {
  return "‘‘’’<strong><big><font color=#" + JKit.hex(c) + ">" + JKit.str(d) + "</font></big></strong>";
};
JKit.sbR = function (d, c) {
  return "<strong><big><font color=#" + JKit.hex(c) + ">" + JKit.str(d) + "</font></big></strong>";
};
JKit.ss = function (d, c) {
  return "‘‘’’<strong><small><font color=#" + JKit.hex(c) + ">" + JKit.str(d) + "</font></small></strong>";
};

JKit.circled = function (index) {
  index = parseInt(index, 10) || 0;
  if (index < 10) return String.fromCharCode(index + 1 + 10101);
  if (index < 20) return String.fromCharCode(index + 1 + 9440);
  if (index < 35) return String.fromCharCode(index + 1 + 12860);
  if (index < 50) return String.fromCharCode(index + 1 + 12941);
  return (index + 1) + ".";
};

JKit.subnum = function (n) {
  var s = JKit.str(n);
  var i, out = "";
  for (i = 0; i < s.length; i++) {
    out += String.fromCharCode((parseInt(s.charAt(i), 10) || 0) + 8320);
  }
  return out;
};

JKit.plain = function (s) {
  return JKit.str(s).replace(/‘|’|“|”|<[^>]+>/g, "");
};

JKit.wrapExtra = function (item, sname, stype) {
  item = item || {};
  var extra = item.extra || {};
  extra.name = extra.name || extra.pageTitle || JKit.plain(item.title);
  extra.img = extra.img || item.pic_url || item.img;
  extra.pageTitle = extra.pageTitle || extra.name;
  extra.surl = JKit.str(item.url).replace(/hiker:\/\/empty|#immersiveTheme#|#autoCache#|#noRecordHistory#|#noHistory#|#noLoading#|#/g, "");
  extra.sname = sname || extra.sname || "";
  extra.stype = stype || extra.stype || "影视";
  item.extra = extra;
  if (item.img && !item.pic_url) item.pic_url = item.img;
  if (item.pic_url && !item.img) item.img = item.pic_url;
  return item;
};

/* 列表卡包成二级入口。detailRule 由站点烘焙，禁止闭包 parse */
JKit.detailUrl = function (page, sname, stype, detailRule) {
  page = JKit.str(page);
  if (!page) return "hiker://empty";
  if (/^(toast|video|pics|magnet):/i.test(page)) return page;
  if (typeof detailRule === "function") {
    return $(page).rule(detailRule, page, sname || "", stype || "影视");
  }
  return $("hiker://empty#immersiveTheme##autoCache#").rule(function (page, sname, stype) {
    setResult([{
      title: JKit.plain(sname) || "详情",
      url: page,
      desc: stype,
      col_type: "text_center_1"
    }]);
  }, page, sname || "", stype || "影视");
};

JKit.movie = function (item, sname, stype, detailRule) {
  item = JKit.wrapExtra(item, sname, stype);
  var raw = JKit.str(item.url);
  if (raw && !/js:|select:|toast:|hiker:\/\/page|video:|pics:|magnet:/i.test(raw) && raw !== "hiker://empty") {
    item.url = JKit.detailUrl(JKit.wrapExtra(item, sname, stype).extra.surl || raw, sname, stype, detailRule);
  }
  item.col_type = item.col_type || "movie_3";
  return item;
};

/* 轮播：返回一张 card_pic_1，不 registerTask、不 eval */
JKit.banner = function (items, opt) {
  opt = opt || {};
  items = items || [];
  if (!items.length) return null;
  var n = parseInt(opt.index, 10) || 0;
  if (n < 0 || n >= items.length) n = 0;
  var it = items[n] || {};
  var host = opt.host || "";
  var card = {
    title: JKit.color(it.title || "", opt.color || "FF3399"),
    img: JKit.abs(it.img || it.pic_url || "", host),
    pic_url: JKit.abs(it.img || it.pic_url || "", host),
    url: it.url || "hiker://empty",
    col_type: "card_pic_1",
    desc: "0",
    extra: { id: "lunbo", stype: opt.stype || "影视", name: JKit.plain(it.title) }
  };
  if (opt.sname) card = JKit.movie(card, opt.sname, opt.stype || "影视", opt.detailRule);
  return card;
};

JKit.bannerFromHtml = function (nodes, opt) {
  opt = opt || {};
  var host = opt.host || "";
  var titleSel = opt.title || "a&&Text";
  var imgSel = opt.img || "img&&data-original";
  var urlSel = opt.url || "a&&href";
  var items = [];
  var i, node, title, img, href;
  nodes = nodes || [];
  for (i = 0; i < nodes.length; i++) {
    node = nodes[i];
    try { title = pdfh(node, titleSel); } catch (e0) { title = ""; }
    try { img = pd(node, imgSel); } catch (e1) { img = ""; }
    try { href = pd(node, urlSel); } catch (e2) { href = ""; }
    if (!href && title) continue;
    items.push({ title: title, img: JKit.abs(img, host), url: JKit.abs(href, host) });
  }
  return JKit.banner(items, opt);
};

/* 分类筛选。href 烘焙进 lazyRule，不读 input */
JKit.filters = function (d, html, opt) {
  opt = opt || {};
  d = d || [];
  var host = JKit.str(opt.host);
  var key = opt.key || (host + "flt");
  var colorOn = opt.color || "FF6699";
  var groupSel = opt.group || "body&&.filter_type_list";
  var extraSel = opt.extra || "";
  var itemSel = opt.item || "body&&a";
  var titleSel = opt.title || "a&&Text";
  var hrefSel = opt.href || "a&&href";
  var groups = [];
  try { groups = pdfa(html, groupSel) || []; } catch (e0) { groups = []; }
  if (extraSel) {
    try { groups = groups.concat(pdfa(html, extraSel) || []); } catch (e1) {}
  }
  var init = [];
  var i;
  for (i = 0; i < 20; i++) init.push("0");
  var raw = "";
  try { raw = getMyVar(key + "t", "") || ""; } catch (e2) { raw = ""; }
  var cate = init;
  if (raw) {
    try { cate = JSON.parse(raw) || init; } catch (e3) { cate = init; }
  }
  var fold = "1";
  try { fold = getMyVar(key + "fold", "1") || "1"; } catch (e4) { fold = "1"; }
  d.push({
    title: fold === "1" ? JKit.strong("∨", "FF0000") : JKit.strong("∧", "1aad19"),
    col_type: "scroll_button",
    url: $("#noLoading#").lazyRule(function (k, f) {
      putMyVar(k + "fold", f === "1" ? "0" : "1");
      refreshPage(false);
      return "hiker://empty";
    }, key, fold)
  });
  var gi, items, ii, node, title, href, on;
  for (gi = 0; gi < groups.length; gi++) {
    if (gi !== 0 && fold !== "1") continue;
    try { items = pdfa(groups[gi], itemSel) || []; } catch (e5) { items = []; }
    for (ii = 0; ii < items.length; ii++) {
      node = items[ii];
      try { title = pdfh(node, titleSel); } catch (e6) { title = ""; }
      try { href = pd(node, hrefSel); } catch (e7) { href = ""; }
      if (!title) continue;
      href = JKit.abs(href, host);
      on = JKit.str(cate[gi]) === String(ii);
      d.push({
        title: on ? JKit.strong(title, colorOn) : JKit.strong(title, "666666"),
        col_type: "scroll_button",
        url: $("#noLoading#").lazyRule(function (k, href, gi, ii) {
          var raw2 = "";
          try { raw2 = getMyVar(k + "t", "") || ""; } catch (e8) { raw2 = ""; }
          var arr = [];
          var z;
          for (z = 0; z < 20; z++) arr.push("0");
          if (raw2) {
            try { arr = JSON.parse(raw2) || arr; } catch (e9) {}
          }
          arr[gi] = String(ii);
          putMyVar(k + "t", JSON.stringify(arr));
          putMyVar(k + "url", href);
          refreshPage(true);
          return "hiker://empty";
        }, key, href, gi, ii)
      });
    }
    d.push({ col_type: "blank_block" });
  }
  return d;
};

JKit.filterUrl = function (host, fallback) {
  var u = "";
  try { u = getMyVar((host || "") + "flturl", "") || ""; } catch (e0) { u = ""; }
  if (!u) {
    try { u = getMyVar((host || "") + "flturl".replace("flturl", "flt") + "url", "") || ""; } catch (e1) { u = ""; }
  }
  try {
    if (!u) u = getMyVar(JKit.str(host) + "flturl", "") || "";
  } catch (e2) {}
  try {
    if (!u) u = getMyVar(JKit.str(host) + "flt" + "url", "") || "";
  } catch (e3) {}
  return u || fallback || "";
};

/* 标准影视二级对象。聚阅宿主可直接吃这个 return */
JKit.detailObj = function (opt) {
  opt = opt || {};
  return {
    detail1: opt.detail1 || "",
    detail2: opt.detail2 || "",
    desc: opt.desc || "",
    img: opt.img || "",
    line: opt.line || [],
    list: opt.list || []
  };
};

/* 没有宿主 erji 时，把标准对象摊成 setResult 数组 */
JKit.detailCards = function (obj, playRule) {
  obj = obj || {};
  var d = [];
  if (obj.img) {
    d.push({
      title: obj.detail1 || "",
      desc: obj.detail2 || "",
      img: obj.img,
      url: obj.img,
      col_type: "movie_1_vertical_pic_blur"
    });
  }
  if (obj.desc) {
    d.push({ title: obj.desc, url: "hiker://empty", col_type: "long_text" });
  }
  var lines = obj.line || [];
  var lists = obj.list || [];
  var li, eps, ei, ep, u;
  for (li = 0; li < lines.length; li++) {
    d.push({
      title: JKit.sb(lines[li] || ("线路" + (li + 1)), "FF6699"),
      url: "hiker://empty",
      col_type: "text_center_1"
    });
    eps = lists[li] || [];
    for (ei = 0; ei < eps.length; ei++) {
      ep = eps[ei] || {};
      u = JKit.str(ep.url);
      if (typeof playRule === "function" && u && u.indexOf("http") === 0) {
        u = $(u).lazyRule(playRule, u);
      }
      d.push({
        title: ep.title || ("第" + (ei + 1) + "集"),
        url: u || "toast://无地址",
        col_type: "text_3",
        extra: ep.extra || {}
      });
    }
  }
  if (!d.length) d.push({ title: "‘‘’’暂无详情", url: "hiker://empty", col_type: "text_center_1" });
  return d;
};

/* MACCMS player_aaaa，encrypt 0/1/2 */
JKit.aaaa = function (html) {
  html = JKit.str(html);
  var m = html.match(/player_aaaa[^{]*(\{[\s\S]*?\})s*</);
  if (!m) m = html.match(/player_aaaa.*?=(\{[\s\S]*?\})\s*</);
  if (!m) m = html.match(/player_aaaa.*?=(\{[\s\S]+)/);
  if (!m) return "";
  var obj = null;
  try { obj = JSON.parse(m[1]); } catch (e0) { obj = null; }
  if (!obj || !obj.url) return "";
  var u = JKit.str(obj.url);
  var enc = JKit.str(obj.encrypt);
  try {
    if (enc === "1") u = unescape(u);
    else if (enc === "2") u = unescape(base64Decode(u));
  } catch (e1) {}
  return u;
};

JKit.playHeader = function (u, origin, referer) {
  u = JKit.str(u);
  if (!u) return "toast://无播放地址";
  if (/^magnet:/i.test(u)) return u;
  if (/\.m3u8|\.mp4|\.flv/i.test(u)) {
    var parts = [];
    if (origin) parts.push("Origin@" + origin);
    if (referer) parts.push("Referer@" + referer);
    return parts.length ? (u + ";{" + parts.join("&&") + "}") : u;
  }
  return u;
};

JKit.get = function (url, opt) {
  opt = opt || {};
  url = JKit.str(url);
  if (!url || url.indexOf("http") !== 0) return "";
  var headers = opt.headers || {};
  if (!headers["User-Agent"]) headers["User-Agent"] = opt.ua || "Mozilla/5.0";
  if (!headers["Accept-Encoding"]) headers["Accept-Encoding"] = "identity";
  if (opt.referer && !headers.Referer) headers.Referer = opt.referer;
  try {
    return JKit.str(request(url, { headers: headers, timeout: opt.timeout || 15000 }));
  } catch (e0) {
    return "";
  }
};

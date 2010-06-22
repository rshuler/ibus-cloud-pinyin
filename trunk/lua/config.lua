--[[----------------------------------------------------------------------------
 ibus-cloud-pinyin - cloud pinyin client for ibus
 Configuration Script

 Copyright (C) 2010 WU Jun <quark@lihdd.net>

 This file is part of ibus-cloud-pinyin.

 ibus-cloud-pinyin is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.

 ibus-cloud-pinyin is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with ibus-cloud-pinyin.  If not, see <http://www.gnu.org/licenses/>.
--]]----------------------------------------------------------------------------

socket, http, url = require 'socket', require 'socket.http', require 'socket.url'

--------------------------------------------------------------------------------
-- notify(title, [body], [icon])
-- 输入法 API
-- 显示桌面提示，例如：notify('hello', 'welcome!', 'info')

--------------------------------------------------------------------------------
-- get_selection()
-- 输入法 API
-- 获取用户选定内容，返回一个字符串

--------------------------------------------------------------------------------
-- commit(content)
-- 输入法 API
-- 向客户端程序提交文本

--------------------------------------------------------------------------------
-- set_response(pinyins, content, [priority = 128])
-- 输入法 API （仅在配置脚本中可用）
-- 设定云请求结果缓存，pinyins 相同时，只有更高 priority 才能改写 content
-- 例如：set_response('wo men', '我们')

--------------------------------------------------------------------------------
-- 一些常量
keys, masks = {	backspace = 0xff08,	tab = 0xff09,	enter = 0xff0d,	escape = 0xff1b,	delete = 0xffff,	page_up = 0xff55,	page_down = 0xff56,	shift_left = 0xffe1,	shift_right = 0xffe2,	ctrl_left = 0xffe3,	ctrl_right = 0xffe4,	alt_left = 0xffe9,	alt_right = 0xffea,	super_left = 0xffeb,	super_right = 0xffec,	space = 0x020,}, {shift = 1,	lock = 2,	control = 4,	mod1 = 8,	mod4 = 64,	super = 67108864,	meta = 268435456,	release  = 1073741824,}

--------------------------------------------------------------------------------
-- set_key(key, mask, action)
-- 输入法 API （仅在配置脚本中可用）
-- 设置快捷键动作，其中 key 是上述 keys 值或者是单个 ASCII 字符，mask 是
-- 上述 masks 的组合，注意如果 masks 中含有 shift, 那么 key 应该采用大写 ASCII
-- 字符。action 可以是 "lua:..." 用来执行一段 lua 脚本，或者是用空格分开的一些
-- 固定动作，输入法会决定要执行哪一个动作。固定的动作有：
--   correct 进入选词或者纠正模式
--   back 退格
--   commit 提交当前编辑的拼音串（转换成中文）
--   raw 将当前编辑的拼音串的键入内容直接提交（不转换成中文）
--   pgup, pgdn 选词列表中向上或者向下翻页
--   sep （全拼下）添加一个拼音分隔符
--   trad, simp 切换到繁体、简体
--   eng, chs 切换到英文模式，中文模式
--   online, offline 切换到在线、离线模式
--   cand:x x 是一个从 0 开始的数字，选择选词列表中相应的词条
-- 默认如下：
--[[
set_key(keys.tab, 0, "correct")
set_key(keys.backspace, 0, "back")
set_key(keys.space, 0, "commit")
set_key(keys.escape, 0, "clear commit")
set_key(keys.page_down, 0, "pgdn")
set_key('h', 0, "pgdn")
set_key(']', 0, "pgdn")
set_key('=', 0, "pgdn")
set_key(keys.page_up, 0, "pgup")
set_key('g', 0, "pgup")
set_key('[', 0, "pgup")
set_key('-', 0, "pgup")
set_key('\'', 0, "sep")
-- Ctrl + Shift + L : 简繁切换
set_key('L', masks.release + masks.control + masks.shift, "trad simp")
-- 左 Shift : 中英文切换
set_key(keys.shift_left, masks.release + masks.shift, "eng chs")
-- 右 Shift : 在线/离线切换
set_key(keys.shift_left, masks.release + masks.shift, "online offline")
set_key(keys.enter, "raw")
set_key('j', 'cand:0')
set_key('1', 'cand:0')
set_key('k', 'cand:1')
set_key('2', 'cand:1')
...
--]]

--------------------------------------------------------------------------------
-- set_candidate_labels(labels1, [labels2 = labels1])
-- 输入法 API （仅在配置脚本中可用）
-- 设置选词列表文字提示，仅文字提示，和按键无关，默认如下：
-- set_candidate_labels("jkl;asdf", "12345678")

--------------------------------------------------------------------------------
-- set_punctuation(half, full, [only_after_chinese = false])
-- 输入法 API （仅在配置脚本中可用）
-- 设置全角标点，half 为半角标点，full 为全角标点，如果对应多个全角标点，用
-- 空格分开。默认如下：
--[[
set_punctuation('.', "。", true)
set_punctuation(',', "，", true)
set_punctuation('^', "……")
set_punctuation('@', "·")
set_punctuation('!', "！")
set_punctuation('~', "～")
set_punctuation('?', "？")
set_punctuation('#', "＃")
set_punctuation('$', "￥")
set_punctuation('&', "＆")
set_punctuation('(', "（")
set_punctuation(')', "）")
set_punctuation('{', "｛")
set_punctuation('}', "｝")
set_punctuation('[', "［")
set_punctuation(']', "］")
set_punctuation(';', "；")
set_punctuation(':', "：")
set_punctuation('<', "《")
set_punctuation('>', "》")
set_punctuation('\\', "、")
set_punctuation('\'', "‘ ’")
set_punctuation('\"', "“ ”")
--]]

--------------------------------------------------------------------------------
-- set_double_pinyin(scheme)
-- 输入法 API （仅在配置脚本中可用）
-- 设置双拼布局，接受一个双拼到全拼的字符串映射表
-- 无默认值，使用双拼必须指定双拼布局，下面是微软拼音双拼布局
set_double_pinyin{ ['ca'] = 'ca', ['cb'] = 'cou', ['ce'] = 'ce', ['cg'] = 'ceng', ['cf'] = 'cen', ['ci'] = 'ci', ['ch'] = 'cang', ['ck'] = 'cao', ['cj'] = 'can', ['cl'] = 'cai', ['co'] = 'cuo', ['cp'] = 'cun', ['cs'] = 'cong', ['cr'] = 'cuan', ['cu'] = 'cu', ['cv'] = 'cui', ['ba'] = 'ba', ['bc'] = 'biao', ['bg'] = 'beng', ['bf'] = 'ben', ['bi'] = 'bi', ['bh'] = 'bang', ['bk'] = 'bao', ['bj'] = 'ban', ['bm'] = 'bian', ['bl'] = 'bai', ['bo'] = 'bo', ['bn'] = 'bin', ['bu'] = 'bu', ['bx'] = 'bie', ['b;'] = 'bing', ['bz'] = 'bei', ['da'] = 'da', ['dc'] = 'diao', ['db'] = 'dou', ['de'] = 'de', ['dg'] = 'deng', ['di'] = 'di', ['dh'] = 'dang', ['dk'] = 'dao', ['dj'] = 'dan', ['dm'] = 'dian', ['dl'] = 'dai', ['do'] = 'duo', ['dq'] = 'diu', ['dp'] = 'dun', ['ds'] = 'dong', ['dr'] = 'duan', ['du'] = 'du', ['dv'] = 'dui', ['dx'] = 'die', ['d;'] = 'ding', ['dz'] = 'dei', ['ga'] = 'ga', ['gb'] = 'gou', ['ge'] = 'ge', ['gd'] = 'guang', ['gg'] = 'geng', ['gf'] = 'gen', ['gh'] = 'gang', ['gk'] = 'gao', ['gj'] = 'gan', ['gl'] = 'gai', ['go'] = 'guo', ['gp'] = 'gun', ['gs'] = 'gong', ['gr'] = 'guan', ['gu'] = 'gu', ['gw'] = 'gua', ['gv'] = 'gui', ['gy'] = 'guai', ['gz'] = 'gei', ['fa'] = 'fa', ['fb'] = 'fou', ['fg'] = 'feng', ['ff'] = 'fen', ['fh'] = 'fang', ['fj'] = 'fan', ['fo'] = 'fo', ['fu'] = 'fu', ['fz'] = 'fei', ['ia'] = 'cha', ['ib'] = 'chou', ['ie'] = 'che', ['id'] = 'chuang', ['ig'] = 'cheng', ['if'] = 'chen', ['ii'] = 'chi', ['ih'] = 'chang', ['ik'] = 'chao', ['ij'] = 'chan', ['il'] = 'chai', ['io'] = 'chuo', ['ip'] = 'chun', ['is'] = 'chong', ['ir'] = 'chuan', ['iu'] = 'chu', ['iv'] = 'chui', ['iy'] = 'chuai', ['ha'] = 'ha', ['hb'] = 'hou', ['he'] = 'he', ['hd'] = 'huang', ['hg'] = 'heng', ['hf'] = 'hen', ['hh'] = 'hang', ['hk'] = 'hao', ['hj'] = 'han', ['hl'] = 'hai', ['ho'] = 'huo', ['hp'] = 'hun', ['hs'] = 'hong', ['hr'] = 'huan', ['hu'] = 'hu', ['hw'] = 'hua', ['hv'] = 'hui', ['hy'] = 'huai', ['hz'] = 'hei', ['ka'] = 'ka', ['kb'] = 'kou', ['ke'] = 'ke', ['kd'] = 'kuang', ['kg'] = 'keng', ['kf'] = 'ken', ['kh'] = 'kang', ['kk'] = 'kao', ['kj'] = 'kan', ['kl'] = 'kai', ['ko'] = 'kuo', ['kp'] = 'kun', ['ks'] = 'kong', ['kr'] = 'kuan', ['ku'] = 'ku', ['kw'] = 'kua', ['kv'] = 'kui', ['ky'] = 'kuai', ['jc'] = 'jiao', ['jd'] = 'jiang', ['ji'] = 'ji', ['jm'] = 'jian', ['jn'] = 'jin', ['jq'] = 'jiu', ['jp'] = 'jun', ['js'] = 'jiong', ['jr'] = 'juan', ['ju'] = 'ju', ['jt'] = 'jue', ['jw'] = 'jia', ['jv'] = 'jue', ['jx'] = 'jie', ['j;'] = 'jing', ['ma'] = 'ma', ['mc'] = 'miao', ['mb'] = 'mou', ['me'] = 'me', ['mg'] = 'meng', ['mf'] = 'men', ['mi'] = 'mi', ['mh'] = 'mang', ['mk'] = 'mao', ['mj'] = 'man', ['mm'] = 'mian', ['ml'] = 'mai', ['mo'] = 'mo', ['mn'] = 'min', ['mq'] = 'miu', ['mu'] = 'mu', ['mx'] = 'mie', ['m;'] = 'ming', ['mz'] = 'mei', ['la'] = 'la', ['lc'] = 'liao', ['lb'] = 'lou', ['le'] = 'le', ['ld'] = 'liang', ['lg'] = 'leng', ['li'] = 'li', ['lh'] = 'lang', ['lk'] = 'lao', ['lj'] = 'lan', ['lm'] = 'lian', ['ll'] = 'lai', ['lo'] = 'luo', ['ln'] = 'lin', ['lq'] = 'liu', ['lp'] = 'lun', ['ls'] = 'long', ['lr'] = 'luan', ['lu'] = 'lu', ['lv'] = 'lve', ['ly'] = 'lv', ['lx'] = 'lie', ['l;'] = 'ling', ['lz'] = 'lei', ['oa'] = 'a', ['ob'] = 'ou', ['oe'] = 'e', ['of'] = 'en', ['oh'] = 'ang', ['ok'] = 'ao', ['oj'] = 'an', ['ol'] = 'ai', ['oo'] = 'o', ['or'] = 'er', ['oz'] = 'ei', ['na'] = 'na', ['nc'] = 'niao', ['nb'] = 'nou', ['ne'] = 'ne', ['nd'] = 'niang', ['ng'] = 'neng', ['nf'] = 'nen', ['ni'] = 'ni', ['nh'] = 'nang', ['nk'] = 'nao', ['nj'] = 'nan', ['nm'] = 'nian', ['nl'] = 'nai', ['no'] = 'nuo', ['nn'] = 'nin', ['nq'] = 'niu', ['ns'] = 'nong', ['nr'] = 'nuan', ['nu'] = 'nu', ['nv'] = 'nve', ['ny'] = 'nv', ['nx'] = 'nie', ['n;'] = 'ning', ['nz'] = 'nei', ['qc'] = 'qiao', ['qd'] = 'qiang', ['qi'] = 'qi', ['qm'] = 'qian', ['qn'] = 'qin', ['qq'] = 'qiu', ['qp'] = 'qun', ['qs'] = 'qiong', ['qr'] = 'quan', ['qu'] = 'qu', ['qt'] = 'que', ['qw'] = 'qia', ['qv'] = 'que', ['qx'] = 'qie', ['q;'] = 'qing', ['pa'] = 'pa', ['pc'] = 'piao', ['pb'] = 'pou', ['pg'] = 'peng', ['pf'] = 'pen', ['pi'] = 'pi', ['ph'] = 'pang', ['pk'] = 'pao', ['pj'] = 'pan', ['pm'] = 'pian', ['pl'] = 'pai', ['po'] = 'po', ['pn'] = 'pin', ['pu'] = 'pu', ['px'] = 'pie', ['p;'] = 'ping', ['pz'] = 'pei', ['sa'] = 'sa', ['sb'] = 'sou', ['se'] = 'se', ['sg'] = 'seng', ['sf'] = 'sen', ['si'] = 'si', ['sh'] = 'sang', ['sk'] = 'sao', ['sj'] = 'san', ['sl'] = 'sai', ['so'] = 'suo', ['sp'] = 'sun', ['ss'] = 'song', ['sr'] = 'suan', ['su'] = 'su', ['sv'] = 'sui', ['rb'] = 'rou', ['re'] = 're', ['rg'] = 'reng', ['rf'] = 'ren', ['ri'] = 'ri', ['rh'] = 'rang', ['rk'] = 'rao', ['rj'] = 'ran', ['ro'] = 'ruo', ['rp'] = 'run', ['rs'] = 'rong', ['rr'] = 'ruan', ['ru'] = 'ru', ['rv'] = 'rui', ['ua'] = 'sha', ['ub'] = 'shou', ['ue'] = 'she', ['ud'] = 'shuang', ['ug'] = 'sheng', ['uf'] = 'shen', ['ui'] = 'shi', ['uh'] = 'shang', ['uk'] = 'shao', ['uj'] = 'shan', ['ul'] = 'shai', ['uo'] = 'shuo', ['up'] = 'shun', ['ur'] = 'shuan', ['uu'] = 'shu', ['uw'] = 'shua', ['uv'] = 'shui', ['uy'] = 'shuai', ['uz'] = 'shei', ['ta'] = 'ta', ['tc'] = 'tiao', ['tb'] = 'tou', ['te'] = 'te', ['tg'] = 'teng', ['ti'] = 'ti', ['th'] = 'tang', ['tk'] = 'tao', ['tj'] = 'tan', ['tm'] = 'tian', ['tl'] = 'tai', ['to'] = 'tuo', ['tp'] = 'tun', ['ts'] = 'tong', ['tr'] = 'tuan', ['tu'] = 'tu', ['tv'] = 'tui', ['tx'] = 'tie', ['t;'] = 'ting', ['wa'] = 'wa', ['wg'] = 'weng', ['wf'] = 'wen', ['wh'] = 'wang', ['wj'] = 'wan', ['wl'] = 'wai', ['wo'] = 'wo', ['wu'] = 'wu', ['wz'] = 'wei', ['va'] = 'zha', ['vb'] = 'zhou', ['ve'] = 'zhe', ['vd'] = 'zhuang', ['vg'] = 'zheng', ['vf'] = 'zhen', ['vi'] = 'zhi', ['vh'] = 'zhang', ['vk'] = 'zhao', ['vj'] = 'zhan', ['vl'] = 'zhai', ['vo'] = 'zhuo', ['vp'] = 'zhun', ['vs'] = 'zhong', ['vr'] = 'zhuan', ['vu'] = 'zhu', ['vw'] = 'zhua', ['vv'] = 'zhui', ['vy'] = 'zhuai', ['ya'] = 'ya', ['yb'] = 'you', ['ye'] = 'ye', ['yi'] = 'yi', ['yh'] = 'yang', ['yk'] = 'yao', ['yj'] = 'yan', ['yl'] = 'yai', ['yo'] = 'yo', ['yn'] = 'yin', ['yp'] = 'yun', ['ys'] = 'yong', ['yr'] = 'yuan', ['yu'] = 'yu', ['yt'] = 'yue', ['yv'] = 'yue', ['y;'] = 'ying', ['xc'] = 'xiao', ['xd'] = 'xiang', ['xi'] = 'xi', ['xm'] = 'xian', ['xn'] = 'xin', ['xq'] = 'xiu', ['xp'] = 'xun', ['xs'] = 'xiong', ['xr'] = 'xuan', ['xu'] = 'xu', ['xt'] = 'xue', ['xw'] = 'xia', ['xv'] = 'xue', ['xx'] = 'xie', ['x;'] = 'xing', ['za'] = 'za', ['zb'] = 'zou', ['ze'] = 'ze', ['zg'] = 'zeng', ['zf'] = 'zen', ['zi'] = 'zi', ['zh'] = 'zang', ['zk'] = 'zao', ['zj'] = 'zan', ['zl'] = 'zai', ['zo'] = 'zuo', ['zp'] = 'zun', ['zs'] = 'zong', ['zr'] = 'zuan', ['zu'] = 'zu', ['zv'] = 'zui', ['zz'] = 'zei',['v'] = 'zh', ['i'] = 'ch', ['u'] = 'sh',}

--------------------------------------------------------------------------------
-- set_switch(switches)
-- 输入法 API
-- 设置开关，默认值如下
--[[
set_switch{
	default_chinese_mode = true,
	default_offline_mode = false,
	default_traditional_mode = false,
	double_pinyin = false,
	background_request = true,
	show_raw_in_auxiliary = false,
	always_show_candidates = false,
	show_pinyin_auxiliary = true,
}
--]]

--------------------------------------------------------------------------------
-- set_timeout(timeouts)
-- 输入法 API
-- 设置超时，单位为秒，默认如下：
--[[
set_timeout{
	request = 15.0,
	prerequest = 3.0,
	selection = 2.0,
}
--]]

--------------------------------------------------------------------------------
-- set_limit(limits)
-- 输入法 API
-- 设置限制，默认如下：
--[[
set_limit{
	db_query_limit = 128,
	request_retry_limit = 3,
}
--]]

--------------------------------------------------------------------------------
-- set_color(colors)
-- 输入法 API （仅在配置脚本中可用）
-- 设置颜色，颜色的格式是 “[foreground][,[background][,underlined]]” 默认如下：
--[[
set_colors{
	'buffer_raw' = '00B75D',
	'buffer_pinyin' = ',,1',
	'candidate_local' = '',
	'candidate_remote' = '0050FF',
	'preedit_correcting' = ',FFB442',
	'preedit_local' = '8C8C8C',
	'preedit_remote' = '0D88FF',
	'preedit_fixed' = '242322',
}
--]]

--------------------------------------------------------------------------------
-- user_config_path， user_data_path， user_cache_path, data_path
-- 由输入法提供的一些路径

local user_config_path = user_config_path .. '/config.lua'
local autoload_file_path = '/tmp/.cloud-pinyin-autoload.lua'

--------------------------------------------------------------------------------
-- register_engine(name, script_path, [priority = 1])
-- 输入法 API （仅在配置脚本中可用）
-- 注册一个云请求脚本，如果 script_path 为空，则注销该脚本，重复注册取后者
-- priority 为通过该云请求脚本的请求的优先级
-- 注意：注册多个云请求脚本明显导致使用时消耗更多的系统资源，优先级相同有助于
-- 降低系统资源消耗，建议选择速度较快的一个云请求脚本（注销另一个），以消除资源
-- 浪费
register_engine("Sogou", data_path .. '/lua/engine_sogou.lua')
register_engine("QQ", data_path .. '/lua/engine_qq.lua')

-- wrapped dofile
function try_dofile(path)
	local file = io.open(path, 'r')
	if file then file:close() pcall(function() dofile(path) end) end
end

-- load various script files if exists
try_dofile(user_config_path)
try_dofile(autoload_file_path)

--------------------------------------------------------------------------------
-- go_background()
-- go_background 使得后续代码在单独的进程中执行，不再阻塞主 lua 线程，但由于新生
-- 进程和主进程无联系，在此之后不能再使用任何输入法提供的接口。
go_background()

-- update various things in background
http.TIMEOUT = 10

if false and not do_not_load_remote_script then
	http.TIMEOUT = 5
	os.execute("mkdir '"..ime.USERCACHEDIR.."' -p")
	local autoload_file_path = ime.USERCACHEDIR..'/autoload.lua'
	local ret, c = http.request('http://ibus-cloud-pinyin.googlecode.com/svn/trunk/lua/autoload.lua')
	if c == 200 and ret and ret:match('ibus%-cloud%-pinyin%-end') then
		local autoload_file = io.open(autoload_file_path, 'w')
		autoload_file:write(ret)
		autoload_file:close()
	end
end

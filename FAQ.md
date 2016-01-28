# 常见问题 #

**Q**: 程序崩溃了，怎么办？<br>
<b>A</b>: 请先检查一下程序的版本，如果您是之前自行编译安装的，请重新编译安装一遍并重新启动 ibus 试试看，因为本程序使用的编译器和相关依赖库代码也在不断变化中，此种变化很容易造成以前编译好的程序不稳定；如果您是通过发行版或者是第三方软件包安装的，请试试看自行编译或者稍微等一等。如果以上步骤还不行，请通过 <a href='Feedback.md'>Feedback</a> 描述的方法反馈您的问题。<br>
<br>
<b>Q</b>: 为什么没有图形界面的配置工具？<br>
<b>A</b>: 因为目前支持的配置文件太过灵活，做出对应的配置工具很麻烦，作者认为也没有必要。另外，经典的 fcitx 输入法也是使用配置文件的 :p<br>
<br>
<b>Q</b>: 修改配置文件之后如何生效？<br>
<b>A</b>: 默认情况下重启 ibus 即可：右键单击 ibus 图标，选择 Restart。<br>
<br>
<b>Q</b>: 如果没联网会怎样？<br>
<b>A</b>: 如果没有联网并且输入法正处于在线模式的话，所有的请求都会很快失败，并很快达到最大容忍次数，输入起来和离线模式差别不大，绿色的网络状态提示图标会是 0 格。但如果联网了，同时无法连接到云服务器（比如防火墙或者是某些局域网环境），请求不会立即失败，而是到达超时容忍限度才会失败，默认情况下这段时间比较长，输入法状态条会有动画的蓝色图标表示请求正在进行中，建议此时立即切换到离线模式。<br>
<br>
<b>Q</b>: 什么是“纠正模式”？<br>
<b>A</b>: <i>[待编辑]</i>

<b>Q</b>: 关于模糊音？<br>
<b>A</b>: <i>[待编辑]</i>

<b>Q</b>: 如何才能用繁体字？<br>
<b>A</b>: <i>[待编辑]</i>

<b>Q</b>: 如何自造词？<br>
<b>A</b>: 自造词首先要输入需要造的词的*完整拼音<b>，不能使用简拼，也不能一段一段地输入这个词，然后从左到右依次选词（可以直接选词，也可以先按下 Tab 键进入纠正模式然后选词）将这个词确定下来，即可完成造词。</b>

<b>Q</b>: 候选词的位置是怎样动态调整的？<br>
<b>A</b>: 候选词的位置和词频以及上一次使用的时间有关，如果输入了*完整拼音<b>，并选择了处在非本地词库第一候选的词，则输入法会适量增加该词的词频信息并调整使用时间。一个长期不使用的词可能会处在很靠后的位置。</b>

<b>Q</b>: scel 词库是什么，是不是导入得越多越好？<br>
<b>A</b>: scel 词库是搜狗细胞词库文件。其中的词频信息没有被完全解读出，各细胞词库之间的词频信息差异较大，虽然本输入法尝试做了一些标准化，但最终不同文件的词频数据仍显得混乱，所以并不是导入得越多越好。导入的词库中含有同现有词库词条内容相同时，会覆盖现有词库词频，建议仅用此功能导入词条偏僻的词库。<br>
<br>
<b>Q</b>: 在离线模式下输入法使用的什么词库？<br>
<b>A</b>: 离线模式下输入法使用的是与 ibus-pinyin 1.2 - 1.3 内容相同词库文件（虽然内容相同，但建立的索引不同，直接混用会有性能问题），以及不直接与其他输入法兼容的用户词库。<br>
<br>
<b>Q</b>: 在线模式下会考虑用户词库吗？<br>
<b>A</b>: 在线模式下的蓝色候选以及整句默认转换是云服务器直接返回的结果，仅和输入的拼音有关，与本地词库以及用户词库没有关系。候选词列表中非蓝色条目，无论在线模式或是离线模式，都会考虑本地词库。<br>
<br>
<b>Q</b>: 如何使用代理服务器？<br>
<b>A</b>: 目前没有好的办法设置代理服务器，如果确实需要的话，可以配置 proxychains 或者 tsocks 这样的程序，使用类似 <code>proxychains ibus-daemon -rxd</code> 的方法运行 ibus 来让程序使用代理。<br>
<br>
<b>Q</b>: 我担心输入内容的隐私问题...<br>
<b>A</b>: 输入法默认使用了 Sogou 和 QQ 的 Web 版本云拼音服务，在线模式下，输入的拼音会被明文发送到 Sogou 和 QQ 服务器，结果会明文返回，此过程中经过的所有中继设备（比如，路由）都可记录下这些拼音和文字。用户选择具体哪一个词的信息不会被发送到网络上。要输入隐私内容的时，可以切换到输入法的离线模式。<br>
<br>
<b>Q</b>: 这个输入法和 Sogou 和 QQ 有什么关系？<br>
<b>A</b>: 这个输入法用到了 Sogou 和 QQ 的 Web 拼音服务，即：这个输入法会发送拼音，然后采用远程服务返回的汉字。开发此项目是个人行为。
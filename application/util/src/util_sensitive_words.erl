%% @author Administrator
%% @doc @todo Add description to util_sensitive_words.

-module(util_sensitive_words).

-define(SENSITIVE_WORDS,
		["钓鱼岛","尖阁列岛","谋杀","吸毒","贩毒","赌博","拐卖","走私","卖淫","造反","监狱","强奸","轮奸","抢劫","先奸后杀","下注","押大","押小","抽头","坐庄","赌马","赌球","筹码","老虎机","轮盘赌",
		 "安非他命","大麻","可卡因","海洛因","冰毒","摇头丸","杜冷丁","鸦片","罂粟","迷幻药","白粉","东正教","大法","法轮","法轮功","瘸腿帮","真理教","真善忍","转法轮","自焚","走向圆满","风水",
		 "跳大神","神汉","神婆","大卫教","阎王","黑白无常","牛头马面","藏独","回回","疆独","蒙古鞑子","台独","台独分子","台联","台湾民国","西藏独立","新疆独立","南蛮","老毛子","回民吃猪肉",
		 "毛泽东","周恩来","刘少奇","朱德","彭德怀","林彪","刘伯承","陈毅","贺龙","聂荣臻","徐向前","罗荣桓","叶剑英","李大钊","陈独秀","孙中山","孙文","孙逸仙","邓小平","陈云","江泽民","李鹏",
		 "朱镕基","李瑞环","尉健行","李岚清","胡锦涛","罗干","温家宝","吴邦国","曾庆红","贾庆林","黄菊","吴官正","李长春","吴仪","回良玉","曾培炎","周永康","曹刚川","唐家璇","华建敏","陈至立",
		 "陈良宇","张德江","张立昌","俞正声","王乐泉","刘云山","王刚","王兆国","刘淇","贺国强","郭伯雄","胡耀邦","李登辉","连战","陈水扁","宋楚瑜","吕秀莲","郁慕明","蒋介石","蒋中正",
		 "蒋经国","马英九","习近平","李克强","杨尚昆","王光美","郭振家","陈秋平","蒋达德","陈忠财","樊金源","赵文淦","张国栋","石宗源","于永湛","桂晓风","杨牧之","任泽民","沈仁干","石峰","吴帮国",
		 "无帮国","无邦国","无帮过","瘟家宝","假庆林","甲庆林","假青林","离长春","习远平","袭近平","李磕墙","刘延东","李长春","李克强","李源潮","吴邦国","汪洋","张高丽","张德江","周永康","胡锦涛",
		 "俞正声","贺国强","贾庆林","徐才厚","郭伯雄","温家宝","薄熙来","王立军","郭振家","李闽榕","蒋达德","陈忠财","樊金源","赵文淦","张国栋","国民党","打倒国民党","日本帝国","达赖","达赖喇嘛",
		 "江青","张春桥","姚文元","王洪文","东条英机","希特勒","墨索里尼","冈村秀树","冈村宁次","高丽朴","赵紫阳","王丹","沃尔开西","李洪志","李大师","赖昌星","马加爵","班禅","额尔德尼",
		 "山本五十六","阿扁","阿扁万岁","热那亚","花革命","茉莉花","牡丹花","两会","中国茉莉花革命","中国茉莉花运动","ML花革命","ML花运动","ML花","梅花革命","牡丹花革命",
		 "映山红(金达莱)革命","葵花子政变","二十日","广场","东突厥斯坦","1989年6月4日","六四","六四运动","美国之音","民国","民进党","民运","民主","民主潮","纳粹","南华早报",
		 "明慧网","起义","亲民党","人民报","法轮大法","打倒共产党","台独万岁","示威","台湾岛国","台湾国","台湾独立","太子党","天安门事件","屠杀","新党","新疆分裂","新疆国","西藏分裂",
		 "西藏国","藏青会","藏妇会","学潮","学运","一党专政","一中一台","两个中国","一贯道","游行","圆满","镇压","政变","政治","政治反对派","政治犯","中共","共产党","反党","反共","政府",
		 "民主党","中国之春","共党","共匪","苏家屯","基地组织","塔利班","东亚病夫","支那","高治联","高自联","专政","专制","陆肆事件","九评","gongchandang","一党独裁","核工业基地","核武器",
		 "铀","原子弹","氢弹","导弹","核潜艇","大参考","小参考","国内动态清样","内蒙古抗议","内蒙古5.11","内蒙古5.11事件","内蒙古锡林郭勒盟","毛主席","3P","处女","奸杀","K粉","任弼时",
		 "房事","新闻出版总署","血腥鎮壓","一黨","中國官方","獨裁政權","六四天安門","大屠殺","李鵬","專制","吾爾開希","高自聯","六四鎮壓","北高聯","天安門清场","第廿七軍","六四運動",
		 "天安門大屠殺","八九民運","八九學運","抗議鎮壓","反革命暴亂","向學生開槍","趙紫陽","罷課潮","烰嬅","獨立","達賴","臺灣獨立","藏獨","西藏獨立","疆獨","新疆獨立","台灣","李红痔",
		 "李宏志","李宏治","共铲","供产傥","供残傥","产傥","反黨","褪出","法輪","法谪","法谪功","发抡功","法一轮","法十轮十功","珐.輪功","法lun功","法L功","多黨","发轮","发伦","发抡","发沦",
		 "发囵","发仑","发纶","法纶","法沦","法抡","法愣","fa轮","下法轮","发论","抡功","伦功","轮大","法功","胡紧掏","胡锦滔","胡锦淘","江八点","江流氓","江则民","江泽慧","江贼","江独裁",
		 "江贼民","江折民","江澤民","江猪","江猪媳","江core","江ze民","江蛤蟆","将则民","僵贼","僵贼民","酱猪媳","毛厕洞","毛贼东","温加保","封杀酱猪媳","共黨","鄧小平","共產黨","黑社會",
		 "高幹","溫家寶","吳邦國","曾慶紅","黃菊","羅幹","賈慶林","朱溶剂","邓笑贫","美國之音","江澤泯","毛猪席","毛澤","朱榮機","大紀元","活摘人體","车仑工力","砝仑大砝","砝伦","砝轮",
		 "江昏君","江二世","江魔头","江浙.民","法論","法论功","法伦","猪聋畸","供谠","胡紧套","胡錦濤","fa车仑工","正攵氵台","鎮壓","學生運動","還權","tianandoor","學運","m泽东",
		 "猪容鸡","胡紧逃","曾q红","温jb","胡jt","湖竟套","江戏子","李月月鸟","江路线","虎劲涛","瘟家饱","被增长","被自愿","反中游行","谭豁子","三呆婊","胡锦套","胡金淘","江泽泯","朱容鸡",
		 "腐败症腐","九.评","九一评","ufco.net","退党","tuidang.epochtimes","三退热线","大纪元","大记元","大一纪","大纪园","共一党","邓颖超日记","人民内情真相","南大自由论坛",
		 "木子论坛","反社会","反人类","共狗","卖国","高薪养廉","独立中文笔会","邪党","中共暴政","9评","9平视频","退出党","腐败无救","灭中共","党邪恶","中共暴力","党的暴力","中国新民党",
		 "中国网民党","愚民政策","反民众","官僚精英","反共复国","收复大陆","消灭共产帝国","反共产","诛共匪","灭共党","反攻大陆","铲除共匪","pilibaoliao.4pu","藏字石","中共专制","专制当局",
		 "内人党","挖肃","八路匪","sites.google.comsitezhongyuanxue","退出傥","共产专制","共产小丑","共产极权","共产王朝","共产无赖","中共迫害","中共走狗","中共恶霸","中共独枭",
		 "政治恶棍","政治小丑","共产党独裁","反封锁","反对党","贪污犯","官场经济","政府腐败","中共当局","洋奴哲学","联动分子","镇压群众","反共复民","反共复清","中華民國","共產党","共产",
		 "中共","中华人民","大圆满法","大善大忍","法正人间预","江泽民其人","江氏末政","京城血案的真相","法仑","中国之毁灭","自焚案惊人秘密","自焚还是骗局","洗脑班","大法的纯洁","大法资料",
		 "非法抓捕","被害学员","大法修炼","被毛整死","参与迫害的中共","明慧周报","明慧周刊","修炼大法","发愣工","法.轮功","法.轮.功","法轮.功","法l2工力","法一轮一功","法轮一功","法一轮功",
		 "非法器官移植","非法镇压","诽谤大法","佛家大法","破坏大法","干扰大法","高.智.晟","六一○办公室","秘密关押","秘密监禁","纪元动态","纪元快讯","纪元特稿","纪元文化","纪元专栏","正法修炼",
		 "正法之路","正见书籍","正清网","氵去lun","珐伦","真sh忍","9一i平","da法好","神惩罚党","氵去仑","fa工力","李da师","轮公","轮攻","沦功","沦公","沦攻","论攻","论功","法论公","伦攻",
		 "伦公","法淪","法倫","發輪","發論","發淪","發倫","輪功","輪公","輪攻","淪功","淪公","淪攻","論攻","論功","論公","倫攻","倫功","倫公","大g元","法治大法","不信耶稣的人会下地狱","法抡工",
		 "万邦教会","万邦宣教教会","fa抡工力","会道门","主神教","中华养生益智功","旷野窄门","太比力克","沈昌特功","观音法门","闻香教","圆顿教","圆顿法门","被立王","国际中功总会","國際中功總會",
		 "灵灵教","三元教","乐施会","aboluowang.com","联合教会","城市教会","三赎基督","见证三赎","蒙福派","二两囊帕拉","雪山狮子","次旺仁增","东突","东土耳其斯坦","西藏论坛","自由西藏","北京之春",
		 "自由时报","蔡崇国","北美自由论坛","亚洲自由之声","春夏自由论坛","正义党论坛","宇明网","蒙古国","统独论坛","台盟","台湾建国运动组织","台湾青年独立联盟","台湾政论区","台湾自由联盟",
		 "独立台湾会","建国党","乌伊会","世维会","西藏万岁","我的上师","反汉复藏","藏族独立","西藏之声","其美仁增","自由亚洲电台","达赖集团","踩踏佛像","藏国","白玉网","西藏要人权","西藏要人權",
		 "西藏要独立","蒙独","黑色之年","西藏妇女会","热比亚","热比娅","曹长青","西藏作为宗教国家","天佑台湾","1989年诺贝尔和平奖","印度爱藏","祝福达赖","西藏49秒","voanews.com",
		 "rfa.org","洛波桑","西藏平暴","雪山狮子旗","dalailama","西藏青年大会","前政治犯协会","西藏全国民主党","国际西藏运动","西藏委员会","西藏之友","西藏的控制","西藏的压制",
		 "拉顿德通","刚热","西藏团结委员会","西藏人民大起义运动","泰米尔猛虎","自杀式爆炸","索朗朗杰","迪考谭凯","旦正昂杰","夏珠活佛","门朗塔庆","格桑坚赞","西藏国家","西藏妇女协会",
		 "噶伦桑东","国际支持西藏网络","九十三运动","普布次仁仁波切","freetibet","達賴喇嘛","藏人国旗","藏人的国旗","桑东仁波切","比次仁","圣战组织","圣战培训班","东伊运",
		 "突厥斯坦伊斯兰党","东突解","世界维吾尔青年代表大会","苗独","台獨","世界维吾尔代表大会","熱比婭","热比婭","熱比娅","世界維吾爾代表大會","精神母亲","世维大会","世界维吾尔大会",
		 "迪里夏提","世界维吾尔族人大会","多里坤艾沙","多里坤.艾沙","新纳粹","欧洲东突联盟","东突信息中心","阿不都吉力力","卡拉卡西","乌兹别克斯坦伊斯兰运动","阿卜杜勒","哈克","艾孜来提",
		 "真主党","东突民族党","维吾尔青年联盟","东突信息联络中心","蓝色蒙古","爱的10个条件","瑞典维吾尔人委员会","买买提","阿不都热合曼","艾山买合苏木","亚甫泉","新疆独立运动","卡日阿吉",
		 "吐尔逊","胡达拜尔地","阿西尔白克","亚生买买提","阿塔汗","阿不都艾尼","国际声援西藏运动","侯赛因江","事实独立","东北独立","四川独立","回民暴动","藏青會","西藏本非国土","我的喇嘛",
		 "艾买提","亚库甫","阿布都米吉提","夏米斯丁艾合麦提","艾可米来","吾买尔江","爱的十个条件","西藏血统","藏族血统","陈巧文","果洛拉加寺","祥萨仁波切","打压异族","达赖活佛",
		 "没有伤痕的酷刑","台灣獨立","新疆人","同香会","捅死一女两男","噶玛巴","扎西东知","19582008的恐惧","会见达赖","印度之子","起义日","反华活动","西藏抗暴","中共极左政策","我的土地我的人民",
		 "我的土地和我的人民","藏人社区","毁灭佛教","⒍4学潮","六四学潮","民运领袖","天安门母亲","六四天安","工自联","中国六四真相","坦克车从学生们的身上辗过","军队向人民开枪","坦克车压伤",
		 "六4事件","天安門事件","六四詩集","六四诗集","北京市高校学生自治联合会","北京工人自治联合会","六四镇压","六四屠杀","天安门屠杀","天安门清场","64事件","第二十七军","五一七宣言",
		 "四二二事件","天安门大屠杀","八九民运","八九学运","八九见证","六四政变","六四屠城","六四之役","六四母亲","六四血案","天安门录影带","89学潮","天安门四君子","6.4事件","张柏笠",
		 "天安门大学生事件","港支联","香港支联会","六肆","除报禁","六四惨案","五四谈话","六四风波","二六社论","北高联","六四尾声","六四民運","六四死难者","六四平反","六四动乱","六四暴乱",
		 "平反64","平反六四","tiananmenshijian","六．四运动","64学生运动","八九学生","六.四惨案","六si死難","六四死難","64死難者","64死难","6.4运动","64运动","64学潮",
		 "6四事件","6四学潮","6泗","六泗","64血案","64学运","六四学运","六四之後","六四之后","學生運動","64遇難","六四遇难","64死難","勿忘六四","勿忘64","毋忘六四","毋忘64",
		 "六四民运","64民运","民运平反","liu四","liu泗","六si","六四纪念","纪念六四","64纪念","纪念64","64天安门","六四二十周年","六四20周年","64二十周年","民运二十周年",
		 "民运20周年","纪念89","89纪念","纪念八九","八九纪念","八九二十周年","89二十周年","八九20周年","六四屠殺","六四血腥","學潮","戒嚴","广场学生","426社论","516社论","绝食静坐",
		 "吳學燦","血洗政策","89年春夏之交","还我紫阳","高治聯","血洗京华","4．26社论","鲍彤","改革历程","国家囚徒","赵紫阳回忆录","军队屠城","6.4学潮","熊焱","熊炎","八九之后","89之后",
		 "静思节","禁食祷告日","唐荆陵","熱血可以換來自由","歷史的傷口","八九风波","89风波","靜思節","靜偲兯","靜偲節","6月fourth","怀念64","屠杀学生","屠杀大学生","悼念胡耀邦",
		 "二十年前天安门","政治風波","20年前天安门","张伯笠","学生运动","天安门的母亲","隐退的正义","同声哭泣","民主运动","鲍朴","64之前","雨夜送耀邦","逃离中国","64暴乱","民運",
		 "64天安","64真相","64真像","64詩集","64诗集","64镇压","64屠杀","64政变","64屠城","64之役","64母亲","64惨案","64风波","64尾声","64平反","64动乱","64之後",
		 "64之后","64屠殺","64血腥","64伤残","广场上的热血","热血洒广场","广场上的鲜血","鲜血洒广场","89天安门","89年天安门","学生动乱","廿周年","天安門","20週年","二十週年","鮑彤",
		 "鮑朴","改革歷程","廣場上的共和國","广场上的共和国","民主歷程","我的民主历程","民主運動","屠殺學生","李录","戒严令","64历史","民主化運動","64旁见","柴琳","柴铃","六一一四","6一一4",
		 "六一四","6一4","吾爾開","吾尔开西","泯运","戒严指挥","候德建","柴总指挥","北京动乱","天安门之魂","springof1989","天安门广场枪杀学生","天安门广场大屠杀","天安门广场民主运动","八九六四",
		 "64memo.com","六四档案","天安门事变","血腥镇压","四月二十六日社论","八九北京事件","血洗京城","血洗北京","反革命暴乱","1989年春夏之交","封从德","郭海峰","赵长青","王有才","周锋锁",
		 "王维林","军民冲突","天安门被清场","陈一咨","苏晓康","学自联","邢铮","蘇曉康","河殤","外高联","1989天安门","鲍戈","六四图片","六四掺案","tiananmen事件","镇压学生事件","林昭",
		 "动乱分子","大学动乱","6.4屠城","89年学潮","八九年学潮","大学生闹天安门","镇压六四","89年6月","学潮暴乱","漆黑将不再面对","天安门母亲的呼唤","狐狸先生的尾巴",
		 "bloodisonthesquare","国共伪造的历史","毛泽东的最后二十年","天安门路在何方","怎么看和怎么办","江上的母亲尘世挽歌","走近冰山","⑥四分子","坦克节","中共打压","5月35号",
		 "5月35日","北京大屠杀","中共屠城","镇压八九","中共倒台","游行抗议","官官相护","恶打","滥用枪支","暴打","毒打","强征土地","忽视农民","中国人很能骂","公安恶人","暴力执法","警车被掀",
		 "黑恶公安","伪法院","警察暴力","匪警","群众聚集","打伤小贩","血腥暴力","流血冲突","警察打人","邪警","结谠营私","爆乱","骚乱","见人就打","见车就砸","打人致死","暴乱","动乱","困官砸车",
		 "执法何在","带薪坐牢","打人公务员","公务员打人","官商联手","滥用政府权力","贪淫","流氓警察","被警察打","警察的暴行","官员奸淫","黑衙门","打人交警","有执照的流氓","警察杀人","警察禽兽",
		 "黑暗政府","强行拆迁","强制拆迁","官员恶","官员流氓","官匪","闵行倒钩门","政府太黑","政府太贪","政府太无能","官场腐败","钓鱼执法","tmd政府","抵制政府","政府是大爷","政府是爷",
		 "政府吃屎","政府他妈的","他妈的政府","霸王执法","合法土匪","中国的腐败","警察的腐败","官官相照","官官相通","官官相互","垃圾政府","打死人","官官勾结","警察腐败","军警毒打",
		 "军警殴打","政府垃圾","醉驾撞死","特大血案","替党说话","国家的黑暗","强拆","朱容基","滥用武力","围攻","群殴","渎职","势力的狗","闹事","深夜执法","大虹桥规划","郑州警方扫黄",
		 "粗暴执法","郑州扫黄","嫖资纠纷","学生暴动","抗議強拆","暴力拆房","艺术区遭拆迁","艺术区拆迁","开水有毒","有毒的不是开水","喝水死","施工暴徒","呼和浩特戒毒所","戒毒所遭强奸",
		 "睡觉死","亲友死在看守所","全国模范看守所","先谢国家","强奸致死","孙中界","王益","砍伤儿童事件","砍杀事件","砍伤19名师生","杀人事件","被砍事件","砍杀学生","砍杀小学生",
		 "砍人事件","幼儿园砍杀","幼儿园被砍杀","砍杀幼儿园","凶杀案","砍伤32人","踩踏事件","踩踏事故","本田","铝厂污染","群体性事件","村民游行","世博文化中心","执法犯罪","以权办案",
		 "以钱结案","权钱交易","警匪勾结","军匪勾结","残害百姓","暴力冲突","交警暴力","掀翻警车","官逼民反","重大事件","上万围攻","民众爆动","中国留学生","料理店","妓女","拆迁户","警察",
		 "地方势力","火葬场","洞口县","城管","民警","武警","黑车","警用执法车","阅兵仪式","恶警","公安","特警","绝对的弱者","军警","执法者","围观的群众","警车","公务员","当政者","陈雄杰",
		 "南汇","景逸鸣","小姐裸照","邓罗生","藝術家","长安街游行","艺术家长安街","王亚辉","活埋","郗红","何舍彪","周洋","不配合","索赔12万","王小丫","王小y","王小鸭","王小压","幼儿园",
		 "惨案","血案","世博","韩国馆","自制土炮","闹罢工","工人罢工","靖西","跳楼","自杀","维权","交警","派出所","回族","抗日","反日","网民诬告","游精佑","范燕琼","吴华英","福清纪委爆炸",
		 "南京近期要地震","中国地震局预报","地质学家的预言","学校血案频起","全怪隔壁幼儿园","前面左转是政府","砸你饭碗是城管","官商勾结我无罪","奶粉毒害的是你们","疫苗伤害的是你们",
		 "地震压死的是你们","成人用刀报复的也是你们","你们扫了爷爷的兴","你们扫了爷爷兴","你们扫了爷的兴","美国国家地震台网预测","南平血案","南平事件","雷州砍人","泰兴惨案","中国没有人权",
		 "幼儿园又遭毒手","校园伤害案","天上人间夜总会被查","天上人间都被查了","天上人间被查","天上人间是事业单位","失去了原有意义的世博会","世博能否推出中国价值观","沁园春房","房奴如潮",
		 "房奴滔滔","数天价楼盘","数天价楼市","平息不了西南人民的怨气","军队在锦州集结","军队集结完毕","国内恐慌","封索信息","农民自制土炮","轰退百人强拆队","马鞍山6.11事件","地铁爆炸",
		 "靖西事件","靖西肉搏事件","罢工事件","罢工潮","罢工维权","女大学生包养价格","包年生活费","哪个让你直播的","谁让你直播的","铲车事件","铲车撞人","铲车肇事","捍卫粤语","保护粤语",
		 "支持粤语","撑粤语","推普废粤","淄博博山机关幼儿园","周小川出逃","示威抗议","政府黑幕","严格封锁","官界黑暗","主子奴才和狗","游行的意义","背离了改革初衷","2010诺贝尔和平奖",
		 "龙圩特大暴乱事件","反日游行","抗日游行","还我钓鱼岛","工人的觉醒","新工人运动","联通罢工","维护罢工","抵制联通","交警当街被杀","交警遇刺","持刀杀交警","杀死交警后","刺死警察",
		 "砸警车","集体罢工","出租车大罢工","出租车罢工","兲朝真理","真理部","不得报道","不得炒作","零八宪章","O八宪章","08宪章","零8宪章","张祖桦","09宪章","零九宪章",
		 "没有理由拒绝的宪章","世界人权宣言60周年","被删除文章","抵制央视","拒绝洗脑","抵制新闻联播","宣传联播","303名各界人士","劉曉波","二+六宪章","2的三次方宪章","23宪章",
		 "91宪章","2的3次方宪章","二的三次方宪章","二的3次方宪章","零八纲领","黄琦","网络革命宣言","零八憲章","难忘如火广场景","自记血浮帝王宫","道是无秦却有秦","贪风如虎吞三辰",
		 "天安门下泪汪洋","京华学子誓绝食","坦克狂奔追人碾","天安门下盈尸野","敢用炸子杀青年","人民军杀人民子","江婴","蒙汗药出售","迷奸药出售","强奸丸","淫荡迷情药","香烟迷药催眠迷幻药",
		 "速效迷奸药","失身粉","拍肩迷药出售","红蜘蛛迷奸药","迷魂药出售","迷情水出售","喷雾蒙汗药","迷奸香水出售","香水型迷奸药","少女迷奸药水","少女迷情药","西班牙苍蝇水",
		 "少女迷情粉货到付款","狂插男根胶囊","狂插性器具","SM后庭器具","制幻剂出售","女性自慰sex吧","阴茎","日你","阴道","干死","你妈","TNND","幼齿","干死你","作爱","阝月","歇逼",
		 "蛤蟆","发骚","招妓","阴唇","操你妈","精子","奸淫","菜逼","奶奶的","日死你","贱人","你娘","肛交","破鞋","贱逼","娘的","狗卵子","骚货","大比","龟公","欠日","狗b","牛逼","妈批",
		 "欠操","我操你","烂逼","你爸","屁眼","密穴","鸡奸","群奸","烂比","喷你","大b","小b","性欲","你大爷","淫荡","中国猪","狂操","婊子","我操","淫秽","狗屎","十八摸","操逼","二B","猪毛",
		 "狗操","奶子","大花逼","逼样","去你妈的","完蛋操","下贱","淫穴","猪操","阴水","操比","精液","卖比","16dy-图库","獸交","爱女人","拔出来","操b","插进","插穴","吃精","抽插","大乳",
		 "调教","黄色电影","激情电影","轮暴","迷奸","乳房","色猫","色欲","性爱图库","亚情","淫亂","淫女","淫蕩","淫水","淫汁","幼圖","中文搜性网","自慰","鷄巴","學生妹","１８歲淫亂","999日本妹",
		 "幹炮","摸阴蒂","金鳞岂是池中物","掰穴皮卡丘","白虎少妇","白虎阴穴","包二奶","暴淫","逼痒","蕩妹","肥逼","粉穴","干穴","开苞","口活","狼友","春药","风艳阁","激情小说","兽欲","全裸","秘唇",
		 "蜜穴","玉穴","应召","菊花蕾","大力抽送","干的爽","肉蒲团","后庭","淫叫","男女交欢","极品波霸","兽奸","流淫","销魂洞","操烂","成人网站","淫色","一夜欢","姦淫","给你爽","偷窥图片","性奴",
		 "大奶头","奸幼","中年美妇","豪乳","喷精","逼奸","脱内裤","发浪","浪叫","肉茎","菊花洞","成人自拍","自拍美穴","抠穴","颜射","肉棍","淫水爱液","阴核","露B","母子奸情","人妻熟女","色界",
		 "丁香社区","爱图公园","色色五月天","鹿城娱乐","色色","幼香阁","隐窝窝","乱伦熟女网","插阴","露阴照","美幼","97sese","嫩鲍鱼","日本AV女优","美女走光","33bbb走光","激情贴图",
		 "成人论坛","就去诱惑","浴室自拍","BlowJobs","激情裸体","丽春苑","窝窝客","银民吧","亚洲色","碧香亭","爱色cc","妹妹骚图","宾馆女郎","美腿丝足","好色cc","无码长片","淫水涟涟",
		 "放荡少妇","成人图片","黄金圣水","脚交","勾魂少妇","女尻","我要性交","SM女王","乳此丝袜","日本灌肠","集体性爱","国产骚货","操B指南","亚洲淫娃","熟女乱伦","SM舔穴","無碼H漫",
		 "大胆少女","乳此丰满","屄屄特写","熟女颜射","要色色","耻辱轮奸","巨乳素人","妩媚挑逗","骚姨妈","裸体少妇","美少妇","射奶","杨思敏","野外性交","风骚淫荡","白虎嫩B","明星淫图",
		 "淫乱熟女","高清性愛","高潮集锦","淫兽学园","俏臀摄魄","有容奶大","无套内射","毛鲍","3P炮图","性交课","激凸走光","性感妖娆","人妻交换","监禁陵辱","生徒胸触","東洋屄","翘臀嫩穴",
		 "春光外泻","淫妇自慰","本土无码","淫妻交换","日屄","近亲相奸","艳乳","白虎小穴","肛门喷水","淫荡贵妇","鬼畜轮奸","浴室乱伦","生奸内射","国产嫖娼","白液四溅","带套肛交","大乱交",
		 "精液榨取","性感乳娘","魅惑巨乳","无码炮图","群阴会","人性本色","极品波神","淫乱工作","白浆四溅","街头扒衣","口内爆射","嫩BB","肛门拳交","灌满精液","莲花逼","自慰抠穴","人妻榨乳",
		 "拔屄自拍","洗肠射尿","人妻色诱","淫浆","狂乳激揺","騷浪","射爽","蘚鮑","制服狩","無毛穴","骚浪美女","肏屄","舌头穴","人妻做爱","插逼","爆操","插穴止痒","骚乳","食精","爆乳娘","插阴茎",
		 "黑毛屄","肉便器","肉逼","淫亂潮吹","母奸","熟妇人妻","発射","幹砲","性佣","爽穴","插比","嫩鲍","骚母","吃鸡巴","金毛穴","体奸","爆草","操妻","a4u","酥穴","屄毛","厕所盗摄","艳妇淫女",
		 "掰穴打洞","盗撮","薄码","少修正","巧淫奸戏","成人片","换妻大会","破处","穴爽","g点","欢欢娱乐时空","近親相姦","裤袜","乱伦","买春","妹妹阴毛","免费成人网站","免费偷窥网","免费A片",
		 "摩洛客","嫩b","捏弄","女优","肉棒","骚姐姐","色区","色书库","射颜","手淫","兽交","吸精少女","下流地带","性虎","性饥渴","阴部","淫妹","淫图","幼交","欲火","援交妹","嫩屄","嫩女","噴精",
		 "情色天崖","情色文学","群交亂舞","日本骚货","肉唇","肉沟","肉棍干骚妇","肉壶","肉淫器吞精","骚妹","骚女","骚水","骚穴","色狐狸网址","色狼论坛","色狼小说","湿穴","爽死我了","舔逼","舔屁眼",
		 "好嫩","大波","亂倫","做爱电影","色诱","秘裂","采花堂","含屌","亚洲性虐","夫妻自拍","熟女","操穴","裹本","淫妇","嫩逼","淫贱","欢乐性今宵","巨乳","性愛圖片","学生妹","炮友之家","花花公子",
		 "一夜情","乳沟","淫虫","叫床","porn","小姐打飞机","少女被插","Ｘ到噴屎尿","口淫","按摩棒","操我","奸情","被干","露逼","美女高潮","日逼","肉洞","阴缔","插暴","人妻","内射","肉具","欲仙欲浪",
		 "玉乳","被插","吞精","暴乳","成人午夜场","买春堂","性之站","成人社区","群交","激情聊天","三八淫","做爱自拍","淫妻","夫妻俱乐部","激情交友","诱色uu","就去色色","熟妇","mm美图","走光偷拍",
		 "77bbb","虎骑","咪咪图片","成人导航","深爱色色","厕所偷拍","成人A片","夫妻多p","我就色","释欲","你色吗","裙内偷拍","男女蒲典","色97爱","丝诱","人妻自拍","色情工厂","色色婷婷","美体艳姿",
		 "颜射自拍","熟母","肉丝裤袜","sm调教","打野炮","赤裸天使","淫欲世家","就去日","爱幼阁","巨屌","花样性交","裸陪","夫妻3p","大奶骚女","性愛插穴","日本熟母","幼逼","淫水四溅","大胆出位",
		 "旅馆自拍","无套自拍","快乐AV","国产无码","强制浣肠","援交自拍","凸肉优","撅起大白腚","骚妹妹","插穴手淫","双龙入洞","美女吞精","处女开包","调教虐待","淫肉诱惑","激情潮喷","骚穴怒放",
		 "馒头屄","无码丝袜","写真","寂寞自摸","警奴","轮操","淫店","精液浴","淫乱诊所","极品奶妹","惹火身材","暴力虐待","巨乳俏女医","扉之阴","淫の方程","丁字裤翘臀","轮奸内射","空姐性交",
		 "美乳斗艳","舔鸡巴","骚B熟女","淫丝荡袜","奴隷调教","阴阜高耸","翘臀嫩逼","口交放尿","媚药少年","暴奸","无修正","国产AV","淫水横流","插入内射","东热空姐","大波粉B","互舔淫穴",
		 "丝袜淫妇","乳此动人","大波骚妇","无码做爱","口爆吞精","放荡熟女","巨炮兵团","叔嫂肉欲","肉感炮友","爱妻淫穴","无码精选","超毛大鲍","熟妇骚器","内射美妇","毒龙舔脚","性爱擂台",
		 "圣泉学淫","性奴会","密室淫行","亮屄","操肿","无码淫女","玩逼","淫虐","我就去色","淫痴","风骚欲女","亮穴","操穴喷水","幼男","肉箫","巨骚","骚妻","漏逼","骚屄","大奶美逼","高潮白浆",
		 "性战擂台","淫女炮图","小穴","淫水横溢","性交吞精","姦染","淫告白","乳射","操黑","朝天穴","公媳乱","女屄","慰春情","集体淫","淫B","屄屄","肛屄","小嫩鸡","舔B","嫩奶","a4y","品穴",
		 "淫水翻騰","一本道","乳尻","羞耻母","艳照","三P","露毛","紧穴","露点","18禁","g片","teen","無碼電影","爱液","插b","赤裸","荡妇","荡女","浪穴","露穴","美穴","猛插","迷药","嫩穴",
		 "肉穴","乳交","乳头","无码","吸精","现代情色小说","性交图","性息","艳情小说","阴部特写","阴道图片","淫书","幼女","玉蒲团玉女心经","援助交易","中国成人论坛","中国性爱城","自拍写真",
		 "做爱图片","掰穴","万淫堂","穴图","穴淫","艳舞淫业","咬着龟头","要射了","一夜性网","阴茎插小穴","陰穴新玩法","婬乱军团","淫逼","淫姐","淫浪","淫流","淫糜","淫蜜","淫魔","淫母","淫妞",
		 "淫奴","淫娃","淫液","钻插","H动漫","交换夫妻","美腿","舔脚","蜜洞","丝袜","淫情","亚洲情色网","强奸处女","鸡巴暴胀","美乳","大众色情成人网","火辣图片","淫声浪语","疯狂抽送","淫河",
		 "多人性愛","操屄","浪女","色情论坛","性虎色网","淫欲日本","操死","色迷城","petgirl","骚女叫春","成人百强","猖妓","天天干贴图","密穴贴图","凌辱","偷欢","小逼","酥痒","品色堂","浪妇",
		 "嫖妓指南","肉缝","色窝窝","被操","巨奶","骚洞","阴精","阴阜","阴屄","群魔色舞","扒穴","六月联盟","55sss偷拍区","张筱雨","xiao77","极品黑丝","丝袜写真","天天情色","成人小说",
		 "成人文学","情色艺术天空","222se图片","偷拍","淫色贴图","厕奴","美女成人","酥胸诱惑","五月天","人体摄影","东北xx网","玛雅网","成人bt","周六性吧","爆乳","诱惑视频","裙下风光",
		 "嘻游中国","操母狗","御の二代目","丝袜足交","肮脏美学","亚洲有码","欲仙欲死","丝袜高跟","偷拍美穴","原味丝袜","裸露自拍","针孔偷拍","放荡少妇宾馆","性感肉丝","拳交","迫奸","品香堂",
		 "北京xx网","虐奴","情色导航","欧美大乳","欧美无套","骚妇露逼","炮友","淫水丝袜","母女双飞","老少乱伦","幼妓","素人娘","前凸后翘","制服誘惑","舔屄","色色成人","迷奸系列","性交无码",
		 "惹火自拍","胯下呻吟","淫驴屯","少妇偷情","护士诱惑","群奸乱交","极品白虎","曲线消魂","淫腔","无码淫漫","假阳具插穴","蝴蝶逼","自插小穴","SM援交","西洋美女","爱液横流","无码无套",
		 "淫战群P","口爆","酒店援交","乳霸","湿身诱惑","火辣写真","动漫色图","熟女护士","粉红穴","经典炮图","童颜巨乳","性感诱惑","援交薄码","美乳美穴","奇淫宝鉴","美骚妇","跨下呻吟","无毛美少女",
		 "流蜜汁","日本素人","爆乳人妻","妖媚熟母","日本有码","激情打炮","制服美妇","无码彩图","放尿","入穴一游","丰唇艳姬","群奸轮射","高级逼","MM屄","美臀嫰穴","淫东方","国产偷拍","清晰内射",
		 "嫩穴肉缝","雪腿玉胯","骚妇掰B","白嫩骚妇","梅花屄","猛操狂射","潮喷","无码体验","吞精骚妹","紧缚凌辱","奸淫电车","堕淫","颜骑","互淫","逼毛","胸濤乳浪","夫妻乱交","黑屄","奶大屄肥","拔屄",
		 "穴海","换妻杂交","狂插","黑逼","粉屄","口射","多人轮","奶挺臀翘","扒屄","痴乳","鬼輪姦","乳爆","浴尿","淫样","発妻","姫辱","插后庭","操爽","嫩缝","操射","骚妈","激插","暴干","母子交欢","嫐屄",
		 "足脚交","露屄","柔阴术","相奸","淫师荡母","欠干","桃园蜜洞","二穴中出","奴畜抄","连続失禁","大鸡巴","玩穴","性交自拍","叫鸡","骚浪人妻","做爱","坐台","子宫","杂种","淫","阴毛","阴户","阴蒂",
		 "阳具","性交","性爱","小鸡鸡","小弟弟","小便","武藤","慰安妇","猥亵","猥琐","生殖","煞笔","傻逼","傻B","色情","骚逼","三陪","肉欲","肉体","情色","排泄","女干","灭族","梅毒","卵子","淋病","口交",
		 "尻","贱","鸡吧","胡瘟","龟头","狗日","狗娘","根正苗红","睾丸","疯狗","腚","大便","打飞机","娼","瘪三","妈逼","sm","睪丸","小洞","毛片","娇吟","性器","小jj","逗乳","舌头舔","处女地","舌头添",
		 "香舌","滑腻","好紧","少妇","做一次","艳欲","骚淫","乳肌","淫裆","zuoai","口做","色图","修肛","gay男","坐台公关","男公关","性伴侣","搞个处女","性开放","e◎夜情","性欲较强","淫荡是时尚",
		 "同性恋吧","红灯区","欲生欲死","找情人","商务公关","女公关","公关小姐","g网","黄色网","cosplay","援助交际","两性私语","激情网站","炮片","两性生活","一夜激情","性电影","x伴侣","极度诱惑",
		 "性友谊","makelove","三级片","成人漫画","春宵阁","未成年禁入","成年网","就去爱","声优","生殖保健","异性按摩","卵巢保养","精油开背","优秀技师","毒龙","口暴","鸳鸯浴","性服务","蚂蚁上树",
		 "诱人身材","美女服务","推油","制服幼惑","寂寞妹妹","兼职辣妹","沙漠風暴","螞蟻上樹","老汉推车","联系妹妹","观音做帘","毒龙转","鸳鸯欲","开心转","贵妃醉酒","舔蛋","兼职上门","上门小姐",
		 "24小时上门","满足身体","制服诱惑","sexygirl","sexybottom","寂寞少婦","高级小姐","工作轻松钱又多","视频作爱联盟","视频秀","性爱视频","热舞视频","脱给你看","成人影院","激情图片",
		 "淫影","成人影视","欧美图区","亚洲图区","欧美色图","激情小电影","黄色小电影","色情小电影","色情电影","激情自拍","同居社区","狼友俱乐部","色界论坛","色吧论坛","两性屋","玉女吹箫",
		 "同志聊天室","丝袜俱乐部","情色五月","情色网","就去干","就爱色","艳狐软件","性爱网","色电影","黄色图片","黄色照片","成人网","妞妞基地","美女会所","成人频道","成人卫星频道","激情短片",
		 "成人聊天室","成人视频聊天","激情黄色","黄色激情","大学艳遇史","淫荡少妇","最新网址","淫影片","淫电影","色情导航","艳情电影","性色社区","激情在线","淫贴图","淫片","激情影院","淫色网站",
		 "黄色网站","最新黄站","诱惑电影","爽电影","成人俱乐部","色屋图片","淫情贴图","淫美贴图","熟女俱乐部","激情俱乐部","淫影院","黄站","成人社區","服务工作者","a片网","网址经过加密",
		 "e夜激情","e夜情","女人的胸男人为什么喜欢摸","成人在线电影","黄色小说","色情小说","黄小说","黄片","成人站","人体艺术","亞洲bt","清純唯美","美腿誘惑","性愛","亞洲圖區","歐美bt",
		 "激情文學","激情文学","校園文學","裸网","无毒无马","激情成人","最新网站","成人图库","清纯唯美","套图","乱伦熟女","幼幼诱女","人妻小说","台湾性虎","两性乐园","美女裸体","有碼",
		 "绝对电影地址","就去播播","97色色","97爱","无碼","美女网站","美腿丝袜","丝袜美腿","两性淫乱","成人小电影","波动少女","藏春阁","g情网站","夜店模特","性开放俱乐部","夫妻友论坛",
		 "无病毒无木马","色情影视","g情图片","jiqingshaofu","成人配色","色狼网","色情自拍","情色论坛","成人電影","黃色小電影","激情視頻","免费a片","淫荡妹妹","丁香五月天","視頻表演",
		 "淫蕩少婦","叶倩彤","葉倩彤","高樹三姐妹","高树三姐妹","激情一夜","人性rv","茎候佳阴","茎候佳淫","茎大物勃","单飞模特","东京热","tokyohot","性爱文学","性爱技巧","淫书网","中国性吧",
		 "色情网","性福联盟","漂流淫河","月宫无码","色虎网","淫乳","操丝袜","丝袜情缘","精子飲","gay片","無碼","裸体贴图","裸体在线","性爱宝典","处女全过程","处女被奸","熟女网","性爱频道",
		 "插少女","射入花心","妈的花心","淫护士","三级电影","风骚女友","护士穴","粉红乳晕","吸精痴女","bt亚洲","pp点点激情","脱衣美女","激情少女","百家性","色站","盗摄护士","毛电影",
		 "激爽电影","黄色免费电影","幼女bb","淫mm","肥嫩饱满","亚洲激情","轮姦","操护士","午夜成人","肉縫","自淫","骚b","性爱电影","淫少妇","搔b","套动着","操妹妹","情色贴图","情迷电影",
		 "淫荡骚妇","抠插","亂交","淫窝窝","成人激情","avgirls","淫嘴","激情网","艳遇录","情色網","乱轮","淫蕩妖艷","視訊辣妹","妹妹屄","咪咪情色","暴淫网","淫荡性","野外偷情","美女穴",
		 "色成人","淫虫电影","淫行物语","成人贴图","抽叉","金瓶梅","床上自拍","成人禁书","亚洲情色","色工厂","咪咪色界","欧美淫暴","熟女丝袜","极品成人","穴癢","搔逼","色妹妹","kamikazegirls",
		 "菊地麗子","作爱电影","丝袜视频","情色聊天","歐美圖區","toratora","情色電影","金城安娜","偷情網","色影院","三级小电影","性愛電影","插入穴","激情热舞","鉴别处男","鉴别处女","若妻夢交",
		 "妹妹社区","mixstudiovol","yukihoshino","avwfuckdown","angelcosplayvol","yellowsvol","nekognvol","春宫108姿势","夫妻交换","女士服务","h漫","呖呖园上操","激情午夜",
		 "色魔五月天","激情mm","激情妹妹","制服尤物","极品学妹","xing奴隶","性奴隶","极度高潮","乳房照","激情片","黄色大片","美女脱衣","欧美性爱","日本av","窥淫","湿润的内裤","妓淫",
		 "性爱体位","性交姿势","房事体位","性爱姿势","女性跪卧后入","女卧男跪前入","取女上男下位","性前调情","调情按摩","划船式性交","兩膝屈起式","頂頂撞撞式","拱橋離地式","做爱姿势","横钳树熊式",
		 "倒插莲式","胎欢姿势","小汤匙偎合","背入式性交","箍身箍勢式.共享激情","a片目录","风流情妇","本末倒置式","點心車式","后浪推前浪式","摸屁股式","女上男下式","箍身箍勢式","自由操式",
		 "淫招式","股股滑滑式","腎部橫交式","拱桥离地式","湿身的诱惑","欧美av","色情電影","走光图","性吧sex8","激情五月天","御色阁","淫间道","新情色海岸","迷失少女天堂","幼香帝国","御女阁",
		 "淫春堂","美脚美乳","淫荡妻","色性影视","夜场演员","亂倫熟女","丝袜美女","丝袜浪女","丝足地带","玉足丝袜","色性网","美女激情","艳舞靓照","空姐护士","性虎网","淫人堂","狼友必上",
		 "成人必上网站","暮春堂狼友","色色导航","本色影院","快播","永久防屏蔽地址","后宫社区","转发给","一品色导航","本站永久地址","永久地址","就去吻","就去色吧","阴穴","处女穴","穴洞","乳晕",
		 "陰莖","陰道","龜頭","陰戶","雞雞","處女膜","屄裏","放入春药","阴dao","坚挺丰满的双峰","含鸡鸡","j巴","j吧","淫靡","玉杵捣花径","破瓜之","丰乳肥臀","小屄","阴护","阴纯","阳物","龟缝",
		 "骚浪","性欲泛滥","瑷液","够鳋","乳fan","yin部","舔奶","雞巴","裸體","雞八","日批","丰满坚挺","阴di","爽片","茎精","y户","yin道","凤啄水","凤反展翅","凤抬头","逗肛","淫棍","阴丘",
		 "y茎","b痒","b好痒","av女","yin毛","诱人双峰","少妇穴","陰核","陰毛","陰茎","陰户","靓穴","狂穴","小姨子穴","姐的穴","毛穴","幼穴","插进穴","姐穴","女人穴","mm穴","淫暴","浪妻",
		 "搔穴","菊穴","幼b","淫洞","紧窄","私密处","私处","大腿内侧","隐私部位","两乳之间","卵蛋","私密地带","舔花苞","穴前庭","穴口","六九体位","逼穴","粉红小逼","逼好痒","b穴","肉根","肉击",
		 "满床春色","臀沟","骚婊","骚比","三鱼比目","十八山羊对树","十临坛竹","八背飞凫","一蚕缠","清纯女教师","大奶mm","騷逼","抠b","抠逼","摸奶","莹穴","大jj","會陰","哥的jj","淫唇","秘處","陰部",
		 "肉芽","骚痒","交奸","肤白胸大","亲jj","粗大的玩意","穴里","秘部","秘肉","蜜唇","蜜壶","她的mm","屁穴","肉门","肉丘","肉圈","肉臀","乳球","乳首","臀洞","臀孔","臀丘","摸胸","yinshui",
		 "yindi","y蒂","淫欲","淫兽","婬水","性学教授","姐开苞","妹开苞","屄友","美屄","淫肉","美尻","膣肉","肥奶","膣穴","性高潮","豔尻","酥胸白亮","騷婦","膣口","犬交","膣壁","蜜缝","处女开苞",
		 "淫艳","淫友","穴穴","肉蚌","淫棒","陽具","濡穴","宓毛","以茎治洞在","淫盪","舔弄","抽送","套弄","喷潮","舔下面","舔xue","舔穴","淫声","添你下面","舔吮","后面插","zuo阴chun","添阴",
		 "粉红小b","舔阴","浪淫","肏穴","操小逼","添逼","舔舐","插进来","射出来","顶得好深","插的好舒服","被人干","舔便","舔遍","吸舔","等你插","口鉸","插爆","插弄","抽捣","肏死","肏她","肏入",
		 "肏我","肏干","肏破","肏这","肏娘","肏妳","狠肏","猛操","弄穴","流了好多的水","流了好多水","下面的水","插进你的下面","插进你下面","插你的下面","亲吻蛋蛋","亲蛋蛋","舔批","插屄",
		 "狗交式","抽送着","輪姦","全根尽入","全根插入","舔陰","张开双腿","强j","卖逼","卖b","狅操","强姦","双腿间的禁地","双腿叉开","舔肛","肛插","做要带套","做ai","同淫","淫奸","插女","射精",
		 "两性狂情","裸照","浓精","插进来射出来","吸啜","流出淫水","挤入窄洞","抽动","插入","插肛","诱奸","cha她","肏你","通奸","含住","轻啃","狠抽着","舐吸","揉搓","抚着","舔动着","套动","吸吮",
		 "舔着","用口吸着","吮吸","抚弄着","搓捻着","插進去","吸唑着","射进","坐着插","插深一点","蠕动着","套撸着","扭动着","吸允","抠着","来回抚摸","抽拉","指头插进","揉动着","揉捏","蠕动",
		 "抽提","揉起","含着","爱抚","含进","插到","摩娑","搓揉","射了","猛吸","抚摸","揉弄","搓弄","逗弄","掏弄","摩擦着","挠着","轻插","抚摩","鸡巴","乳峰","酥胸","双唇","樱唇","小xue","y液",
		 "阴jing","花穴","蜜道","g头","nai子","yin唇","粉红的乳头","椒乳","小逼里","阴jin","麻穴","淫具","贱b","抽插","舔吻","揉摸","尝舔","插送","拧绕","滑动着","探索着","吸着","扒拉着","揉擦",
		 "搓着","捏动","揉着","插ru","舔磨","搓摸着","chou插","cha了进去","瞎添","爱液溢出","相慰","关键词","虐恋花园","色BB吧","人人有色论坛","52异性社区","我要官人","百凤宫","80色区",
		 "点色论坛","收单管猎狗","提供各式小","口径步槍","单管猎枪30发提供","五连猎枪30发提供","双管猎枪30发提供","提供猎槍小口径步槍","国64式762mm枪提供","港38式左轮提供",
		 "中国54式762mm枪出售","92式9mm枪提供","盐酸羟亚胺技术转让","卖迷魂药三唑仑","性福源","龟头对准阴道","色情倚天屠龙记","老师的小穴","纵情兵团","妈妈色","鸿图记","对准桃源洞口",
		 "小骚BB","小骚BB自拍","蜜桃成熟时","我做骚妻","性感沙滩2","欲海天龙传","淫穴里骚水","猎枪","手枪","仿真枪","气枪","弹药","子弹","氯胺酮","k粉","神仙水","迷魂药","要枪","抢支","猎抢",
		 "世博吉祥物","海宝","吹箭","梯恩梯","硝基苯","六硝基二苯胺","甲基三硝胺","四醇四硝酸酯","硝化甘油","硝化纤维素","茴香醚","硝酸甘油","硝化丙三醇","硝化棉","雷汞","二氯乙烯","异氰酸甲酯",
		 "乙酯","氢氧化钡","四氯化碳","三氯甲烷","硼酸","过氧化氢","三氯化铝","冰乙酸","甲醛","二硫化碳","乙酸乙酯","无水乙醇","工业酒精","二甲苯","高锰酸钾","硝酸铵","硝酸钾","硝酸钠","重铬酸钾",
		 "硝酸汞","硝酸银","黑客技术","黑客教程","黑客基地","黑客网站","黑客入门","黑客工具","黑客软件园","黑客必学","黑客资料","黑客武器","六合彩","开奖结果","三肖","特码","博客赚钱","迷幻药专卖",
		 "专卖迷药","出售迷幻药","迷药专卖","销售迷药","销售迷幻药","卖迷藥","购买迷藥","迷藥销售","出售冰毒","销售k粉","赌博专用迷薬","出售喷雾型","出售手枪","办理各种证件","办各种证件","出售枪",
		 "枪支销售","枪支出售","手枪出售","办理学历","办学历","办真实学历","办理真实学历","批发假币","假币批发","出售硬币","硬币出售","办所有证件","提供肾源","有偿捐肾","百家乐开户","代开发票",
		 "出售答案","办理文凭","cet4答案","办理证件","网上办证","专业洗票","证件办理","足球投注","足球系统","皇冠足球","皇冠投注","在线投注","线上投注","博彩公司","发票代理","办理各类证件",
		 "办证热线","辩證","辦證","代考","替考","助考","考试帮助","代办文凭","磁卡复制","复制银行卡","真钱加印钞技术","报仇收帐","销售枪支","代開发票","出售银行卡","真钱斗地主","吉祥宝贝破解",
		 "掰证","手表短信接收器","代销违章","赌博技巧","赢钱技巧","出千技巧","证书办理","帝王游戏","买肾","卖肾","卫星电视安装","卫星天线安装","批发硬币","验钞机包通过","体检代理","体检枪手",
		 "mihuen药","酐乐欣","海樂神","海乐神","三坐仑","迷幻液","酐樂欣","三唑侖","笔式呼叫系统","迷情粉","冰.麻","卖shen","猎弩","催情香水","迷幻香水","迷幻水","魔女乖乖粉","迷魂藥","迷昏藥",
		 "麻醉香烟","蒙.汗藥","蒙汗藥","ghb水","礼品机","三挫仑","狼弩","麻醉槍","缅古","地产古弩中之王","迷彩弩","专用弩","黑钞","64手抢","保单机","cui情用品","催情用品","五星洪辉","迷惑药",
		 "迷魂液","成品冰","植物冰","唆哈粉","fm2粉","拍肩粉","醱票","小飞狼","森林之狼","森林之狐","森林之鹰","森林之豹","需要假币","3唑仑","透视相机","自家游","连线宝马","无线微型耳机",
		 "无线远程监控","无线微型摄像机","钢笔摄像机","针孔摄象头","赌博隐形","兴奋镇痛","侦探器材","隔墙听","跟踪仪器","追踪仪器","监听跟踪","迷情液","迷奸粉","强奸粉","转膛枪","气动枪",
		 "滑膛枪","膛线枪","三利达","大黑鹰","黑蟒","狙击弩","拍肩型","速眠水","婴儿汤","吃女婴","婴兒汤","迷幻粉","猎槍","气槍","氯氨铜","出售人民币","解瑪器","半自动枪","防护具","水果ji",
		 "苹果ji","水惈機","錠位噐","逩馳寳馬","賽唓諷紜","迷欲水","电子解密","麦角酸二乙基酰胺","盐酸二氢埃托菲","苯环已哌啶","彩金狮王","疯狂斗地主","狮子彩金","老.虎.机","识牌器","作.弊.器",
		 "大白钻","大黄钻","絔家樂","64式手枪","64手枪","67式无声手枪","77式手枪","84微型手枪","假幣","催情藥","麻醉藥","失意藥","迷奸藥","拍肩神藥","丁丙諾啡","催情液","狙击瞄准镜",
		 "红点瞄准镜","佳靜安定片","監聽王","mi药","shui果机","5星洪辉","5星宏辉","8台连","5星红辉","冲峰枪","斯登姆","滑油枪","mp3840","mkb42","工字弹簧","锡锋弹簧","峨嵋弹簧",
		 "cfx弹簧","gamo弹簧","快鹿弹簧","工字皮碗","工字密封圈","峨嵋皮碗","峨嵋密封圈","狮牌皮碗","狮牌密封圈","gamo皮碗","gamo密封圈","锡锋皮碗","锡锋密封圈","武夷山皮碗",
		 "武夷山密封圈","光学瞄准器","麻醉注射枪","样品枪","催泪枪","电击器","战斗弹","检验弹","教练弹","非电导爆系统","爆破剂","三棱刮刀","cfx皮碗","cfx狗","三哆论","曲吗多",
		 "醋托啡","美沙朵","烯丙罗定","美罗定","阿法罗定","阿尼利定","苄替定","苄吗啡","倍他罗定","苯晴米特","氯尼他秦","古可叶","可多克辛","右马拉胺","地恩丙胺","二乙噻丁","地芬诺辛",
		 "地美庚醇","二甲噻丁","吗苯丁酯","地芬诺酯","苯乙派啶","地匹哌酮","羟蒂巴酚","乙甲噻丁","依托尼秦","依托利定","呋替定","氢可酮","氢吗啡醇","哌替定","凯托米酮","左美沙芬",
		 "左芬啡烷","左啡诺","美他左辛","甲地索啡","甲二氢吗啡","美托酮","吗酰胺中间体","吗哌利定","哌啶丙酸盐","麦罗啡","尼可吗啡","甲左啡烷","诺匹哌酮","苯吗庚酮","非那柄胺","非那佐辛",
		 "非诺非烷","苯哌利定","匹米诺定","普罗庚嗪","丙哌利定","甲啡烷","消旋啡烷","蒂巴因","替利定","三甲利定","醋氢可待因","丙兰","苯西克列丁","傣肌松","地氟烷","库氯铵","恩氟烷",
		 "粉肌松","氟喹酮","肌安松","迷情喷雾","迷魂蚊香","晕倒型","军用54口","军用64口","77式口","勃朗宁微型口","雷明登来复枪","双管平式","双管立式","麻醉器械","麻醉钢针器械",
		 "空心钢针","用器械","五六2式","弹药价格","小牌变大","大牌变小","稳健赢利","操盘服务","真烟接嘴","氺猓机","大霸机","手腕机","游戏输赢笑人间","夜想日思唯赢钱","839557715",
		 "权威彩票阵地","彩票软件","caipiao868","访问被屏蔽的网站","访问被屏蔽掉的网站","龙虎吧","真钱娱乐","枪支买卖","窃听钢笔","窃听手表","录音手表","录像钢笔","摄像钢笔","bing毒",
		 "强暴药","激情丸","电击棍","茶色炸药","三硝基芴酮","三硝基氯苯","三硝基萘","高氯酸","硝化淀粉","雷酸汞","苦基","三硝基安息香酸","苦味酸甲酯","苦味酸铵","苦酰氯","苦基氯",
		 "二苦基胺","黑索金","喷梯尔","甘油三硝酸酯","二乙基醚","烯丙胺","甲胺溶液","正丁腈","硅酸甲酯","乙基氰","丙腈","异丁腈","旋风炸药","二氯化钡","乙酸铅","硝酸铜","黑客视频教程",
		 "黑客快速入门","黑客英语","黑客手册","黑基论坛","黑客社区","黑客论坛","黑客兵器","黑客攻击步骤","特码主论坛","六合玄机","杀肖","挂牌出肖","六肖","六合网","朱狨基","朱熔基",
		 "邾","猪毛1","舳","瘃","躅","翥","專政","颛","丬","隹","窀","卓伯源","倬","斫","诼","髭","鲻","秭","訾","自民党","自已的故事","自由民主论坛","总理","神仙水","火药","枪弹",
		 "枪支","炸弹","政府","system","admin","administrator","管理","管里","管理员","服务管理","官方","系统公告","审查","巡查","监督","GameMaster","gm","游戏管理员","Client",
		 "Server","kefu","客户服务","客服","服务天使","test","运营者","运营组","运营商","运营长","运营官","运营人","教官","工作人员","优玩","uwan","动网","合作商","fuck","shit","就是牛",
"法轮功","李洪志","信徒","主佛","活摘","陆雪琴","法輪功","西藏","圣战","疆独","新疆","东伊运","东突","人间福报","自由新闻报","都市日报","头条日报","香港商报","香港电台","Discuss","华富财经","新报网站","The Standard","Hong Kong Herald. 台湾报纸","中央社新闻网","中央日报网络报","中时电子报","联合新闻网","自由时报","新台湾新闻","中华日报","民众电子报","交清电子报","东亚日报","马祖日报","国语日报","八方国际资讯","自立晚报","台湾旺报","天下杂志","美洲台湾日报","经济日报","苹果日报","壹周刊(台湾)","世界电影(台湾)","鑫报e乐网","工商时报","金融邮报(台湾股网)","30杂志","农业电子报","双语学生邮报","中国时报新竹分社","1999亚太新新闻","台湾记者协会","生命力公益新闻网","英文中国邮报","台英社","Taipei Times","天眼日报社","青年日报","世界新闻媒体网","非常新闻通讯社","更生日报","彭博新闻社","彭博商业周刊","纽约时报","C-SPAN","明报","明报月刊","星岛日报","太阳报","亚洲周刊","忽然1周","壹周刊","爽报","穿越浏览器","香港报纸","联合报","旺报","中华电视公司","客家电视台","原住民族电视台","壹电视","澳洲广播电台中文网","荷兰国际广播电台中文网","Engadget中文网","博客大赛网站","自由亚洲电台","自由欧洲电台","加拿大国际广播电台","法国国际广播电台","梵蒂冈广播电台","梵蒂冈亚洲新闻通讯社","今日悉尼","澳大利亚时报澳奇网","中欧新闻网","北美中文网","南洋视界","华人今日网","多维新闻","牛博网","博讯","香港独立媒体","媒体公民行动网","新头壳","主场新闻","香港人网","MyRadio","民间电台","阳光时务周刊","开放杂志","苦劳网","留园网","新三才","希望之声国际广播电台","新唐人电视台","大纪元时报","信报财经新闻","公教报","星岛日报消息","达赖喇嘛的智慧箴言","辛子陵","高文谦","心灵法门“白话佛法”系列节目","世界报纸","周恩来","红太阳的陨落","CNN/NHK","彭博","美国有线电视频道","国际广播的电视节目","穆斯林","达赖","美国之音","世维会","伊斯兰","真主","安拉","白话佛法","islam","黄祸","天藏","法西斯 ","右翼","CND刊物和论坛","东方日报","内幕","中国茉莉花革命","美国之音","法广中文网","明镜网","大事件","北京之春","多维","中央社","倍可亲","BBC","大纪元网","阿波罗新闻网","看中国专栏","万维读者网","RFA","零八宪章","华尔街日报","法广新闻网","中国密报","民主中国","多维新闻网","万维博客","太陽報","东网","世界日报","法广网","希望之声","世界新闻网","阿波罗网","内幕第28期","多维网","新纪元周刊387期","中国时报","新唐人电视台网","南华早报","联合早报","星岛环球网","博讯网","金融时报","南早中文网","新史记","金山桥","牛泪","德国之声中文网","信报月刊","中国人权双周刊","明星新聞網","西藏之声","开放网","RFI","博谈网","观察者网","路透社","香港经济日报","新纪元","纵览中国","爱思想","明镜新闻","动向杂志","争鸣杂志","DJY","茉莉花革命","英国金融时报","明镜周刊","联合新闻","BBC","AV","草榴","性交","做爱","裸体","裸聊","性交易","援交","性感","诱惑","重口味","情色","做爱姿势","性虐","肛交","口交","胸推","自慰","淫","卖身","偷欢","赤裸","勾引","强奸","迷奸","淫荡","高潮","偷精","卖淫","性骚扰","意淫","破处","吹萧","打炮","失身","失禁","外遇","变态","出轨","呻吟","闷骚","风骚","调戏","调教","不良","寻欢","推女郎","诱人","害羞","色撸","TD","撸","性乐","恋孕","爱爱","里番","天天干","性息","裸欲","调教性奴","成人软件","sex聊天室","小姐裸聊","情色五月","美女祼聊","同居万岁","风流岁月","一本道","腹黑","滥情","暴君","同居","人屠","撩人","专宠","禁忌","木耳","丰乳","翘臀","乳波","臀浪","浪臀","咪咪","小攻","诱惑","小姐","妓女","很黄","他妈","小右","小受"
]).
%% ====================================================================
%% API functions
%% ====================================================================
-export([
         block_sensitive_word/1,
         block_sensitive_word/2,
         block_sensitive_word/3
        ]).                  

%% 替换敏感字，*代替
block_sensitive_word(Content) ->
	block_sensitive_word(Content, "*").

block_sensitive_word(Content, Char) ->
    block_sensitive_word(Content, Char, ?SENSITIVE_WORDS).

block_sensitive_word(Content, _Char, []) ->
    Content;
block_sensitive_word(Content, Char, [KeyWord | L]) ->
    NewContent = util:replace_all(Content, KeyWord, Char, [{return,list}]),
    block_sensitive_word(NewContent, Char, L).
    



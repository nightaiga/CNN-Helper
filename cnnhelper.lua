
script_author("nightaiga")
script_name("CNN Helper")
script_version("v1.0")

-- Зависимости
require 'moonloader'
local mt = getmetatable("String") function mt.__index:insert(implant, pos)     if pos == nil then         return self .. implant     end     return self:sub(1, pos) .. implant .. self:sub(pos + 1) end  function mt.__index:extract(pattern)     self = self:gsub(pattern, "")     return self end  function mt.__index:array()     local array = {}     for s in self:sub(".") do         array[#array + 1] = s     end     return array end  function mt.__index:isEmpty()     return self:find("%S") == nil end  function mt.__index:isDigit()     return self:find("%D") == nil end  function mt.__index:isAlpha()     return self:find("[%d%p]") == nil end  function mt.__index:split(sep, plain)     assert(not sep:isEmpty(), "Empty separator")         result, pos = {}, 1     repeat         local s, f = self:find(sep or " ", pos, plain)         result[#result + 1] = self:sub(pos, s and s - 1)         pos = f and f + 1     until pos == nil     return result end  local orig_lower = string.lower function mt.__index:lower()     for i = 192, 223 do         self = self:gsub(string.char(i), string.char(i + 32))     end     self = self:gsub(string.char(168), string.char(184))     return orig_lower(self) end  local orig_upper = string.upper function mt.__index:upper()     for i = 224, 255 do         self = self:gsub(string.char(i), string.char(i - 32))     end     self = self:gsub(string.char(184), string.char(168))     return orig_upper(self) end  function mt.__index:isSpace()     return self:find("^[%s%c]+$") ~= nil end  function mt.__index:isUpper()     return self:upper() == self end  function mt.__index:isLower()     return self:lower() == self end  function mt.__index:isSimilar(str)     return self == str end  function mt.__index:isTitle()     local p = self:find("[A-zА-яЁё]")     local let = self:sub(p, p)     return let:isSimilar(let:upper()) end  function mt.__index:startsWith(str)     return self:sub(1, #str):isSimilar(str) end  function mt.__index:endsWith(str)     return self:sub(#self - #str + 1, #self):isSimilar(str) end  function mt.__index:capitalize()     local cap = self:sub(1, 1):upper()     self = self:gsub("^.", cap)     return self end  function mt.__index:tabsToSpace(count)     local spaces = (" "):rep(count or 4)     self = self:gsub("\t", spaces)     return self end  function mt.__index:spaceToTabs(count)     local spaces = (" "):rep(count or 4)     self = self:gsub(spaces, "t")     return self end  function mt.__index:center(width, char)     local len = width - #self     local s = string.rep(char or " ", len)      return s:insert(self, math.ceil(len / 2)) end  function mt.__index:count(search, p1, p2)     assert(not search:isEmpty(), "Empty search")     local area = self:sub(p1 or 1, p2 or #self)     local count, pos = 0, p1 or 1     repeat         local s, f = area:find(search, pos, true)         count = s and count + 1 or count         pos = f and f + 1     until pos == nil     return count end  function mt.__index:trimEnd()     self = self:gsub("%s*$", "")     return self end  function mt.__index:trimStart()     self = self:gsub("^%s*", "")     return self end  function mt.__index:trim()     self = self:match("^%s*(.-)%s*$")     return self end  function mt.__index:swapCase()     local result = {}     for s in self:gmatch(".") do         if s:isAlpha() then             s = s:isLower() and s:upper() or s:lower()         end         result[#result + 1] = s     end     return table.concat(result) end  function mt.__index:splitEqually(width)     assert(width > 0, "Width less than zero")     assert(width <= self:len(), "Width is greater than the string length")     local result, i = {}, 1     repeat         if #result == 0 or #result[#result] >= width then             result[#result + 1] = ""         end         result[#result] = result[#result] .. self:sub(i, i)         i = i + 1     until i > #self     return result end  function mt.__index:rFind(pattern, pos, plain)     local i = pos or #self     repeat         local result = { self:find(pattern, i, plain) }         if next(result) ~= nil then             return table.unpack(result)         end         i = i - 1     until i <= 0     return nil end  function mt.__index:wrap(width)     assert(width > 0, "Width less than zero")     assert(width < self:len(), "Width is greater than the string length")     local pos = 1     self = self:gsub("(%s+)()(%S+)()", function(sp, st, word, fi)         if fi - pos > (width or 72) then             pos = st             return "\n" .. word         end     end)        return self end  function mt.__index:levDist(str)     if #self == 0 then         return #str     elseif #str == 0 then         return #self     elseif self == str then         return 0     end          local cost = 0     local matrix = {}     for i = 0, #self do matrix[i] = {}; matrix[i][0] = i end     for i = 0, #str do matrix[0][i] = i end     for i = 1, #self, 1 do         for j = 1, #str, 1 do             cost = self:byte(i) == str:byte(j) and 0 or 1             matrix[i][j] = math.min(                 matrix[i - 1][j] + 1,                 matrix[i][j - 1] + 1,                 matrix[i - 1][j - 1] + cost             )         end     end     return matrix[#self][#str] end  function mt.__index:getSimilarity(str)     local dist = self:levDist(str)     return 1 - dist / math.max(#self, #str) end
local imgui = require 'mimgui'
local sampev = require 'samp.events'
local effil = require 'effil'
local copas = require 'copas'
local http = require 'copas.http'
local requests = require 'requests'
local ffi = require 'ffi'
encoding = require 'encoding'
encoding.default = 'UTF-8'
cp = encoding.CP1251
cp1252 = encoding.CP1252
u8 = encoding.UTF8

-- Переменные
local window = imgui.new.bool()
local adwindow = imgui.new.bool()
local shuffleinput = imgui.new.char[128]()
local moneyinput = imgui.new.char[128]()
local adinput = imgui.new.char[256]()
local shuffled = ''
local money = nil
local sizeX, sizeY = getScreenResolution()
local customcars = {}
local tuning = {}
local sponsors = {}
local competitors = {}
local cars = {"Landstalker", "Bravura", "Buffalo", "Linerunner", "Perrenial", "Sentinel", "Dumper", "Firetruck", "Trashmaster",
"Stretch", "Manana", "Infernus", "Voodoo", "Pony", "Mule", "Cheetah", "Ambulance", "Leviathan", "Moonbeam",
"Esperanto", "Taxi", "Washington", "Bobcat", "Whoopee", "BF Injection", "Hunter", "Premier", "Enforcer",
"Securicar", "Banshee", "Predator", "Bus", "Rhino", "Barracks", "Hotknife", "Trailer", "Previon", "Coach",
"Cabbie", "Stallion", "Rumpo", "RC Bandit", "Romero", "Packer", "Monster A", "Admiral", "Squalo", "Seasparrow",
"Pizzaboy", "Tram", "Trailer", "Turismo", "Speeder", "Reefer", "Tropic", "Flatbed", "Yankee", "Caddy", "Solair",
"Topfun Van", "Skimmer", "PCJ-600", "Faggio", "Freeway", "RC Baron", "RC Raider", "Glendale", "Oceanic",
"Sanchez", "Sparrow", "Patriot", "Quad", "Coastguard", "Dinghy", "Hermes", "Sabre", "Rustler", "ZR-350", "Walton",
"Regina", "Comet", "BMX", "Burrito", "Camper", "Marquis", "Baggage", "Dozer", "Maverick", "News Chopper", "Rancher",
"FBI Rancher", "Virgo", "Greenwood", "Jetmax", "Hotring", "Sandking", "Blista Compact", "Police Maverick",
"Boxville", "Benson", "Mesa", "RC Goblin", "Hotring Racer A", "Hotring Racer B", "Bloodring Banger", "Rancher",
"Super GT", "Elegant", "Journey", "Bike", "Mountain Bike", "Beagle", "Cropduster", "Stunt", "Tanker", "Roadtrain",
"Nebula", "Majestic", "Buccaneer", "Shamal", "Hydra", "FCR-900", "NRG-500", "HPV1000", "Cement Truck", "Tow Truck",
"Fortune", "Cadrona", "APC", "Willard", "Forklift", "Tractor", "Combine", "Feltzer", "Remington", "Slamvan",
"Blade", "Freight", "Streak", "Vortex", "Vincent", "Bullet", "Clover", "Sadler", "Firetruck", "Hustler", "Intruder",
"Primo", "Cargobob", "Tampa", "Sunrise", "Merit", "Utility", "Nevada", "Yosemite", "Windsor", "Monster B", "Monster C",
"Uranus", "Jester", "Sultan", "Stratum", "Elegy", "Raindance", "RC Tiger", "Flash", "Tahoma", "Savanna", "Bandito",
"Freight Flat", "Streak Carriage", "Kart", "Mower", "Dune", "Sweeper", "Broadway", "Tornado", "AT 400", "DFT 30",
"Huntley", "Stafford", "BF 400", "News Van", "Tug", "Trailer", "Emperor", "Wayfarer", "Euros", "Hotdog", "Club",
"Freight Box", "Trailer", "Andromada", "Dodo", "RC Cam", "Launch", "Police Car", "Police Car", "Police Car",
"Police Ranger", "Picador", "S.W.A.T", "Alpha", "Phoenix", "Glendale", "Sadler", "Luggage", "Luggage", "Stairs",
"Boxville", "Tiller", "Utility Trailer"}
local countries = {
    {"Австралия", "Канберра", "Австралийский доллар"},
    {"Австрия", "Вена", "Евро"},
    {"Азербайджан", "Баку", "Манат"},
    {"Албания", "Тирана", "Лек"},
    {"Алжир", "Алжир", "Алжирский динар"},
    {"Ангола", "Луанда", "Кванза"},
    {"Андорра", "Андорра-ла-Велья", "Евро"},
    {"Антигуа и Барбуда", "Сент-Джонс", "Восточно-карибский доллар"},
    {"Аргентина", "Буэнос-Айрес", "Аргентинское песо"},
    {"Армения", "Ереван", "Армянский драм"},
    {"Афганистан", "Кабул", "Афгани"},
    {"Багамы", "Нассау", "Багамский доллар"},
    {"Бангладеш", "Дакка", "Така"},
    {"Барбадос", "Бриджтаун", "Барбадосский доллар"},
    {"Бахрейн", "Манама", "Бахрейнский динар"},
    {"Беларусь", "Минск", "Белорусский рубль"},
    {"Бельгия", "Брюссель", "Евро"},
    {"Белиз", "Бельмопан", "Белизский доллар"},
    {"Бенин", "Порто-Ново", "Франк КФА"},
    {"Болгария", "София", "Болгарский лев"},
    {"Боливия", "Сукре", "Боливиано"},
    {"Босния и Герцеговина", "Сараево", "Конвертируемая марка"},
    {"Ботсвана", "Габороне", "Пула"},
    {"Бразилия", "Бразилиа", "Бразильский реал"},
    {"Бруней", "Бандар-Сери-Бегаван", "Брунейский доллар"},
    {"Буркина-Фасо", "Уагадугу", "Франк КФА"},
    {"Бурунди", "Гитега", "Бурундийский франк"},
    {"Бутан", "Тхимпху", "Нгултрум"},
    {"Вануату", "Порт-Вила", "Вату"},
    {"Ватикан", "Ватикан", "Евро"},
    {"Великобритания", "Лондон", "Фунт стерлингов"},
    {"Венгрия", "Будапешт", "Форинт"},
    {"Венесуэла", "Каракас", "Венесуэльский боливар"},
    {"Восточный Тимор", "Дили", "Доллар США"},
    {"Вьетнам", "Ханой", "Донг"},
    {"Габон", "Либревиль", "Франк КФА"},
    {"Гаити", "Порт-о-Пренс", "Гурд"},
    {"Гайана", "Джорджтаун", "Гайанский доллар"},
    {"Гамбия", "Банжул", "Даласи"},
    {"Гана", "Аккра", "Ганский седи"},
    {"Гватемала", "Гватемала", "Кетсаль"},
    {"Гвинея", "Конакри", "Гвинейский франк"},
    {"Гвинея-Бисау", "Бисау", "Франк КФА"},
    {"Германия", "Берлин", "Евро"},
    {"Гондурас", "Тегусигальпа", "Лемпира"},
    {"Гренада", "Сент-Джорджес", "Восточно-карибский доллар"},
    {"Греция", "Афины", "Евро"},
    {"Грузия", "Тбилиси", "Лари"},
    {"Дания", "Копенгаген", "Датская крона"},
    {"Джибути", "Джибути", "Джибутийский франк"},
    {"Доминика", "Розо", "Восточно-карибский доллар"},
    {"Доминиканская Республика", "Санто-Доминго", "Доминиканское песо"},
    {"Египет", "Каир", "Египетский фунт"},
    {"Замбия", "Лусака", "Замбийская квача"},
    {"Зимбабве", "Хараре", "Доллар Зимбабве"},
    {"Израиль", "Иерусалим", "Новый израильский шекель"},
    {"Индия", "Нью-Дели", "Индийская рупия"},
    {"Индонезия", "Джакарта", "Индонезийская рупия"},
    {"Иордания", "Амман", "Иорданский динар"},
    {"Ирак", "Багдад", "Иракский динар"},
    {"Иран", "Тегеран", "Иранский риал"},
    {"Ирландия", "Дублин", "Евро"},
    {"Исландия", "Рейкьявик", "Исландская крона"},
    {"Испания", "Мадрид", "Евро"},
    {"Италия", "Рим", "Евро"},
    {"Йемен", "Сана", "Йеменский риал"},
    {"Кабо-Верде", "Прая", "Эскудо Кабо-Верде"},
    {"Казахстан", "Астана", "Тенге"},
    {"Камбоджа", "Пномпень", "Риель"},
    {"Камерун", "Яунде", "Франк КФА"},
    {"Канада", "Оттава", "Канадский доллар"},
    {"Катар", "Доха", "Катарский риал"},
    {"Кения", "Найроби", "Кенийский шиллинг"},
    {"Кипр", "Никосия", "Евро"},
    {"Киргизия", "Бишкек", "Сом"},
    {"Кирибати", "Южная Тарава", "Австралийский доллар"},
    {"КНР", "Пекин", "Китайский юань"},
    {"Колумбия", "Богота", "Колумбийское песо"},
    {"Коморы", "Морони", "Коморский франк"},
    {"Конго", "Браззавиль", "Франк КФА"},
    {"КНДР", "Пхеньян", "Северокорейская вона"},
    {"Коста-Рика", "Сан-Хосе", "Коста-риканский колон"},
    {"Кот-д'Ивуар", "Ямусукро", "Франк КФА"},
    {"Куба", "Гавана", "Кубинское песо"},
    {"Кувейт", "Эль-Кувейт", "Кувейтский динар"},
    {"Лаос", "Вьентьян", "Лаосский кип"},
    {"Латвия", "Рига", "Евро"},
    {"Лесото", "Масеру", "Лоти"},
    {"Либерия", "Монровия", "Либерийский доллар"},
    {"Ливан", "Бейрут", "Ливанский фунт"},
    {"Ливия", "Триполи", "Ливийский динар"},
    {"Литва", "Вильнюс", "Евро"},
    {"Лихтенштейн", "Вадуц", "Швейцарский франк"},
    {"Люксембург", "Люксембург", "Евро"},
    {"Маврикий", "Порт-Луи", "Маврикийская рупия"},
    {"Мавритания", "Нуакшот", "Мавританская угия"},
    {"Мадагаскар", "Антананариву", "Малагасийский ариари"},
    {"Малави", "Лилонгве", "Малавийская квача"},
    {"Малайзия", "Куала-Лумпур", "Малайзийский ринггит"},
    {"Мали", "Бамако", "Франк КФА"},
    {"Мальдивы", "Мале", "Мальдивская руфия"},
    {"Мальта", "Валлетта", "Евро"},
    {"Марокко", "Рабат", "Марокканский дирхам"},
    {"Маршалловы Острова", "Маджуро", "Доллар США"},
    {"Мексика", "Мехико", "Мексиканское песо"},
    {"Микронезия", "Паликир", "Доллар США"},
    {"Мозамбик", "Мапуту", "Мозамбикский метикал"},
    {"Молдова", "Кишинёв", "Молдавский лей"},
    {"Монако", "Монако", "Евро"},
    {"Монголия", "Улан-Батор", "Монголия тугрик"},
    {"Мьянма", "Нейпьидо", "Мьянманский кьят"},
    {"Намибия", "Виндхук", "Намибийский доллар"},
    {"Науру", "Ярен", "Австралийский доллар"},
    {"Непал", "Катманду", "Непальская рупия"},
    {"Нигер", "Ниамей", "Франк КФА"},
    {"Нигерия", "Абуджа", "Найра"},
    {"Нидерланды", "Амстердам", "Евро"},
    {"Никарагуа", "Манагуа", "Никарагуанская кордоба"},
    {"Новая Зеландия", "Веллингтон", "Новозеландский доллар"},
    {"Норвегия", "Осло", "Норвежская крона"},
    {"ОАЭ", "Абу-Даби", "Дирхам ОАЭ"},
    {"Оман", "Маскат", "Оманский риал"},
    {"Пакистан", "Исламабад", "Пакистанская рупия"},
    {"Палау", "Нгерулмуд", "Доллар США"},
    {"Панама", "Панама", "Бальбоа, доллар США"},
    {"Папуа — Новая Гвинея", "Порт-Морсби", "Кина"},
    {"Парагвай", "Асунсьон", "Гуарани"},
    {"Перу", "Лима", "Перуанский соль"},
    {"Польша", "Варшава", "Злотый"},
    {"Португалия", "Лиссабон", "Евро"},
    {"Республика Корея", "Сеул", "Южнокорейская вона"},
    {"Россия", "Москва", "Российский рубль"},
    {"Руанда", "Кигали", "Руандийский франк"},
    {"Румыния", "Бухарест", "Румынский лей"},
    {"Сальвадор", "Сан-Сальвадор", "Доллар США"},
    {"Самоа", "Апиа", "Тала"},
    {"Сан-Марино", "Сан-Марино", "Евро"},
    {"Сан-Томе и Принсипи", "Сан-Томе", "Добра"},
    {"Саудовская Аравия", "Эр-Рияд", "Саудовский риял"},
    {"Северная Македония", "Скопье", "Македонский денар"},
    {"Сейшельские Острова", "Виктория", "Сейшельская рупия"},
    {"Сенегал", "Дакар", "Франк КФА"},
    {"Сент-Винсент и Гренадины", "Кингстаун", "Восточно-карибский доллар"},
    {"Сент-Китс и Невис", "Бастер", "Восточно-карибский доллар"},
    {"Сент-Люсия", "Кастри", "Восточно-карибский доллар"},
    {"Сербия", "Белград", "Сербский динар"},
    {"Сингапур", "Сингапур", "Сингапурский доллар"},
    {"Сирия", "Дамаск", "Сирийский фунт"},
    {"Словакия", "Братислава", "Евро"},
    {"Словения", "Любляна", "Евро"},
    {"Соломоновы Острова", "Хониара", "Соломонов островов доллар"},
    {"Сомали", "Могадишо", "Сомалийский шиллинг"},
    {"Судан", "Хартум", "Суданский фунт"},
    {"Суринам", "Парамарибо", "Суринамский доллар"},
    {"Сьерра-Леоне", "Фритаун", "Сьерра-леонский леоне"},
    {"Таджикистан", "Душанбе", "Сомони"},
    {"Таиланд", "Бангкок", "Бат"},
    {"Танзания", "Додома", "Танзанийский шиллинг"},
    {"Того", "Ломе", "Франк КФА"},
    {"Тонга", "Нукуалофа", "Паанга"},
    {"Тринидад и Тобаго", "Порт-оф-Спейн", "Тринидад и Тобаго доллар"},
    {"Тувалу", "Фунафути", "Австралийский доллар"},
    {"Тунис", "Тунис", "Тунисский динар"},
    {"Туркмения", "Ашхабад", "Туркменский манат"},
    {"Турция", "Анкара", "Турецкая лира"},
    {"Уганда", "Кампала", "Угандийский шиллинг"},
    {"Узбекистан", "Ташкент", "Узбекский сум"},
    {"Украина", "Киев", "Гривна"},
    {"Уругвай", "Монтевидео", "Уругвайский песо"},
    {"Фиджи", "Сува", "Фиджийский доллар"},
    {"Филиппины", "Манила", "Филиппинское песо"},
    {"Финляндия", "Хельсинки", "Евро"},
    {"Франция", "Париж", "Евро"},
    {"Хорватия", "Загреб", "Евро"},
    {"ЦАР", "Банги", "Франк КФА"},
    {"Чад", "Нджамена", "Франк КФА"},
    {"Чехия", "Прага", "Чешская крона"},
    {"Чили", "Сантьяго", "Чилийский песо"},
    {"Швейцария", "Берн", "Швейцарский франк"},
    {"Швеция", "Стокгольм", "Шведская крона"},
    {"Шри-Ланка", "Шри-Джаяварденепура-Котте", "Шри-ланкийская рупия"},
    {"Эквадор", "Кито", "Доллар США"},
    {"Экваториальная Гвинея", "Малабо", "Франк КФА"},
    {"Эритрея", "Асмэра", "Накфа"},
    {"Эсватини", "Мбабане", "Лилангени"},
    {"Эстония", "Таллин", "Евро"},
    {"Эфиопия", "Аддис-Абеба", "Быр"},
    {"ЮАР", "Претория", "Южноафриканский рэнд"},
    {"Южный Судан", "Джуба", "Южносуданский фунт"},
    {"Ямайка", "Кингстон", "Ямайский доллар"},
    {"Япония", "Токио", "Японская иена"}
}

local buttons = {{"Продам", "Куплю"},
    {"а/м", "м/ц", "в/т", "с/т", "г/т", "р/с", "а/с", "дом", "предприятие", "квартиру"}, 
    {"с э/т", "в п/к", "с м/д"}, 
    {"Бюджет:", "Бюджет: свободный", "Цена:", "Цена: договорная", "/шт"}
}
function getAdaptiveX(x)
	return sizeX * (x / 1920)
end
function getAdaptiveY(y)
	return sizeY * (y / 1080)
end
function shuffle_word(word)
    -- Преобразуем слово в таблицу букв
    local letters = {}
    for letter in word:gmatch(".") do
        table.insert(letters, letter:upper())
    end
    
    -- Перемешиваем таблицу букв
    math.randomseed(os.time())
    for i = #letters, 2, -1 do
        local j = math.random(i)
        letters[i], letters[j] = letters[j], letters[i]
    end
    
    -- Соединяем буквы обратно в строку
    local shuffled_word = table.concat(letters, ". ")
    
    return shuffled_word
end

function asyncHttpRequest(method, url, args, resolve, reject) -- Функция асинхронного запроса
	local request_thread = effil.thread(function (method, url, args)
	   local requests = require 'requests'
	   local result, response = pcall(requests.request, method, url, args)
	   if result then
		  response.json, response.xml = nil, nil
		  return true, response
	   else
		  return false, response
	   end
	end)(method, url, args)
	-- Если запрос без функций обработки ответа и ошибок.
	if not resolve then resolve = function() end end
	if not reject then reject = function() end end
	-- Проверка выполнения потока
	lua_thread.create(function()
	   local runner = request_thread
	   while true do
		  local status, err = runner:status()
		  if not err then
			 if status == 'completed' then
				local result, response = runner:get()
				if result then
				   resolve(response)
				else
				   reject(response)
				end
				return
			 elseif status == 'canceled' then
				return reject(status)
			 end
		  else
			 return reject(err)
		  end
		  wait(0)
	   end
	end)
end

function GetPlayerId(arg)
    local id = tonumber(arg)
    local str = 0

    local function isConnected(id)
        return select(2, sampGetPlayerIdByCharHandle(PLAYER_PED)) == id or sampIsPlayerConnected(id)
    end

    if id then
        str = isConnected(id) and id or false
    else
        local escaped_nickname = arg
        for _, s in ipairs({"%$", "%^", "%+", "%_", "%-", "%(", "%)"}) do
            escaped_nickname = escaped_nickname:gsub(s, "%"..s)
        end

        str = false
        for id = 0, sampGetMaxPlayerId(false) do
            if isConnected(id) then
                if sampGetPlayerNickname(id):lower():find("^"..escaped_nickname:lower()) then
                    str = id
                    break
                end
            end
        end
    end

    return str
end

function imgui.Underline(text, color1, color2) -- Подчеркивание текста
    local tSize = imgui.CalcTextSize(text)
    local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
    if imgui.InvisibleButton("##"..text, tSize) then return true end
    local color = imgui.IsItemHovered() and color2 or color1
    
    DL:AddText(p, color, text)
    DL:AddLine(imgui.ImVec2(p.x, p.y + tSize.y), imgui.ImVec2(p.x + tSize.x, p.y + tSize.y), color)
end

imgui.OnInitialize(function() -- Инициализация MImgui
    cnn() -- Тема
    imgui.GetIO().IniFilename = nil
    local glyph_ranges = imgui.GetIO().Fonts:GetGlyphRangesCyrillic()
    font = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14)..'\\arialbd.ttf', 14.0, nil, glyph_ranges) -- Шрифт
end)

local search = imgui.new.char[256]()
local input = imgui.new.char[128]()
local bank = 0

imgui.OnFrame( -- Основное меню /cnnhelp
    function() return window[0] end,
    function(player)
        imgui.PushFont(font)
        imgui.SetNextWindowPos(imgui.ImVec2((sizeX / 2), (sizeY / 2)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(getAdaptiveX(460), getAdaptiveY(420)))
        imgui.Begin("CNN Helper | by Rick Ross | "..thisScript().version, window, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings)
        if imgui.BeginTabBar('##main') then
            if imgui.BeginTabItem('Функции') then
                if imgui.Button("Музыкальная заставка") then 
                    sampSendChat("/news ..::Музыкальная заставка Cable News Network::..")
                end
                imgui.Separator()
                imgui.Text("Перемешать слово")
                imgui.Separator()
                imgui.InputText('##shuffle', shuffleinput, ffi.sizeof(shuffleinput)) imgui.SameLine()
                if imgui.Button('Перемешать') then
                    shuffled = shuffle_word(cp(ffi.string(shuffleinput)))
                end
                imgui.Text(cp:decode(shuffled)) imgui.SameLine()
                if shuffled ~= '' then
                    if imgui.Button('Скопировать') then
                        imgui.SetClipboardText(cp:decode(shuffled))
                    end
                else imgui.NewLine() end
                imgui.Separator()
                imgui.TextDisabled("Общая сумма: "..format_number(bank).."$")
                imgui.TextDisabled("Выигрыш: "..format_number(math.floor(bank - bank / 100 * 15)).."$")
                imgui.SameLine()
                imgui.TextDisabled("Процент: "..format_number(math.floor(bank / 100 * 15)).."$")
                if imgui.Button("Очистить список спонсоров") then 
                    sponsors = {}
                    bank = 0
                end
                for k, v in pairs(sponsors) do
                    if imgui.Button("X##deletesponsor"..k) then
                        sponsors[k] = nil
                    end
                    imgui.SameLine()
                    imgui.Text(v[1].." - "..format_number(v[2]).."$")
                end
                imgui.Separator()
                imgui.PushItemWidth(imgui.CalcTextSize(" Введите ID или часть ник-нейма ").x)
                    imgui.InputTextWithHint("##competitorsinput", "Введите ID или часть ник-нейма", input, ffi.sizeof(input))
                imgui.PopItemWidth()
                if imgui.Button("Ввести") then
                    local id = GetPlayerId(ffi.string(input))
                    if id then
                        table.insert(competitors, {sampGetPlayerNickname(id), 1})
                    end
                end
                imgui.SameLine()
                if imgui.Button("Очистить") then
                    competitors = {}
                end
                for k, v in pairs(competitors) do
                    if imgui.Button("X##delete"..k) then
                        competitors[k] = nil
                    end
                    imgui.SameLine()
                    imgui.Text(v[1].." - "..v[2])
                    imgui.SameLine()
                    if imgui.Button("-##minus"..k) then
                        if v[2] > 1 then
                            v[2] = v[2] - 1
                        end
                    end
                    imgui.SameLine()
                    if imgui.Button("+##plus"..k) then
                        v[2] = v[2] + 1
                    end
                end
                imgui.EndTabItem() 
            end
            if imgui.BeginTabItem('Транспорт') then
                imgui.PushItemWidth(getAdaptiveX(443))
                imgui.InputTextWithHint('##findcar', 'Поиск', search, ffi.sizeof(search))
                imgui.PopItemWidth()
                imgui.BeginChild('##carlist', imgui.ImVec2(getAdaptiveX(443), getAdaptiveY(332)), true)
                    if imgui.BeginPopup('##succesmessage', imgui.WindowFlags.NoMove) then
                        imgui.Text('Скопировано в буфер обмена.')
                        imgui.EndPopup()
                    end
                    for k, v in pairs(cars) do
                        if v:lower():find(cp(ffi.string(search))) or tostring(k+399):find(cp(ffi.string(search))) then
                            if imgui.Selectable('[ '..(k+399)..' ] '..cp:decode(v)) then
                                imgui.SetClipboardText(v)
                                imgui.OpenPopup('##succesmessage')
                            end
                        end
                    end
                    for k, v in pairs(customcars) do
                        if v:lower():find(cp(ffi.string(search))) or tostring(k+1999):find(cp(ffi.string(search))) then
                            if imgui.Selectable('[ '..(k+1999)..' ] '..cp:decode(v)) then
                                imgui.SetClipboardText(cp:decode(v))
                                imgui.OpenPopup('##succesmessage')
                            end
                        end
                    end
                imgui.EndChild()
            imgui.EndTabItem()
            end
            if imgui.BeginTabItem('Тюнинг') then
                imgui.BeginChild('##tunlist', imgui.ImVec2(getAdaptiveX(450), getAdaptiveY(358)), false)
                    if imgui.BeginPopup('##succesmessage', imgui.WindowFlags.NoMove) then
                        imgui.Text('Скопировано в буфер обмена.')
                        imgui.EndPopup()
                    end
                    for k, v in pairs(tuning) do
                        imgui.TextDisabled(k)
                        for i = 1, #v do
                            if imgui.Selectable(v[i]) then
                                imgui.SetClipboardText(v[i])
                                imgui.OpenPopup('##succesmessage')
                            end
                        end
                        if #k ~= 16 then imgui.Separator() end
                    end
                    imgui.EndChild()
            imgui.EndTabItem()
            end
            if imgui.BeginTabItem('Страны') then
                imgui.BeginChild('##countries', imgui.ImVec2(getAdaptiveX(450), getAdaptiveY(358)), false)
                        if imgui.BeginPopup('##succesmessage', imgui.WindowFlags.NoMove) then
                            imgui.Text('Скопировано в буфер обмена.')
                            imgui.EndPopup()
                        end
                        imgui.Columns(3)
                        imgui.Text("Страны")
                        imgui.NextColumn()
                        imgui.Text("Столицы")
                        imgui.NextColumn()
                        imgui.Text("Валюта")
                        imgui.Separator()              
                        for _, v in pairs(countries) do
                            imgui.NextColumn()
                            if imgui.Underline(v[1], 0xffffffff, 0xFF66CCFF) then
                                imgui.SetClipboardText(v[1])
                                imgui.OpenPopup('##succesmessage')
                            end
                            imgui.NextColumn()
                            if imgui.Underline(v[2], 0xffffffff, 0xFF66CCFF) then
                                imgui.SetClipboardText(v[2])
                                imgui.OpenPopup('##succesmessage')
                            end
                            imgui.NextColumn()
                            if imgui.Underline(v[3], 0xffffffff, 0xFF66CCFF) then
                                imgui.SetClipboardText(v[3])
                                imgui.OpenPopup('##succesmessage')
                            end
                            imgui.Separator()
                        end
                    imgui.EndChild()
            imgui.EndTabItem()
            end
        end
        imgui.EndTabBar()
        imgui.PopFont()
        imgui.End()
    end
)

imgui.OnFrame( -- Меню редактирования объявления
    function() return adwindow[0] end,
    function(player)
        imgui.PushFont(font)
        imgui.SetNextWindowPos(imgui.ImVec2((sizeX / 2), (sizeY / 2)), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(getAdaptiveX(500), getAdaptiveY(220)))
        imgui.Begin("Редактирование объявления", adwindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.NoTitleBar)
        local w = imgui.GetWindowPos()
        local s = imgui.GetWindowSize()
        imgui.TextDisabled("Исходный текст:") imgui.SameLine() imgui.Text(ad) imgui.SameLine()
        imgui.SetCursorPosX(imgui.GetWindowWidth() - imgui.CalcTextSize(" X ").x - imgui.GetStyle().WindowPadding.x)
        if imgui.Button('X') then
            sampSendDialogResponse(3091, 0, 65535)
            adwindow[0] = false
        end
        if imgui.Button("C") then imgui.StrCopy(adinput, "") end imgui.SameLine()
        imgui.PushItemWidth(getAdaptiveX(373)) imgui.InputText('##adinput', adinput, ffi.sizeof(adinput)) imgui.PopItemWidth() imgui.SameLine()
        if imgui.Button("Отправить") then
            sampSendDialogResponse(3091, 1, 65535, cp(ffi.string(adinput)))
            adwindow[0] = false
        end
        imgui.Separator()
        for i, v in pairs(buttons[1]) do
            if imgui.Button(v) then imgui.StrCopy(adinput, ffi.string(adinput)..v.." ") end if i ~= #buttons[1] then imgui.SameLine() end
        end
        imgui.Separator()
        for i, v in pairs(buttons[2]) do
            if imgui.Button(v) then imgui.StrCopy(adinput, ffi.string(adinput)..v.." ") end if i ~= #buttons[2] then imgui.SameLine() end
        end
        imgui.Separator()
        for i, v in pairs(buttons[3]) do
            if imgui.Button(v) then imgui.StrCopy(adinput, ffi.string(adinput)..v.." ") end if i ~= #buttons[3] then imgui.SameLine() end
        end
        imgui.Separator()
        for i, v in pairs(buttons[4]) do
            if imgui.Button(v) then imgui.StrCopy(adinput, ffi.string(adinput)..v) end if i ~= #buttons[4] then imgui.SameLine() end
        end
        imgui.PushItemWidth(getAdaptiveX(imgui.CalcTextSize("  Введите сумму  ").x)) 
        if imgui.InputTextWithHint('##moneyinput', "Введите сумму", moneyinput, ffi.sizeof(moneyinput)) then
            if ffi.string(moneyinput):find("k") or cp(ffi.string(moneyinput)):find(cp("к")) or ffi.string(moneyinput):find("r") then
                local number, k = ffi.string(moneyinput):match("(%d+)(.+)")
                if k then
                    local count = 0
                    for i = 1, #k do
                        if k:sub(i, i) == "k" or k:sub(i, i) == "r" or cp(k):sub(i, i) == cp"к" then
                            count = count + 1
                        end
                    end
                    local m = 1
                    for i = 1, count do
                        m = m * 1000
                    end
                    money = number * m
                    money = format_number(money)
                end
            else
                money = format_number(ffi.string(moneyinput))
            end
        end
        imgui.PopItemWidth() imgui.SameLine()
        if money and imgui.Underline(money.."$", 0xffffffff, 0xFF66CCFF) then
            imgui.StrCopy(adinput, ffi.string(adinput).." "..money.."$")
        end
        imgui.SetNextWindowPos(imgui.ImVec2((w.x + s.x), (w.y - s.y + getAdaptiveY(35))), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(getAdaptiveX(400), getAdaptiveY(405)))
        imgui.Begin("##lists", adwindow, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.NoSavedSettings + imgui.WindowFlags.NoTitleBar)
        if imgui.BeginTabBar('##label2') then
            if imgui.BeginTabItem('Транспорт') then
                imgui.PushItemWidth(getAdaptiveX(384))
                imgui.InputTextWithHint('##findcar', 'Поиск', search, ffi.sizeof(search))
                imgui.PopItemWidth()
                imgui.BeginChild('##carlist', imgui.ImVec2(getAdaptiveX(384), getAdaptiveY(336)), true)
                    if imgui.BeginPopup('##succesmessage', imgui.WindowFlags.NoMove) then
                        imgui.Text('Скопировано в буфер обмена.')
                        imgui.EndPopup()
                    end
                    for k, v in pairs(cars) do
                        if v:lower():find(cp(ffi.string(search))) or tostring(k+399):find(cp(ffi.string(search))) then
                            if imgui.Selectable('[ '..(k+399)..' ] '..cp:decode(v)) then
                                imgui.StrCopy(adinput, ffi.string(adinput)..v.." ")
                            end
                        end
                    end
                    for k, v in pairs(customcars) do
                        if v:lower():find(cp(ffi.string(search))) or tostring(k+1999):find(cp(ffi.string(search))) then
                            if imgui.Selectable('[ '..(k+1999)..' ] '..cp:decode(v)) then
                                imgui.StrCopy(adinput, ffi.string(adinput)..cp:decode(v).." ")
                            end
                        end
                    end
                imgui.EndChild()
                imgui.EndTabItem()
            end
            if imgui.BeginTabItem('Тюнинг') then
                imgui.BeginChild('##tunlist', imgui.ImVec2(getAdaptiveX(450), getAdaptiveY(358)), false)
                    if imgui.BeginPopup('##succesmessage', imgui.WindowFlags.NoMove) then
                        imgui.Text('Скопировано в буфер обмена.')
                        imgui.EndPopup()
                    end
                    for k, v in pairs(tuning) do
                        imgui.TextDisabled(k)
                        for i = 1, #v do
                            if imgui.Selectable(v[i]) then
                                imgui.StrCopy(adinput, ffi.string(adinput)..v[i].." ")
                            end
                        end
                        if #k ~= 16 then imgui.Separator() end
                    end
                    imgui.EndChild()
            imgui.EndTabItem()
            end
        imgui.EndTabBar()
        end
        imgui.PopFont()
        imgui.End()
    end
)

function sampev.onShowDialog(dialogid, style, title, button1, button2, text)
    if dialogid == 3091 and title == cp'{cccccc}** Объявление {ffcc66}CNN' then
        ad = cp:decode(text:match(cp'{ff9000}.+%[%d+%]\n{cccccc}Исходный текст объявления:\n(.+)'))
        adwindow[0] = true
        imgui.StrCopy(adinput, ad)
        return false
    end
end

function sampev.onServerMessage(color, text)
    if text:find(cp"{99ff66}%[ BANK %]: {cccccc}Поступили средства от: {ff9000}(.-) {cccccc}| Сумма: {99ff66}(%d+)$ %[(.-)%]") then
        local nick, summ = text:match(cp"{99ff66}%[ BANK %]: {cccccc}Поступили средства от: {ff9000}(.-) {cccccc}| Сумма: {99ff66}(%d+)$ %[(.-)%]")
        bank = bank + summ
        table.insert(sponsors, {nick, summ})
    end
end

function format_number(num)
    local formatted = tostring(num)
    while true do  
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1.%2')
        if k == 0 then
            break
        end
    end
    return formatted
end


function main()
	while not isSampAvailable() do wait(0) end -- Проверка на доступность сампа

    asyncHttpRequest('GET', 'https://raw.githubusercontent.com/nightaiga/Pears/main/cars.json', nil, -- Запрос на получение списка авто.
	function(response)
        local result = decodeJson(response.text)
        for _, v in pairs(result) do
            table.insert(customcars, cp(v))
        end
    end,
    function(err)
		print('Ошибка при получении списка авто')
	end)

    asyncHttpRequest('GET', 'https://raw.githubusercontent.com/nightaiga/Pears/main/tun.json', nil, -- Запрос на получение списка тюнинга.
	function(response)
        local result = decodeJson(response.text)
        for k, v in pairs(result) do
            tuning[k] = v
        end
    end,
    function(err)
		print('Ошибка при получении списка авто')
	end)

    sampRegisterChatCommand('cnnhelp', function() -- Регистрация команды на открытие окна
        window[0] = not window[0]
    end)

    wait(-1)
end

function onWindowMessage(msg, wparam, lparam)
	if msg == 0x100 or msg == 0x101 then
		if wparam == 27 and window[0] and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() then
			consumeWindowMessage(true, false)
			window[0] = not window[0]
        elseif wparam == 27 and adwindow[0] and not sampIsChatInputActive() and not sampIsDialogActive() and not isPauseMenuActive() then
            consumeWindowMessage(true, false)
            sampSendDialogResponse(3091, 0, 65535)
            adwindow[0] = not adwindow[0]
        end
	end	
end	

function cnn() -- Стиль интерфейса
    local style = imgui.GetStyle();
    local colors = style.Colors;
    style.Alpha = 1;
    style.WindowPadding = imgui.ImVec2(8.00, 8.00);
    style.WindowRounding = 5;
    style.WindowBorderSize = 1;
    style.WindowMinSize = imgui.ImVec2(32.00, 32.00);
    style.WindowTitleAlign = imgui.ImVec2(0.00, 0.50);
    style.ChildRounding = 5;
    style.ChildBorderSize = 1;
    style.PopupRounding = 0;
    style.PopupBorderSize = 1;
    style.FramePadding = imgui.ImVec2(4.00, 3.00);
    style.FrameRounding = 2;
    style.FrameBorderSize = 0;
    style.ItemSpacing = imgui.ImVec2(8.00, 6.00);
    style.ItemInnerSpacing = imgui.ImVec2(4.00, 4.00);
    style.IndentSpacing = 21;
    style.ScrollbarSize = 14;
    style.ScrollbarRounding = 9;
    style.GrabMinSize = 10;
    style.GrabRounding = 0;
    style.TabRounding = 4;
    style.ButtonTextAlign = imgui.ImVec2(0.50, 0.50);
    style.SelectableTextAlign = imgui.ImVec2(0.00, 0.00);
    colors[imgui.Col.Text] = imgui.ImVec4(1.00, 1.00, 1.00, 1.00);
    colors[imgui.Col.TextDisabled] = imgui.ImVec4(0.80, 0.80, 0.80, 1.00);
    colors[imgui.Col.WindowBg] = imgui.ImVec4(0.06, 0.06, 0.06, 0.94);
    colors[imgui.Col.ChildBg] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[imgui.Col.PopupBg] = imgui.ImVec4(0.08, 0.08, 0.08, 0.94);
    colors[imgui.Col.Border] = imgui.ImVec4(1.00, 1.00, 1.00, 0.63);
    colors[imgui.Col.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00);
    colors[imgui.Col.FrameBg] = imgui.ImVec4(1.00, 0.80, 0.40, 0.63);
    colors[imgui.Col.FrameBgHovered] = imgui.ImVec4(1.00, 0.80, 0.40, 0.63);
    colors[imgui.Col.FrameBgActive] = imgui.ImVec4(1.00, 0.80, 0.40, 0.45);
    colors[imgui.Col.TitleBg] = imgui.ImVec4(0.04, 0.04, 0.04, 1.00);
    colors[imgui.Col.TitleBgActive] = imgui.ImVec4(0.71, 0.56, 0.28, 1.00);
    colors[imgui.Col.TitleBgCollapsed] = imgui.ImVec4(0.00, 0.00, 0.00, 0.51);
    colors[imgui.Col.MenuBarBg] = imgui.ImVec4(0.14, 0.14, 0.14, 1.00);
    colors[imgui.Col.ScrollbarBg] = imgui.ImVec4(0.02, 0.02, 0.02, 0.53);
    colors[imgui.Col.ScrollbarGrab] = imgui.ImVec4(0.31, 0.31, 0.31, 1.00);
    colors[imgui.Col.ScrollbarGrabHovered] = imgui.ImVec4(0.41, 0.41, 0.41, 1.00);
    colors[imgui.Col.ScrollbarGrabActive] = imgui.ImVec4(0.51, 0.51, 0.51, 1.00);
    colors[imgui.Col.CheckMark] = imgui.ImVec4(1.00, 0.80, 0.40, 1.00);
    colors[imgui.Col.SliderGrab] = imgui.ImVec4(1.00, 0.80, 0.40, 0.78);
    colors[imgui.Col.SliderGrabActive] = imgui.ImVec4(1.00, 0.80, 0.40, 1.00);
    colors[imgui.Col.Button] = imgui.ImVec4(1.00, 0.80, 0.40, 0.63);
    colors[imgui.Col.ButtonHovered] = imgui.ImVec4(1.00, 0.80, 0.40, 0.79);
    colors[imgui.Col.ButtonActive] = imgui.ImVec4(1.00, 0.80, 0.40, 0.86);
    colors[imgui.Col.Header] = imgui.ImVec4(1.00, 0.80, 0.40, 0.67);
    colors[imgui.Col.HeaderHovered] = imgui.ImVec4(1.00, 0.80, 0.40, 0.84);
    colors[imgui.Col.HeaderActive] = imgui.ImVec4(1.00, 0.80, 0.40, 0.86);
    colors[imgui.Col.Separator] = imgui.ImVec4(0.43, 0.43, 0.50, 0.50);
    colors[imgui.Col.SeparatorHovered] = imgui.ImVec4(1.00, 0.80, 0.40, 0.84);
    colors[imgui.Col.SeparatorActive] = imgui.ImVec4(1.00, 0.80, 0.40, 0.86);
    colors[imgui.Col.ResizeGrip] = imgui.ImVec4(1.00, 0.80, 0.40, 0.63);
    colors[imgui.Col.ResizeGripHovered] = imgui.ImVec4(1.00, 0.80, 0.40, 0.84);
    colors[imgui.Col.ResizeGripActive] = imgui.ImVec4(1.00, 0.80, 0.40, 0.86);
    colors[imgui.Col.Tab] = imgui.ImVec4(1.00, 0.80, 0.40, 0.67);
    colors[imgui.Col.TabHovered] = imgui.ImVec4(1.00, 0.80, 0.40, 0.84);
    colors[imgui.Col.TabActive] = imgui.ImVec4(1.00, 0.80, 0.40, 0.86);
    colors[imgui.Col.TabUnfocused] = imgui.ImVec4(0.07, 0.10, 0.15, 0.97);
    colors[imgui.Col.TabUnfocusedActive] = imgui.ImVec4(0.14, 0.26, 0.42, 1.00);
    colors[imgui.Col.PlotLines] = imgui.ImVec4(0.61, 0.61, 0.61, 1.00);
    colors[imgui.Col.PlotLinesHovered] = imgui.ImVec4(1.00, 0.43, 0.35, 1.00);
    colors[imgui.Col.PlotHistogram] = imgui.ImVec4(0.90, 0.70, 0.00, 1.00);
    colors[imgui.Col.PlotHistogramHovered] = imgui.ImVec4(1.00, 0.60, 0.00, 1.00);
    colors[imgui.Col.TextSelectedBg] = imgui.ImVec4(1.00, 0.80, 0.40, 0.67);
    colors[imgui.Col.DragDropTarget] = imgui.ImVec4(1.00, 1.00, 0.00, 0.90);
    colors[imgui.Col.NavHighlight] = imgui.ImVec4(0.26, 0.59, 0.98, 1.00);
    colors[imgui.Col.NavWindowingHighlight] = imgui.ImVec4(1.00, 1.00, 1.00, 0.70);
    colors[imgui.Col.NavWindowingDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.20);
    colors[imgui.Col.ModalWindowDimBg] = imgui.ImVec4(0.80, 0.80, 0.80, 0.35);
end
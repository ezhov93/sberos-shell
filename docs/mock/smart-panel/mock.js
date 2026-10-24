(() => {
    'use strict';
    const $ = id => document.getElementById(id);
    const sourceBase = '../../sources/panel/screenshots/';
    const shapes = {
        sber: '<path d="M20 10a9 9 0 1 1-5-7M6 10l5 4L22 5"/>',
        settings: '<path d="m9 3 1-2h4l1 2 2 1 2-1 2 3-1 2v3l1 2-2 3-2-1-2 1-1 2h-4l-1-2-2-1-2 1-2-3 1-2V8L2 6l2-3 2 1 3-1Z" transform="translate(1 2)"/><circle cx="12" cy="12" r="3"/>',
        terminal: '<path d="m4 5 7 7-7 7m10 0h7"/>',
        power: '<path d="M12 2v10M6 5a9 9 0 1 0 12 0"/>',
        down: '<path d="m6 9 6 6 6-6"/>', up: '<path d="m6 15 6-6 6 6"/>',
        left: '<path d="m14 5-7 7 7 7"/>', right: '<path d="m9 5 7 7-7 7"/>',
        controls: '<rect x="2" y="3" width="20" height="7" rx="3"/><rect x="2" y="14" width="20" height="7" rx="3"/><circle cx="7" cy="6.5" r="1"/><circle cx="17" cy="17.5" r="1"/>',
        wifi: '<path d="M2 8a16 16 0 0 1 20 0M5 12a11 11 0 0 1 14 0M8 16a6 6 0 0 1 8 0"/><circle cx="12" cy="20" r=".7" fill="currentColor"/>',
        bluetooth: '<path d="m7 6 10 12-5 4V2l5 4L7 18"/>',
        battery: '<rect x="2" y="6" width="17" height="12" rx="2"/><path d="M22 10v4"/><path d="M5 9h10v6H5z" fill="currentColor" stroke="none"/>',
        speaker: '<path d="M3 9h4l5-4v14l-5-4H3zM16 8a6 6 0 0 1 0 8m3-11a10 10 0 0 1 0 14"/>',
        sun: '<circle cx="12" cy="12" r="4"/><path d="M12 1v3m0 16v3M1 12h3m16 0h3M4 4l2 2m12 12 2 2M4 20l2-2M18 6l2-2"/>',
        bell: '<path d="M5 17h14l-2-3V9a5 5 0 0 0-10 0v5zM10 21h4"/>',
        moon: '<path d="M20 14A9 9 0 0 1 10 3a9 9 0 1 0 10 11Z"/>',
        plane: '<path d="m3 15 7-4V4a2 2 0 0 1 4 0v7l7 4v3l-7-2v4l2 1v1l-4-1-4 1v-1l2-1v-4l-7 2Z"/>',
        night: '<path d="M3 17h18M6 14a6 6 0 0 1 12 0M12 2v3M3 6l3 3m15-3-3 3M6 21h12"/>',
        vpn: '<path d="m12 2 8 3v6c0 5-8 11-8 11S4 16 4 11V5zM8 12l3 3 5-6"/>',
        capture: '<path d="M8 3H5a2 2 0 0 0-2 2v3m13-5h3a2 2 0 0 1 2 2v3M3 16v3a2 2 0 0 0 2 2h3m8 0h3a2 2 0 0 0 2-2v-3"/><circle cx="12" cy="12" r="4"/>',
        info: '<circle cx="12" cy="12" r="10"/><path d="M12 11v6m0-11v1"/>'
    };
    const originalIcons = new Set('sber settings terminal power down left right controls wifi bluetooth battery speaker sun moon plane night bellOff capture'.split(' '));
    const icon = name => originalIcons.has(name) ? `<span class="icon original-icon" data-glyph="${name}" aria-hidden="true"></span>` : `<svg class="icon" viewBox="0 0 24 24" aria-hidden="true">${shapes[name] || shapes.info}</svg>`;
    const escape = value => String(value).replace(/[&<>"']/g, c => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));
    const appData = [
        ['browser','СберБраузер'], ['usersoft','UserSoft'], ['jazz','Jazz'], ['pulse','Пульс'],
        ['pixso','Pixso'], ['varm','ВАРМ'], ['online','Сбер Онлайн'], ['mail','Почта'],
        ['python','Python'], ['emp','EMP'], ['office','Р7 Офис'], ['chat','СберЧат'],
        ['friend','ПО Друга 2.0'], ['pdf','PDF creator'], ['boards','Доски'], ['f1','F1'],
        ['citrix','Citrix Alpha'], ['sigma','Citrix Sigma'], ['disk','Диск'], ['docs','SberDocs'],
        ['access','Мои доступы'], ['potok','Поток.webloc'], ['protocol','Автопротокол…'], ['vpn','Cisco AnyConnect'],
        ['mapp','M-app'], ['isy','ИСУ'], ['space','SberSpace'], ['shares','Акции'],
        ['design','SberDesign'], ['boost','СберБуст'], ['aigen','AIGenAI'], ['files','Файловый менеджер']
    ].map(([id, name], index) => ({id, name, x:256 + index % 8 * 184, y:124 + Math.floor(index / 8) * 196}));
    const appsById = Object.fromEntries(appData.map(a => [a.id, a]));
    function appIcon(id, size) {
        return `<img class="app-icon" src="assets/apps/${id}.svg" width="${size}" height="${size}" alt="${escape(appsById[id].name)}" draggable="false">`;
    }
    const launchIcon = '<img class="launch-icon" src="assets/launchpad.svg" alt="" aria-hidden="true">';
    const state = {
        dark:false, opaque:false, popup:null, localQuery:'сбер', noticesCleared:false, powerMenu:false, launcher:false, query:'', page:0,
        appsMode:'desktop', running:{files:4,jazz:1}, notifications:true, wifi:true, wifiExpanded:false,
        ssid:'NovayaSetWiFi_5G_1786527', bluetooth:true, btDevice:'AirPods Pro', profile:'Сбалансированный',
        vpn:true, night:false, airplane:false, volume:75, brightness:90, month:8, year:2026,
        selectedDay:null, notification:false, reference:'applications-pinned-running.png', comparison:false, nativeScale:false
    };
    let lastTrigger = null;
    let messageTimer;
    function updateScale() {
        const scale = state.nativeScale ? 1 : Math.min(window.innerWidth / 1920, window.innerHeight / 1080);
        document.documentElement.style.setProperty('--scale', scale);
        $('viewport').style.overflow = state.nativeScale ? 'auto' : 'hidden';
        $('viewport').style.placeItems = state.nativeScale ? 'start' : 'center';
        $('scene').style.transformOrigin = state.nativeScale ? 'top left' : 'center';
    }
    function setReference(file) {
        state.reference = file;
        const svgRefs = {'quick-settings-light.png':'quick','calendar-light.png':'calendar','button-sber-menu-power.png':'sber','quick-settings-wifi-expanded.png':'wifi','quick-settings-bt-connected.png':'bluetooth','launchpad-open.png':'launcher'};
        const key = file.startsWith('svg:') ? file.slice(4) : svgRefs[file];
        state.referenceAsset = key ? `assets/references/${key}.svg` : sourceBase + file;
        $('referenceImage').src = state.referenceAsset;
        $('referenceName').textContent = `Сверка: ${state.referenceAsset}`;
    }
    function syncTheme() {
        $('scene').classList.toggle('dark', state.dark);
        $('scene').classList.toggle('opaque', state.opaque);
        $('themeButton').textContent = state.dark ? 'Светлая тема' : 'Тёмная тема';
        $('surfaceButton').textContent = state.opaque ? 'Поверхности: непрозрачные' : 'Поверхности: по макету';
    }
    function setDark(value) {
        state.dark = value; syncTheme(); renderPopup();
        if (state.popup === 'calendar' || state.popup === 'quick') syncPopupReference();
    }
    function message(text, persistent=false) {
        clearTimeout(messageTimer);
        $('oskaMessage').innerHTML = `<span class="oska-avatar" aria-hidden="true"></span><span class="message-text">${escape(text)}</span>${icon('battery')}`;
        $('oskaMessage').hidden = false;
        if (!persistent) messageTimer = setTimeout(() => {$('oskaMessage').hidden = true;}, 3500);
    }
    function closeTop(restore=true) {
        if (!$('confirmation').hidden) { $('confirmation').hidden = true; return; }
        if (state.powerMenu) { state.powerMenu = false; renderPopup(); setReference('button-sber-menu-open.png'); return; }
        state.launcher = false; state.popup = null;
        if (state.appsMode === 'overflowOpen') state.appsMode = 'overflow';
        state.notification = false;
        $('oskaMessage').hidden = true;
        $('launcher').hidden = true; $('panel').hidden = false;
        $('popups').innerHTML = '';
        updateExpanded(); renderApps(); syncDesktopReference();
        if (restore && lastTrigger?.isConnected) lastTrigger.focus();
    }
    function updateExpanded() {
        $('searchButton').textContent = state.noticesCleared ? 'Новых уведомлений пока нет' : 'Найду документ или приложение';
        $('oska').hidden = ['localSearch','notificationsList'].includes(state.popup);
        $('notificationsButton').setAttribute('aria-expanded', String(state.popup === 'notificationsList'));
        $('sberButton').hidden = state.popup === 'sber';
        $('sberButton').setAttribute('aria-expanded', String(state.popup === 'sber'));
        $('quickButton').setAttribute('aria-expanded', String(['quick','wifi','bluetooth','profile'].includes(state.popup)));
        $('calendarButton').setAttribute('aria-expanded', String(state.popup === 'calendar'));
    }
    function syncDesktopReference() {
        const refs={desktop:'applications-pinned-running.png',empty:'applications-empty.png',icons40:'applications-icons-40px.png',icons32:'applications-icons-32px.png',unread:'applications-unread-count.png',overflow:'applications-overflow-count.png',overflowOpen:'applications-overflow-open.png'};
        setReference(refs[state.appsMode] || refs.desktop);
    }
    function openPopup(name, trigger) {
        const toggle = state.popup === name;
        closeTop(false); state.powerMenu = false;
        if (toggle) { if (trigger) trigger.focus(); return; }
        lastTrigger = trigger || document.activeElement;
        state.popup = name;
        if (name === 'calendar') { state.year=2026; state.month=8; state.selectedDay=null; }
        renderPopup(); updateExpanded(); syncPopupReference();
        if (name === 'localSearch') $('localQuery').focus();
    }
    function syncPopupReference() {
        if (state.popup === 'localSearch') return setReference('svg:search');
        if (state.popup === 'notificationsList') return setReference('svg:notifications');
        if (state.popup === 'sber') return setReference(state.powerMenu ? 'button-sber-menu-power.png' : 'button-sber-menu-open.png');
        if (state.popup === 'quick') return setReference(`quick-settings-${state.dark ? 'dark' : 'light'}.png`);
        if (state.popup === 'calendar') return setReference(`calendar-${state.dark ? 'dark' : 'light'}.png`);
        if (state.popup === 'wifi') return setReference(`quick-settings-wifi-${!state.wifi ? 'off' : state.wifiExpanded ? 'expanded' : 'collapsed'}.png`);
        if (state.popup === 'bluetooth') return setReference(`quick-settings-bt-${!state.bluetooth ? 'not-found' : state.btDevice ? 'connected' : 'not-connected'}.png`);
        if (state.popup === 'profile') return setReference(`quick-settings-power-${state.profile === 'Производительный' ? 'performance' : state.profile === 'Энергосберегающий' ? 'balanced-2' : 'balanced-1'}.png`);
    }
    function dockItems() {
        if (state.appsMode === 'empty') return ['launchpad','files','browser'];
        if (state.appsMode === 'desktop') return ['launchpad','files','browser', ...Object.keys(state.running).filter(id => !['files','browser'].includes(id) && state.running[id] > 0)];
        if (state.appsMode === 'unread') return ['launchpad','files','browser','jazz','chat','mail','vpn'];
        const list = ['launchpad','files','browser','pixso','python','jazz','chat','mail','vpn','docs','isy','pdf','aigen','boost','shares','office','potok','mapp','space','varm','protocol','emp','sigma','f1','design'];
        return state.appsMode === 'icons40' ? list.slice(0,12) : state.appsMode === 'icons32' ? list.slice(0,14) : list;
    }
    function renderApps() {
        const ids = dockItems();
        const compact = ['icons32','overflow','overflowOpen'].includes(state.appsMode);
        const expanded = state.appsMode === 'overflowOpen';
        const visible = state.appsMode === 'overflow' ? ids.slice(0,13) : ids;
        const buttons = visible.map((id,index) => {
            const running = state.appsMode === 'empty' ? 0 : state.running[id] || (index > 2 && state.appsMode !== 'desktop' ? (index % 4 + 1) : 0);
            const dots = '<span class="app-dots" aria-hidden="true">' + '<i></i>'.repeat(Math.min(4,running)) + '</span>';
            const badge = ['chat','mail'].includes(id) && ['unread','icons40','icons32','overflow','overflowOpen'].includes(state.appsMode) ? `<span class="badge">${id==='chat'?6:3}</span>` : '';
            const size = index<3 || compact ? 32 : 40;
            return `${index===3?'<span class="app-separator" aria-hidden="true"></span>':''}<button class="app-button" data-action="${id==='launchpad'?'launchpad':'app'}" data-id="${id}" title="${escape(id==='launchpad'?'Launchpad':appsById[id].name)}" aria-label="${escape(id==='launchpad'?'Launchpad':appsById[id].name)}">${id==='launchpad'?launchIcon:appIcon(id,size)}${running?dots:''}${badge}</button>`;
        }).join('');
        $('applications').className = `applications island ${compact?'compact':''} ${expanded?'expanded':''}`;
        $('applications').innerHTML = `<div class="app-inner">${buttons}${state.appsMode==='overflow'?`<button class="app-button" data-action="overflow" aria-label="Показать ещё ${ids.length-visible.length} приложений">+${ids.length-visible.length}</button>`:''}</div>`;
    }
    function renderPopup() {
        if (!state.popup) { $('popups').innerHTML = ''; return; }
        let html='';
        if (state.popup==='sber') html=renderSber();
        if (state.popup==='quick') html=renderQuick();
        if (state.popup==='wifi') html=renderWifi();
        if (state.popup==='bluetooth') html=renderBluetooth();
        if (state.popup==='profile') html=renderProfiles();
        if (state.popup==='calendar') html=renderCalendar();
        if (state.popup==='localSearch') html=renderLocalSearch();
        if (state.popup==='notificationsList') html=renderNotifications();
        $('popups').innerHTML=html;
        if (state.popup==='localSearch') { $('localQuery').value=state.localQuery; renderLocalResults(); }
    }
    function renderSber() {
        const actions=[['settings','settings','Настройки оболочки'],['terminal','terminal','Терминал'],['power','power','Питание и сеанс'],['collapse','down','Свернуть меню']];
        const menu=`<div class="popup sber-menu" role="menu" aria-label="Меню Сбера"><div class="menu-inner">${actions.map(([action,i,label])=>`<button class="menu-icon ${action==='power'&&state.powerMenu?'active':''}" data-action="${action}" title="${label}" aria-label="${label}" role="menuitem">${icon(i)}</button>`).join('')}</div></div>`;
        if (!state.powerMenu) return menu;
        const commands=[['Завершить сеанс',''],['Перезагрузить',''],['Перезагрузить с обновлением',''],['Выключить с обновлением',''],['Выключить','Ctrl+Alt+Delete'],['Заблокировать экран','Win+L'],['Спящий режим','']];
        return menu+`<div class="power-menu" role="menu" aria-label="Питание и сеанс">${commands.map(([label,hint],i)=>`${i===5?'<div class="power-divider"></div>':''}<button class="power-action" data-action="session" data-command="${label}" role="menuitem">${label} <small>${hint}</small></button>`).join('')}</div>`;
    }
    function tile(action, i, title, subtitle, on, expandable=false) {
        return `<button class="quick-tile ${on?'on':''}" data-action="${action}"><span class="round">${icon(i)}</span><span class="tile-label"><strong>${title}</strong><small>${escape(subtitle)}</small></span>${expandable?`<span class="tile-chevron">${icon('right')}</span>`:''}</button>`;
    }
    function renderQuick() {
        return `<section class="popup quick" aria-label="Быстрые настройки"><div class="quick-header"><button data-action="battery" aria-label="Батарея заряжена на 64 процента">${icon('battery')}64%</button><button class="capture" data-action="capture" aria-label="Сделать снимок экрана">${icon('capture')}</button></div><div class="quick-sliders"><label class="slider-group"><span class="slider-title">Звук</span><span class="slider-row">${icon('speaker')}<input type="range" aria-label="Громкость" data-setting="volume" min="0" max="100" value="${state.volume}" style="--fill:${state.volume}%"></span></label><label class="slider-group"><span class="slider-title">Дисплей</span><span class="slider-row">${icon('sun')}<input type="range" aria-label="Яркость" data-setting="brightness" min="0" max="100" value="${state.brightness}" style="--fill:${state.brightness}%"></span></label></div><div class="quick-grid">${tile('wifi','wifi','Wi‑Fi',state.wifi?state.ssid:'Выкл.',state.wifi,true)}${tile('vpn','vpn','VPN',state.vpn?'SberVPN (CORP) Active':'Выкл.',state.vpn,true)}${tile('bluetooth','bluetooth','Bluetooth',state.bluetooth?(state.btDevice||'Не подключено'):'Выкл.',state.bluetooth,true)}${tile('profile','battery','Режим питания',state.profile,false,true)}${tile('notifications',state.notifications?'bell':'bellOff','Уведомления',state.notifications?'Вкл.':'Выкл.',state.notifications)}${tile('night','night','Ночной свет',state.night?'Вкл.':'Выкл.',state.night)}${tile('airplane','plane','Авиарежим',state.airplane?'Вкл.':'Выкл.',state.airplane)}${tile('dark','moon','Тёмный стиль',state.dark?'Вкл.':'Выкл.',state.dark)}</div></section>`;
    }
    function subHeader(title, toggleAction, on) {
        return `<div class="sub-header"><button class="back-button" data-action="back" aria-label="Назад к быстрым настройкам">${icon('left')}</button><strong>${title}</strong>${toggleAction?`<button class="toggle ${on?'on':''}" role="switch" aria-checked="${on}" aria-label="${title}" data-action="${toggleAction}"></button>`:'<span style="width:32px"></span>'}</div>`;
    }
    function row(name, type, selected=false) {
        return `<button class="connection ${selected?'selected':''}" data-action="${type==='wifi'?'network':'device'}" data-value="${escape(name)}"><span class="round">${icon(type)}</span>${escape(name)}</button>`;
    }
    function renderWifi() {
        const networks=['NovayaSetWiFi_2G_1786527','Sber','Sber_Guest','MyHome','Android Alex','Victor','MoyaLichnayaTochkaDostup…','net.36'];
        return `<section class="popup subpanel" aria-label="Wi-Fi">${subHeader('Wi‑Fi','wifiToggle',state.wifi)}${state.wifi?`${row(state.ssid,'wifi',true)}<button class="net-disclosure" data-action="networks" aria-expanded="${state.wifiExpanded}">Другие сети ${icon(state.wifiExpanded?'up':'down')}</button>${state.wifiExpanded?`<div class="network-list">${networks.filter(n=>n!==state.ssid).map(n=>row(n,'wifi')).join('')}</div>`:''}`:''}<button class="settings-link" data-action="wifiSettings">Настройки Wi‑Fi</button></section>`;
    }
    function renderBluetooth() {
        const devices=['MyPhone','TV','AirPods Pro','CarPlay','Music Go 3','Watch','OtherPhone','Visual','DesktopFrame'];
        return `<section class="popup subpanel" aria-label="Bluetooth">${subHeader('Bluetooth','bluetoothToggle',state.bluetooth)}${state.bluetooth?`${state.btDevice?row(state.btDevice,'bluetooth',true):''}<div class="network-list">${devices.filter(d=>d!==state.btDevice).map(d=>row(d,'bluetooth')).join('')}</div>`:''}<button class="settings-link" data-action="bluetoothSettings">Настройки Bluetooth</button></section>`;
    }
    function renderProfiles() {
        return `<section class="popup subpanel" aria-label="Режим питания">${subHeader('Режим питания')}<div role="radiogroup" aria-label="Режим питания">${['Энергосберегающий','Сбалансированный','Производительный'].map(name=>`<button class="profile-option" role="radio" aria-checked="${state.profile===name}" data-action="profileSelect" data-value="${name}"><span class="radio"></span>${name}</button>`).join('')}</div>${state.profile==='Производительный'?`<div class="power-info">${icon('info')}<span>В этом режиме устройство может нагреваться и шуметь</span></div>`:''}</section>`;
    }
    function calendarDays(year, month) {
        const offset=(new Date(year,month,1).getDay()+6)%7;
        const count=new Date(year,month+1,0).getDate();
        return Array.from({length:Math.ceil((offset+count)/7)*7},(_,i)=>new Date(year,month,i-offset+1));
    }
    function renderCalendar() {
        const month=new Intl.DateTimeFormat('ru-RU',{month:'long',year:'numeric'}).format(new Date(state.year,state.month,1)).replace(/\s*г\.$/,'');
        const monthLabel=month[0].toUpperCase()+month.slice(1);
        return `<section class="popup calendar" aria-label="Календарь"><div class="date-heading"><strong>Четверг, 10 сентября</strong><span>Встреч пока нет</span></div><div class="calendar-sheet"><div class="month-heading"><button data-action="monthPrev" aria-label="Предыдущий месяц">${icon('left')}</button><strong>${monthLabel}</strong><button data-action="monthNext" aria-label="Следующий месяц">${icon('right')}</button></div><div class="calendar-grid">${['пн','вт','ср','чт','пт','сб','вс'].map(x=>`<span class="weekday">${x}</span>`).join('')}${calendarDays(state.year,state.month).map(date=>{const outside=date.getMonth()!==state.month;const today=date.getFullYear()===2026&&date.getMonth()===8&&date.getDate()===10;const past=date<new Date(2026,8,10);const key=[date.getFullYear(),date.getMonth(),date.getDate()].join('-');return `<button class="calendar-day ${outside?'outside':''} ${past?'past':''} ${today?'today':''} ${state.selectedDay===key?'selected':''}" data-action="date" data-value="${key}" aria-label="${new Intl.DateTimeFormat('ru-RU',{day:'numeric',month:'long',year:'numeric'}).format(date)}" ${today?'aria-current="date"':''}>${date.getDate()}</button>`;}).join('')}</div></div></section>`;
    }
    const localDocuments = [
        ['SberDecision (преза).pdf','11 июня 2026 · 14 Мб','filePdf'],
        ['Должностная (Сбер)','5 апр. 2026 · 120 Кб','fileWord'],
        ['KV Сбера.pptx','20 янв. 2026 · 3.5 Мб','filePowerpoint'],
        ['Лого Сбер.png','24 дек. 2025 · 1.3 Мб','fileImage'],
        ['Сбербанкиада.xlsx','14 янв. 2025 · 29 Кб','fileExcel'],
        ['Сбер.txt','11 янв. 2025 · 230 Кб','file']
    ];
    const notices = [
        ['Срок действия PIN истёк','Обновите сертификат PIN в домене Sigma','2 часа назад','settings'],
        ['Почта','Почтовый ящик почти заполнен. Удалите часть писем или отправьте в архив','Вчера в 14:52','mail'],
        ['Доступ к ресурсам ограничен','Для доступа к внешним ресурсам оформите заявку в Друг','7 сент. в 09:43','settings']
    ];
    function searchFooter(input=false) {
        return `<div class="oska-footer">${input?'<input id="localQuery" type="search" aria-label="Поиск приложений и документов" placeholder="Найду документ или приложение" autocomplete="off">':'<button class="oska-avatar" data-action="closeNotifications" aria-label="Закрыть уведомления"></button><button class="search-button" data-action="localSearch">Найду документ или приложение</button><span class="keyboard-label">RU</span>'}</div>`;
    }
    function renderLocalSearch() {
        return `<section class="popup local-search" aria-label="Локальный поиск"><div id="localResults" class="local-results"></div>${searchFooter(true)}</section>`;
    }
    function renderLocalResults() {
        const normalize=value=>value.toLocaleLowerCase('ru').replaceAll('sber','сбер');
        const query=normalize(state.localQuery.trim());
        const apps=['browser','chat','docs','boost'].filter(id=>normalize(appsById[id].name).includes(query));
        const docs=localDocuments.filter(d=>normalize(d[0]).includes(query));
        $('localResults').innerHTML=apps.length||docs.length ? `<h2>Приложения</h2><div class="local-apps">${apps.map(id=>`<button data-action="app" data-id="${id}">${appIcon(id,64)}<span>${escape(appsById[id].name)}</span></button>`).join('')}</div><h2 class="documents-heading">Документы</h2><div class="document-list">${docs.map(([name,meta,i])=>`<button class="document-result" data-action="document" data-value="${escape(name)}"><img src="assets/icons/${i}.svg" width="24" height="24" alt=""><span><strong>${escape(name)}</strong><small>${meta}</small></span>${icon('right')}</button>`).join('')}</div>` : '<p class="local-empty">Ничего не найдено</p>';
    }
    function renderNotifications() {
        return `<section class="popup notifications-list" aria-label="Уведомления"><div class="notices-header"><strong>Уведомления <span>${state.noticesCleared?0:notices.length}</span></strong><button data-action="clearNotices">Очистить</button></div><div class="notices">${state.noticesCleared?'<p class="local-empty">Уведомлений пока нет</p>':notices.map(([title,text,time,i])=>`<article class="notice"><span class="notice-icon">${i==='mail'?appIcon('mail',24):icon(i)}</span><div><h3>${title}</h3><p>${text}</p></div><time>${time}</time></article>`).join('')}</div>${searchFooter()}</section>`;
    }
    function openLauncher(query='', trigger) {
        closeTop(false); state.powerMenu=false; state.launcher=true; state.query=query; state.page=0;
        lastTrigger=trigger||document.activeElement;
        $('launcher').hidden=false; $('panel').hidden=true;
        $('launcher').innerHTML='<div id="launchResults"></div><div id="launchPages" class="pages"></div><label class="launch-search"><span class="oska-avatar" aria-hidden="true"></span><input id="launchQuery" type="search" aria-label="Поиск приложений" placeholder="Какое приложение найти?" autocomplete="off"></label>';
        $('launchQuery').value=query;
        $('launchQuery').addEventListener('input', e=>{state.query=e.target.value;state.page=0;renderLaunchResults();});
        renderLaunchResults(); $('launchQuery').focus();
    }
    function renderLaunchResults() {
        const query=state.query.trim().toLocaleLowerCase('ru');
        const normalize=value=>value.toLocaleLowerCase('ru').replaceAll('sber','сбер');
        const found=appData.filter(a=>normalize(a.name).includes(normalize(query)));
        if(normalize(query)==='сбер') {
            const referenceOrder=['browser','online','chat','docs','space','boost','design'];
            found.sort((a,b)=>referenceOrder.indexOf(a.id)-referenceOrder.indexOf(b.id));
        }
        const pages=Math.max(1,Math.ceil(found.length/32)); state.page=Math.min(state.page,pages-1);
        const visible=found.slice(state.page*32,(state.page+1)*32);
        $('launchResults').innerHTML=visible.length?`<div class="launch-grid" style="grid-template-columns:repeat(${Math.min(8,visible.length)},168px)">${visible.map(a=>`<button class="launch-app" data-action="app" data-id="${a.id}">${appIcon(a.id,120)}<span class="name">${escape(a.name)}</span></button>`).join('')}</div>`:'<p class="no-results">Ничего не найдено</p>';
        $('launchPages').innerHTML=Array.from({length:pages},(_,p)=>`<button class="page-dot ${p===state.page?'active':''}" data-action="page" data-page="${p}" aria-label="Страница ${p+1}" ${p===state.page?'aria-current="page"':''}></button>`).join('');
        $('launchPages').hidden=pages===1;
        $('launchQuery').parentElement.classList.toggle('filled',query.length>0);
        setReference(!query?'launchpad-open.png':!found.length?'launchpad-search-empty.png':state.notification?'launchpad-search-notification.png':'launchpad-search.png');
    }
    function launchApp(id) {
        const app=appsById[id]; if(!app) return;
        state.running[id]=Math.max(1,state.running[id]||0);closeTop(false);renderApps();
        $('appWindow').innerHTML=`<section class="mock-window" aria-label="${escape(app.name)}"><div class="window-heading"><span>${escape(app.name)}</span><button data-action="windowClose" data-id="${id}" aria-label="Закрыть окно">×</button></div><div class="window-content"><h2>${escape(app.name)}</h2><p>Демонстрационное окно приложения.</p></div></section>`;
        $('appWindow').hidden=false;
    }
    function openSettings(label='Настройки оболочки') {
        closeTop(false);
        $('appWindow').innerHTML=`<section class="mock-window" aria-label="${label}"><div class="window-heading"><span>${label}</span><button data-action="windowClose" aria-label="Закрыть окно">×</button></div><div class="window-content"><h2>${label}</h2><p>Оформление</p><button data-action="dark">${state.dark?'Светлая':'Тёмная'} тема</button><p>Изменения применяются только к мокапу.</p></div></section>`;
        $('appWindow').hidden=false;
    }
    function confirmSession(command) {
        $('confirmation').innerHTML=`<div class="confirm-veil"><section class="confirm-card" role="dialog" aria-modal="true" aria-labelledby="confirmTitle"><h2 id="confirmTitle">${escape(command)}?</h2><p>Это демонстрация действия в мокапе.</p><div class="buttons"><button data-action="cancelSession">Отмена</button><button class="primary" data-action="confirmSession" data-command="${escape(command)}">Продолжить</button></div></section></div>`;
        $('confirmation').hidden=false;
        $('confirmation').querySelector('button').focus();
    }
    function applyScenario(name) {
        state.powerMenu=false;closeTop(false);state.appsMode='desktop';$('appWindow').hidden=true;
        const modes={desktop:'desktop',empty:'empty',icons40:'icons40',icons32:'icons32',unread:'unread',overflow:'overflow',overflowOpen:'overflowOpen'};
        const refs={desktop:'applications-pinned-running.png',empty:'applications-empty.png',icons40:'applications-icons-40px.png',icons32:'applications-icons-32px.png',unread:'applications-unread-count.png',overflow:'applications-overflow-count.png',overflowOpen:'applications-overflow-open.png'};
        if(!(name in modes)) state.appsMode='empty';
        if(name in modes){state.appsMode=modes[name];setReference(refs[name]);}
        else if(['sber','power'].includes(name)){state.popup='sber';state.powerMenu=name==='power';syncPopupReference();}
        else if(name==='quick'){state.popup='quick';state.bluetooth=state.dark;state.notifications=state.dark;state.btDevice=state.dark?'AirPods Pro':'';syncPopupReference();}
        else if(['wifi','wifiList','wifiOff'].includes(name)){state.popup='wifi';state.wifi=name!=='wifiOff';state.wifiExpanded=name==='wifiList';syncPopupReference();}
        else if(['bluetooth','bluetoothConnected','bluetoothOff'].includes(name)){state.popup='bluetooth';state.bluetooth=name!=='bluetoothOff';state.btDevice=name==='bluetoothConnected'?'AirPods Pro':'';syncPopupReference();}
        else if(['balanced','saving','performance'].includes(name)){state.popup='profile';state.profile=name==='saving'?'Энергосберегающий':name==='performance'?'Производительный':'Сбалансированный';syncPopupReference();}
        else if(name==='localSearch'){state.popup='localSearch';state.localQuery='сбер';syncPopupReference();}
        else if(name==='notificationsList'){state.popup='notificationsList';state.noticesCleared=false;syncPopupReference();}
        else if(name==='calendar'){state.popup='calendar';state.year=2026;state.month=8;syncPopupReference();}
        else if(['launcher','search','noResults','notification'].includes(name)){
            openLauncher(name==='launcher'?'':name==='noResults'?'лмвртуоцаимушатмы':'сбер');
            state.notification=name==='notification';
            if(state.notification) { renderLaunchResults(); message('Разряжаюсь. Подключите зарядку',true); }
        }
        renderApps();renderPopup();updateExpanded();
    }
    $('sberButton').innerHTML='<span class="button-face">'+icon('sber')+'</span>'; $('quickButton').innerHTML=icon('controls');
    $('sberButton').addEventListener('click',e=>openPopup('sber',e.currentTarget));
    $('quickButton').addEventListener('click',e=>openPopup('quick',e.currentTarget));
    $('calendarButton').addEventListener('click',e=>openPopup('calendar',e.currentTarget));
    $('searchButton').addEventListener('click',e=>openPopup('localSearch',e.currentTarget));
    $('notificationsButton').addEventListener('click',e=>openPopup('notificationsList',e.currentTarget));
    const targets=[['files',0,0],['jazz',1,0],['files',2,0],['browser',0,1],['files',1,1],['varm',2,1],['usersoft',0,2],['chat',1,2],['files',2,2],['pixso',0,3],['disk',1,3],['docs',2,3],['files',0,4],['files',1,4],['vpn',0,5],['mail',1,5],['pulse',0,6],['files',1,6],['files',0,7],['python',1,7]];
    $('desktopTargets').innerHTML=targets.map(([id,col,rowIndex])=>`<button class="desktop-target" data-action="app" data-id="${id}" style="left:${16+col*112}px;top:${20+rowIndex*120}px" aria-label="${escape(appsById[id].name)}"></button>`).join('');
    document.addEventListener('input',e=>{
        if (e.target.id==='localQuery') { state.localQuery=e.target.value; renderLocalResults(); }
        if (e.target.matches('[data-setting]')) { state[e.target.dataset.setting]=Number(e.target.value);e.target.style.setProperty('--fill',e.target.value+'%'); }
    });
    document.addEventListener('click',e=>{
        const button=e.target.closest('[data-action]');
        if(!button){
            if(e.target.closest('.prototype-tools')) return;
            if(state.launcher && e.target.closest('#launcher') && !e.target.closest('.launch-search,.launch-grid,.pages')) closeTop();
            else if(state.popup && !e.target.closest('.popup,.power-menu,.system,.sber,.oska')) closeTop();
            else if(state.appsMode==='overflowOpen' && !e.target.closest('#applications')) closeTop();
            return;
        }
        const action=button.dataset.action;
        if(state.powerMenu && button.closest('.sber-menu') && action!=='power') {
            state.powerMenu=false;renderPopup();syncPopupReference();return;
        }
        if(action==='localSearch') return openPopup('localSearch',button);
        if(action==='closeNotifications') return closeTop();
        if(action==='clearNotices'){state.noticesCleared=true;closeTop();return;}
        if(action==='document'){closeTop(false);message(`${button.dataset.value}: демонстрация открытия документа`);return;}
        if(action==='launchpad') return openLauncher('',button);
        if(action==='app') return launchApp(button.dataset.id);
        if(action==='overflow'){state.appsMode='overflowOpen';lastTrigger=button;renderApps();setReference('applications-overflow-open.png');return;}
        if(action==='collapse'){state.powerMenu=false;closeTop();setReference('button-sber-sber-button-default.png');return;}
        if(action==='settings') return openSettings();
        if(action==='terminal') {closeTop(false);$('appWindow').innerHTML='<section class="mock-window"><div class="window-heading"><span>Терминал</span><button data-action="windowClose" aria-label="Закрыть терминал">×</button></div><div class="terminal-content">alexey@sberos:~$ <br><small>Демонстрационный терминал</small></div></section>';$('appWindow').hidden=false;return;}
        if(action==='power'){state.powerMenu=!state.powerMenu;renderPopup();syncPopupReference();return;}
        if(action==='session') return confirmSession(button.dataset.command);
        if(action==='cancelSession'){$('confirmation').hidden=true;return;}
        if(action==='confirmSession'){$('confirmation').hidden=true;state.powerMenu=false;closeTop(false);message(`${button.dataset.command}: действие показано в мокапе`);return;}
        if(action==='windowClose'){if(button.dataset.id){state.running[button.dataset.id]=0;renderApps();}$('appWindow').hidden=true;return;}
        if(['wifi','bluetooth','profile'].includes(action)){state.popup=action;renderPopup();syncPopupReference();return;}
        if(action==='back'){state.popup='quick';renderPopup();syncPopupReference();return;}
        if(action==='networks'){state.wifiExpanded=!state.wifiExpanded;renderPopup();syncPopupReference();return;}
        if(action==='wifiToggle'){state.wifi=!state.wifi;renderPopup();syncPopupReference();if(!state.wifi)message('Отвалился Wi‑Fi');return;}
        if(action==='bluetoothToggle'){state.bluetooth=!state.bluetooth;renderPopup();syncPopupReference();return;}
        if(action==='network'){state.ssid=button.dataset.value;renderPopup();return;}
        if(action==='device'){state.btDevice=state.btDevice===button.dataset.value?'':button.dataset.value;renderPopup();syncPopupReference();return;}
        if(action==='profileSelect'){state.profile=button.dataset.value;renderPopup();syncPopupReference();return;}
        if(action==='wifiSettings') return openSettings('Настройки Wi‑Fi');
        if(action==='bluetoothSettings') return openSettings('Настройки Bluetooth');
        if(action==='dark'){setDark(!state.dark);return;}
        if(['vpn','notifications','night','airplane'].includes(action)){state[action]=!state[action];if(action==='airplane'&&state.airplane){state.wifi=false;state.bluetooth=false;}renderPopup();return;}
        if(action==='monthPrev'||action==='monthNext'){const date=new Date(state.year,state.month+(action==='monthNext'?1:-1),1);state.year=date.getFullYear();state.month=date.getMonth();state.selectedDay=null;renderPopup();return;}
        if(action==='date'){state.selectedDay=button.dataset.value;renderPopup();return;}
        if(action==='page'){state.page=Number(button.dataset.page);renderLaunchResults();return;}
        if(action==='capture'){closeTop(false);message('Создание снимка экрана · демонстрация');return;}
        if(action==='battery') message('Заряд батареи: 64%');
    });
    document.addEventListener('keydown',e=>{
        if(e.key==='Escape'){e.preventDefault();closeTop();return;}
        if(e.key.toLowerCase()==='h'&&!e.target.matches('input,select,textarea')){document.querySelector('.prototype-tools').hidden=!document.querySelector('.prototype-tools').hidden;}
        if(state.popup==='sber'&&!state.powerMenu&&['ArrowDown','ArrowUp','Tab'].includes(e.key)){
            const items=[...document.querySelectorAll('.sber-menu .menu-icon')];
            const index=items.indexOf(document.activeElement);const backwards=e.key==='ArrowUp'||e.shiftKey;
            e.preventDefault();items[index<0?(backwards?items.length-1:0):(index+(backwards?-1:1)+items.length)%items.length].focus();
        }
        if(state.popup==='localSearch'&&e.key==='Enter'&&e.target.id==='localQuery')document.querySelector('.local-apps button,.document-result')?.click();
        if(state.launcher&&e.key==='Enter'&&e.target.id==='launchQuery')document.querySelector('.launch-app')?.click();
    });
    $('toolsButton').addEventListener('click',()=>{$('toolsBody').hidden=!$('toolsBody').hidden;$('toolsButton').setAttribute('aria-expanded',String(!$('toolsBody').hidden));});
    $('scenario').addEventListener('change',e=>applyScenario(e.target.value));
    $('themeButton').addEventListener('click',()=>setDark(!state.dark));
    $('surfaceButton').addEventListener('click',()=>{state.opaque=!state.opaque;syncTheme();});
    $('compareButton').addEventListener('click',()=>{state.comparison=!state.comparison;$('referenceLayer').hidden=!state.comparison;$('comparisonLine').hidden=!state.comparison;$('compareControls').hidden=!state.comparison;$('compareButton').setAttribute('aria-pressed',String(state.comparison));});
    $('comparisonRange').addEventListener('input',e=>{$('referenceLayer').style.clipPath=`inset(0 0 0 ${e.target.value}%)`;$('comparisonLine').style.left=e.target.value+'%';});
    $('scaleButton').addEventListener('click',()=>{state.nativeScale=!state.nativeScale;$('scaleButton').textContent=state.nativeScale?'Вписать в окно':'Масштаб 1:1';updateScale();});
    window.addEventListener('resize',updateScale);
    syncTheme();renderApps();setReference('applications-pinned-running.png');updateScale();
})();

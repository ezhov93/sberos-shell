(() => {
    'use strict';
    const $ = id => document.getElementById(id);
    const artwork = {
        entry: '../../sources/login/svg/sddm-entry.svg',
        password: '../../sources/login/svg/sddm-lock-enter-password.svg',
        welcome: '../../sources/login/svg/hello-loader.svg'
    };
    const state = { screen: 'entry', flow: 'login', user: null, timer: null };

    function setScreen(screen, message = '') {
        clearTimeout(state.timer);
        state.screen = screen;
        $('screenArtwork').hidden = screen === 'desktop';
        $('screenArtwork').src = artwork[screen] || artwork.entry;
        $('screenArtwork').alt = screen === 'entry'
            ? 'Экран входа SberOS'
            : screen === 'password'
                ? state.flow === 'lock' ? 'Экран блокировки с запросом пароля' : 'Ввод пароля для входа в SberOS'
                : screen === 'welcome' ? 'Приветственный экран SberOS' : '';
        $('entryTargets').hidden = screen !== 'entry';
        $('passwordForm').hidden = screen !== 'password';
        $('desktopFrame').hidden = screen !== 'desktop';
        $('screenNotice').hidden = !message;
        $('screenNotice').textContent = message;
        $('submitPassword').hidden = screen !== 'password';
        $('continueDesktop').hidden = screen !== 'welcome';
        $('lockButton').hidden = screen !== 'desktop';
        $('logoutButton').hidden = screen !== 'desktop';
        $('passwordHint').hidden = screen !== 'password';

        const titles = {
            entry: 'Экран входа',
            password: state.flow === 'lock' ? 'Разблокировка сессии' : 'Ввод пароля',
            welcome: 'Подготовка рабочего стола',
            desktop: 'Рабочий стол'
        };
        const descriptions = {
            entry: 'Выберите одного из двух пользователей на макете, чтобы перейти к вводу пароля.',
            password: state.flow === 'lock'
                ? 'Введите любой непустой пароль и разблокируйте демонстрационную сессию.'
                : 'Введите любой непустой пароль, чтобы показать успешный вход в демо.',
            welcome: 'Рабочая среда готовится. Мок автоматически откроет рабочий стол через несколько секунд.',
            desktop: 'Для проверки блокировки нажмите «Заблокировать». Возврат из блокировки восстановит этот экран.'
        };
        $('stateLabel').textContent = titles[screen];
        $('stateDescription').textContent = descriptions[screen];

        if (screen === 'password') {
            $('passwordInput').value = '';
            $('passwordInput').focus();
        } else if (screen === 'welcome') {
            state.timer = setTimeout(showDesktop, 2400);
        }
    }

    function showDesktop() {
        setScreen('desktop', 'Демонстрационный рабочий стол готов');
    }

    function acceptPassword() {
        if (!$('passwordInput').value.trim()) {
            $('screenNotice').textContent = 'Введите любой непустой пароль для продолжения демо.';
            $('screenNotice').hidden = false;
            $('passwordInput').focus();
            return;
        }
        $('passwordInput').value = '';
        if (state.flow === 'lock') {
            setScreen('desktop', 'Сессия разблокирована · рабочий стол восстановлен');
            return;
        }
        setScreen('welcome', 'Вход выполнен в демонстрационном режиме');
    }

    function reset() {
        state.flow = 'login';
        state.user = null;
        setScreen('entry');
    }

    $('entryTargets').addEventListener('click', event => {
        const target = event.target.closest('[data-user], [data-action="other-user"]');
        if (!target) return;
        if (target.dataset.action === 'other-user') {
            $('screenNotice').textContent = 'Другой пользователь показан как элемент макета; этот маршрут в демо не раскрывается.';
            $('screenNotice').hidden = false;
            return;
        }
        state.user = target.dataset.user;
        state.flow = 'login';
        setScreen('password', 'Выбран пользователь · демонстрационный режим');
    });
    $('passwordForm').addEventListener('submit', event => {
        event.preventDefault();
        acceptPassword();
    });
    $('submitPassword').addEventListener('click', acceptPassword);
    $('continueDesktop').addEventListener('click', showDesktop);
    $('lockButton').addEventListener('click', () => {
        state.flow = 'lock';
        setScreen('password', 'Сессия заблокирована · введите пароль для демо-разблокировки');
    });
    $('logoutButton').addEventListener('click', reset);
    $('resetButton').addEventListener('click', reset);

    const stage = $('screenStage');
    const updateDesktopScale = () => {
        stage.style.setProperty('--desktop-scale', String(stage.clientWidth / 1920));
    };
    new ResizeObserver(updateDesktopScale).observe(stage);
    updateDesktopScale();
})();

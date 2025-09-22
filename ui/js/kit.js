// Kits UI logic
// Listens to NUI messages from cl_kits.lua and renders a modal UI

(function() {
    let kitsData = [];
    let kitTimers = {};
    let playerRole = "user";
    let playerRoles = null; // optional array
    let countdownInterval = null;

    const KIT_ICONS = {
        dailykit: 'fa-calendar-day',
        booster: 'fa-rocket',
        starterkit: 'fa-seedling',
        combat: 'fa-crosshairs',
        vip: 'fa-crown',
        'vip+': 'fa-crown',
        mvp: 'fa-trophy',
        boss: 'fa-chess-king'
    };

    function createTitleWithIcon(kitKey) {
        const wrapper = document.createElement('div');
        wrapper.className = 'kit-title';
        const iconClass = KIT_ICONS[kitKey && kitKey.toLowerCase()] || 'fa-box-open';
        const icon = document.createElement('i');
        icon.className = 'fa-solid ' + iconClass + ' kit-icon';
        const label = document.createElement('span');
        label.textContent = (kitKey || '').toUpperCase();
        wrapper.appendChild(icon);
        wrapper.appendChild(label);
        return wrapper;
    }

    function getItemRarity(labelOrName) {
        if (!labelOrName) return null;
        const txt = String(labelOrName).toLowerCase();
        // Epic (purple)
        if (txt.includes('marksman rifle') || txt.includes('compact launcher')) {
            return 'rar-epic';
        }
        // Legendary (gold)
        if (txt === 'rpg' || txt.includes('rocket-propelled grenade') || txt.includes('weapon_rpg')) {
            return 'rar-legendary';
        }
        return null;
    }

    function hasAccess(roles) {
        if (!Array.isArray(roles)) return false;
        return roles.indexOf(playerRole) !== -1 ||
            (Array.isArray(playerRoles) && playerRoles.some(r => roles.indexOf(r) !== -1));
    }

    function isAlwaysOpen(kitKey) {
        const key = (kitKey || '').toLowerCase();
        return key === 'daily' || key === 'combat';
    }

    function secondsToClock(seconds) {
        const s = Math.max(0, Math.floor(seconds));
        const h = String(Math.floor(s / 3600)).padStart(2, '0');
        const m = String(Math.floor((s % 3600) / 60)).padStart(2, '0');
        const sec = String(s % 60).padStart(2, '0');
        return h + ":" + m + ":" + sec;
    }

    function nowUnix() {
        return Math.floor(Date.now() / 1000);
    }

    function renderKits() {
        const grid = document.getElementById('kits-grid');
        if (!grid) return;
        grid.innerHTML = '';

        kitsData.forEach(kit => {
            const canUse = isAlwaysOpen(kit.kit) || hasAccess(kit.role);
            const endTime = kitTimers[kit.kit];
            let state = 'open';
            let cooldownText = '';
            if (!canUse) {
                state = 'locked';
            } else if (endTime && endTime > nowUnix()) {
                state = 'cooldown';
                cooldownText = secondsToClock(endTime - nowUnix());
            }

            const card = document.createElement('div');
            card.className = 'kit-card ' + state;
            card.dataset.kit = kit.kit;
            if (endTime) card.dataset.endTime = String(endTime);

            const title = createTitleWithIcon(kit.kit);

            const items = document.createElement('div');
            items.className = 'kit-items';
            // Force visible scrollbar for kits with many items: VIP, VIP+, MVP, BOSS
            const kitKey = (kit.kit || '').toLowerCase();
            if (kitKey === 'vip' || kitKey === 'vip+' || kitKey === 'mvp' || kitKey === 'boss') {
                items.classList.add('force-scroll');
                items.style.overflowY = 'scroll';
            }
            if (Array.isArray(kit.listItems)) {
                kit.listItems.forEach(it => {
                    const itEl = document.createElement('div');
                    itEl.className = 'kit-item';
                    const display = (it.label || it.name);
                    const rarity = getItemRarity(display || it.name);
                    if (rarity) itEl.classList.add(rarity);
                    itEl.textContent = display + ' x' + (it.count || 1);
                    items.appendChild(itEl);
                });
            }

            const action = document.createElement('button');
            action.className = 'kit-action';
            if (state === 'locked') {
                action.innerHTML = '<i class="fa-solid fa-lock"></i> Locked';
                action.disabled = true;
            } else if (state === 'cooldown') {
                action.textContent = cooldownText;
                action.disabled = true;
            } else {
                action.textContent = 'Open kit';
                action.onclick = function() {
                    // Claim the kit
                    try {
                        fetch('https://gamemode/claimKit', {
                            method: 'POST',
                            body: JSON.stringify({ kitName: kit.kit })
                        });
                    } catch (e) {}
                    // Also use NUI callback route to match cl_kits RegisterNUICallback
                    try {
                        $.post('https://gamemode/claimKit', JSON.stringify({ kitName: kit.kit }));
                    } catch (e) {}
                };
            }

            card.appendChild(title);
            card.appendChild(items);
            // Add custom scroll indicator (always visible when scrollable)
            const indicator = document.createElement('div');
            indicator.className = 'scroll-indicator';
            const thumb = document.createElement('div');
            thumb.className = 'scroll-thumb';
            indicator.appendChild(thumb);

            card.appendChild(action);
            grid.appendChild(card);

            // Badge for specific kits: VIP, VIP+, MVP, BOSS
            const badgeKey = (kit.kit || '').toLowerCase();
            if (badgeKey === 'vip' || badgeKey === 'vip+' || badgeKey === 'mvp' || badgeKey === 'boss') {
                const badge = document.createElement('div');
                badge.className = 'kit-badge';
                badge.textContent = 'EVERY 4H';
                card.appendChild(badge);
            }
            if (badgeKey === 'combat') {
                const badge = document.createElement('div');
                badge.className = 'kit-badge';
                badge.textContent = 'EVERY 2H';
                card.appendChild(badge);
            }
            if (badgeKey === 'booster' || badgeKey === 'daily') {
                const badge = document.createElement('div');
                badge.className = 'kit-badge';
                badge.textContent = 'EVERY 24H';
                card.appendChild(badge);
            }

            // Toggle scroll hint if content overflows
            requestAnimationFrame(function() {
                if (items.scrollHeight > items.clientHeight + 2) {
                    items.classList.add('is-scrollable');
                    card.appendChild(indicator);
                    attachScrollIndicator(items, thumb, indicator);
                } else {
                    items.classList.remove('is-scrollable');
                }
            });
        });
    }

    function attachScrollIndicator(scrollEl, thumbEl, trackEl) {
        function updateThumb() {
            const total = scrollEl.scrollHeight;
            const view = scrollEl.clientHeight;
            const top = scrollEl.scrollTop;
            if (total <= view) {
                thumbEl.style.height = '0px';
                thumbEl.style.transform = 'translateY(0)';
                return;
            }
            const ratio = view / total;
            const trackHeight = trackEl ? trackEl.clientHeight : scrollEl.clientHeight; // position relative to visible indicator track
            const thumbHeight = Math.max(20, Math.floor(trackHeight * ratio));
            const maxScroll = total - view;
            const progress = top / maxScroll; // 0..1
            const maxTranslate = trackHeight - thumbHeight;
            const translateY = Math.floor(maxTranslate * progress);
            thumbEl.style.height = thumbHeight + 'px';
            thumbEl.style.transform = 'translateY(' + translateY + 'px)';
        }

        scrollEl.addEventListener('scroll', updateThumb);
        window.addEventListener('resize', updateThumb);
        updateThumb();
    }

    function openMenu(data) {
        kitsData = data.kitsData || [];
        kitTimers = data.kitTimers || {};
        playerRole = data.playerRole || 'user';
        playerRoles = Array.isArray(data.playerRoles) ? data.playerRoles : null;
        const overlay = document.querySelector('.kits-overlay');
        if (!overlay) return;
        overlay.style.display = 'flex';
        renderKits();

        // Start real-time countdown updater
        if (countdownInterval) clearInterval(countdownInterval);
        countdownInterval = setInterval(function() {
            const cards = document.querySelectorAll('.kit-card.cooldown');
            const now = nowUnix();
            cards.forEach(card => {
                const kitName = card.dataset.kit;
                const endTime = Number(card.dataset.endTime || kitTimers[kitName] || 0);
                const btn = card.querySelector('.kit-action');
                if (!btn) return;
                const remaining = endTime - now;
                if (remaining > 0) {
                    btn.textContent = secondsToClock(remaining);
                } else {
                    // Switch to open state when cooldown ends
                    card.classList.remove('cooldown');
                    card.classList.add('open');
                    delete card.dataset.endTime;
                    btn.textContent = 'Open kit';
                    btn.disabled = false;
                    btn.onclick = function() {
                        try { fetch('https://gamemode/claimKit', { method: 'POST', body: JSON.stringify({ kitName }) }); } catch (e) {}
                        try { $.post('https://gamemode/claimKit', JSON.stringify({ kitName })); } catch (e) {}
                    };
                }
            });
        }, 1000);
    }

    function updateTimer(kitName, newTime) {
        kitTimers[kitName] = newTime;
        renderKits();
    }

    function closeMenu() {
        const overlay = document.querySelector('.kits-overlay');
        if (!overlay) return;
        overlay.style.display = 'none';
        if (countdownInterval) {
            clearInterval(countdownInterval);
            countdownInterval = null;
        }
    }

    window.addEventListener('message', function(event) {
        const data = event.data || {};
        if (data.type === 'openKitsMenu') {
            openMenu(data);
        } else if (data.type === 'updateKitTimer') {
            updateTimer(data.kitName, data.newTime);
        } else if (data.type === 'closeKitsMenu') {
            closeMenu();
        }
    });

    document.addEventListener('DOMContentLoaded', function() {
        const closeBtn = document.getElementById('kits-close-btn');
        if (closeBtn) {
            closeBtn.addEventListener('click', function() {
                // Immediately hide locally
                closeMenu();
                // Inform game to release focus
                try { fetch('https://gamemode/closeKitMenu', { method: 'POST', body: JSON.stringify({}) }); } catch (e) {}
                try { $.post('https://gamemode/closeKitMenu', JSON.stringify({})); } catch (e) {}
            });
        }
        // Close on Escape
        document.addEventListener('keydown', function(ev) {
            const overlay = document.querySelector('.kits-overlay');
            if (!overlay || overlay.style.display === 'none') return;
            if (ev.key === 'Escape') {
                closeMenu();
                try { fetch('https://gamemode/closeKitMenu', { method: 'POST', body: JSON.stringify({}) }); } catch (e) {}
                try { $.post('https://gamemode/closeKitMenu', JSON.stringify({})); } catch (e) {}
            }
        });
    });
})();



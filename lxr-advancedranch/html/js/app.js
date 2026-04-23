/*
    ██╗     ██╗  ██╗██████╗        ██████╗  █████╗ ███╗   ██╗ ██████╗██╗  ██╗
    🐺 Advanced Ranch System - NUI Logic
    © 2026 iBoss21 / The Lux Empire | wolves.land

    Vanilla JS, no frameworks. Tab routing, data pull via NUI callbacks,
    ESC-close guarantee, activity feed, bid/contract interactions.
    No <form> tags — all actions via onClick handlers.
*/

'use strict';

const RanchUI = (function () {

    const RES_NAME = (typeof GetParentResourceName === 'function')
        ? GetParentResourceName() : 'lxr-advancedranch';

    const state = {
        open: false,
        ranchId: null,
        tab: 'dashboard',
        locale: {},
        theme: {},
        feedMax: 25,
        feed: [],
        data: {
            dashboard: null, livestock: null, workforce: null,
            economy: null, environment: null, progression: null, auction: null
        },
        selectedAnimalId: null
    };

    // ═══════════════════════════════════════════════════════════════════
    // 🔧 POST TO CLIENT LUA
    // ═══════════════════════════════════════════════════════════════════
    function post(endpoint, payload) {
        return fetch(`https://${RES_NAME}/${endpoint}`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json; charset=UTF-8' },
            body: JSON.stringify(payload || {})
        }).catch(() => null);
    }

    // ═══════════════════════════════════════════════════════════════════
    // 🔧 TOAST
    // ═══════════════════════════════════════════════════════════════════
    function toast(msg, kind, ttl) {
        const rail = document.getElementById('toast-rail');
        if (!rail) return;
        const el = document.createElement('div');
        el.className = 'toast' + (kind ? ' ' + kind : '');
        el.textContent = msg;
        rail.appendChild(el);
        setTimeout(() => {
            el.style.opacity = 0;
            setTimeout(() => el.remove(), 240);
        }, ttl || 3500);
    }

    // ═══════════════════════════════════════════════════════════════════
    // 🔧 OPEN / CLOSE
    // ═══════════════════════════════════════════════════════════════════
    function open(payload) {
        state.open = true;
        state.ranchId = payload.ranchId || null;
        state.locale  = payload.locale || {};
        state.theme   = payload.theme || {};
        state.feedMax = payload.feedMaxEntries || 25;
        state.tab     = payload.defaultTab || 'dashboard';

        document.getElementById('app-root').classList.remove('hidden');
        switchTab(state.tab);
    }

    function close() {
        state.open = false;
        document.getElementById('app-root').classList.add('hidden');
        post('close', {});
    }

    // ═══════════════════════════════════════════════════════════════════
    // 🔧 TAB ROUTER
    // ═══════════════════════════════════════════════════════════════════
    function switchTab(tab) {
        state.tab = tab;
        document.querySelectorAll('.tab-btn').forEach(b => {
            b.classList.toggle('active', b.dataset.tab === tab);
        });
        document.querySelectorAll('.panel').forEach(p => {
            p.classList.toggle('active', p.dataset.panel === tab);
        });
        post('pullTab', { tab: tab });
    }

    // ═══════════════════════════════════════════════════════════════════
    // 🔧 DATA INGEST
    // ═══════════════════════════════════════════════════════════════════
    function onTabData(tab, data, err) {
        if (err) { toast('Error: ' + err, 'error'); return; }
        state.data[tab] = data;
        render(tab);
    }

    function onDelta(kind, payload) {
        if (kind === 'animalAdded' || kind === 'animalUpdated') {
            if (state.data.livestock) {
                const idx = state.data.livestock.findIndex(a => a.id === payload.id);
                if (idx >= 0) state.data.livestock[idx] = payload;
                else state.data.livestock.push(payload);
                if (state.tab === 'livestock') render('livestock');
            }
            appendFeed(kind === 'animalAdded'
                ? `Animal added — ${payload.species} "${payload.name}"`
                : `Animal updated — ${payload.name || payload.id}`);
        }
        else if (kind === 'animalRemoved') {
            if (state.data.livestock) {
                state.data.livestock = state.data.livestock.filter(a => a.id !== payload.id);
                if (state.tab === 'livestock') render('livestock');
            }
            appendFeed(`Animal removed`);
        }
        else if (kind === 'contractsRefreshed') {
            if (state.tab === 'economy') post('pullTab', { tab: 'economy' });
            appendFeed('Contract boards refreshed');
        }
        else if (kind === 'auctionCreated' || kind === 'auctionUpdated' || kind === 'auctionSettled') {
            if (state.tab === 'auction') post('pullTab', { tab: 'auction' });
            if (kind === 'auctionSettled') appendFeed(`Auction settled: ${payload.status}`);
        }
        else if (kind === 'xpGained') {
            appendFeed(`+${payload.amount} XP in ${payload.skill}`);
            if (state.tab === 'progression') post('pullTab', { tab: 'progression' });
        }
        else if (kind === 'achievement') {
            toast(`Achievement: ${payload.def.label}`, 'success', 5000);
            appendFeed(`Achievement — ${payload.def.label}`);
        }
    }

    function appendFeed(text) {
        const ts = new Date().toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
        state.feed.unshift({ ts: ts, text: text });
        if (state.feed.length > state.feedMax) state.feed.pop();
        if (state.tab === 'dashboard') renderFeed();
    }

    // ═══════════════════════════════════════════════════════════════════
    // 🔧 RENDERERS
    // ═══════════════════════════════════════════════════════════════════
    function render(tab) {
        if (tab === 'dashboard')     renderDashboard();
        else if (tab === 'livestock')   renderLivestock();
        else if (tab === 'workforce')   renderWorkforce();
        else if (tab === 'economy')     renderEconomy();
        else if (tab === 'environment') renderEnvironment();
        else if (tab === 'progression') renderProgression();
        else if (tab === 'auction')     renderAuction();
    }

    function setText(id, v) { const el = document.getElementById(id); if (el) el.textContent = v; }

    function renderHeader(env) {
        if (!env) return;
        setText('h-season',  env.season || '—');
        setText('h-weather', env.weather || '—');
        setText('h-temp',    (env.temp !== undefined ? env.temp + '°C' : '—'));
    }

    function renderDashboard() {
        const d = state.data.dashboard;
        if (!d) return;
        setText('dash-ranch-label', d.ranch && d.ranch.label || '—');
        setText('dash-tier',       d.tierLabel || '—');
        setText('dash-balance',    '$' + (d.balance || 0).toLocaleString());
        setText('dash-livestock',  d.livestock && d.livestock.total || 0);
        setText('dash-workers',    d.workers || 0);
        setText('dash-health',     (d.livestock && d.livestock.avgHealth !== undefined) ? (d.livestock.avgHealth + '%') : '—');
        setText('dash-season',     (d.environment && d.environment.season) || '—');
        renderHeader(d.environment);

        const sp = document.getElementById('dash-species');
        sp.innerHTML = '';
        if (d.livestock && d.livestock.counts) {
            Object.keys(d.livestock.counts).forEach(sk => {
                const cell = document.createElement('div');
                cell.className = 'species-cell';
                cell.innerHTML = `<span class="sp-label">${sk}</span><span class="sp-count">${d.livestock.counts[sk] || 0}</span>`;
                sp.appendChild(cell);
            });
        }

        // Seed feed from ledger
        if (d.ledger && d.ledger.length && state.feed.length === 0) {
            d.ledger.slice(0, state.feedMax).forEach(l => {
                const ts = new Date((l.ts || 0) * 1000).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
                state.feed.push({ ts: ts, text: `${l.kind || ''} — ${l.description || ''}` });
            });
        }
        renderFeed();
    }

    function renderFeed() {
        const ul = document.getElementById('feed-list');
        if (!ul) return;
        ul.innerHTML = '';
        state.feed.forEach(f => {
            const li = document.createElement('li');
            li.innerHTML = `<span class="ts">${f.ts}</span>${escapeHTML(f.text)}`;
            ul.appendChild(li);
        });
    }

    function renderLivestock() {
        const list = document.getElementById('ls-list');
        const detail = document.getElementById('ls-detail');
        if (state.selectedAnimalId) {
            list.classList.add('hidden');
            detail.classList.remove('hidden');
            renderAnimalDetail();
            return;
        }
        list.classList.remove('hidden');
        detail.classList.add('hidden');

        list.innerHTML = '';
        const animals = state.data.livestock || [];
        const q = (document.getElementById('ls-search').value || '').toLowerCase();
        const sp = document.getElementById('ls-filter-species').value || '';

        animals
            .filter(a => !sp || a.species === sp)
            .filter(a => !q || (a.name || '').toLowerCase().includes(q) ||
                         (a.species || '').toLowerCase().includes(q) ||
                         (a.traits || '').toLowerCase().includes(q))
            .forEach(a => {
                const row = document.createElement('div');
                row.className = 'ls-row';
                row.onclick = () => { state.selectedAnimalId = a.id; renderLivestock(); };
                const hp = a.health || 0;
                const hpClass = hp < 30 ? ' low' : '';
                row.innerHTML = `
                    <div class="ls-name">${escapeHTML(a.name || a.id)}</div>
                    <div class="ls-sub">${escapeHTML(a.species)} · ${escapeHTML(a.sex || '')} · age ${a.age_days || 0}d</div>
                    <div class="ls-bars">
                        ${bar('Health', hp, 'health' + hpClass)}
                        ${bar('Hunger', a.hunger || 0, 'hunger')}
                        ${bar('Thirst', a.thirst || 0, 'thirst')}
                    </div>
                `;
                list.appendChild(row);
            });
    }

    function renderAnimalDetail() {
        const animals = state.data.livestock || [];
        const a = animals.find(x => x.id === state.selectedAnimalId);
        if (!a) { state.selectedAnimalId = null; renderLivestock(); return; }
        setText('ld-name', a.name || a.id);
        const grid = document.getElementById('ld-grid');
        grid.innerHTML = `
            <div class="card"><div class="card-h">Species</div><div class="card-v">${escapeHTML(a.species)}</div></div>
            <div class="card"><div class="card-h">Sex</div><div class="card-v">${escapeHTML(a.sex || '—')}</div></div>
            <div class="card"><div class="card-h">Age</div><div class="card-v">${a.age_days || 0}d</div></div>
            <div class="card"><div class="card-h">Health</div><div class="card-v">${a.health || 0}%</div></div>
            <div class="card"><div class="card-h">Hunger</div><div class="card-v">${a.hunger || 0}</div></div>
            <div class="card"><div class="card-h">Thirst</div><div class="card-v">${a.thirst || 0}</div></div>
            <div class="card"><div class="card-h">Trust</div><div class="card-v">${a.trust || 0}</div></div>
            <div class="card"><div class="card-h">Bloodline</div><div class="card-v">${escapeHTML(a.bloodline || '—')}</div></div>
        `;
    }

    function bar(label, val, cls) {
        const pct = Math.max(0, Math.min(100, val));
        return `<div class="bar-wrap"><span class="bar-label">${label}</span>
                <div class="bar"><div class="bar-fill ${cls}" style="width:${pct}%"></div></div></div>`;
    }

    function renderWorkforce() {
        const roster = state.data.workforce || [];
        const el = document.getElementById('wf-roster');
        el.innerHTML = '';
        if (!roster.length) {
            el.innerHTML = '<div class="card" style="grid-column:1/-1;text-align:center;">No workers hired.</div>';
            return;
        }
        roster.forEach(w => {
            const card = document.createElement('div');
            card.className = 'worker-card';
            card.innerHTML = `
                <div class="worker-name">${escapeHTML(w.name || w.identifier)}</div>
                <div class="worker-role">${escapeHTML(w.role)}</div>
                <div class="worker-stats">
                    <div class="stat-cell"><div class="h">Morale</div><div class="v">${w.morale || 0}</div></div>
                    <div class="stat-cell"><div class="h">Fatigue</div><div class="v">${w.fatigue || 0}</div></div>
                </div>
            `;
            el.appendChild(card);
        });
    }

    function renderEconomy() {
        const d = state.data.economy;
        if (!d) return;

        const pg = document.getElementById('eco-prices');
        pg.innerHTML = '';
        Object.keys(d.prices || {}).forEach(k => {
            const c = document.createElement('div');
            c.className = 'price-cell';
            c.innerHTML = `<span class="good">${k}</span><span class="price">$${d.prices[k]}</span>`;
            pg.appendChild(c);
        });

        const ct = document.getElementById('eco-contracts');
        ct.innerHTML = '';
        (d.openContracts || []).forEach(c => {
            const row = document.createElement('div');
            row.className = 'contract-row';
            row.innerHTML = `
                <div class="ct-town">${escapeHTML(c.town)}</div>
                <div class="ct-body">${c.amount}× ${escapeHTML(c.good)} · deadline ${fmtDeadline(c.deadline)}</div>
                <div class="ct-reward">$${c.reward}</div>
                <button class="btn" data-cid="${escapeHTML(c.id)}">Accept</button>
            `;
            row.querySelector('button').onclick = () => post('acceptContract', { contractId: c.id });
            ct.appendChild(row);
        });

        const mc = document.getElementById('eco-mycontracts');
        mc.innerHTML = '';
        (d.myContracts || []).forEach(c => {
            const row = document.createElement('div');
            row.className = 'contract-row';
            row.innerHTML = `
                <div class="ct-town">${escapeHTML(c.town)}</div>
                <div class="ct-body">${c.amount}× ${escapeHTML(c.good)} · deadline ${fmtDeadline(c.deadline)}</div>
                <div class="ct-reward">$${c.reward}</div>
                <button class="btn" data-cid="${escapeHTML(c.id)}">Deliver</button>
            `;
            row.querySelector('button').onclick = () => post('deliverContract', { contractId: c.id });
            mc.appendChild(row);
        });

        const pr = document.getElementById('eco-prod');
        pr.innerHTML = '';
        const chains = d.productionChains || {};
        Object.keys(chains).forEach(k => {
            const ch = chains[k];
            const io = `${objLine(ch.input)} → ${objLine(ch.output)}`;
            const cell = document.createElement('div');
            cell.className = 'prod-cell';
            cell.innerHTML = `
                <div class="prod-title">${k}</div>
                <div class="prod-io">${escapeHTML(io)}</div>
                <div class="prod-time">${ch.timeMinutes || 0} min · +${ch.xpPerBatch || 0} XP</div>
                <button class="btn" data-chain="${escapeHTML(k)}">Start</button>
            `;
            cell.querySelector('button').onclick = () => post('startProduction', { chainKey: k });
            pr.appendChild(cell);
        });

        const led = document.getElementById('eco-ledger');
        led.innerHTML = '';
        (d.ledger || []).slice(0, 30).forEach(l => {
            const ts = new Date((l.ts || 0) * 1000).toLocaleString();
            const amt = l.amount || 0;
            const cls = amt < 0 ? 'neg' : '';
            const li = document.createElement('li');
            li.innerHTML = `<span class="ts">${ts}</span>
                            <span class="desc">${escapeHTML(l.kind || '')} — ${escapeHTML(l.description || '')}</span>
                            <span class="amt ${cls}">$${amt.toLocaleString()}</span>`;
            led.appendChild(li);
        });
    }

    function renderEnvironment() {
        const d = state.data.environment;
        if (!d) return;
        renderHeader(d.snapshot);

        const hero = document.getElementById('env-hero');
        const s = d.snapshot || {};
        hero.innerHTML = `
            <div class="h-cell"><div class="h">Season</div><div class="v">${escapeHTML(s.season || '—')}</div></div>
            <div class="h-cell"><div class="h">Weather</div><div class="v">${escapeHTML(s.weather || '—')}</div></div>
            <div class="h-cell"><div class="h">Temperature</div><div class="v">${s.temp !== undefined ? s.temp + '°C' : '—'}</div></div>
            <div class="h-cell"><div class="h">Uptime</div><div class="v">${fmtUptime(s.season_started)}</div></div>
        `;

        const se = document.getElementById('env-seasons');
        se.innerHTML = '';
        Object.keys(d.seasons || {}).forEach(k => {
            const sdef = d.seasons[k];
            const cell = document.createElement('div');
            cell.className = 'season-cell' + (s.season === k ? ' current' : '');
            cell.innerHTML = `
                <div class="s-name">${escapeHTML(sdef.label || k)}</div>
                <div class="s-temp">${(sdef.tempRange || [0,0]).join('° – ')}°C</div>
            `;
            se.appendChild(cell);
        });

        const hz = document.getElementById('env-hazards');
        hz.innerHTML = '';
        const activeByRanch = s.active_hazards || {};
        const all = [];
        Object.keys(activeByRanch).forEach(rid => {
            (activeByRanch[rid] || []).forEach(h => all.push({ rid: rid, h: h }));
        });
        if (!all.length) {
            hz.innerHTML = '<div class="hazard-row" style="color:var(--wl-text-soft);border-color:var(--wl-border-soft);background:var(--wl-bg-cell);">No active hazards.</div>';
        } else {
            all.forEach(a => {
                const row = document.createElement('div');
                row.className = 'hazard-row';
                row.textContent = `⚠ ${a.h.label} @ ${a.rid}`;
                hz.appendChild(row);
            });
        }
    }

    function renderProgression() {
        const d = state.data.progression;
        if (!d) return;

        const sk = document.getElementById('prog-skills');
        sk.innerHTML = '';
        Object.keys(d.skills || {}).forEach(k => {
            const s = d.skills[k];
            const total = Math.max(1, s.nextLevelXp - s.currentLevelXp);
            const have = Math.max(0, s.xp - s.currentLevelXp);
            const pct = Math.max(0, Math.min(100, Math.floor(have / total * 100)));
            const card = document.createElement('div');
            card.className = 'skill-card';
            let bonuses = '';
            Object.keys(s.bonuses || {}).sort((a, b) => +a - +b).forEach(tier => {
                const isActive = s.activeBonuses && s.activeBonuses[tier];
                bonuses += `<li class="${isActive ? 'active' : ''}">Lvl ${tier}: ${escapeHTML(s.bonuses[tier])}</li>`;
            });
            card.innerHTML = `
                <div class="sk-title">
                    <span class="sk-name">${escapeHTML(s.label)}</span>
                    <span class="sk-lvl">Lvl ${s.level}</span>
                </div>
                <div class="sk-desc">${escapeHTML(s.description || '')}</div>
                <div class="sk-xp">
                    <div class="bar"><div class="bar-fill" style="width:${pct}%"></div></div>
                    <div class="xp-text">${have.toLocaleString()} / ${total.toLocaleString()} XP</div>
                </div>
                <ul class="sk-bonuses">${bonuses}</ul>
            `;
            sk.appendChild(card);
        });

        const ac = document.getElementById('prog-ach');
        ac.innerHTML = '';
        // No direct list of all achievement defs in payload (server only sent owned),
        // so we iterate owned set. Config could be included server-side if needed.
        Object.keys(d.achievements || {}).forEach(k => {
            const cell = document.createElement('div');
            cell.className = 'ach-cell unlocked';
            cell.innerHTML = `<div class="ach-name">${escapeHTML(k)}</div>
                              <div class="ach-req">Unlocked</div>`;
            ac.appendChild(cell);
        });
        if (!ac.innerHTML) {
            ac.innerHTML = '<div class="ach-cell"><div class="ach-name">No achievements yet</div><div class="ach-req">Build your empire</div></div>';
        }
    }

    function renderAuction() {
        const d = state.data.auction;
        const list = document.getElementById('auc-list');
        list.innerHTML = '';
        if (!d || !d.lots || !d.lots.length) {
            list.innerHTML = '<div class="card" style="text-align:center;">No live auctions.</div>';
            return;
        }
        d.lots.forEach(a => {
            const row = document.createElement('div');
            row.className = 'auction-row';
            const timeLeft = Math.max(0, (a.deadline || 0) - Math.floor(Date.now() / 1000));
            const mm = Math.floor(timeLeft / 60), ss = timeLeft % 60;
            row.innerHTML = `
                <div class="au-lot">${escapeHTML(a.lot_type)}: ${escapeHTML(a.lot_ref)}</div>
                <div class="au-body">Seller: ${escapeHTML(a.seller || '—')}<br/>High bidder: ${escapeHTML(a.high_bidder || '—')}</div>
                <div class="au-bid">$${(a.current_bid || 0).toLocaleString()}</div>
                <div class="au-time">${mm}m ${ss}s</div>
                <div>
                    <input class="text-input" type="number" min="1" placeholder="Bid" data-aid="${escapeHTML(a.id)}" />
                    <button class="btn" data-aid="${escapeHTML(a.id)}">Bid</button>
                </div>
            `;
            const btn = row.querySelector('button');
            const input = row.querySelector('input');
            btn.onclick = () => {
                const amount = parseInt(input.value, 10);
                if (!amount || amount <= 0) { toast('Enter a valid bid', 'error'); return; }
                post('placeBid', { auctionId: a.id, amount: amount });
            };
            list.appendChild(row);
        });
    }

    function submitAuction() {
        const lotType = document.getElementById('auc-type').value;
        const lotRef  = document.getElementById('auc-ref').value.trim();
        const startBid = parseInt(document.getElementById('auc-bid').value, 10);
        if (!lotRef || !startBid || startBid <= 0) { toast('Fill all auction fields', 'error'); return; }
        post('createAuction', {
            ranchId: state.ranchId, lotType: lotType, lotRef: lotRef, startBid: startBid
        });
        document.getElementById('auc-ref').value = '';
        document.getElementById('auc-bid').value = '';
    }

    function closeDetail() {
        state.selectedAnimalId = null;
        renderLivestock();
    }

    // ═══════════════════════════════════════════════════════════════════
    // 🔧 HELPERS
    // ═══════════════════════════════════════════════════════════════════
    function escapeHTML(s) {
        if (s === null || s === undefined) return '';
        return String(s)
            .replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
            .replace(/"/g, '&quot;').replace(/'/g, '&#39;');
    }
    function fmtDeadline(ts) {
        if (!ts) return '—';
        const diff = ts - Math.floor(Date.now() / 1000);
        if (diff <= 0) return 'expired';
        const h = Math.floor(diff / 3600), m = Math.floor((diff % 3600) / 60);
        return `${h}h ${m}m`;
    }
    function fmtUptime(ts) {
        if (!ts) return '—';
        const diff = Math.floor(Date.now() / 1000) - ts;
        const h = Math.floor(diff / 3600), m = Math.floor((diff % 3600) / 60);
        return `${h}h ${m}m`;
    }
    function objLine(o) {
        if (!o) return '';
        return Object.keys(o).map(k => `${o[k]}× ${k}`).join(', ');
    }

    // ═══════════════════════════════════════════════════════════════════
    // 🔧 WIRING
    // ═══════════════════════════════════════════════════════════════════
    window.addEventListener('message', function (ev) {
        const msg = ev.data || {};
        if (msg.action === 'open')      open(msg);
        else if (msg.action === 'close')   close();
        else if (msg.action === 'tabData') onTabData(msg.tab, msg.data, msg.error);
        else if (msg.action === 'delta')   onDelta(msg.kind, msg.payload);
    });

    window.addEventListener('keyup', function (e) {
        if (!state.open) return;
        if (e.key === 'Escape' || e.keyCode === 27) { close(); }
    });

    document.addEventListener('DOMContentLoaded', function () {
        document.querySelectorAll('.tab-btn').forEach(b => {
            b.addEventListener('click', () => switchTab(b.dataset.tab));
        });
        document.getElementById('btn-close').addEventListener('click', close);

        document.getElementById('ls-search').addEventListener('input', () => {
            if (state.tab === 'livestock') renderLivestock();
        });
        document.getElementById('ls-filter-species').addEventListener('change', () => {
            if (state.tab === 'livestock') renderLivestock();
        });

        document.querySelectorAll('.detail-actions [data-act]').forEach(btn => {
            btn.addEventListener('click', () => {
                if (!state.selectedAnimalId) return;
                post('interactAnimal', { animalId: state.selectedAnimalId, action: btn.dataset.act });
            });
        });
    });

    return {
        submitAuction: submitAuction,
        closeDetail:   closeDetail
    };

})();

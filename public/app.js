// Pause SaaS Sandbox - Core Application Logic
// Handles State, Onboarding, Screens, Simulated Feed, Analytics, Custom Settings, & Upgrade states.

const DEFAULT_STATE = {
    onboarded: false,
    managedApps: ['Instagram', 'TikTok', 'Twitter / X', 'YouTube', 'Reddit', 'Snapchat'],
    pauseDuration: 10, // seconds
    hasPremium: false,
    streak: 3, // starting streak
    simulatedDaysElapsed: 1,
    dailyScrollTime: 42, // minutes (simulated)
    longestSession: 18, // minutes
    nudgesTriggered: 12,
    nudgesResisted: 5,
    checkedInCount: 4,
    tokens: 15,
    selectedBonsaiSeason: 'Spring',
    unlockedSeasons: ['Spring'],
    koiColor: 'Orange',
    unlockedKoiColors: ['Orange'],
    pazuState: 'idle', // idle, happy, proud, clumsy, sleeping, curious, excited, gentleDisappointment, meditating, playing, eating, greeting, watching
    pazuHat: 'None',
    pazuGlasses: 'None',
    pazuScarf: 'None',
    pazuOutfit: 'None',
    pazuAccessory: 'None',
    unlockedPazuItems: ['None'],
    gardenTree: 'Cherry Blossom',
    gardenPond: 'Small Pond',
    gardenDecoration: 'None',
    gardenAmbient: 'None',
    unlockedGardenDecorations: ['Cherry Blossom', 'Small Pond'],
    logs: [
        { time: '09:12 AM', action: 'App Opened: Instagram', result: 'Resisted / Closed App' },
        { time: '11:30 AM', action: 'App Opened: TikTok', result: 'Continued (15 min feed)' },
        { time: '11:45 AM', action: 'Check-In Completed', result: 'Rated: 😐 (Not Sure)' },
        { time: '02:15 PM', action: 'App Opened: YouTube', result: 'Resisted / Closed App' },
        { time: '06:00 PM', action: 'App Opened: Reddit', result: 'Continued (15 min feed)' },
        { time: '06:15 PM', action: 'Check-In Completed', result: 'Rated: 😊 (Well Spent)' }
    ],
    lastCheckInRating: '',
    enableIntentionPrompt: true,
    quietHoursStart: '09:00',
    quietHoursEnd: '17:00',
    enableQuietHours: false,
    scrollSessions: [
        { id: 1, start: '08:00', end: '08:30', active: true },
        { id: 2, start: '12:00', end: '13:00', active: false },
        { id: 3, start: '19:00', end: '20:00', active: true }
    ],
    moodTrend: 'observational',
    badgeText: 'I\'m trying to scroll less'
};

let state = { ...DEFAULT_STATE };

// Decide Pazu's autonomous behavior (Lower chance of clumsy: 5% probability)
function updatePazuBehavior() {
    if (state.streak === 0) {
        state.pazuState = 'sleeping';
    } else if (state.streak >= 7) {
        state.pazuState = 'proud';
    } else {
        const roll = Math.random();
        if (roll < 0.05) { // 5% chance of clumsy fall (reduced as requested)
            state.pazuState = 'clumsy';
        } else if (roll < 0.25) {
            state.pazuState = 'playing';
        } else if (roll < 0.45) {
            state.pazuState = 'curious';
        } else if (roll < 0.60) {
            state.pazuState = 'eating';
        } else if (roll < 0.75) {
            state.pazuState = 'meditating';
        } else {
            state.pazuState = 'idle';
        }
    }
}

// Initialize State from LocalStorage
function loadState() {
    const saved = localStorage.getItem('pause_saas_state');
    if (saved) {
        try {
            state = JSON.parse(saved);
        } catch (e) {
            state = { ...DEFAULT_STATE };
        }
    } else {
        state = { ...DEFAULT_STATE };
    }
    if (state.tokens === undefined) state.tokens = 15;
    if (state.selectedBonsaiSeason === undefined) state.selectedBonsaiSeason = 'Spring';
    if (state.unlockedSeasons === undefined) state.unlockedSeasons = ['Spring'];
    if (state.koiColor === undefined) state.koiColor = 'Orange';
    if (state.unlockedKoiColors === undefined) state.unlockedKoiColors = ['Orange'];
    if (state.simulatedDaysElapsed === undefined) state.simulatedDaysElapsed = 1;
    if (state.pazuState === undefined) state.pazuState = 'idle';
    if (state.pazuHat === undefined) state.pazuHat = 'None';
    if (state.pazuGlasses === undefined) state.pazuGlasses = 'None';
    if (state.pazuScarf === undefined) state.pazuScarf = 'None';
    if (state.pazuOutfit === undefined) state.pazuOutfit = 'None';
    if (state.pazuAccessory === undefined) state.pazuAccessory = 'None';
    if (state.unlockedPazuItems === undefined) state.unlockedPazuItems = ['None'];
    if (state.gardenTree === undefined) state.gardenTree = 'Cherry Blossom';
    if (state.gardenPond === undefined) state.gardenPond = 'Small Pond';
    if (state.gardenStructure === undefined) state.gardenStructure = 'None';
    if (state.gardenAmbient === undefined) state.gardenAmbient = 'None';
    if (state.unlockedGardenDecorations === undefined) state.unlockedGardenDecorations = ['Cherry Blossom', 'Small Pond'];

    updatePazuBehavior();
    updateSaaSCompanionUI();
    renderCurrentScreen();
}

function saveState() {
    localStorage.setItem('pause_saas_state', JSON.stringify(state));
    updateSaaSCompanionUI();
}

// Clear and delete all account data immediately
function deleteAccountAndAllData() {
    if (confirm('Are you absolutely sure you want to delete your account and wipe all stored data? This cannot be undone.')) {
        localStorage.removeItem('pause_saas_state');
        state = { ...DEFAULT_STATE };
        state.onboarded = false;
        currentScreen = 'onboarding-1';
        saveState();
        renderCurrentScreen();
        alert('All locally saved logs, trends, and account data have been completely deleted.');
    }
}

// Logging helper
function logAction(action, result) {
    const now = new Date();
    const timeStr = now.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    state.logs.unshift({ time: timeStr, action, result });
    if (state.logs.length > 25) state.logs.pop(); // limit size
    saveState();
}

// Current Phone View Screen State
let currentScreen = 'home';
let pauseGateTimer = null;
let pauseRemaining = 10;
let simulatedAppToOpen = 'Instagram';
let feedRemainingSeconds = 15 * 60; // 15 mins simulator
let feedTimer = null;
let selectedIntentChip = null;
let ghostCheckInActive = false;
let ghostCheckInSeconds = 0;
let ghostCheckInTimer = null;

// Initialize app when DOM is fully loaded
document.addEventListener('DOMContentLoaded', () => {
    loadState();

    if (!state.onboarded) {
        currentScreen = 'onboarding-1';
    } else {
        currentScreen = 'home';
    }

    if (window.location.pathname === '/sandbox') {
        if (typeof switchTab === 'function') switchTab('sandbox-tab');
    }

    renderCurrentScreen();

    const resetBtn = document.getElementById('reset-btn');
    if (resetBtn) {
        resetBtn.addEventListener('click', () => {
            if (confirm('Reset entire sandbox simulator to default?')) {
                localStorage.removeItem('pause_saas_state');
                state = { ...DEFAULT_STATE };
                currentScreen = 'onboarding-1';
                saveState();
                renderCurrentScreen();
            }
        });
    }

    const upgradeToggle = document.getElementById('sandbox-upgrade-toggle');
    if (upgradeToggle) {
        upgradeToggle.addEventListener('click', () => {
            state.hasPremium = !state.hasPremium;
            logAction('Sandbox Mode', `Subscription Tier toggled to: ${state.hasPremium ? 'Premium (Pause+)' : 'Free Tier'}`);
            saveState();
            renderCurrentScreen();
        });
    }

    const ffBtn = document.getElementById('fast-forward-btn');
    if (ffBtn) {
        ffBtn.addEventListener('click', () => {
            state.dailyScrollTime += Math.floor(Math.random() * 20) + 15;
            state.longestSession = Math.max(state.longestSession, Math.floor(Math.random() * 10) + 15);
            state.nudgesTriggered += Math.floor(Math.random() * 4) + 1;
            state.nudgesResisted += Math.floor(Math.random() * 3);
            state.streak += 1;
            state.tokens += 5;
            state.simulatedDaysElapsed += 1;
            updatePazuBehavior();
            logAction('Simulation Engine', `Simulated 1 day of usage patterns. Total Simulated Days: ${state.simulatedDaysElapsed}`);
            saveState();
            renderCurrentScreen();
        });
    }
});

// Play haptic audio feedback
function playHapticFeedback(type) {
    try {
        const audioCtx = new (window.AudioContext || window.webkitAudioContext)();
        const osc = audioCtx.createOscillator();
        const gain = audioCtx.createGain();
        osc.connect(gain);
        gain.connect(audioCtx.destination);

        if (type === 'heavy') {
            osc.frequency.setValueAtTime(80, audioCtx.currentTime);
            osc.frequency.exponentialRampToValueAtTime(30, audioCtx.currentTime + 0.15);
            gain.gain.setValueAtTime(0.5, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.15);
            osc.start();
            osc.stop(audioCtx.currentTime + 0.15);
        } else {
            osc.frequency.setValueAtTime(400, audioCtx.currentTime);
            osc.frequency.exponentialRampToValueAtTime(150, audioCtx.currentTime + 0.05);
            gain.gain.setValueAtTime(0.1, audioCtx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, audioCtx.currentTime + 0.05);
            osc.start();
            osc.stop(audioCtx.currentTime + 0.05);
        }
    } catch(e) {
    }
}

// Update the SaaS companion panel details on the right side
function updateSaaSCompanionUI() {
    const tierText = document.getElementById('current-tier-text');
    if (tierText) {
        tierText.innerText = state.hasPremium ? 'Pause+ Premium Tier ($39.99/yr)' : 'Free Tier ($0/mo)';
        tierText.className = state.hasPremium ? 'text-sm font-bold text-amber-500' : 'text-sm font-bold text-slate-200';
    }

    const totalDaysEl = document.getElementById('inspector-total-days');
    if (totalDaysEl) totalDaysEl.innerText = state.streak > 0 ? state.streak : '1';

    const checkinsEl = document.getElementById('inspector-checkins');
    if (checkinsEl) checkinsEl.innerText = state.checkedInCount;

    const nudgesEl = document.getElementById('inspector-nudges');
    if (nudgesEl) nudgesEl.innerText = state.nudgesTriggered;

    const resistedEl = document.getElementById('inspector-resisted');
    if (resistedEl) resistedEl.innerText = state.nudgesResisted;

    const logsContainer = document.getElementById('raw-logs-container');
    if (logsContainer) {
        logsContainer.innerHTML = state.logs.map(log => `
            <div class="flex items-start justify-between py-1 border-b border-slate-900/60 hover:bg-slate-900/20 transition-all">
                <span class="text-indigo-400 shrink-0 select-all mr-2 font-semibold">[${log.time}]</span>
                <span class="text-slate-200 flex-1 select-all mr-2">${log.action}</span>
                <span class="text-emerald-500 shrink-0 font-medium">${log.result}</span>
            </div>
        `).join('') || '<div class="text-slate-500 text-center py-4">No logged activities yet. Try triggering the Pause Gate on the left.</div>';
    }

    if (window.lucide) {
        window.lucide.createIcons();
    }
}

// Trigger Simulated App Launch from the outside sandbox
function triggerAppLaunch(appName) {
    simulatedAppToOpen = appName;

    const isManaged = state.managedApps.includes(appName);

    let isInQuietHours = false;
    if (state.enableQuietHours) {
        isInQuietHours = true;
    }

    if (isManaged && !isInQuietHours) {
        state.nudgesTriggered++;
        saveState();
        logAction(`Attempted Open: ${appName}`, `Triggered the Turbo-Tap Gate overlay`);

        selectedIntentChip = null;
        currentScreen = 'pause-gate';
    } else {
        logAction(`Attempted Open: ${appName}`, `Bypassed overlay (Unmanaged app / Quiet Hours)`);
        startScrollSimulator(appName);
    }
    renderCurrentScreen();
}

function startScrollSimulator(appName, method = 'touch', selectedIntent = null) {
    currentScreen = 'scrolling-feed';
    simulatedAppToOpen = appName;
    feedRemainingSeconds = 15 * 60;

    state.tokens += 1;
    saveState();

    logAction(`Gate Unlocked (${method})`, `Intent: ${selectedIntent || 'None'} (+1 Token awarded)`);

    if (feedTimer) clearInterval(feedTimer);
    feedTimer = setInterval(() => {
        feedRemainingSeconds -= 150;
        if (feedRemainingSeconds <= 0) {
            clearInterval(feedTimer);
            exitFeedAndGoToCheckIn(true);
        } else {
            const timerEl = document.getElementById('feed-timer-countdown');
            if (timerEl) {
                const mins = Math.floor(feedRemainingSeconds / 60);
                const secs = Math.floor(feedRemainingSeconds % 60);
                timerEl.innerText = `${mins}:${secs.toString().padStart(2, '0')}`;
            }
        }
    }, 1000);

    renderCurrentScreen();
}

function exitFeedAndGoToCheckIn(isAutoTriggered = false) {
    if (feedTimer) clearInterval(feedTimer);
    if (ghostCheckInTimer) clearInterval(ghostCheckInTimer);

    currentScreen = 'check-in';
    ghostCheckInActive = isAutoTriggered;
    ghostCheckInSeconds = 0;

    if (isAutoTriggered) {
        logAction('Ghost Check-In Active', '12-second auto-dismissal window started.');
        ghostCheckInTimer = setInterval(() => {
            ghostCheckInSeconds++;

            if (ghostCheckInSeconds === 3) {
                playHapticFeedback('heavy');
                setTimeout(() => playHapticFeedback('heavy'), 150);
                logAction('Ghost Warning', '3 seconds elapsed: Double haptic warning bzz-bzz triggered');
            }

            if (ghostCheckInSeconds >= 12) {
                clearInterval(ghostCheckInTimer);
                ghostCheckInActive = false;
                autoLogGhostCheckIn();
            } else {
                renderCurrentScreen();
            }
        }, 1000);
    }

    renderCurrentScreen();
}

function autoLogGhostCheckIn() {
    state.checkedInCount++;
    state.lastCheckInRating = 'Neutral (😐)';
    state.tokens += 1;

    logAction('Ghost Auto-Logged', '12s elapsed. Auto-logged Neutral 😐 with autoLogged: true');
    saveState();
    changeScreen('home');
}

function toggleIntentChipSelection(intentName) {
    playHapticFeedback('light');
    if (selectedIntentChip === intentName) {
        selectedIntentChip = null;
    } else {
        selectedIntentChip = intentName;
    }
    renderCurrentScreen();
}

function triggerHardwareBypass() {
    playHapticFeedback('light');
    startScrollSimulator(simulatedAppToOpen, 'hardware', null);
    renderCurrentScreen();
}

// Render Shoulders-Up Pazu Red Panda App Icon Viewport with Matching Expressions
function renderPazuCharacter() {
    const hatDecoration = state.pazuHat === 'Leaf Crown' ? '👑🍃' : state.pazuHat === 'Straw Hat' ? '👒' : state.pazuHat === 'Wizard Hat' ? '🧙' : '';
    const glassesDecoration = state.pazuGlasses === 'Round Glasses' ? '👓' : state.pazuGlasses === 'Sunglasses' ? '🕶️' : '';
    const scarfDecoration = state.pazuScarf === 'Red Scarf' ? '🧣' : '';

    let pazuEmoji = '😊🐾';
    let pazuActionText = 'Pazu is resting in the Zen Garden';

    switch (state.pazuState) {
        case 'happy':
            pazuEmoji = '😁🐾';
            pazuActionText = 'Pazu waves happily! "I\'m happy to see you!"';
            break;
        case 'proud':
            pazuEmoji = '😏🐾';
            pazuActionText = 'Pazu stands proud of your mindful streak!';
            break;
        case 'clumsy':
            pazuEmoji = '😵🐾';
            pazuActionText = 'Pazu tripped over its bushy tail! "Eep!" (Clumsy 5% chance)';
            break;
        case 'sleeping':
            pazuEmoji = '😴🐾';
            pazuActionText = 'Pazu is curled up asleep under the tree...';
            break;
        case 'curious':
            pazuEmoji = '🧐🐾';
            pazuActionText = 'Pazu is curiously exploring the bamboo grove...';
            break;
        case 'excited':
            pazuEmoji = '🤩🐾';
            pazuActionText = 'Pazu is bouncing with excitement!';
            break;
        case 'gentleDisappointment':
            pazuEmoji = '🥺🐾';
            pazuActionText = 'Pazu missed you, but is ready when you are.';
            break;
        case 'meditating':
            pazuEmoji = '🧘🐾';
            pazuActionText = 'Pazu is meditating peacefully in the garden...';
            break;
        case 'playing':
            pazuEmoji = '😄🐾';
            pazuActionText = 'Pazu is chasing falling cherry blossom leaves!';
            break;
        case 'eating':
            pazuEmoji = '😋🐾';
            pazuActionText = 'Pazu is munching on fresh bamboo treats!';
            break;
        case 'greeting':
            pazuEmoji = '👋🐾';
            pazuActionText = 'Pazu is waving happily at you!';
            break;
        case 'watching':
            pazuEmoji = '👀🐾';
            pazuActionText = 'Pazu is observing your session...';
            break;
        default:
            pazuEmoji = '😊🐾';
            pazuActionText = 'Pazu the Red Panda is breathing calmly.';
            break;
    }

    return `
        <div class="relative w-44 h-44 bg-[#232323]/60 border border-amber-500/20 rounded-full mx-auto flex flex-col items-center justify-center overflow-hidden shadow-2xl p-2">
            <!-- Swimming Koi ring -->
            <div class="absolute inset-2 border border-cyan-900/20 rounded-full animate-spin" style="animation-duration: 12s;">
                <div class="w-3 h-1.5 bg-[#B8860B] rounded-full opacity-70" style="margin-left: 8px;"></div>
            </div>

            <!-- Shoulders-Up Pazu Dynamic App Icon Squircle Frame -->
            <div class="z-10 flex flex-col items-center text-center">
                <div class="relative w-20 h-20 bg-gradient-to-br from-[#232323] to-[#1A1A1A] border-2 border-[#B8860B] rounded-3xl flex items-center justify-center shadow-lg">
                    <span class="absolute -top-3 left-1/2 -translate-x-1/2 text-xs">${hatDecoration}</span>
                    <span class="absolute top-2 left-1/2 -translate-x-1/2 text-[10px]">${glassesDecoration}</span>
                    <span class="text-3xl animate-bounce" style="animation-duration: 4s;">${pazuEmoji}</span>
                    <span class="absolute -bottom-2 left-1/2 -translate-x-1/2 text-xs">${scarfDecoration}</span>
                </div>
                <div class="text-[11px] font-black text-white mt-1.5 tracking-wide">Pazu App Icon</div>
                <div class="text-[9px] text-[#B8860B] font-medium px-2 leading-tight mt-0.5">${pazuActionText}</div>
            </div>
        </div>
    `;
}

// Render dynamic views inside the Mock Smartphone viewport
function renderCurrentScreen() {
    const screen = document.getElementById('screen-container');
    if (!screen) return;

    screen.className = "relative w-full h-full flex flex-col bg-[#1A1A1A] text-[#94A3B8] animate-fade-in industrial-noise";

    switch (currentScreen) {
        case 'onboarding-1':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 relative overflow-hidden">
                    <div class="flex gap-1.5 w-full">
                        <div class="h-1 flex-1 bg-[#B8860B] rounded-full"></div>
                        <div class="h-1 flex-1 bg-slate-800 rounded-full"></div>
                        <div class="h-1 flex-1 bg-slate-800 rounded-full"></div>
                    </div>

                    <div class="my-auto space-y-6 text-center z-10">
                        <div class="w-20 h-20 bg-amber-950/10 border border-[#B8860B]/30 rounded-2xl flex items-center justify-center mx-auto shadow-2xl shadow-amber-950/30">
                            <i data-lucide="compass" class="w-10 h-10 text-[#B8860B]"></i>
                        </div>
                        <h3 class="text-3xl font-black tracking-tight text-white leading-tight">
                            "You don't have to quit. You just have to <span class="text-[#B8860B]">pause.</span>"
                        </h3>
                        <p class="text-slate-400 text-xs leading-relaxed px-4">
                            Welcome to Industrial Mindfulness. Meet Pazu the Red Panda, your lovable companion helping you align screen intent with reality.
                        </p>
                    </div>

                    <div class="space-y-3 z-10">
                        <button onclick="changeScreen('onboarding-2')" class="w-full bg-[#232323] border border-[#2d2d2d] hover:bg-[#2d2d2d] text-[#B8860B] font-bold py-3.5 px-4 rounded-full shadow-lg transition-all text-xs flex items-center justify-center gap-2">
                            <span>Get Started</span>
                            <i data-lucide="arrow-right" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>
            `;
            break;

        case 'onboarding-2':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 relative">
                    <div class="flex gap-1.5 w-full">
                        <div class="h-1 flex-1 bg-[#B8860B] rounded-full"></div>
                        <div class="h-1 flex-1 bg-[#B8860B] rounded-full"></div>
                        <div class="h-1 flex-1 bg-slate-800 rounded-full"></div>
                    </div>

                    <div class="my-auto space-y-4">
                        <div class="text-center">
                            <h3 class="text-xl font-bold text-white mb-1">Managed Social Networks</h3>
                            <p class="text-[10px] text-slate-400">Select social apps that you wish to pause before scrolling.</p>
                        </div>

                        <div class="space-y-2 max-h-[260px] overflow-y-auto pr-1">
                            ${['Instagram', 'TikTok', 'YouTube', 'Snapchat', 'Reddit', 'Facebook'].map(app => {
                                const checked = state.managedApps.includes(app);
                                return `
                                    <label class="flex items-center justify-between p-3 bg-[#232323] border ${checked ? 'border-[#B8860B]/30 bg-[#B8860B]/5' : 'border-slate-800'} rounded-xl cursor-pointer transition-colors">
                                        <span class="text-xs font-semibold text-slate-200">${app}</span>
                                        <input type="checkbox" onchange="toggleManagedApp('${app}')" ${checked ? 'checked' : ''} class="w-4.5 h-4.5 rounded text-[#B8860B] bg-slate-800 border-slate-700 focus:ring-[#B8860B]">
                                    </label>
                                `;
                            }).join('')}
                        </div>
                    </div>

                    <div>
                        <button onclick="changeScreen('onboarding-3')" class="w-full bg-[#232323] border border-[#2d2d2d] hover:bg-[#2d2d2d] text-[#B8860B] font-bold py-3.5 px-4 rounded-full shadow-lg transition-all text-xs flex items-center justify-center gap-2">
                            <span>Continue</span>
                            <i data-lucide="arrow-right" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>
            `;
            break;

        case 'onboarding-3':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 relative">
                    <div class="flex gap-1.5 w-full">
                        <div class="h-1 flex-1 bg-[#B8860B] rounded-full"></div>
                        <div class="h-1 flex-1 bg-[#B8860B] rounded-full"></div>
                        <div class="h-1 flex-1 bg-[#B8860B] rounded-full"></div>
                    </div>

                    <div class="my-auto space-y-5 text-center">
                        <div class="w-16 h-16 bg-amber-950/10 border border-[#B8860B]/30 rounded-full flex items-center justify-center mx-auto">
                            <i data-lucide="timer" class="w-8 h-8 text-[#B8860B]"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white mb-1">Set your Pause duration</h3>
                            <p class="text-xs text-slate-400">Choose custom breathing interval times.</p>
                        </div>

                        <div class="grid grid-cols-2 gap-2 max-w-xs mx-auto">
                            ${[5, 10, 15, 30].map(sec => `
                                <button onclick="setPauseDuration(${sec})" class="py-3 px-4 border ${state.pauseDuration === sec ? 'border-[#B8860B] bg-[#B8860B]/10 text-[#B8860B]' : 'border-slate-800 hover:border-slate-700'} rounded-xl text-xs font-bold transition-all">
                                    ${sec} Seconds
                                </button>
                            `).join('')}
                        </div>
                    </div>

                    <div>
                        <button onclick="completeOnboarding()" class="w-full bg-gradient-to-r from-[#B8860B] to-amber-700 hover:from-amber-600 hover:to-amber-500 text-white font-bold py-3.5 px-4 rounded-full shadow-lg transition-all text-xs flex items-center justify-center gap-2">
                            <span>Ready to Try</span>
                            <i data-lucide="check" class="w-4 h-4"></i>
                        </button>
                    </div>
                </div>
            `;
            break;

        case 'home':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-5 relative overflow-y-auto">
                    <div class="flex items-center justify-between mt-1">
                        <div class="flex items-center gap-1.5">
                            <span class="w-2 h-2 rounded-full bg-[#6B8F71] animate-pulse active-status-glow"></span>
                            <span class="text-[9px] text-[#6B8F71] font-bold uppercase tracking-wider">Pause Mode Active</span>
                        </div>
                        <div class="flex items-center gap-2">
                            <div class="flex items-center gap-1 bg-[#232323] px-2 py-0.5 rounded-full border border-slate-800">
                                <i data-lucide="star" class="w-3 h-3 text-[#B8860B] fill-[#B8860B]/20"></i>
                                <span class="text-[10px] font-bold text-white font-mono">${state.tokens}</span>
                            </div>
                            <button onclick="changeScreen('settings')" class="w-7 h-7 rounded-lg hover:bg-slate-900 border border-slate-800 flex items-center justify-center text-slate-400 hover:text-white transition-colors">
                                <i data-lucide="settings" class="w-4 h-4"></i>
                            </button>
                        </div>
                    </div>

                    <div class="my-auto space-y-4 text-center">
                        ${renderPazuCharacter()}

                        <div class="space-y-1">
                            <span class="text-[10px] text-slate-500 font-semibold tracking-wider uppercase">Today's Scroll Time</span>
                            <div class="flex items-baseline justify-center gap-1">
                                <span class="text-4xl font-extrabold text-white tracking-tight font-mono">${state.dailyScrollTime}</span>
                                <span class="text-xs font-semibold text-slate-400">Minutes</span>
                            </div>
                        </div>

                        <div class="grid grid-cols-2 gap-2.5">
                            <div class="bg-[#232323] border border-slate-800/80 p-3 rounded-2xl flex items-center gap-3">
                                <div class="w-8 h-8 bg-amber-500/10 rounded-xl flex items-center justify-center text-amber-500 border border-amber-500/20">
                                    <i data-lucide="flame" class="w-4 h-4"></i>
                                </div>
                                <div class="text-left">
                                    <div class="text-[9px] text-slate-500 font-medium">Streak</div>
                                    <div class="text-xs font-bold text-slate-200 font-mono">${state.streak} Days</div>
                                </div>
                            </div>
                            <div class="bg-[#232323] border border-slate-800/80 p-3 rounded-2xl flex items-center gap-3">
                                <div class="w-8 h-8 bg-cyan-500/10 rounded-xl flex items-center justify-center text-cyan-400 border border-cyan-500/20">
                                    <i data-lucide="award" class="w-4 h-4"></i>
                                </div>
                                <div class="text-left">
                                    <div class="text-[9px] text-slate-500 font-medium">Tokens</div>
                                    <div class="text-xs font-bold text-slate-200 font-mono">${state.tokens}</div>
                                </div>
                            </div>
                        </div>

                        <div class="bg-[#232323] border border-slate-800/80 p-3.5 rounded-2xl space-y-2.5 text-left">
                            <div class="text-[11px] font-bold text-slate-300">Active Social Triggers</div>
                            <div class="grid grid-cols-2 gap-2">
                                ${state.managedApps.slice(0, 4).map(app => `
                                    <button onclick="triggerAppLaunch('${app}')" class="flex items-center gap-2 p-2 bg-slate-950 hover:bg-slate-900 border border-slate-800 rounded-xl text-left transition-all">
                                        <i data-lucide="iphone" class="w-3.5 h-3.5 text-indigo-400"></i>
                                        <span class="text-[11px] font-medium text-slate-300 truncate">${app}</span>
                                    </button>
                                `).join('')}
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-4 border-t border-slate-900 pt-3 mt-4">
                        <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-[#B8860B]">
                            <i data-lucide="home" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Home</span>
                        </button>
                        <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                            <i data-lucide="bar-chart-2" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Scrollytics</span>
                        </button>
                        <button onclick="changeScreen('garden-shop')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                            <i data-lucide="shopping-bag" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Garden</span>
                        </button>
                        <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 ${state.hasPremium ? 'text-amber-500' : 'text-slate-500 hover:text-slate-300'} transition-colors">
                            <i data-lucide="award" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Pause Pro</span>
                        </button>
                    </div>

                </div>
            `;
            break;

        case 'pause-gate':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 relative overflow-hidden bg-[#1A1A1A]">
                    <div class="absolute inset-0 flex items-center justify-center pointer-events-none opacity-20">
                        <div class="w-48 h-48 border-2 border-[#B8860B] rounded-full passive-breathing-ring"></div>
                        <div class="absolute w-60 h-60 border border-slate-500 rounded-full passive-breathing-ring" style="animation-delay: 1s;"></div>
                    </div>

                    <div class="space-y-2 text-center mt-2 z-10">
                        <h4 class="text-xs font-bold text-slate-500 tracking-widest uppercase">${simulatedAppToOpen} triggered</h4>
                        <p class="text-lg text-white font-bold italic serif-brand">"What brings you here?"</p>
                    </div>

                    <div class="my-auto space-y-3 z-10">
                        <div class="grid grid-cols-2 gap-2">
                            ${['Relax / unwind', 'Connect w/ friends', 'Kill time / bored', 'Work / research'].map(chip => {
                                const isSel = (selectedIntentChip === chip);
                                return `
                                    <button onclick="toggleIntentChipSelection('${chip}')" class="intent-chip text-left p-3 border ${isSel ? 'border-[#B8860B] bg-[#B8860B]/10 text-[#B8860B]' : 'border-slate-800 bg-[#232323] text-slate-300'} rounded-xl text-xs font-bold transition-all">
                                        ${chip}
                                    </button>
                                `;
                            }).join('')}
                        </div>
                    </div>

                    <div class="space-y-4 z-10">
                        <button onclick="playHapticFeedback('heavy'); startScrollSimulator(simulatedAppToOpen, 'touch', selectedIntentChip);" class="arcade-button w-full py-4 text-xs font-extrabold tracking-widest uppercase flex items-center justify-center gap-2">
                            <span>YES, LET ME IN</span>
                            <i data-lucide="log-in" class="w-4 h-4"></i>
                        </button>

                        <div class="text-center">
                            <button onclick="triggerHardwareBypass()" class="text-[10px] text-slate-600 hover:text-slate-400 underline tracking-wide">
                                skip this gate by double-tapping side button
                            </button>
                        </div>
                    </div>

                </div>
            `;
            break;

        case 'scrolling-feed':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col bg-[#1A1A1A] relative">
                    <div class="px-4 py-3 border-b border-slate-900 bg-black flex items-center justify-between">
                        <div class="flex items-center gap-2">
                            <span class="w-2 h-2 rounded-full bg-indigo-500 animate-pulse"></span>
                            <span class="text-xs font-bold text-white tracking-wide uppercase">${simulatedAppToOpen} Sim</span>
                        </div>
                        <div class="flex items-center gap-1 text-slate-400 text-xs bg-[#232323] px-2 py-1 rounded-full border border-slate-800">
                            <i data-lucide="timer" class="w-3.5 h-3.5 text-indigo-400"></i>
                            <span id="feed-timer-countdown" class="font-mono">15:00</span>
                        </div>
                    </div>

                    <div class="flex-1 overflow-y-auto p-4 space-y-4">
                        <div class="p-3 bg-black rounded-xl border border-slate-900 space-y-2">
                            <div class="flex items-center gap-2">
                                <div class="w-6 h-6 rounded-full bg-slate-800"></div>
                                <div class="text-[11px] font-bold">@doomscroller_anon</div>
                            </div>
                            <div class="text-xs text-slate-300 leading-relaxed">
                                Just scrolling... nothing real here. Just wasting seconds. But wait, Pause is keeping time of my session in the background!
                            </div>
                        </div>

                        <div class="bg-black/95 p-3.5 rounded-2xl border border-emerald-500/20 space-y-3 shadow-2xl active-status-glow animate-bounce">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <div class="w-5 h-5 bg-emerald-950/20 border border-emerald-500/30 rounded-full flex items-center justify-center">
                                        <span class="w-1.5 h-1.5 bg-emerald-500 rounded-full"></span>
                                    </div>
                                    <span class="text-[10px] font-bold text-[#6B8F71] font-mono">15/15 min limit</span>
                                </div>
                                <span class="text-[10px] font-bold text-white">Dynamic Island Alert</span>
                            </div>
                            <div class="text-xs font-bold text-white italic">"Time's up. Was it worth it?"</div>

                            <div class="grid grid-cols-3 gap-2 pt-1">
                                <button onclick="playHapticFeedback('light'); submitCheckIn('Yes, I got what I needed')" class="p-2 bg-slate-900 hover:bg-slate-800 rounded-lg text-center text-xs">
                                    😊 Yes
                                </button>
                                <button onclick="playHapticFeedback('light'); submitCheckIn('Not sure')" class="p-2 bg-slate-900 hover:bg-slate-800 rounded-lg text-center text-xs">
                                    😐 Neutral
                                </button>
                                <button onclick="playHapticFeedback('light'); submitCheckIn('No, I got lost')" class="p-2 bg-slate-900 hover:bg-slate-800 rounded-lg text-center text-xs">
                                    😞 No
                                </button>
                            </div>
                        </div>

                        <div class="p-3 bg-black rounded-xl border border-slate-900 space-y-2">
                            <div class="flex items-center gap-2">
                                <div class="w-6 h-6 rounded-full bg-slate-800"></div>
                                <div class="text-[11px] font-bold">@viral_feed_trend</div>
                            </div>
                            <p class="text-xs text-slate-300">
                                This is simulated infinite scrolling inside the sandbox environment.
                            </p>
                        </div>
                    </div>

                    <div class="p-4 bg-black border-t border-slate-900">
                        <button onclick="exitFeedAndGoToCheckIn()" class="w-full bg-rose-950/50 border border-rose-500/20 text-rose-300 font-bold py-3 px-4 rounded-xl text-xs transition-colors flex items-center justify-center gap-1.5">
                            <i data-lucide="log-out" class="w-4 h-4"></i> Stop Scrolling (Exit Feed)
                        </button>
                    </div>
                </div>
            `;
            break;

        case 'check-in':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 text-center bg-[#1A1A1A]">
                    <div class="space-y-2">
                        <div class="w-12 h-12 bg-amber-950/20 border border-amber-500/30 rounded-2xl flex items-center justify-center mx-auto">
                            <i data-lucide="smile" class="w-6 h-6 text-[#B8860B]"></i>
                        </div>
                        <h3 class="text-xl font-black text-white">After-Scroll Reflection</h3>
                        <p class="text-xs text-slate-400">Pause builds self-awareness. Reflect on the 15-minute scroll session.</p>
                        ${ghostCheckInActive ? `
                            <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-rose-950/40 border border-rose-500/30 text-rose-300 text-[10px] font-bold uppercase tracking-wider mx-auto animate-pulse">
                                <i data-lucide="bell-ring" class="w-3.5 h-3.5"></i>
                                <span>Ghost Auto-Checkin: ${12 - ghostCheckInSeconds}s left</span>
                            </div>
                        ` : ''}
                    </div>

                    <div class="bg-[#232323] border border-slate-800 rounded-2xl p-5 my-auto space-y-4">
                        <h4 class="text-sm font-bold text-slate-200">"Was that time well spent?"</h4>

                        <div class="grid grid-cols-3 gap-2">
                            <button onclick="playHapticFeedback('light'); submitCheckIn('Yes, I got what I needed')" class="p-3 border border-slate-800 hover:border-emerald-500/40 hover:bg-emerald-950/10 rounded-xl flex flex-col items-center gap-1.5 transition-all">
                                <span class="text-2xl">😊</span>
                                <span class="text-[10px] text-slate-300 font-semibold leading-tight">Yes</span>
                            </button>
                            <button onclick="playHapticFeedback('light'); submitCheckIn('Not sure')" class="p-3 border border-slate-800 hover:border-amber-500/40 hover:bg-amber-950/10 rounded-xl flex flex-col items-center gap-1.5 transition-all">
                                <span class="text-2xl">😐</span>
                                <span class="text-[10px] text-slate-300 font-semibold leading-tight">Not Sure</span>
                            </button>
                            <button onclick="playHapticFeedback('light'); submitCheckIn('No, I got lost')" class="p-3 border border-slate-800 hover:border-rose-500/40 hover:bg-rose-950/10 rounded-xl flex flex-col items-center gap-1.5 transition-all">
                                <span class="text-2xl">😞</span>
                                <span class="text-[10px] text-slate-300 font-semibold leading-tight">No, Lost</span>
                            </button>
                        </div>
                    </div>

                    <div class="text-[10px] text-slate-500 leading-normal px-2">
                        Reflection is stored anonymously in your Scrollytics Dashboard database.
                    </div>
                </div>
            `;
            break;

        case 'dashboard':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-4 relative overflow-y-auto">
                    <div class="flex items-center justify-between mb-4 border-b border-slate-900 pb-2">
                        <div class="flex items-center gap-1.5">
                            <i data-lucide="bar-chart-2" class="w-4 h-4 text-indigo-400"></i>
                            <span class="text-xs font-black uppercase tracking-wider text-white">Scrollytics™</span>
                        </div>
                        <span class="text-[10px] text-slate-400">Ledger Aesthetic</span>
                    </div>

                    <div class="space-y-4">
                        <div class="bg-[#232323] border border-slate-800/80 rounded-2xl p-3.5 space-y-2.5 ledger-grid">
                            <span class="text-[11px] font-bold text-slate-400">Daily Scroll (Audited vs Unchecked)</span>
                            <div class="space-y-2 font-mono text-[10px] text-slate-300">
                                <div class="flex items-center justify-between">
                                    <span class="w-6">Wed</span>
                                    <div class="flex-1 bg-slate-800 h-2.5 mx-2 rounded overflow-hidden flex">
                                        <div class="h-full bg-[#6B8F71]" style="width: 70%"></div>
                                        <div class="h-full bg-slate-700" style="width: 30%"></div>
                                    </div>
                                    <span>${state.dailyScrollTime} min</span>
                                </div>
                                <div class="flex items-center justify-between">
                                    <span class="w-6">Tue</span>
                                    <div class="flex-1 bg-slate-800 h-2.5 mx-2 rounded overflow-hidden flex">
                                        <div class="h-full bg-[#6B8F71]" style="width: 40%"></div>
                                        <div class="h-full bg-slate-700" style="width: 60%"></div>
                                    </div>
                                    <span>48 min</span>
                                </div>
                                <div class="flex items-center justify-between">
                                    <span class="w-6">Mon</span>
                                    <div class="flex-1 bg-slate-800 h-2.5 mx-2 rounded overflow-hidden flex">
                                        <div class="h-full bg-[#6B8F71]" style="width: 50%"></div>
                                        <div class="h-full bg-slate-700" style="width: 50%"></div>
                                    </div>
                                    <span>32 min</span>
                                </div>
                            </div>
                        </div>

                        <div class="bg-[#232323] border border-slate-800/80 rounded-2xl p-4 space-y-2">
                            <span class="text-[11px] font-bold text-slate-400">Intent vs. Reality</span>
                            <div class="space-y-2 text-[10px] font-mono text-slate-300">
                                <div class="flex justify-between">
                                    <span>Relax / unwind</span>
                                    <span class="text-[#6B8F71]">😊 85%  😐 10%  😞 5%</span>
                                </div>
                                <div class="flex justify-between">
                                    <span>Kill time / bored</span>
                                    <span class="text-rose-400">😊 25%  😐 45%  😞 30%</span>
                                </div>
                            </div>
                            <p class="text-[9px] text-[#B8860B] leading-tight pt-1">
                                💡 Tip: "Kill time" sessions are twice as likely to end with regret.
                            </p>
                        </div>

                        ${(!state.hasPremium && state.simulatedDaysElapsed >= 8) ? `
                            <div class="bg-indigo-950/20 border border-indigo-500/30 rounded-2xl p-4 text-left space-y-1.5">
                                <div class="flex items-center gap-1.5 text-indigo-400">
                                    <i data-lucide="sparkles" class="w-4 h-4"></i>
                                    <span class="text-[10px] font-bold uppercase tracking-wider">Curiosity Nudge (Day ${state.simulatedDaysElapsed} of journey)</span>
                                </div>
                                <p class="text-[11px] text-slate-300 leading-normal">
                                    You have built a <strong>${state.streak}-day</strong> mindful scrolling streak! Upgrade to Pause Pro to unlock month-over-month graphs and identify your biggest attention sinks.
                                </p>
                                <button onclick="changeScreen('premium-modal')" class="text-[10px] text-indigo-300 hover:text-indigo-200 font-bold underline flex items-center gap-0.5 pt-0.5">
                                    Upgrade to Pause Pro <i data-lucide="chevron-right" class="w-3.5 h-3.5"></i>
                                </button>
                            </div>
                        ` : ''}

                        <div class="relative bg-[#232323] border border-slate-800/80 p-4 rounded-2xl overflow-hidden flex flex-col items-center justify-center text-center">
                            ${!state.hasPremium ? `
                                <div class="absolute inset-0 bg-[#1A1A1A]/90 rounded-2xl backdrop-blur-sm z-10 flex flex-col items-center justify-center p-3">
                                    <i data-lucide="lock" class="w-4.5 h-4.5 text-[#B8860B] mb-1"></i>
                                    <span class="text-[10px] font-bold text-white uppercase tracking-wider">Locked (Requires Pause Pro)</span>
                                    <button onclick="changeScreen('premium-modal')" class="text-[9px] text-[#B8860B] font-bold underline mt-0.5">Upgrade for $39.99/yr</button>
                                </div>
                            ` : ''}
                            <span class="text-[11px] font-bold text-slate-400 mb-2">Month-over-Month historical trend</span>
                            <div class="h-10 w-full bg-slate-800/20 rounded"></div>
                        </div>
                    </div>

                    <div class="grid grid-cols-4 border-t border-slate-900 pt-3 mt-4">
                        <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                            <i data-lucide="home" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Home</span>
                        </button>
                        <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-[#B8860B]">
                            <i data-lucide="bar-chart-2" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Scrollytics</span>
                        </button>
                        <button onclick="changeScreen('garden-shop')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                            <i data-lucide="shopping-bag" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Garden</span>
                        </button>
                        <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 ${state.hasPremium ? 'text-amber-500' : 'text-slate-500 hover:text-slate-300'} transition-colors">
                            <i data-lucide="award" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Pause Pro</span>
                        </button>
                    </div>

                </div>
            `;
            break;

        case 'garden-shop':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-4 relative overflow-y-auto">
                    <div class="flex items-center justify-between border-b border-slate-900 pb-2 mb-3">
                        <span class="text-xs font-black uppercase tracking-wider text-white">Focus Garden &amp; Shop</span>
                        <div class="flex items-center gap-1 bg-[#232323] px-2 py-0.5 rounded-full border border-slate-800">
                            <i data-lucide="star" class="w-3.5 h-3.5 text-[#B8860B]"></i>
                            <span class="text-[10px] font-bold text-white font-mono">${state.tokens}</span>
                        </div>
                    </div>

                    <div class="space-y-3.5 flex-1 max-h-[360px] overflow-y-auto pr-1">
                        <!-- Pazu Wearable Cosmetics -->
                        <div class="p-3 bg-[#232323] border border-slate-800 rounded-xl space-y-2">
                            <div class="text-xs font-bold text-white">Pazu Wearables</div>
                            <div class="grid grid-cols-2 gap-2">
                                ${[
                                    { name: 'Leaf Crown', cost: 5, type: 'Hat' },
                                    { name: 'Straw Hat', cost: 10, type: 'Hat' },
                                    { name: 'Round Glasses', cost: 5, type: 'Glasses' },
                                    { name: 'Red Scarf', cost: 5, type: 'Scarf' }
                                ].map(item => {
                                    const unlocked = state.unlockedPazuItems.includes(item.name);
                                    const selected = state.pazuHat === item.name || state.pazuGlasses === item.name || state.pazuScarf === item.name;
                                    return `
                                        <button onclick="interactPazuWearable('${item.type}', '${item.name}', ${item.cost})" class="p-2 border text-center rounded-xl text-[10px] transition-all ${selected ? 'border-[#B8860B] bg-[#B8860B]/10 text-[#B8860B]' : unlocked ? 'border-slate-800 text-slate-300' : 'border-slate-800/40 text-slate-500'}">
                                            <div>${item.name}</div>
                                            <div class="text-[8px] font-bold font-mono text-slate-400 mt-1">
                                                ${selected ? 'Equipped' : unlocked ? 'Equip' : item.cost + ' ★'}
                                            </div>
                                        </button>
                                    `;
                                }).join('')}
                            </div>
                        </div>

                        <!-- Bonsai Seasons -->
                        <div class="p-3 bg-[#232323] border border-slate-800 rounded-xl space-y-2">
                            <div class="text-xs font-bold text-white">Bonsai Seasons</div>
                            <div class="grid grid-cols-2 gap-2">
                                ${['Spring', 'Summer', 'Autumn', 'Winter'].map(season => {
                                    const unlocked = state.unlockedSeasons.includes(season);
                                    const selected = state.selectedBonsaiSeason === season;
                                    const cost = season === 'Summer' ? 5 : season === 'Autumn' ? 15 : season === 'Winter' ? 25 : 0;
                                    return `
                                        <button onclick="interactGardenItem('Season', '${season}', ${cost})" class="p-2 border text-center rounded-xl text-[10px] transition-all ${selected ? 'border-[#B8860B] bg-[#B8860B]/10 text-[#B8860B]' : unlocked ? 'border-slate-800 text-slate-300' : 'border-slate-800/40 text-slate-500'}">
                                            <div>${season}</div>
                                            <div class="text-[8px] font-bold font-mono text-slate-400 mt-1">
                                                ${selected ? 'Selected' : unlocked ? 'Equip' : cost + ' ★'}
                                            </div>
                                        </button>
                                    `;
                                }).join('')}
                            </div>
                        </div>

                        <!-- Koi Colors -->
                        <div class="p-3 bg-[#232323] border border-slate-800 rounded-xl space-y-2">
                            <div class="text-xs font-bold text-white">Koi Pond Colors</div>
                            <div class="grid grid-cols-2 gap-2">
                                ${['Orange', 'White', 'Black', 'Gold'].map(color => {
                                    const unlocked = state.unlockedKoiColors.includes(color);
                                    const selected = state.koiColor === color;
                                    const cost = color === 'White' ? 10 : color === 'Black' ? 20 : color === 'Gold' ? 30 : 0;
                                    return `
                                        <button onclick="interactGardenItem('Koi', '${color}', ${cost})" class="p-2 border text-center rounded-xl text-[10px] transition-all ${selected ? 'border-[#B8860B] bg-[#B8860B]/10 text-[#B8860B]' : unlocked ? 'border-slate-800 text-slate-300' : 'border-slate-800/40 text-slate-500'}">
                                            <div>${color} Koi</div>
                                            <div class="text-[8px] font-bold font-mono text-slate-400 mt-1">
                                                ${selected ? 'Selected' : unlocked ? 'Equip' : cost + ' ★'}
                                            </div>
                                        </button>
                                    `;
                                }).join('')}
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-4 border-t border-slate-900 pt-3 mt-4">
                        <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                            <i data-lucide="home" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Home</span>
                        </button>
                        <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                            <i data-lucide="bar-chart-2" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Scrollytics</span>
                        </button>
                        <button onclick="changeScreen('garden-shop')" class="flex flex-col items-center gap-1 text-[#B8860B]">
                            <i data-lucide="shopping-bag" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Garden</span>
                        </button>
                        <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 ${state.hasPremium ? 'text-amber-500' : 'text-slate-500 hover:text-slate-300'} transition-colors">
                            <i data-lucide="award" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Pause Pro</span>
                        </button>
                    </div>
                </div>
            `;
            break;

        case 'settings':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-4 relative overflow-y-auto">
                    <div class="flex items-center gap-2 border-b border-slate-900 pb-2.5 mb-3.5">
                        <button onclick="changeScreen('home')" class="w-6 h-6 hover:bg-slate-900 rounded flex items-center justify-center text-slate-400">
                            <i data-lucide="chevron-left" class="w-4.5 h-4.5"></i>
                        </button>
                        <span class="text-xs font-black uppercase tracking-wider text-white">Settings Configuration</span>
                    </div>

                    <div class="space-y-4 flex-1">
                        <div class="space-y-1.5">
                            <label class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Pause Duration</label>
                            <div class="grid grid-cols-4 gap-1.5">
                                ${[5, 10, 15, 30].map(sec => `
                                    <button onclick="updateSettingsField('pauseDuration', ${sec})" class="py-2 border ${state.pauseDuration === sec ? 'border-[#B8860B] bg-[#B8860B]/10 text-[#B8860B]' : 'border-slate-800'} rounded-xl text-xs font-bold transition-all">
                                        ${sec}s
                                    </button>
                                `).join('')}
                            </div>
                        </div>

                        <div class="flex items-center justify-between p-3 bg-[#232323] rounded-xl border border-slate-800">
                            <div>
                                <div class="text-xs font-bold text-slate-200">Intention Prompt</div>
                                <div class="text-[10px] text-slate-400">Ask "What are you here for?" first</div>
                            </div>
                            <button onclick="toggleIntentionPrompt()" class="w-9 h-5 rounded-full p-0.5 transition-colors duration-200 ${state.enableIntentionPrompt ? 'bg-indigo-600' : 'bg-slate-700'}">
                                <div class="bg-white w-4 h-4 rounded-full shadow-md transform duration-200 ${state.enableIntentionPrompt ? 'translate-x-4' : 'translate-x-0'}"></div>
                            </button>
                        </div>

                        <div class="p-3 bg-[#232323] rounded-xl border border-slate-800 space-y-2">
                            <label class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Edit Managed Apps</label>
                            <div class="grid grid-cols-2 gap-2">
                                ${['Instagram', 'TikTok', 'YouTube', 'Snapchat', 'Reddit', 'Facebook'].map(app => {
                                    const checked = state.managedApps.includes(app);
                                    return `
                                        <button onclick="toggleManagedApp('${app}')" class="p-2 border text-center rounded-xl text-[10px] transition-all ${checked ? 'border-[#B8860B] bg-[#B8860B]/5 text-slate-200' : 'border-slate-800 text-slate-500'}">
                                            ${app}
                                        </button>
                                    `;
                                }).join('')}
                            </div>
                        </div>

                        <div class="p-3 bg-[#232323] rounded-xl border border-slate-800 space-y-2 relative">
                            ${!state.hasPremium ? `
                                <div class="absolute inset-0 bg-[#1A1A1A]/90 rounded-xl backdrop-blur-sm z-10 flex flex-col items-center justify-center text-center p-3">
                                    <i data-lucide="lock" class="w-4 h-4 text-amber-500 mb-1"></i>
                                    <span class="text-[10px] font-bold text-white uppercase tracking-wider">Requires Pro</span>
                                    <button onclick="changeScreen('premium-modal')" class="text-[9px] text-[#B8860B] font-bold underline mt-0.5">Upgrade for $39.99/yr</button>
                                </div>
                            ` : ''}

                            <div class="flex items-center justify-between">
                                <div>
                                    <div class="text-xs font-bold text-slate-200">Quiet Hours</div>
                                    <div class="text-[10px] text-slate-400">Suppress nudges at custom time</div>
                                </div>
                                <button onclick="toggleQuietHours()" class="w-9 h-5 rounded-full p-0.5 transition-colors duration-200 ${state.enableQuietHours ? 'bg-indigo-600' : 'bg-slate-700'}">
                                    <div class="bg-white w-4 h-4 rounded-full shadow-md transform duration-200 ${state.enableQuietHours ? 'translate-x-4' : 'translate-x-0'}"></div>
                                </button>
                            </div>
                        </div>

                        <div class="pt-2 border-t border-slate-900">
                            <button onclick="deleteAccountAndAllData()" class="w-full bg-rose-950/30 hover:bg-rose-950/50 border border-rose-500/20 text-rose-300 font-bold py-3 rounded-xl text-xs transition-colors flex items-center justify-center gap-1.5">
                                <i data-lucide="trash-2" class="w-4 h-4"></i> Delete All My Data &amp; Account
                            </button>
                        </div>
                    </div>

                    <button onclick="changeScreen('home')" class="w-full bg-slate-900 hover:bg-slate-800 border border-slate-800 text-white font-bold py-2.5 rounded-xl text-xs transition-colors mt-3">
                        Save & Return
                    </button>
                </div>
            `;
            break;

        case 'premium-modal':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-5 relative overflow-y-auto">
                    <div class="text-center space-y-1 mt-2">
                        <div class="w-11 h-11 bg-amber-500/10 border border-amber-500/30 rounded-2xl flex items-center justify-center mx-auto text-amber-500 mb-2">
                            <i data-lucide="award" class="w-6 h-6 animate-bounce"></i>
                        </div>
                        <h3 class="text-xl font-black text-white">Unlock Pause Pro</h3>
                        <p class="text-xs text-slate-400">Full annual commitment to intentional growth.</p>
                    </div>

                    ${state.hasPremium ? `
                        <div class="my-auto bg-[#232323] border border-[#B8860B]/20 p-5 rounded-2xl space-y-3 text-center">
                            <span class="text-2xl">🎉</span>
                            <h4 class="text-sm font-bold text-[#B8860B]">You are in Pause Pro</h4>
                            <p class="text-[11px] text-slate-300 leading-relaxed">
                                Thank you for your subscription of $39.99/year. Feel good about trying. You have full access to custom breathing, quiet hours, and historical Scrollytics trends.
                            </p>
                            <button onclick="cancelPremiumSubscription()" class="text-[10px] text-rose-400 font-bold underline">
                                Sim Cancellation
                            </button>
                        </div>
                    ` : `
                        <div class="my-auto space-y-3.5">
                            <button onclick="upgradeToPremium(39.99, 'Annual')" class="w-full text-left p-4 bg-[#232323] hover:bg-indigo-950/10 border border-[#B8860B]/30 rounded-2xl transition-all relative">
                                <span class="absolute right-4 top-4 text-[9px] bg-[#B8860B]/20 text-[#B8860B] px-1.5 py-0.5 rounded-full font-bold">BEST VALUE</span>
                                <div class="text-xs font-black text-slate-200">Annual Membership</div>
                                <div class="text-lg font-extrabold text-white mt-0.5">$39.99 <span class="text-xs font-normal text-slate-500">/ year</span></div>
                                <p class="text-[10px] text-slate-400 mt-1">7-Day Free Trial included. Standard Apple StoreKit native purchase.</p>
                            </button>
                        </div>
                    `}

                    <div class="space-y-3">
                        ${!state.hasPremium ? `
                            <button onclick="upgradeToPremium(39.99, 'Annual')" class="w-full bg-gradient-to-r from-[#B8860B] to-amber-700 hover:from-amber-600 hover:to-amber-500 text-white font-bold py-3 px-4 rounded-full text-xs transition-all flex items-center justify-center gap-1.5">
                                <i data-lucide="credit-card" class="w-4 h-4"></i> Start 7-Day Free Trial
                            </button>
                        ` : ''}

                        <div class="grid grid-cols-4 border-t border-slate-900 pt-3">
                            <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                                <i data-lucide="home" class="w-4.5 h-4.5"></i>
                                <span class="text-[9px] font-bold">Home</span>
                            </button>
                            <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                                <i data-lucide="bar-chart-2" class="w-4.5 h-4.5"></i>
                                <span class="text-[9px] font-bold">Scrollytics</span>
                            </button>
                            <button onclick="changeScreen('garden-shop')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                                <i data-lucide="shopping-bag" class="w-4.5 h-4.5"></i>
                                <span class="text-[9px] font-bold">Garden</span>
                            </button>
                            <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 text-[#B8860B]">
                                <i data-lucide="award" class="w-4.5 h-4.5"></i>
                                <span class="text-[9px] font-bold">Pause Pro</span>
                            </button>
                        </div>
                    </div>
                </div>
            `;
            break;
    }

    if (window.lucide) {
        window.lucide.createIcons();
    }
}

function interactPazuWearable(type, name, cost) {
    if (state.tokens >= cost || state.unlockedPazuItems.includes(name)) {
        if (!state.unlockedPazuItems.includes(name)) {
            state.tokens -= cost;
            state.unlockedPazuItems.push(name);
        }

        if (type === 'Hat') state.pazuHat = (state.pazuHat === name ? 'None' : name);
        if (type === 'Glasses') state.pazuGlasses = (state.pazuGlasses === name ? 'None' : name);
        if (type === 'Scarf') state.pazuScarf = (state.pazuScarf === name ? 'None' : name);

        saveState();
        logAction('Pazu Store', `Equipped ${name}`);
        renderCurrentScreen();
    } else {
        alert(`Need ${cost} ★ tokens to buy ${name}`);
    }
}

function interactGardenItem(type, name, cost) {
    if (state.tokens >= cost) {
        if (type === 'Season') {
            if (!state.unlockedSeasons.includes(name)) {
                state.tokens -= cost;
                state.unlockedSeasons.push(name);
            }
            state.selectedBonsaiSeason = name;
        } else {
            if (!state.unlockedKoiColors.includes(name)) {
                state.tokens -= cost;
                state.unlockedKoiColors.push(name);
            }
            state.koiColor = name;
        }
        saveState();
        logAction('Garden Store', `Equipped ${name} ${type}`);
        renderCurrentScreen();
    } else {
        alert(`Insufficient tokens! You need ${cost} ★ tokens.`);
    }
}

function changeScreen(screenName) {
    if (pauseGateTimer) clearInterval(pauseGateTimer);
    if (feedTimer) clearInterval(feedTimer);
    currentScreen = screenName;
    renderCurrentScreen();
}

function toggleManagedApp(app) {
    const idx = state.managedApps.indexOf(app);
    if (idx > -1) {
        state.managedApps.splice(idx, 1);
        logAction('Settings Changed', `Removed app: ${app}`);
    } else {
        state.managedApps.push(app);
        logAction('Settings Changed', `Added app: ${app}`);
    }
    saveState();
    renderCurrentScreen();
}

function setPauseDuration(sec) {
    state.pauseDuration = sec;
    saveState();
    logAction('Settings Changed', `Pause duration set to ${sec}s`);
    renderCurrentScreen();
}

function completeOnboarding() {
    state.onboarded = true;
    saveState();
    logAction('Welcome to Pause', 'Completed onboarding guide. Met Pazu!');
    changeScreen('home');
}

function submitCheckIn(ratingText) {
    if (ghostCheckInTimer) {
        clearInterval(ghostCheckInTimer);
        ghostCheckInTimer = null;
    }
    ghostCheckInActive = false;

    state.checkedInCount++;
    state.lastCheckInRating = ratingText;
    state.tokens += 3;

    updatePazuBehavior();
    logAction(`Check-In Reflect`, `Session rated: ${ratingText} (+3 Tokens awarded)`);
    saveState();
    changeScreen('home');
}

function updateSettingsField(field, value) {
    state[field] = value;
    saveState();
    logAction('Settings Changed', `${field} updated to ${value}`);
    renderCurrentScreen();
}

function toggleIntentionPrompt() {
    state.enableIntentionPrompt = !state.enableIntentionPrompt;
    saveState();
    logAction('Settings Changed', `Intention Prompt toggled: ${state.enableIntentionPrompt ? 'ON' : 'OFF'}`);
    renderCurrentScreen();
}

function toggleQuietHours() {
    state.enableQuietHours = !state.enableQuietHours;
    saveState();
    logAction('Settings Changed', `Quiet Hours toggled: ${state.enableQuietHours ? 'ON' : 'OFF'}`);
    renderCurrentScreen();
}

function upgradeToPremium(price, tier) {
    state.hasPremium = true;
    saveState();
    logAction('Premium Subscribed', `Upgraded to Pause Pro Annual Plan ($39.99/yr)`);
    triggerSandboxCelebrationSparkles();
    renderCurrentScreen();
}

function cancelPremiumSubscription() {
    state.hasPremium = false;
    saveState();
    logAction('Premium Cancelled', 'Simulated subscription cancellation.');
    renderCurrentScreen();
}

function triggerSandboxCelebrationSparkles() {
    const container = document.getElementById('phone-app-container');
    if (!container) return;

    for (let i = 0; i < 25; i++) {
        const sparkle = document.createElement('div');
        sparkle.className = 'celebration-sparkle';
        sparkle.style.backgroundColor = `hsl(${Math.random() * 360}, 100%, 70%)`;
        sparkle.style.left = `${Math.random() * 100}%`;
        sparkle.style.top = `${Math.random() * 100}%`;

        container.appendChild(sparkle);
        setTimeout(() => sparkle.remove(), 800);
    }
}

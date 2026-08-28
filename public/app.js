// Pause SaaS Sandbox - Core Application Logic
// Washi Paper Minimalism Implementation with ZERO Emojis

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
        { time: '11:45 AM', action: 'Check-In Completed', result: 'Rated: Neutral [Dash]' },
        { time: '02:15 PM', action: 'App Opened: YouTube', result: 'Resisted / Closed App' },
        { time: '06:00 PM', action: 'App Opened: Reddit', result: 'Continued (15 min feed)' },
        { time: '06:15 PM', action: 'Check-In Completed', result: 'Rated: Positive [Circle]' }
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
        if (roll < 0.05) { // 5% chance of clumsy fall
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
        tierText.innerText = state.hasPremium ? 'Pause Pro ($39.99/yr)' : 'Free Tier ($0/mo)';
        tierText.className = state.hasPremium ? 'text-sm font-bold text-[#E07A5F]' : 'text-sm font-bold text-[#2B2D42]';
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
            <div class="flex items-start justify-between py-1 border-b border-[#E8E4D9] hover:bg-[#E5E0D5]/20 transition-all">
                <span class="text-[#E07A5F] shrink-0 select-all mr-2 font-semibold">[${log.time}]</span>
                <span class="text-[#2B2D42] flex-1 select-all mr-2">${log.action}</span>
                <span class="text-[#81B29A] shrink-0 font-medium">${log.result}</span>
            </div>
        `).join('') || '<div class="text-[#8D8F9A] text-center py-4">No logged activities yet. Try triggering the Pause Gate on the left.</div>';
    }

    if (window.lucide) {
        window.lucide.createIcons();
    }
}

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
    state.lastCheckInRating = 'Neutral [Dash]';
    state.tokens += 1;

    logAction('Ghost Auto-Logged', '12s elapsed. Auto-logged Neutral [Dash]');
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

// Render Pazu Red Panda Shoulders-Up App Icon Frame in 32-Bit Pixel-Art Style (NO EMOJIS)
function renderPazuCharacter() {
    let pazuActionText = 'Pazu is resting in the Zen Garden';

    switch (state.pazuState) {
        case 'happy':
            pazuActionText = 'Pazu waves happily! "I\'m happy to see you!"';
            break;
        case 'proud':
            pazuActionText = 'Pazu stands proud of your mindful streak!';
            break;
        case 'clumsy':
            pazuActionText = 'Pazu tripped over its bushy tail! "Eep!" (Clumsy 5% chance)';
            break;
        case 'sleeping':
            pazuActionText = 'Pazu is curled up asleep under the tree...';
            break;
        case 'curious':
            pazuActionText = 'Pazu is curiously exploring the bamboo grove...';
            break;
        case 'excited':
            pazuActionText = 'Pazu is bouncing with excitement!';
            break;
        case 'meditating':
            pazuActionText = 'Pazu is meditating peacefully in the garden...';
            break;
        case 'playing':
            pazuActionText = 'Pazu is chasing falling cherry blossom leaves!';
            break;
        case 'eating':
            pazuActionText = 'Pazu is munching on fresh bamboo treats!';
            break;
        default:
            pazuActionText = 'Pazu the Red Panda is breathing calmly.';
            break;
    }

    // Draw 32-Bit Pixel Art Pazu Canvas HTML
    setTimeout(() => {
        const canvas = document.getElementById('pazu-pixel-canvas');
        if (canvas && canvas.getContext) {
            const ctx = canvas.getContext('2d');
            ctx.clearRect(0, 0, 128, 128);
            const pixelSize = 4; // 128 / 32 = 4px per grid unit

            function drawPixel(x, y, color) {
                ctx.fillStyle = color;
                ctx.fillRect(x * pixelSize, y * pixelSize, pixelSize, pixelSize);
            }

            function drawRect(x, y, w, h, color) {
                for (let px = x; px < x + w; px++) {
                    for (let py = y; py < y + h; py++) {
                        drawPixel(px, py, color);
                    }
                }
            }

            const orange = '#E07A5F';
            const cream = '#FDF1E7';
            const ink = '#2B2D42';
            const sage = '#81B29A';

            // 32-bit Pazu Shoulders-Up
            drawRect(8, 22, 16, 10, orange);
            drawRect(13, 22, 6, 8, cream);

            // Ears
            drawRect(7, 5, 5, 6, orange);
            drawRect(8, 6, 3, 4, cream);
            drawRect(20, 5, 5, 6, orange);
            drawRect(21, 6, 3, 4, cream);

            // Head
            drawRect(8, 10, 16, 13, orange);
            drawRect(11, 16, 10, 6, cream);
            drawRect(9, 17, 14, 4, cream);

            // Nose
            drawRect(15, 16, 2, 2, ink);

            // Eyes
            if (state.pazuState === 'happy' || state.pazuState === 'proud') {
                drawPixel(11, 14, ink);
                drawPixel(12, 13, ink);
                drawPixel(13, 14, ink);
                drawPixel(18, 14, ink);
                drawPixel(19, 13, ink);
                drawPixel(20, 14, ink);
            } else if (state.pazuState === 'sleeping') {
                drawRect(11, 14, 3, 1, ink);
                drawRect(18, 14, 3, 1, ink);
            } else {
                drawRect(11, 13, 3, 3, ink);
                drawRect(18, 13, 3, 3, ink);
                drawPixel(12, 13, '#FFFFFF');
                drawPixel(19, 13, '#FFFFFF');
            }

            // Accessories
            if (state.pazuScarf && state.pazuScarf !== 'None') {
                drawRect(9, 21, 14, 3, '#E07A5F');
                drawRect(18, 23, 3, 5, '#E07A5F');
            }
            if (state.pazuGlasses && state.pazuGlasses !== 'None') {
                drawRect(10, 12, 5, 5, ink);
                drawRect(11, 13, 3, 3, cream);
                drawRect(17, 12, 5, 5, ink);
                drawRect(18, 13, 3, 3, cream);
                drawRect(14, 13, 4, 1, ink);
            }
            if (state.pazuHat && state.pazuHat !== 'None') {
                if (state.pazuHat === 'Leaf Crown') {
                    drawRect(12, 7, 8, 3, sage);
                    drawPixel(15, 6, sage);
                } else {
                    drawRect(6, 8, 20, 2, sage);
                    drawRect(10, 3, 12, 5, sage);
                }
            }
        }
    }, 50);

    return `
        <div class="relative w-48 h-48 bg-[#FFFFFF] border border-[#E8E4D9] rounded-3xl mx-auto flex flex-col items-center justify-center overflow-hidden shadow-lg p-2">
            <!-- Washi Paper Shoulders-Up 32-Bit Pixel App Icon Container -->
            <div class="z-10 flex flex-col items-center text-center">
                <div class="relative w-20 h-20 bg-[#F8F6F0] border-2 border-[#E07A5F] rounded-2xl flex items-center justify-center shadow-md overflow-hidden">
                    <canvas id="pazu-pixel-canvas" width="128" height="128" class="w-full h-full object-contain image-rendering-pixelated"></canvas>
                </div>
                <div class="text-xs font-black text-[#2B2D42] mt-2 tracking-wide">32-Bit Pazu App Icon</div>
                <div class="text-[10px] text-[#E07A5F] font-semibold px-2 leading-tight mt-0.5">${pazuActionText}</div>
            </div>
        </div>
    `;
}

// Render dynamic views inside the Mock Smartphone viewport
function renderCurrentScreen() {
    const screen = document.getElementById('screen-container');
    if (!screen) return;

    screen.className = "relative w-full h-full flex flex-col bg-[#F8F6F0] text-[#2B2D42] animate-fade-in";

    switch (currentScreen) {
        case 'onboarding-1':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 relative overflow-hidden">
                    <div class="flex gap-1.5 w-full">
                        <div class="h-1 flex-1 bg-[#E07A5F] rounded-full"></div>
                        <div class="h-1 flex-1 bg-[#E8E4D9] rounded-full"></div>
                        <div class="h-1 flex-1 bg-[#E8E4D9] rounded-full"></div>
                    </div>

                    <div class="my-auto space-y-6 text-center z-10">
                        <div class="w-20 h-20 bg-[#E07A5F]/10 border border-[#E07A5F]/30 rounded-2xl flex items-center justify-center mx-auto shadow-sm">
                            <i data-lucide="compass" class="w-10 h-10 text-[#E07A5F]"></i>
                        </div>
                        <h3 class="text-3xl font-black tracking-tight text-[#2B2D42] leading-tight">
                            "You don't have to quit. You just have to <span class="text-[#E07A5F]">pause.</span>"
                        </h3>
                        <p class="text-[#8D8F9A] text-xs leading-relaxed px-4">
                            Welcome to Washi Paper Minimalism. Meet Pazu the Red Panda, your gentle companion helping you align screen intent with reality.
                        </p>
                    </div>

                    <div class="space-y-3 z-10">
                        <button onclick="changeScreen('onboarding-2')" class="w-full bg-[#E07A5F] hover:bg-[#d0694e] text-white font-bold py-3.5 px-4 rounded-full shadow-md transition-all text-xs flex items-center justify-center gap-2">
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
                        <div class="h-1 flex-1 bg-[#E07A5F] rounded-full"></div>
                        <div class="h-1 flex-1 bg-[#E07A5F] rounded-full"></div>
                        <div class="h-1 flex-1 bg-[#E8E4D9] rounded-full"></div>
                    </div>

                    <div class="my-auto space-y-4">
                        <div class="text-center">
                            <h3 class="text-xl font-bold text-[#2B2D42] mb-1">Managed Social Networks</h3>
                            <p class="text-[10px] text-[#8D8F9A]">Select social apps that you wish to pause before scrolling.</p>
                        </div>

                        <div class="space-y-2 max-h-[260px] overflow-y-auto pr-1">
                            ${['Instagram', 'TikTok', 'YouTube', 'Snapchat', 'Reddit', 'Facebook'].map(app => {
                                const checked = state.managedApps.includes(app);
                                return `
                                    <label class="flex items-center justify-between p-3 bg-[#FFFFFF] border ${checked ? 'border-[#E07A5F] bg-[#E07A5F]/5' : 'border-[#E8E4D9]'} rounded-xl cursor-pointer transition-colors">
                                        <span class="text-xs font-semibold text-[#2B2D42]">${app}</span>
                                        <input type="checkbox" onchange="toggleManagedApp('${app}')" ${checked ? 'checked' : ''} class="w-4.5 h-4.5 rounded text-[#E07A5F] bg-[#F8F6F0] border-[#E8E4D9] focus:ring-[#E07A5F]">
                                    </label>
                                `;
                            }).join('')}
                        </div>
                    </div>

                    <div>
                        <button onclick="changeScreen('onboarding-3')" class="w-full bg-[#E07A5F] hover:bg-[#d0694e] text-white font-bold py-3.5 px-4 rounded-full shadow-md transition-all text-xs flex items-center justify-center gap-2">
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
                        <div class="h-1 flex-1 bg-[#E07A5F] rounded-full"></div>
                        <div class="h-1 flex-1 bg-[#E07A5F] rounded-full"></div>
                        <div class="h-1 flex-1 bg-[#E07A5F] rounded-full"></div>
                    </div>

                    <div class="my-auto space-y-5 text-center">
                        <div class="w-16 h-16 bg-[#E07A5F]/10 border border-[#E07A5F]/30 rounded-full flex items-center justify-center mx-auto">
                            <i data-lucide="timer" class="w-8 h-8 text-[#E07A5F]"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-[#2B2D42] mb-1">Set your Pause duration</h3>
                            <p class="text-xs text-[#8D8F9A]">Choose custom breathing interval times.</p>
                        </div>

                        <div class="grid grid-cols-2 gap-2 max-w-xs mx-auto">
                            ${[5, 10, 15, 30].map(sec => `
                                <button onclick="setPauseDuration(${sec})" class="py-3 px-4 border ${state.pauseDuration === sec ? 'border-[#E07A5F] bg-[#E07A5F]/10 text-[#E07A5F]' : 'border-[#E8E4D9] bg-[#FFFFFF] hover:border-slate-300'} rounded-xl text-xs font-bold transition-all">
                                    ${sec} Seconds
                                </button>
                            `).join('')}
                        </div>
                    </div>

                    <div>
                        <button onclick="completeOnboarding()" class="w-full bg-[#E07A5F] hover:bg-[#d0694e] text-white font-bold py-3.5 px-4 rounded-full shadow-md transition-all text-xs flex items-center justify-center gap-2">
                            <span>Start My Journey</span>
                            <i data-lucide="sparkles" class="w-4 h-4"></i>
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
                            <i data-lucide="flame" class="w-4 h-4 text-[#E07A5F]"></i>
                            <span class="text-xs text-[#2B2D42] font-bold">Day ${state.streak}</span>
                        </div>
                        <div class="flex items-center gap-3">
                            <div class="flex items-center gap-1.5">
                                <i data-lucide="sun" class="w-4 h-4 text-[#81B29A]"></i>
                                <span class="text-xs font-bold text-[#E07A5F]">★ ${state.tokens}</span>
                            </div>
                            <button onclick="changeScreen('settings')" class="w-7 h-7 rounded-lg bg-[#FFFFFF] border border-[#E8E4D9] flex items-center justify-center text-[#8D8F9A] hover:text-[#2B2D42] transition-colors">
                                <i data-lucide="settings" class="w-4 h-4"></i>
                            </button>
                        </div>
                    </div>

                    <div class="my-auto space-y-4 text-center">
                        ${renderPazuCharacter()}

                        <div class="space-y-1">
                            <span class="text-[10px] text-[#8D8F9A] font-semibold tracking-wider uppercase">Today's Scroll Time</span>
                            <div class="flex items-baseline justify-center gap-1">
                                <span class="text-4xl font-extrabold text-[#2B2D42] tracking-tight font-mono">${state.dailyScrollTime}</span>
                                <span class="text-xs font-semibold text-[#8D8F9A]">Minutes</span>
                            </div>
                        </div>

                        <button onclick="triggerAppLaunch('Instagram')" class="w-full bg-[#E07A5F] hover:bg-[#d0694e] text-white font-bold py-3.5 px-4 rounded-full shadow-md transition-all text-xs flex items-center justify-center gap-2">
                            <i data-lucide="leaf" class="w-4 h-4"></i>
                            <span>Start Mindful Session</span>
                            <i data-lucide="arrow-right-circle" class="w-4 h-4"></i>
                        </button>
                    </div>

                    <div class="grid grid-cols-4 border-t border-[#E8E4D9] pt-3 mt-4">
                        <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-[#E07A5F]">
                            <i data-lucide="home" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Home</span>
                        </button>
                        <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-[#8D8F9A] hover:text-[#2B2D42] transition-colors">
                            <i data-lucide="bar-chart-2" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Scrollytics</span>
                        </button>
                        <button onclick="changeScreen('garden-shop')" class="flex flex-col items-center gap-1 text-[#8D8F9A] hover:text-[#2B2D42] transition-colors">
                            <i data-lucide="shopping-bag" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Shop</span>
                        </button>
                        <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 ${state.hasPremium ? 'text-[#E07A5F]' : 'text-[#8D8F9A] hover:text-[#2B2D42]'} transition-colors">
                            <i data-lucide="award" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Pause Pro</span>
                        </button>
                    </div>

                </div>
            `;
            break;

        case 'pause-gate':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 relative overflow-hidden bg-[#F8F6F0]">
                    <div class="space-y-2 text-center mt-2 z-10">
                        <h4 class="text-xs font-bold text-[#8D8F9A] tracking-widest uppercase">${simulatedAppToOpen} PAUSED</h4>
                        <p class="text-lg text-[#2B2D42] font-bold italic serif-brand">"What brings you here?"</p>
                    </div>

                    <div class="my-auto space-y-3 z-10">
                        <div class="grid grid-cols-2 gap-2">
                            ${['Relax / unwind', 'Connect w/ friends', 'Kill time / bored', 'Work / research'].map(chip => {
                                const isSel = (selectedIntentChip === chip);
                                return `
                                    <button onclick="toggleIntentChipSelection('${chip}')" class="intent-chip text-left p-3 border ${isSel ? 'border-[#E07A5F] bg-[#E07A5F]/10 text-[#E07A5F]' : 'border-[#E8E4D9] bg-[#FFFFFF] text-[#2B2D42]'} rounded-xl text-xs font-bold transition-all">
                                        ${chip}
                                    </button>
                                `;
                            }).join('')}
                        </div>
                    </div>

                    <div class="space-y-4 z-10">
                        <button onclick="playHapticFeedback('heavy'); startScrollSimulator(simulatedAppToOpen, 'touch', selectedIntentChip);" class="arcade-button w-full py-4 text-xs font-extrabold tracking-widest uppercase flex items-center justify-center gap-2 bg-[#E07A5F] text-white rounded-full shadow-md">
                            <span>YES, LET ME IN</span>
                            <i data-lucide="arrow-right-circle" class="w-4 h-4"></i>
                        </button>

                        <div class="text-center">
                            <button onclick="triggerHardwareBypass()" class="text-[10px] text-[#8D8F9A] hover:text-[#2B2D42] underline tracking-wide">
                                skip this gate by double-tapping side button
                            </button>
                        </div>
                    </div>

                </div>
            `;
            break;

        case 'scrolling-feed':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col bg-[#F8F6F0] relative">
                    <div class="px-4 py-3 border-b border-[#E8E4D9] bg-[#FFFFFF] flex items-center justify-between">
                        <div class="flex items-center gap-2">
                            <span class="w-2 h-2 rounded-full bg-[#E07A5F] animate-pulse"></span>
                            <span class="text-xs font-bold text-[#2B2D42] tracking-wide uppercase">${simulatedAppToOpen} Sim</span>
                        </div>
                        <div class="flex items-center gap-1 text-[#8D8F9A] text-xs bg-[#F8F6F0] px-2 py-1 rounded-full border border-[#E8E4D9]">
                            <i data-lucide="timer" class="w-3.5 h-3.5 text-[#E07A5F]"></i>
                            <span id="feed-timer-countdown" class="font-mono">15:00</span>
                        </div>
                    </div>

                    <div class="flex-1 overflow-y-auto p-4 space-y-4">
                        <div class="p-3 bg-[#FFFFFF] rounded-xl border border-[#E8E4D9] space-y-2">
                            <div class="flex items-center gap-2">
                                <div class="w-6 h-6 rounded-full bg-[#E8E4D9]"></div>
                                <div class="text-[11px] font-bold text-[#2B2D42]">@doomscroller_anon</div>
                            </div>
                            <div class="text-xs text-[#2B2D42] leading-relaxed">
                                Just scrolling... nothing real here. Pause is keeping time of my session in the background!
                            </div>
                        </div>

                        <!-- Live Activity Card with Symbol-based Rating Indicators -->
                        <div class="bg-[#FFFFFF] p-3.5 rounded-2xl border border-[#81B29A]/40 space-y-3 shadow-md animate-bounce">
                            <div class="flex items-center justify-between">
                                <div class="flex items-center gap-2">
                                    <span class="w-2 h-2 bg-[#81B29A] rounded-full"></span>
                                    <span class="text-[10px] font-bold text-[#81B29A] font-mono">15/15 MIN LIMIT</span>
                                </div>
                                <span class="text-[10px] font-bold text-[#2B2D42]">Live Activity</span>
                            </div>
                            <div class="text-xs font-bold text-[#2B2D42] italic">"Time's up. Was it worth it?"</div>

                            <div class="grid grid-cols-3 gap-2 pt-1">
                                <button onclick="playHapticFeedback('light'); submitCheckIn('Positive')" class="p-2 bg-[#F8F6F0] border border-[#81B29A]/40 rounded-lg text-center text-xs font-bold text-[#81B29A] flex items-center justify-center gap-1">
                                    <i data-lucide="circle" class="w-3.5 h-3.5"></i> Positive
                                </button>
                                <button onclick="playHapticFeedback('light'); submitCheckIn('Neutral')" class="p-2 bg-[#F8F6F0] border border-[#E8E4D9] rounded-lg text-center text-xs font-bold text-[#8D8F9A] flex items-center justify-center gap-1">
                                    <i data-lucide="minus" class="w-3.5 h-3.5"></i> Neutral
                                </button>
                                <button onclick="playHapticFeedback('light'); submitCheckIn('Negative')" class="p-2 bg-[#F8F6F0] border border-[#E07A5F]/40 rounded-lg text-center text-xs font-bold text-[#E07A5F] flex items-center justify-center gap-1">
                                    <i data-lucide="x" class="w-3.5 h-3.5"></i> Negative
                                </button>
                            </div>
                        </div>
                    </div>

                    <div class="p-4 bg-[#FFFFFF] border-t border-[#E8E4D9]">
                        <button onclick="exitFeedAndGoToCheckIn()" class="w-full bg-[#E07A5F] text-white font-bold py-3 px-4 rounded-xl text-xs transition-colors flex items-center justify-center gap-1.5">
                            <i data-lucide="arrow-right-circle" class="w-4 h-4"></i> Stop Scrolling (Exit Feed)
                        </button>
                    </div>
                </div>
            `;
            break;

        case 'check-in':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 text-center bg-[#F8F6F0]">
                    <div class="space-y-2">
                        <div class="w-12 h-12 bg-[#E07A5F]/10 border border-[#E07A5F]/30 rounded-2xl flex items-center justify-center mx-auto">
                            <i data-lucide="hand-metal" class="w-6 h-6 text-[#E07A5F]"></i>
                        </div>
                        <h3 class="text-xl font-black text-[#2B2D42]">After-Scroll Reflection</h3>
                        <p class="text-xs text-[#8D8F9A]">Pause builds self-awareness. Reflect on the 15-minute scroll session.</p>
                        ${ghostCheckInActive ? `
                            <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#E07A5F]/10 border border-[#E07A5F]/30 text-[#E07A5F] text-[10px] font-bold uppercase tracking-wider mx-auto animate-pulse">
                                <i data-lucide="bell-ring" class="w-3.5 h-3.5"></i>
                                <span>Ghost Auto-Checkin: ${12 - ghostCheckInSeconds}s left</span>
                            </div>
                        ` : ''}
                    </div>

                    <div class="bg-[#FFFFFF] border border-[#E8E4D9] rounded-2xl p-5 my-auto space-y-4 shadow-sm">
                        <h4 class="text-sm font-bold text-[#2B2D42]">"Was that time well spent?"</h4>

                        <div class="grid grid-cols-3 gap-2">
                            <button onclick="playHapticFeedback('light'); submitCheckIn('Positive')" class="p-3 border border-[#81B29A]/40 bg-[#FFFFFF] rounded-xl flex flex-col items-center gap-1.5 transition-all">
                                <i data-lucide="circle" class="w-6 h-6 text-[#81B29A]"></i>
                                <span class="text-[10px] text-[#2B2D42] font-semibold">Positive</span>
                            </button>
                            <button onclick="playHapticFeedback('light'); submitCheckIn('Neutral')" class="p-3 border border-[#E8E4D9] bg-[#FFFFFF] rounded-xl flex flex-col items-center gap-1.5 transition-all">
                                <i data-lucide="minus" class="w-6 h-6 text-[#8D8F9A]"></i>
                                <span class="text-[10px] text-[#2B2D42] font-semibold">Neutral</span>
                            </button>
                            <button onclick="playHapticFeedback('light'); submitCheckIn('Negative')" class="p-3 border border-[#E07A5F]/40 bg-[#FFFFFF] rounded-xl flex flex-col items-center gap-1.5 transition-all">
                                <i data-lucide="x" class="w-6 h-6 text-[#E07A5F]"></i>
                                <span class="text-[10px] text-[#2B2D42] font-semibold">Negative</span>
                            </button>
                        </div>
                    </div>

                    <div class="text-[10px] text-[#8D8F9A] leading-normal px-2">
                        Reflection is stored anonymously in your Scrollytics Dashboard database.
                    </div>
                </div>
            `;
            break;

        case 'dashboard':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-4 relative overflow-y-auto">
                    <div class="flex items-center justify-between mb-4 border-b border-[#E8E4D9] pb-2">
                        <div class="flex items-center gap-1.5">
                            <i data-lucide="bar-chart-2" class="w-4 h-4 text-[#E07A5F]"></i>
                            <span class="text-xs font-black uppercase tracking-wider text-[#2B2D42]">Scrollytics™</span>
                        </div>
                        <span class="text-[10px] text-[#8D8F9A]">Paper Ledger Aesthetic</span>
                    </div>

                    <div class="space-y-4">
                        <div class="bg-[#FFFFFF] border border-[#E8E4D9] rounded-2xl p-3.5 space-y-2.5 shadow-sm">
                            <span class="text-[11px] font-bold text-[#8D8F9A]">Daily Scroll (Audited vs Unchecked)</span>
                            <div class="space-y-2 font-mono text-[10px] text-[#2B2D42]">
                                <div class="flex items-center justify-between">
                                    <span class="w-6">Wed</span>
                                    <div class="flex-1 bg-[#E8E4D9] h-2.5 mx-2 rounded overflow-hidden flex">
                                        <div class="h-full bg-[#81B29A]" style="width: 70%"></div>
                                        <div class="h-full bg-[#8D8F9A]" style="width: 30%"></div>
                                    </div>
                                    <span>${state.dailyScrollTime} min</span>
                                </div>
                            </div>
                        </div>

                        <div class="bg-[#FFFFFF] border border-[#E8E4D9] rounded-2xl p-4 space-y-2 shadow-sm">
                            <span class="text-[11px] font-bold text-[#8D8F9A]">Intent vs. Reality</span>
                            <div class="space-y-2 text-[10px] font-mono text-[#2B2D42]">
                                <div class="flex justify-between">
                                    <span>Relax / unwind</span>
                                    <span class="text-[#81B29A]">[Circle] 85%  [Dash] 10%  [Cross] 5%</span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-4 border-t border-[#E8E4D9] pt-3 mt-4">
                        <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-[#8D8F9A] hover:text-[#2B2D42] transition-colors">
                            <i data-lucide="home" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Home</span>
                        </button>
                        <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-[#E07A5F]">
                            <i data-lucide="bar-chart-2" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Scrollytics</span>
                        </button>
                        <button onclick="changeScreen('garden-shop')" class="flex flex-col items-center gap-1 text-[#8D8F9A] hover:text-[#2B2D42] transition-colors">
                            <i data-lucide="shopping-bag" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Shop</span>
                        </button>
                        <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 ${state.hasPremium ? 'text-[#E07A5F]' : 'text-[#8D8F9A] hover:text-[#2B2D42]'} transition-colors">
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
                    <div class="flex items-center justify-between border-b border-[#E8E4D9] pb-2 mb-3">
                        <span class="text-xs font-black uppercase tracking-wider text-[#2B2D42]">Focus Garden &amp; Shop</span>
                        <div class="flex items-center gap-1 bg-[#FFFFFF] px-2 py-0.5 rounded-full border border-[#E8E4D9]">
                            <i data-lucide="star" class="w-3.5 h-3.5 text-[#E07A5F]"></i>
                            <span class="text-[10px] font-bold text-[#2B2D42] font-mono">${state.tokens}</span>
                        </div>
                    </div>

                    <div class="space-y-3.5 flex-1 max-h-[360px] overflow-y-auto pr-1">
                        <div class="p-3 bg-[#FFFFFF] border border-[#E8E4D9] rounded-xl space-y-2">
                            <div class="text-xs font-bold text-[#2B2D42]">Pazu Wearables</div>
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
                                        <button onclick="interactPazuWearable('${item.type}', '${item.name}', ${item.cost})" class="p-2 border text-center rounded-xl text-[10px] transition-all ${selected ? 'border-[#E07A5F] bg-[#E07A5F]/10 text-[#E07A5F]' : unlocked ? 'border-[#E8E4D9] text-[#2B2D42]' : 'border-[#E8E4D9]/40 text-[#8D8F9A]'}">
                                            <div>${item.name}</div>
                                            <div class="text-[8px] font-bold font-mono text-[#8D8F9A] mt-1">
                                                ${selected ? 'Equipped' : unlocked ? 'Equip' : item.cost + ' ★'}
                                            </div>
                                        </button>
                                    `;
                                }).join('')}
                            </div>
                        </div>
                    </div>

                    <div class="grid grid-cols-4 border-t border-[#E8E4D9] pt-3 mt-4">
                        <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-[#8D8F9A] hover:text-[#2B2D42] transition-colors">
                            <i data-lucide="home" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Home</span>
                        </button>
                        <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-[#8D8F9A] hover:text-[#2B2D42] transition-colors">
                            <i data-lucide="bar-chart-2" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Scrollytics</span>
                        </button>
                        <button onclick="changeScreen('garden-shop')" class="flex flex-col items-center gap-1 text-[#E07A5F]">
                            <i data-lucide="shopping-bag" class="w-4.5 h-4.5"></i>
                            <span class="text-[9px] font-bold">Shop</span>
                        </button>
                        <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 ${state.hasPremium ? 'text-[#E07A5F]' : 'text-[#8D8F9A] hover:text-[#2B2D42]'} transition-colors">
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
                    <div class="flex items-center gap-2 border-b border-[#E8E4D9] pb-2.5 mb-3.5">
                        <button onclick="changeScreen('home')" class="w-6 h-6 hover:bg-[#E8E4D9] rounded flex items-center justify-center text-[#8D8F9A]">
                            <i data-lucide="chevron-left" class="w-4.5 h-4.5"></i>
                        </button>
                        <span class="text-xs font-black uppercase tracking-wider text-[#2B2D42]">Settings Configuration</span>
                    </div>

                    <div class="space-y-4 flex-1">
                        <div class="space-y-1.5">
                            <label class="text-[10px] font-bold uppercase tracking-wider text-[#8D8F9A]">Pause Duration</label>
                            <div class="grid grid-cols-4 gap-1.5">
                                ${[5, 10, 15, 30].map(sec => `
                                    <button onclick="updateSettingsField('pauseDuration', ${sec})" class="py-2 border ${state.pauseDuration === sec ? 'border-[#E07A5F] bg-[#E07A5F]/10 text-[#E07A5F]' : 'border-[#E8E4D9] bg-[#FFFFFF]'} rounded-xl text-xs font-bold transition-all">
                                        ${sec}s
                                    </button>
                                `).join('')}
                            </div>
                        </div>

                        <div class="pt-2 border-t border-[#E8E4D9]">
                            <button onclick="deleteAccountAndAllData()" class="w-full bg-rose-950/10 hover:bg-rose-950/20 border border-rose-500/20 text-[#E07A5F] font-bold py-3 rounded-xl text-xs transition-colors flex items-center justify-center gap-1.5">
                                <i data-lucide="trash-2" class="w-4 h-4"></i> Delete All My Data &amp; Account
                            </button>
                        </div>
                    </div>

                    <button onclick="changeScreen('home')" class="w-full bg-[#E07A5F] text-white font-bold py-2.5 rounded-xl text-xs transition-colors mt-3">
                        Save & Return
                    </button>
                </div>
            `;
            break;

        case 'premium-modal':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-5 relative overflow-y-auto">
                    <div class="text-center space-y-1 mt-2">
                        <div class="w-11 h-11 bg-[#E07A5F]/10 border border-[#E07A5F]/30 rounded-2xl flex items-center justify-center mx-auto text-[#E07A5F] mb-2">
                            <i data-lucide="award" class="w-6 h-6 animate-bounce"></i>
                        </div>
                        <h3 class="text-xl font-black text-[#2B2D42]">Unlock Pause Pro</h3>
                        <p class="text-xs text-[#8D8F9A]">Full annual commitment to intentional growth.</p>
                    </div>

                    <div class="my-auto space-y-3.5">
                        <button onclick="upgradeToPremium(39.99, 'Annual')" class="w-full text-left p-4 bg-[#FFFFFF] border border-[#E07A5F]/30 rounded-2xl transition-all relative">
                            <span class="absolute right-4 top-4 text-[9px] bg-[#E07A5F]/10 text-[#E07A5F] px-1.5 py-0.5 rounded-full font-bold">BEST VALUE</span>
                            <div class="text-xs font-black text-[#2B2D42]">Annual Membership</div>
                            <div class="text-lg font-extrabold text-[#2B2D42] mt-0.5">$39.99 <span class="text-xs font-normal text-[#8D8F9A]">/ year</span></div>
                            <p class="text-[10px] text-[#8D8F9A] mt-1">1-Month Free Trial included. Standard Apple StoreKit native purchase.</p>
                        </button>
                    </div>

                    <div class="space-y-3">
                        <button onclick="upgradeToPremium(39.99, 'Annual')" class="w-full bg-[#E07A5F] text-white font-bold py-3 px-4 rounded-full text-xs transition-all flex items-center justify-center gap-1.5">
                            <i data-lucide="credit-card" class="w-4 h-4"></i> Start 1-Month Free Trial
                        </button>
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
    logAction('Premium Subscribed', `Upgraded to Pause Pro Annual Plan with 1-Month Free Trial ($39.99/yr)`);
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

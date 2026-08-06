// Pause SaaS Sandbox - Core Application Logic
// Handles State, Onboarding, Screens, Simulated Feed, Analytics, Custom Settings, & Upgrade states.

const DEFAULT_STATE = {
    onboarded: false,
    managedApps: ['Instagram', 'TikTok', 'Twitter / X', 'YouTube', 'Reddit', 'Snapchat'],
    pauseDuration: 10, // seconds
    hasPremium: false,
    streak: 3, // starting streak
    dailyScrollTime: 42, // minutes (simulated)
    longestSession: 18, // minutes
    nudgesTriggered: 12,
    nudgesResisted: 5,
    checkedInCount: 4,
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
// Screens: 'onboarding-1', 'onboarding-2', 'onboarding-3', 'home', 'pause-gate', 'scrolling-feed', 'check-in', 'dashboard', 'settings', 'premium-modal'
let currentScreen = 'home';
let pauseGateTimer = null;
let pauseRemaining = 10;
let simulatedAppToOpen = 'Instagram';
let feedRemainingSeconds = 15 * 60; // 15 mins simulator
let feedTimer = null;

// Initialize app when DOM is fully loaded
document.addEventListener('DOMContentLoaded', () => {
    loadState();

    // Check if onboarded
    if (!state.onboarded) {
        currentScreen = 'onboarding-1';
    } else {
        currentScreen = 'home';
    }

    renderCurrentScreen();

    // Reset button
    document.getElementById('reset-btn').addEventListener('click', () => {
        if (confirm('Reset entire sandbox simulator to default?')) {
            localStorage.removeItem('pause_saas_state');
            state = { ...DEFAULT_STATE };
            currentScreen = 'onboarding-1';
            saveState();
            renderCurrentScreen();
        }
    });

    // Premium upgrade toggle
    document.getElementById('sandbox-upgrade-toggle').addEventListener('click', () => {
        state.hasPremium = !state.hasPremium;
        logAction('Sandbox Mode', `Subscription Tier toggled to: ${state.hasPremium ? 'Premium (Pause+)' : 'Free Tier'}`);
        saveState();
        renderCurrentScreen();
    });

    // Fast-forward Sim 1 Day
    document.getElementById('fast-forward-btn').addEventListener('click', () => {
        state.dailyScrollTime += Math.floor(Math.random() * 20) + 15;
        state.longestSession = Math.max(state.longestSession, Math.floor(Math.random() * 10) + 15);
        state.nudgesTriggered += Math.floor(Math.random() * 4) + 1;
        state.nudgesResisted += Math.floor(Math.random() * 3);
        state.streak += 1;
        logAction('Simulation Engine', 'Simulated 1 day of usage patterns.');
        saveState();
        renderCurrentScreen();
    });
});

// Update the SaaS companion panel details on the right side
function updateSaaSCompanionUI() {
    // Current tier
    const tierText = document.getElementById('current-tier-text');
    if (tierText) {
        tierText.innerText = state.hasPremium ? 'Pause+ Premium Tier ($4.99/mo)' : 'Free Tier ($0/mo)';
        tierText.className = state.hasPremium ? 'text-sm font-bold text-amber-400' : 'text-sm font-bold text-slate-200';
    }

    // Database statistics
    const totalDaysEl = document.getElementById('inspector-total-days');
    if (totalDaysEl) totalDaysEl.innerText = state.streak > 0 ? state.streak : '1';

    const checkinsEl = document.getElementById('inspector-checkins');
    if (checkinsEl) checkinsEl.innerText = state.checkedInCount;

    const nudgesEl = document.getElementById('inspector-nudges');
    if (nudgesEl) nudgesEl.innerText = state.nudgesTriggered;

    const resistedEl = document.getElementById('inspector-resisted');
    if (resistedEl) resistedEl.innerText = state.nudgesResisted;

    // Logs rendering
    const logsContainer = document.getElementById('raw-logs-container');
    if (logsContainer) {
        logsContainer.innerHTML = state.logs.map(log => `
            <div class="flex items-start justify-between py-1 border-b border-slate-900/60 hover:bg-slate-900/20 transition-all">
                <span class="text-indigo-400 shrink-0 select-all mr-2 font-semibold">[${log.time}]</span>
                <span class="text-slate-200 flex-1 select-all mr-2">${log.action}</span>
                <span class="text-emerald-400 shrink-0 font-medium">${log.result}</span>
            </div>
        `).join('') || '<div class="text-slate-500 text-center py-4">No logged activities yet. Try triggering the Pause Gate on the left.</div>';
    }

    // Refresh lucide icons
    if (window.lucide) {
        window.lucide.createIcons();
    }
}

// Trigger Simulated App Launch from the outside sandbox
function triggerAppLaunch(appName) {
    simulatedAppToOpen = appName;

    // Check if the app is managed in the list
    const isManaged = state.managedApps.includes(appName);

    // Check if Quiet hours are active
    let isInQuietHours = false;
    if (state.enableQuietHours) {
        // Simple mock check
        isInQuietHours = true;
    }

    if (isManaged && !isInQuietHours) {
        state.nudgesTriggered++;
        saveState();
        logAction(`Attempted Open: ${appName}`, `Triggered the Pause Gate overlay`);

        // Decide if we prompt intention
        if (state.enableIntentionPrompt) {
            currentScreen = 'intention-prompt';
        } else {
            startPauseGate();
        }
    } else {
        logAction(`Attempted Open: ${appName}`, `Bypassed overlay (Unmanaged app / Quiet Hours)`);
        // Straight to scroll simulator
        startScrollSimulator(appName);
    }
    renderCurrentScreen();
}

function startPauseGate() {
    currentScreen = 'pause-gate';
    pauseRemaining = state.pauseDuration;

    if (pauseGateTimer) clearInterval(pauseGateTimer);
    pauseGateTimer = setInterval(() => {
        pauseRemaining--;
        renderCurrentScreen();
        if (pauseRemaining <= 0) {
            clearInterval(pauseGateTimer);
        }
    }, 1000);
}

function startScrollSimulator(appName) {
    currentScreen = 'scrolling-feed';
    simulatedAppToOpen = appName;
    feedRemainingSeconds = 15 * 60; // 15 mins representation

    if (feedTimer) clearInterval(feedTimer);
    feedTimer = setInterval(() => {
        // Speed up timer slightly in simulation mode to make it interesting
        feedRemainingSeconds -= 5;
        if (feedRemainingSeconds <= 0) {
            clearInterval(feedTimer);
            exitFeedAndGoToCheckIn();
        } else {
            const timerEl = document.getElementById('feed-timer-countdown');
            if (timerEl) {
                const mins = Math.floor(feedRemainingSeconds / 60);
                const secs = feedRemainingSeconds % 60;
                timerEl.innerText = `${mins}:${secs.toString().padStart(2, '0')}`;
            }
        }
    }, 1000);
}

function exitFeedAndGoToCheckIn() {
    if (feedTimer) clearInterval(feedTimer);
    currentScreen = 'check-in';
    renderCurrentScreen();
}

// Render dynamic views inside the Mock Smartphone viewport
function renderCurrentScreen() {
    const screen = document.getElementById('screen-container');
    if (!screen) return;

    screen.className = "relative w-full h-full flex flex-col bg-slate-950 text-slate-100 animate-fade-in";

    switch (currentScreen) {
        case 'onboarding-1':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 relative overflow-hidden">
                    <!-- Progress Bar -->
                    <div class="flex gap-1.5 w-full">
                        <div class="h-1 flex-1 bg-indigo-600 rounded-full"></div>
                        <div class="h-1 flex-1 bg-slate-800 rounded-full"></div>
                        <div class="h-1 flex-1 bg-slate-800 rounded-full"></div>
                    </div>

                    <div class="my-auto space-y-6 text-center z-10">
                        <div class="w-20 h-20 bg-indigo-600/10 border border-indigo-500/30 rounded-2xl flex items-center justify-center mx-auto shadow-2xl shadow-indigo-950/50">
                            <i data-lucide="compass" class="w-10 h-10 text-indigo-400"></i>
                        </div>
                        <h3 class="text-2xl font-black tracking-tight text-white leading-tight">
                            "You don't have to quit.<br>You just have to <span class="text-transparent bg-clip-text bg-gradient-to-r from-indigo-400 to-cyan-300">pause.</span>"
                        </h3>
                        <p class="text-slate-400 text-sm leading-relaxed px-4">
                            We are not a digital blocker app. We are a supportive companion that restores the intentional space between impulse and screen action.
                        </p>
                    </div>

                    <div class="space-y-3 z-10">
                        <button onclick="changeScreen('onboarding-2')" class="w-full bg-indigo-600 hover:bg-indigo-500 text-white font-bold py-3.5 px-4 rounded-xl shadow-lg transition-all text-sm flex items-center justify-center gap-2">
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
                    <!-- Progress Bar -->
                    <div class="flex gap-1.5 w-full">
                        <div class="h-1 flex-1 bg-indigo-600 rounded-full"></div>
                        <div class="h-1 flex-1 bg-indigo-600 rounded-full"></div>
                        <div class="h-1 flex-1 bg-slate-800 rounded-full"></div>
                    </div>

                    <div class="my-auto space-y-4">
                        <div class="text-center">
                            <h3 class="text-xl font-bold text-white mb-1">Managed Social Networks</h3>
                            <p class="text-xs text-slate-400">Select social apps that you wish to pause before scrolling.</p>
                        </div>

                        <div class="space-y-2 max-h-[260px] overflow-y-auto pr-1">
                            ${['Instagram', 'TikTok', 'Twitter / X', 'YouTube', 'Reddit', 'Snapchat', 'Facebook'].map(app => {
                                const checked = state.managedApps.includes(app);
                                return `
                                    <label class="flex items-center justify-between p-3 bg-slate-900 border ${checked ? 'border-indigo-500/30 bg-indigo-950/10' : 'border-slate-800'} rounded-xl cursor-pointer transition-colors">
                                        <span class="text-sm font-medium text-slate-200">${app}</span>
                                        <input type="checkbox" onchange="toggleManagedApp('${app}')" ${checked ? 'checked' : ''} class="w-4.5 h-4.5 rounded text-indigo-600 bg-slate-800 border-slate-700 focus:ring-indigo-500">
                                    </label>
                                `;
                            }).join('')}
                        </div>
                    </div>

                    <div>
                        <button onclick="changeScreen('onboarding-3')" class="w-full bg-indigo-600 hover:bg-indigo-500 text-white font-bold py-3.5 px-4 rounded-xl shadow-lg transition-all text-sm flex items-center justify-center gap-2">
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
                    <!-- Progress Bar -->
                    <div class="flex gap-1.5 w-full">
                        <div class="h-1 flex-1 bg-indigo-600 rounded-full"></div>
                        <div class="h-1 flex-1 bg-indigo-600 rounded-full"></div>
                        <div class="h-1 flex-1 bg-indigo-600 rounded-full"></div>
                    </div>

                    <div class="my-auto space-y-5 text-center">
                        <div class="w-16 h-16 bg-cyan-500/10 border border-cyan-500/30 rounded-full flex items-center justify-center mx-auto">
                            <i data-lucide="timer" class="w-8 h-8 text-cyan-400"></i>
                        </div>
                        <div>
                            <h3 class="text-xl font-bold text-white mb-1">Set your Pause duration</h3>
                            <p class="text-xs text-slate-400">How long do you want to breath before access is granted?</p>
                        </div>

                        <div class="grid grid-cols-2 gap-2 max-w-xs mx-auto">
                            ${[5, 10, 15, 30].map(sec => `
                                <button onclick="setPauseDuration(${sec})" class="py-3 px-4 border ${state.pauseDuration === sec ? 'border-indigo-500 bg-indigo-950/30 text-indigo-300' : 'border-slate-800 hover:border-slate-700'} rounded-xl text-sm font-bold transition-all">
                                    ${sec} Seconds
                                </button>
                            `).join('')}
                        </div>
                        <p class="text-[10px] text-slate-500">Recommended duration: 10 seconds</p>
                    </div>

                    <div>
                        <button onclick="completeOnboarding()" class="w-full bg-gradient-to-r from-indigo-600 to-cyan-500 hover:from-indigo-500 hover:to-cyan-400 text-white font-bold py-3.5 px-4 rounded-xl shadow-lg shadow-indigo-950/40 transition-all text-sm flex items-center justify-center gap-2">
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

                    <!-- Top Status Bar Inside App -->
                    <div class="flex items-center justify-between mt-1">
                        <div class="flex items-center gap-1.5">
                            <span class="w-2.5 h-2.5 rounded-full bg-emerald-500 animate-pulse active-status-glow"></span>
                            <span class="text-[10px] text-slate-400 font-bold uppercase tracking-wider">Pause Mode Active</span>
                        </div>
                        <button onclick="changeScreen('settings')" class="w-7 h-7 rounded-lg hover:bg-slate-900 border border-slate-800 flex items-center justify-center text-slate-400 hover:text-white transition-colors">
                            <i data-lucide="settings" class="w-4 h-4"></i>
                        </button>
                    </div>

                    <!-- Heart of the Screen - Dashboard Score -->
                    <div class="my-auto space-y-6">
                        <div class="text-center space-y-1">
                            <span class="text-xs text-slate-500 font-semibold tracking-wider uppercase">Today's Scroll Time</span>
                            <div class="flex items-baseline justify-center gap-1">
                                <span class="text-5xl font-extrabold text-white tracking-tight">${state.dailyScrollTime}</span>
                                <span class="text-sm font-semibold text-slate-400">Minutes</span>
                            </div>
                            <span class="text-[10px] text-indigo-400 flex items-center justify-center gap-1">
                                <i data-lucide="sparkles" class="w-3 h-3"></i>
                                Mindful choices: ${state.nudgesResisted} of ${state.nudgesTriggered} triggers
                            </span>
                        </div>

                        <!-- Stats Strip -->
                        <div class="grid grid-cols-2 gap-3">
                            <div class="bg-slate-900 border border-slate-800/80 p-3.5 rounded-2xl flex items-center gap-3">
                                <div class="w-9 h-9 bg-amber-500/15 rounded-xl flex items-center justify-center text-amber-400 border border-amber-500/20">
                                    <i data-lucide="flame" class="w-5 h-5 fill-amber-500/20"></i>
                                </div>
                                <div class="text-left">
                                    <div class="text-xs text-slate-500 font-medium">Mindful Streak</div>
                                    <div class="text-sm font-bold text-slate-200">${state.streak} Days</div>
                                </div>
                            </div>
                            <div class="bg-slate-900 border border-slate-800/80 p-3.5 rounded-2xl flex items-center gap-3">
                                <div class="w-9 h-9 bg-cyan-500/15 rounded-xl flex items-center justify-center text-cyan-400 border border-cyan-500/20">
                                    <i data-lucide="calendar" class="w-5 h-5"></i>
                                </div>
                                <div class="text-left">
                                    <div class="text-xs text-slate-500 font-medium">Next Session</div>
                                    <div class="text-sm font-bold text-slate-200">19:00 PM</div>
                                </div>
                            </div>
                        </div>

                        <!-- Managed Quick Toggle App Launcher Simulators -->
                        <div class="bg-slate-900 border border-slate-800/80 p-4 rounded-2xl space-y-3">
                            <div class="text-xs font-bold text-slate-300">Managed App Triggers</div>
                            <div class="grid grid-cols-2 gap-2">
                                ${state.managedApps.slice(0, 4).map(app => `
                                    <button onclick="triggerAppLaunch('${app}')" class="flex items-center gap-2 p-2.5 bg-slate-950 hover:bg-slate-800 border border-slate-800/50 rounded-xl text-left transition-all">
                                        <i data-lucide="external-link" class="w-3.5 h-3.5 text-indigo-400"></i>
                                        <span class="text-xs font-medium text-slate-200 truncate">${app}</span>
                                    </button>
                                `).join('')}
                            </div>
                        </div>
                    </div>

                    <!-- Bottom Screen Bar Selector Navigation -->
                    <div class="grid grid-cols-3 border-t border-slate-900 pt-3 mt-4">
                        <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-indigo-400">
                            <i data-lucide="home" class="w-5 h-5"></i>
                            <span class="text-[9px] font-bold">Home</span>
                        </button>
                        <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                            <i data-lucide="bar-chart-2" class="w-5 h-5"></i>
                            <span class="text-[9px] font-bold">Scrollytics</span>
                        </button>
                        <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 ${state.hasPremium ? 'text-amber-400' : 'text-slate-500 hover:text-slate-300'} transition-colors">
                            <i data-lucide="award" class="w-5 h-5"></i>
                            <span class="text-[9px] font-bold">Pause+</span>
                        </button>
                    </div>

                </div>
            `;
            break;

        case 'intention-prompt':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 text-center">
                    <div class="space-y-2">
                        <span class="text-xs font-bold text-indigo-400 tracking-widest uppercase">Intention prompt</span>
                        <h3 class="text-xl font-black text-white px-2">"What are you here for?"</h3>
                        <p class="text-xs text-slate-400">Acknowledge why you open ${simulatedAppToOpen} to reduce subconscious scrolling.</p>
                    </div>

                    <div class="space-y-2 my-auto">
                        ${['Relax / unwind', 'Connect with friends', 'Kill time / bored', 'Work / research', 'Just checking'].map(opt => `
                            <button onclick="selectIntention('${opt}')" class="w-full text-left p-3.5 border border-slate-800 hover:border-indigo-500/40 bg-slate-900/60 hover:bg-indigo-950/10 rounded-2xl text-xs font-medium transition-all text-slate-200">
                                ${opt}
                            </button>
                        `).join('')}
                    </div>

                    <div class="text-[10px] text-slate-500">Your answers are secured in privacy-first local logs.</div>
                </div>
            `;
            break;

        case 'pause-gate':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 relative overflow-hidden bg-gradient-to-b from-indigo-950/30 via-slate-950 to-slate-950">

                    <!-- Top message -->
                    <div class="space-y-2 text-center mt-2">
                        <h4 class="text-xs font-bold text-slate-400 tracking-widest uppercase">${simulatedAppToOpen} is paused</h4>
                        <p class="text-md text-slate-300 font-medium italic px-6">"Is this a conscious choice?"</p>
                    </div>

                    <!-- Calming Breathing Circle -->
                    <div class="my-auto flex flex-col items-center justify-center space-y-6">
                        <div class="relative w-36 h-36 rounded-full flex items-center justify-center">
                            <!-- Background Pulse Layer -->
                            <div class="absolute inset-0 breathing-ring bg-indigo-500/10 rounded-full border border-indigo-500/30"></div>
                            <!-- Core Inner Timer -->
                            <div class="w-24 h-24 bg-slate-900 border border-slate-800/80 rounded-full flex flex-col items-center justify-center shadow-xl">
                                <span class="text-xs text-indigo-400 font-bold tracking-wider">BREATHE</span>
                                <span class="text-3xl font-black text-white tracking-tight">${pauseRemaining}s</span>
                            </div>
                        </div>
                        <span class="text-xs text-slate-400 italic">Inhale... Exhale...</span>
                    </div>

                    <!-- Bottom decision buttons -->
                    <div class="space-y-3">
                        <button id="continue-feed-btn" onclick="continueToFeed()" ${pauseRemaining > 0 ? 'disabled' : ''} class="w-full py-3.5 px-4 font-bold rounded-xl text-sm transition-all flex items-center justify-center gap-2 ${pauseRemaining > 0 ? 'bg-slate-800 text-slate-500 cursor-not-allowed border border-slate-900' : 'bg-gradient-to-r from-indigo-600 to-cyan-500 hover:from-indigo-500 hover:to-cyan-400 text-white shadow-lg shadow-indigo-950/40'}">
                            <span>Continue to Feed</span>
                            <i data-lucide="external-link" class="w-4 h-4"></i>
                        </button>
                        <button onclick="resistNudgeAndClose()" class="w-full bg-slate-900 hover:bg-slate-800 border border-slate-800 text-slate-300 font-semibold py-3.5 px-4 rounded-xl text-sm transition-all flex items-center justify-center gap-2">
                            <span>Close App / Walk Away</span>
                            <i data-lucide="x" class="w-4 h-4"></i>
                        </button>
                    </div>

                </div>
            `;
            break;

        case 'scrolling-feed':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col bg-slate-900 relative">
                    <!-- Feed Header Simulator -->
                    <div class="px-4 py-3 border-b border-slate-800 bg-slate-950 flex items-center justify-between">
                        <div class="flex items-center gap-2">
                            <span class="w-2 h-2 rounded-full bg-indigo-500 animate-pulse"></span>
                            <span class="text-xs font-extrabold text-white tracking-wide uppercase">${simulatedAppToOpen} Sim</span>
                        </div>
                        <div class="flex items-center gap-1 text-slate-400 text-xs bg-slate-900 px-2 py-1 rounded-full border border-slate-800">
                            <i data-lucide="timer" class="w-3.5 h-3.5 text-indigo-400"></i>
                            <span id="feed-timer-countdown" class="font-mono">15:00</span>
                        </div>
                    </div>

                    <!-- Simulated Social Post List (Simulates scroll flow) -->
                    <div class="flex-1 overflow-y-auto p-4 space-y-4">
                        <div class="p-3 bg-slate-950 rounded-xl border border-slate-800/60 space-y-2">
                            <div class="flex items-center gap-2">
                                <div class="w-6 h-6 rounded-full bg-slate-800"></div>
                                <div class="text-[11px] font-bold">@doomscroller_anon</div>
                            </div>
                            <div class="text-xs text-slate-300 leading-relaxed">
                                Just scrolling... nothing real here. Just wasting seconds. But wait, Pause is keeping time of my session in the background!
                            </div>
                        </div>

                        <div class="p-3 bg-slate-950 rounded-xl border border-slate-800/60 space-y-2">
                            <div class="flex items-center gap-2">
                                <div class="w-6 h-6 rounded-full bg-indigo-950"></div>
                                <div class="text-[11px] font-bold text-indigo-300">@mindful_companion</div>
                            </div>
                            <div class="text-xs text-slate-300 leading-relaxed">
                                Remember, this feed has a strict 15-minute budget. When the session expires, a check-in rating cards pop-up.
                            </div>
                        </div>

                        <div class="p-3 bg-slate-950 rounded-xl border border-slate-800/60 space-y-2">
                            <div class="flex items-center gap-2">
                                <div class="w-6 h-6 rounded-full bg-slate-800"></div>
                                <div class="text-[11px] font-bold">@viral_feed_trend</div>
                            </div>
                            <p class="text-xs text-slate-300">
                                This is simulated infinite scrolling inside the sandbox environment.
                            </p>
                            <div class="h-24 bg-gradient-to-br from-indigo-950/40 to-slate-900 rounded-lg flex items-center justify-center border border-indigo-900/20">
                                <span class="text-[10px] text-slate-500">Muted social post image</span>
                            </div>
                        </div>
                    </div>

                    <!-- Floating Return/Exit Bar -->
                    <div class="p-4 bg-slate-950 border-t border-slate-800">
                        <button onclick="exitFeedAndGoToCheckIn()" class="w-full bg-rose-600 hover:bg-rose-500 text-white font-bold py-3 px-4 rounded-xl text-xs transition-colors flex items-center justify-center gap-1.5">
                            <i data-lucide="log-out" class="w-4 h-4"></i> Stop Scrolling (Exit Feed)
                        </button>
                    </div>
                </div>
            `;
            break;

        case 'check-in':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-6 pt-12 text-center bg-gradient-to-b from-indigo-950/20 via-slate-950 to-slate-950">
                    <div class="space-y-2">
                        <div class="w-12 h-12 bg-indigo-500/10 border border-indigo-500/30 rounded-2xl flex items-center justify-center mx-auto">
                            <i data-lucide="smile" class="w-6 h-6 text-indigo-400"></i>
                        </div>
                        <h3 class="text-xl font-black text-white">After-Scroll Reflection</h3>
                        <p class="text-xs text-slate-400">Pause builds self-awareness. Reflect on the 15-minute scroll session.</p>
                    </div>

                    <div class="bg-slate-900/60 border border-slate-800 rounded-2xl p-5 my-auto space-y-4">
                        <h4 class="text-sm font-bold text-slate-200">"Was that time well spent?"</h4>

                        <div class="grid grid-cols-3 gap-2">
                            <button onclick="submitCheckIn('Yes, I got what I needed')" class="p-3 border border-slate-800 hover:border-emerald-500/40 hover:bg-emerald-950/10 rounded-xl flex flex-col items-center gap-1.5 transition-all">
                                <span class="text-2xl">😊</span>
                                <span class="text-[10px] text-slate-300 font-semibold leading-tight">Yes</span>
                            </button>
                            <button onclick="submitCheckIn('Not sure')" class="p-3 border border-slate-800 hover:border-amber-500/40 hover:bg-amber-950/10 rounded-xl flex flex-col items-center gap-1.5 transition-all">
                                <span class="text-2xl">😐</span>
                                <span class="text-[10px] text-slate-300 font-semibold leading-tight">Not Sure</span>
                            </button>
                            <button onclick="submitCheckIn('No, I got lost')" class="p-3 border border-slate-800 hover:border-rose-500/40 hover:bg-rose-950/10 rounded-xl flex flex-col items-center gap-1.5 transition-all">
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
                    <!-- Dashboard Header -->
                    <div class="flex items-center justify-between mb-4 border-b border-slate-900 pb-2">
                        <div class="flex items-center gap-1.5">
                            <i data-lucide="bar-chart-2" class="w-4 h-4 text-indigo-400"></i>
                            <span class="text-xs font-black uppercase tracking-wider text-white">Scrollytics™</span>
                        </div>
                        <span class="text-[10px] text-slate-400">This Week summary</span>
                    </div>

                    <div class="space-y-4">
                        <!-- Weekly Chart SVG representation -->
                        <div class="bg-slate-900 border border-slate-800/80 rounded-2xl p-3.5 space-y-2.5">
                            <span class="text-[11px] font-bold text-slate-400">Daily Scroll Minutes</span>
                            <div class="h-28 flex items-end justify-between gap-2.5 px-2 pt-2">
                                <div class="flex flex-col items-center flex-1 gap-1.5">
                                    <div class="w-full bg-indigo-600/30 hover:bg-indigo-600 h-16 rounded-t transition-colors relative group">
                                        <div class="absolute -top-6 left-1/2 -translate-x-1/2 bg-slate-950 text-white text-[9px] px-1.5 py-0.5 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">45m</div>
                                    </div>
                                    <span class="text-[9px] text-slate-500 font-bold">Mon</span>
                                </div>
                                <div class="flex flex-col items-center flex-1 gap-1.5">
                                    <div class="w-full bg-indigo-600/30 hover:bg-indigo-600 h-10 rounded-t transition-colors relative group">
                                        <div class="absolute -top-6 left-1/2 -translate-x-1/2 bg-slate-950 text-white text-[9px] px-1.5 py-0.5 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">28m</div>
                                    </div>
                                    <span class="text-[9px] text-slate-500 font-bold">Tue</span>
                                </div>
                                <div class="flex flex-col items-center flex-1 gap-1.5">
                                    <div class="w-full bg-indigo-600 h-24 rounded-t relative">
                                        <div class="absolute -top-6 left-1/2 -translate-x-1/2 bg-slate-950 text-white text-[9px] px-1.5 py-0.5 rounded opacity-100 whitespace-nowrap font-bold">${state.dailyScrollTime}m</div>
                                    </div>
                                    <span class="text-[9px] text-indigo-400 font-bold">Wed</span>
                                </div>
                                <div class="flex flex-col items-center flex-1 gap-1.5">
                                    <div class="w-full bg-indigo-600/30 hover:bg-indigo-600 h-14 rounded-t transition-colors relative group">
                                        <div class="absolute -top-6 left-1/2 -translate-x-1/2 bg-slate-950 text-white text-[9px] px-1.5 py-0.5 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">35m</div>
                                    </div>
                                    <span class="text-[9px] text-slate-500 font-bold">Thu</span>
                                </div>
                                <div class="flex flex-col items-center flex-1 gap-1.5">
                                    <div class="w-full bg-indigo-600/30 hover:bg-indigo-600 h-20 rounded-t transition-colors relative group">
                                        <div class="absolute -top-6 left-1/2 -translate-x-1/2 bg-slate-950 text-white text-[9px] px-1.5 py-0.5 rounded opacity-0 group-hover:opacity-100 transition-opacity whitespace-nowrap">50m</div>
                                    </div>
                                    <span class="text-[9px] text-slate-500 font-bold">Fri</span>
                                </div>
                            </div>
                        </div>

                        <!-- Top Attention Sinks -->
                        <div class="bg-slate-900 border border-slate-800/80 rounded-2xl p-4 space-y-2">
                            <span class="text-[11px] font-bold text-slate-400">Top Attention Sinks</span>
                            <div class="space-y-2">
                                <div class="flex items-center justify-between text-xs">
                                    <span class="text-slate-300 font-medium">1. Instagram</span>
                                    <span class="text-slate-400 font-mono font-bold">22 min / day</span>
                                </div>
                                <div class="w-full h-1.5 bg-slate-800 rounded-full overflow-hidden">
                                    <div class="w-[55%] h-full bg-pink-500 rounded-full"></div>
                                </div>

                                <div class="flex items-center justify-between text-xs pt-1">
                                    <span class="text-slate-300 font-medium">2. TikTok</span>
                                    <span class="text-slate-400 font-mono font-bold">15 min / day</span>
                                </div>
                                <div class="w-full h-1.5 bg-slate-800 rounded-full overflow-hidden">
                                    <div class="w-[40%] h-full bg-cyan-400 rounded-full"></div>
                                </div>
                            </div>
                        </div>

                        <!-- Nudges trigger card -->
                        <div class="bg-indigo-950/15 border border-indigo-500/20 rounded-2xl p-3.5 flex items-center justify-between">
                            <div class="space-y-0.5">
                                <div class="text-xs font-bold text-slate-200">Nudges Resisted</div>
                                <div class="text-[10px] text-indigo-400">Total: ${state.nudgesResisted} out of ${state.nudgesTriggered} moments</div>
                            </div>
                            <div class="w-10 h-10 rounded-full border-2 border-indigo-500/30 flex items-center justify-center font-bold text-xs text-indigo-400">
                                ${Math.round((state.nudgesResisted / (state.nudgesTriggered || 1)) * 100)}%
                            </div>
                        </div>
                    </div>

                    <!-- Bottom Nav Tab Selection -->
                    <div class="grid grid-cols-3 border-t border-slate-900 pt-3 mt-4">
                        <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                            <i data-lucide="home" class="w-5 h-5"></i>
                            <span class="text-[9px] font-bold">Home</span>
                        </button>
                        <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-indigo-400">
                            <i data-lucide="bar-chart-2" class="w-5 h-5"></i>
                            <span class="text-[9px] font-bold">Scrollytics</span>
                        </button>
                        <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 ${state.hasPremium ? 'text-amber-400' : 'text-slate-500 hover:text-slate-300'} transition-colors">
                            <i data-lucide="award" class="w-5 h-5"></i>
                            <span class="text-[9px] font-bold">Pause+</span>
                        </button>
                    </div>

                </div>
            `;
            break;

        case 'settings':
            screen.innerHTML = `
                <div class="flex-1 flex flex-col justify-between p-4 relative overflow-y-auto">
                    <!-- Settings Header -->
                    <div class="flex items-center gap-2 border-b border-slate-900 pb-2.5 mb-3.5">
                        <button onclick="changeScreen('home')" class="w-6 h-6 hover:bg-slate-900 rounded flex items-center justify-center text-slate-400">
                            <i data-lucide="chevron-left" class="w-4.5 h-4.5"></i>
                        </button>
                        <span class="text-xs font-black uppercase tracking-wider text-white">Settings Configuration</span>
                    </div>

                    <div class="space-y-4 flex-1">
                        <!-- Custom Pause Duration selection -->
                        <div class="space-y-1.5">
                            <label class="text-[10px] font-bold uppercase tracking-wider text-slate-400">Pause Duration</label>
                            <div class="grid grid-cols-4 gap-1.5">
                                ${[5, 10, 15, 30].map(sec => `
                                    <button onclick="updateSettingsField('pauseDuration', ${sec})" class="py-2 border ${state.pauseDuration === sec ? 'border-indigo-500 bg-indigo-950/20 text-indigo-400' : 'border-slate-800'} rounded-xl text-xs font-bold transition-all">
                                        ${sec}s
                                    </button>
                                `).join('')}
                            </div>
                        </div>

                        <!-- Intention prompt custom toggler -->
                        <div class="flex items-center justify-between p-3 bg-slate-900 rounded-xl border border-slate-800">
                            <div>
                                <div class="text-xs font-bold text-slate-200">Intention Prompt</div>
                                <div class="text-[10px] text-slate-400">Ask "What are you here for?" first</div>
                            </div>
                            <button onclick="toggleIntentionPrompt()" class="w-9 h-5 rounded-full p-0.5 transition-colors duration-200 ${state.enableIntentionPrompt ? 'bg-indigo-600' : 'bg-slate-700'}">
                                <div class="bg-white w-4 h-4 rounded-full shadow-md transform duration-200 ${state.enableIntentionPrompt ? 'translate-x-4' : 'translate-x-0'}"></div>
                            </button>
                        </div>

                        <!-- Quiet Hours premium gating feature selection -->
                        <div class="p-3 bg-slate-900 rounded-xl border border-slate-800 space-y-2 relative">
                            ${!state.hasPremium ? `
                                <div class="absolute inset-0 bg-slate-950/80 rounded-xl backdrop-blur-sm z-10 flex flex-col items-center justify-center text-center p-3">
                                    <i data-lucide="lock" class="w-4 h-4 text-amber-400 mb-1"></i>
                                    <span class="text-[10px] font-bold text-white uppercase tracking-wider">Requires Pause+</span>
                                    <button onclick="changeScreen('premium-modal')" class="text-[9px] text-indigo-400 font-bold underline mt-0.5">Upgrade for $4.99/mo</button>
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

                            <div class="grid grid-cols-2 gap-2 pt-1">
                                <div class="text-[10px] text-slate-400">Start Time: <strong class="text-slate-200">${state.quietHoursStart}</strong></div>
                                <div class="text-[10px] text-slate-400">End Time: <strong class="text-slate-200">${state.quietHoursEnd}</strong></div>
                            </div>
                        </div>

                        <!-- Bio Exporter premium widget custom export representation -->
                        <div class="p-3 bg-indigo-950/10 border border-indigo-500/20 rounded-xl space-y-2">
                            <div class="flex items-center gap-1.5 text-xs font-bold text-indigo-400">
                                <i data-lucide="award" class="w-4 h-4 text-amber-400 animate-pulse"></i>
                                <span>Lock Screen / Bio Badge Creator</span>
                            </div>
                            <p class="text-[10px] text-slate-300">Share your intentional journey with standard exporter copy:</p>
                            <div class="bg-slate-950 p-2 rounded-lg border border-slate-800 text-[11px] font-mono text-slate-300 select-all cursor-pointer">
                                "I'm trying to scroll less. 🧭 @PauseApp"
                            </div>
                        </div>

                        <!-- Mandatory Account Deletion link -->
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
                    <!-- Gating/Upgrade Splash Header -->
                    <div class="text-center space-y-1 mt-2">
                        <div class="w-11 h-11 bg-amber-500/10 border border-amber-500/30 rounded-2xl flex items-center justify-center mx-auto text-amber-400 mb-2">
                            <i data-lucide="award" class="w-6 h-6 animate-bounce"></i>
                        </div>
                        <h3 class="text-xl font-black text-white">Unlock Pause+ Premium</h3>
                        <p class="text-xs text-slate-400">Support your growth with low-stakes pre-commitment.</p>
                    </div>

                    ${state.hasPremium ? `
                        <!-- Already Premium Celebration State -->
                        <div class="my-auto bg-amber-950/20 border border-amber-500/20 p-5 rounded-2xl space-y-3 text-center">
                            <span class="text-2xl">🎉</span>
                            <h4 class="text-sm font-bold text-amber-300">You are in Pause+ Mode</h4>
                            <p class="text-[11px] text-slate-300 leading-relaxed">
                                Thank you for your subscription of $4.99/month. Feel good about trying. You have full access to Custom breathing, Quiet Hours, and Streak history logs.
                            </p>
                            <button onclick="cancelPremiumSubscription()" class="text-[10px] text-rose-400 font-bold underline">
                                Sim Cancellation
                            </button>
                        </div>
                    ` : `
                        <!-- Active subscription offers -->
                        <div class="my-auto space-y-3.5">
                            <button onclick="upgradeToPremium(4.99, 'Monthly')" class="w-full text-left p-4 bg-slate-900 hover:bg-indigo-950/10 border border-indigo-500/30 rounded-2xl transition-all relative">
                                <span class="absolute right-4 top-4 text-[9px] bg-indigo-500/20 text-indigo-300 px-1.5 py-0.5 rounded-full font-bold">POPULAR</span>
                                <div class="text-xs font-black text-slate-200">Monthly Membership</div>
                                <div class="text-lg font-extrabold text-white mt-0.5">$4.99 <span class="text-xs font-normal text-slate-500">/ month</span></div>
                                <p class="text-[10px] text-slate-400 mt-1">Cheap enough to keep even if you never quit scrolling.</p>
                            </button>

                            <button onclick="upgradeToPremium(39.99, 'Annual')" class="w-full text-left p-4 bg-slate-900/60 hover:bg-slate-900 border border-slate-800 rounded-2xl transition-all">
                                <div class="text-xs font-black text-slate-300">Annual Plan (2 Months Free)</div>
                                <div class="text-lg font-extrabold text-slate-200 mt-0.5">$39.99 <span class="text-xs font-normal text-slate-500">/ year</span></div>
                                <p class="text-[10px] text-slate-400 mt-1">Pre-commit to a whole year of mindfulness.</p>
                            </button>
                        </div>
                    `}

                    <!-- Standard Footer links inside subscription views -->
                    <div class="space-y-3">
                        ${!state.hasPremium ? `
                            <button onclick="upgradeToPremium(4.99, 'Monthly')" class="w-full bg-gradient-to-r from-amber-500 to-indigo-600 hover:from-amber-400 hover:to-indigo-500 text-white font-bold py-3 px-4 rounded-xl text-xs transition-all flex items-center justify-center gap-1.5">
                                <i data-lucide="credit-card" class="w-4 h-4"></i> Pre-commit for $4.99/mo
                            </button>
                        ` : ''}

                        <div class="grid grid-cols-3 border-t border-slate-900 pt-3">
                            <button onclick="changeScreen('home')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                                <i data-lucide="home" class="w-5 h-5"></i>
                                <span class="text-[9px] font-bold">Home</span>
                            </button>
                            <button onclick="changeScreen('dashboard')" class="flex flex-col items-center gap-1 text-slate-500 hover:text-slate-300 transition-colors">
                                <i data-lucide="bar-chart-2" class="w-5 h-5"></i>
                                <span class="text-[9px] font-bold">Scrollytics</span>
                            </button>
                            <button onclick="changeScreen('premium-modal')" class="flex flex-col items-center gap-1 text-indigo-400">
                                <i data-lucide="award" class="w-5 h-5"></i>
                                <span class="text-[9px] font-bold">Pause+</span>
                            </button>
                        </div>
                    </div>
                </div>
            `;
            break;
    }

    // Refresh icons inside rendered phone layout
    if (window.lucide) {
        window.lucide.createIcons();
    }
}

// Global actions and callbacks within the screens
function changeScreen(screenName) {
    if (pauseGateTimer) clearInterval(pauseGateTimer);
    if (feedTimer) clearInterval(feedTimer);
    currentScreen = screenName;
    renderCurrentScreen();
}

// Managed app selections
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

// Welcome onboarding
function completeOnboarding() {
    state.onboarded = true;
    saveState();
    logAction('Welcome to Pause', 'Completed onboarding guide. Happy mindful scrolling!');
    changeScreen('home');
}

function selectIntention(option) {
    logAction(`Intention Logged`, `"${option}" for opening ${simulatedAppToOpen}`);
    startPauseGate();
}

function continueToFeed() {
    logAction(`Gate Unlocked`, `Granted 15 min session on ${simulatedAppToOpen}`);
    startScrollSimulator(simulatedAppToOpen);
}

function resistNudgeAndClose() {
    state.nudgesResisted++;
    logAction(`Nudge Resisted`, `Refused feed scroll on ${simulatedAppToOpen}`);
    saveState();
    changeScreen('home');
}

function submitCheckIn(ratingText) {
    state.checkedInCount++;
    state.lastCheckInRating = ratingText;
    logAction(`Check-In Reflect`, `Session rated: ${ratingText}`);
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
    logAction('Premium Subscribed', `Upgraded to Pause+ ${tier} Plan ($${price})`);

    // Animate custom sparkle particles overlaying smartphone viewport
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

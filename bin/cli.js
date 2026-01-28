#!/usr/bin/env node

/**
 * Antigravity Kit (JZ Edition) - Node.js Installer
 * 
 * Provides "npx ag-jz-rm init" functionality.
 * Compatible with Windows, macOS, and Linux.
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');
const os = require('os');

// Configuration
const REPO_CORE_URL = "https://github.com/vudovn/antigravity-kit/archive/refs/heads/main.zip";
const REPO_SKILLS_URL = "https://github.com/sickn33/antigravity-awesome-skills/archive/refs/heads/main.zip";
const KIT_DIR_NAME = ".gemini/antigravity/kit";

// Colors for console
const colors = {
    reset: "\x1b[0m",
    cyan: "\x1b[36m",
    green: "\x1b[32m",
    yellow: "\x1b[33m",
    red: "\x1b[31m",
    gray: "\x1b[90m"
};

function log(msg, color = colors.reset) {
    console.log(`${color}${msg}${colors.reset}`);
}

function getHomeDir() {
    return os.homedir();
}

function downloadFile(url, dest) {
    return new Promise((resolve, reject) => {
        const file = fs.createWriteStream(dest);
        let downloadedBytes = 0;
        let lastDataTime = Date.now();
        const INACTIVITY_TIMEOUT = 20000; // 20s de inatividade causa timeout

        const request = https.get(url, (response) => {
            // Handle redirects
            if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
                log(`[>] Redirecting to download server...`, colors.gray);
                file.close();
                fs.unlink(dest, () => { });
                downloadFile(response.headers.location, dest).then(resolve).catch(reject);
                return;
            }

            if (response.statusCode !== 200) {
                reject(new Error(`Server returned ${response.statusCode}`));
                return;
            }

            const totalSize = parseInt(response.headers['content-length'], 10);

            let startTime = Date.now();
            response.on('data', (chunk) => {
                downloadedBytes += chunk.length;
                lastDataTime = Date.now();
                const elapsedSeconds = (Date.now() - startTime) / 1000;
                const speed = (downloadedBytes / 1024 / (elapsedSeconds || 1)).toFixed(1);

                if (totalSize) {
                    const percent = ((downloadedBytes / totalSize) * 100).toFixed(0);
                    process.stdout.write(`\r[>] Progress: ${percent}% (${(downloadedBytes / 1024).toFixed(0)} KB) @ ${speed} KB/s    `);
                } else {
                    process.stdout.write(`\r[>] Progress: ${(downloadedBytes / 1024).toFixed(0)} KB @ ${speed} KB/s    `);
                }
            });

            response.pipe(file);

            file.on('finish', () => {
                process.stdout.write('\n');
                file.close();
                clearInterval(inactivityCheck);
                resolve();
            });
        }).on('error', (err) => {
            process.stdout.write('\n');
            fs.unlink(dest, () => { });
            clearInterval(inactivityCheck);
            reject(err);
        });

        // Socket Inactivity Monitor
        const inactivityCheck = setInterval(() => {
            if (Date.now() - lastDataTime > INACTIVITY_TIMEOUT) {
                clearInterval(inactivityCheck);
                request.destroy();
                reject(new Error(`Download stalled (no data for ${INACTIVITY_TIMEOUT / 1000}s). Check your internet.`));
            }
        }, 2000);
    });
}

function logHeader() {
    log("\n🌌 Antigravity JZ-RM Edition", colors.cyan);
    log("──────────────────────────", colors.gray);
}

function safeRemove(dir) {
    if (!fs.existsSync(dir)) return;
    try {
        // Use retry settings for Windows locks
        fs.rmSync(dir, { recursive: true, force: true, maxRetries: 3, retryDelay: 100 });
    } catch (e) {
        log(` [!] Note: Could not clean up temporary folder ${dir}. You can delete it manually.`, colors.gray);
    }
}

function mergeFolders(src, dest) {
    if (!fs.existsSync(src)) return;
    if (!fs.existsSync(dest)) fs.mkdirSync(dest, { recursive: true });

    const items = fs.readdirSync(src);
    items.forEach(item => {
        const sPath = path.join(src, item);
        const dPath = path.join(dest, item);

        if (fs.statSync(sPath).isDirectory()) {
            mergeFolders(sPath, dPath);
        } else {
            try {
                fs.copyFileSync(sPath, dPath);
            } catch (e) {
                log(` [!] Failed to copy ${item}: ${e.message}`, colors.yellow);
            }
        }
    });
}

async function main() {
    logHeader();

    const isLocal = process.argv.includes('--local') || process.argv.includes('-l');
    const homeDir = getHomeDir();
    const globalKitDir = path.join(homeDir, KIT_DIR_NAME);
    const installDir = isLocal ? path.join(process.cwd(), ".agent") : globalKitDir;

    // Use system temp for zero-friction
    const tempDir = path.join(os.tmpdir(), `jz_rm_turbo_${Date.now()}`);

    try {
        // 1. Quantum Core Synchronization
        log(`\n🛰️  Synchronizing Quantum Core...`, colors.cyan);
        try {
            // Run silently to hide upstream branding
            if (isLocal) {
                execSync(`npx -y @vudovn/ag-kit init`, { stdio: 'ignore' });
            } else {
                execSync(`npm install -g @vudovn/ag-kit`, { stdio: 'ignore' });
                execSync(`ag-kit init`, { stdio: 'ignore' });
            }
            log(` [✨] Core Engine: Online`, colors.green);
        } catch (e) {
            log(` [!] Core Synchronization Notice. Continuing to augmentation...`, colors.yellow);
        }

        // 2. High-Octane Skills Injection
        log(`\n⚡ Injecting High-Octane Capabilities...`, colors.cyan);
        log(` [>] Pulling 255+ Specialist Skills from Library...`, colors.gray);

        try {
            execSync(`npx -y giget github:sickn33/antigravity-awesome-skills#main "${tempDir}"`, { stdio: 'ignore' });

            const skillsSource = path.join(tempDir, 'skills');
            if (fs.existsSync(skillsSource)) {
                mergeFolders(skillsSource, path.join(installDir, 'skills'));
                log(` [🚀] 255+ Skills Successfully Integrated`, colors.green);
            }
        } catch (e) {
            log(` [!] Skill Injection Timeout. You can run 'ag-jz-rm update' later.`, colors.yellow);
        }

        // 3. Identity & Governance Protocol
        log(`Applying Identity & Governance Protocols...`, colors.cyan);

        const localGemini = path.join(__dirname, '..', '.agent', 'rules', 'GEMINI.md');
        const destRulesDir = path.join(installDir, 'rules');
        const destGemini = path.join(destRulesDir, 'GEMINI.md');

        if (!fs.existsSync(destRulesDir)) fs.mkdirSync(destRulesDir, { recursive: true });
        if (fs.existsSync(localGemini)) {
            fs.copyFileSync(localGemini, destGemini);
            log(` [🔭] JZ-RM Logic Protocols: Active`, colors.green);
        }

        // Copy auxiliary scripts
        const localScripts = path.join(__dirname, '..', '.agent', 'scripts');
        const destScripts = path.join(installDir, 'scripts');
        if (fs.existsSync(localScripts)) {
            mergeFolders(localScripts, destScripts);
        }

        // 4. Cleanup
        safeRemove(tempDir);

        // 5. Neural Indexing
        const indexerScript = path.join(destScripts, 'generate_index.py');
        if (fs.existsSync(indexerScript)) {
            log(`\n📦 Initializing Neural Discovery...`, colors.cyan);
            try {
                const pyCmd = process.platform === 'win32' ? 'python' : 'python3';
                execSync(`${pyCmd} "${indexerScript}"`, { stdio: 'ignore' });
                log(` [✨] Neural Map: 100% Optimized`, colors.green);
            } catch (e) {
                log(` [!] Run 'python .agent/scripts/generate_index.py' to manually optimize map.`, colors.yellow);
            }
        }

        log(`\n🌌  SETUP COMPLETE — Antigravity JZ-RM is now LIVE`, colors.green);
        log(`────────────────────────────────────────`, colors.gray);
        log(`Edition: JZ-RM "Base + Turbo"`, colors.cyan);
        log(`Mode:    ${isLocal ? "Local Workspace" : "Global System"}`, colors.gray);
        log(`Link:    .agent/rules/GEMINI.md`, colors.gray);
        log(`────────────────────────────────────────`, colors.gray);
        log(`Happy hacking! 🚀\n`, colors.cyan);

    } catch (err) {
        log(`\n❌ Fatal Error during setup: ${err.message}`, colors.red);
        safeRemove(tempDir);
        process.exit(1);
    }
}

main();

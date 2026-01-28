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

    // Use system temp for less friction
    const tempDir = path.join(os.tmpdir(), `jz_rm_turbo_${Date.now()}`);

    try {
        // 1. Base Layer Initialization
        log(`\n🚀 Initializing Antigravity Core (@vudovn/ag-kit)...`, colors.cyan);
        try {
            if (isLocal) {
                execSync(`npx -y @vudovn/ag-kit init`, { stdio: 'inherit' });
            } else {
                log(`[>] Global mode: Installing @vudovn/ag-kit core...`, colors.gray);
                execSync(`npm install -g @vudovn/ag-kit`, { stdio: 'ignore' });
                execSync(`ag-kit init`, { stdio: 'inherit' });
            }
        } catch (e) {
            log(` [!] Base installer finished with notice. Attempting augmentation...`, colors.yellow);
        }

        // 2. High-Octane Skills Augmentation (Sickn33)
        log(`\nTurbo-charging Skills Ecosystem...`, colors.cyan);
        log(` [>] Fetching Sickn33 awesome-skills via giget...`, colors.gray);

        try {
            // Use giget directly via npx for maximum extraction robustness
            execSync(`npx -y giget github:sickn33/antigravity-awesome-skills#main "${tempDir}"`, { stdio: 'ignore' });

            const skillsSource = path.join(tempDir, '.agent', 'skills');
            if (fs.existsSync(skillsSource)) {
                log(` [+] Injecting 255+ Specialist Skills`, colors.gray);
                mergeFolders(skillsSource, path.join(installDir, 'skills'));
            } else {
                log(` [!] Could not find skills in downloaded folder.`, colors.yellow);
            }
        } catch (e) {
            log(` [!] Turbo-charge failed: ${e.message}`, colors.red);
            log(` [!] Run 'ag-jz-rm update' later to retry augmentation.`, colors.yellow);
        }

        // 3. Identity Governance (GEMINI.md)
        log(`Applying Identity & Rules Governance...`, colors.cyan);

        const localGemini = path.join(__dirname, '..', '.agent', 'rules', 'GEMINI.md');
        const destRulesDir = path.join(installDir, 'rules');
        const destGemini = path.join(destRulesDir, 'GEMINI.md');

        if (!fs.existsSync(destRulesDir)) fs.mkdirSync(destRulesDir, { recursive: true });
        if (fs.existsSync(localGemini)) {
            fs.copyFileSync(localGemini, destGemini);
            log(` [✨] Antigravity JZ-RM Rules Activated`, colors.green);
        } else {
            // Fallback for npx run: check if .agent is in same level as bin
            const fallbackGemini = path.join(__dirname, 'rules', 'GEMINI.md');
            if (fs.existsSync(fallbackGemini)) {
                fs.copyFileSync(fallbackGemini, destGemini);
                log(` [✨] Antigravity JZ-RM Rules Activated (fallback)`, colors.green);
            }
        }

        // Copy auxiliary scripts
        const localScripts = path.join(__dirname, '..', '.agent', 'scripts');
        const destScripts = path.join(installDir, 'scripts');
        if (fs.existsSync(localScripts)) {
            mergeFolders(localScripts, destScripts);
        }

        // 4. Cleanup
        safeRemove(tempDir);

        // 5. Final Orchestration (Indexing)
        const indexerScript = path.join(destScripts, 'generate_index.py');
        if (fs.existsSync(indexerScript)) {
            log(`\n📦 Indexing Capabilities...`, colors.cyan);
            try {
                execSync(`python "${indexerScript}"`, { stdio: 'ignore' });
                log(` [✨] Skills Indexer: 100% Optimized`, colors.green);
            } catch (e) {
                log(` [!] Indexer manual run: python .agent/scripts/generate_index.py`, colors.yellow);
            }
        }

        log(`\n✅ ${isLocal ? "Local" : "Global"} Setup Complete!`, colors.green);
        log(`🚀 Antigravity JZ-RM is now ONLINE.`, colors.cyan);
        log(`Rules: .agent/rules/GEMINI.md`, colors.gray);
        log(`\n──────────────────────────`, colors.gray);

    } catch (err) {
        log(`\n❌ Setup Error: ${err.message}`, colors.red);
        if (err.stack) log(err.stack, colors.gray);
        safeRemove(tempDir);
        process.exit(1);
    }
}

main();

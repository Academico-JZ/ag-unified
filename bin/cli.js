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
const REPO_ZIP_URL = "https://github.com/Academico-JZ/antigravity-jz-rm/archive/refs/heads/main.zip";
const KIT_DIR_NAME = ".gemini/antigravity/kit";
const TEMP_DIR_NAME = ".gemini/antigravity/temp_npm_install";

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

        const request = https.get(url, (response) => {
            // Handle redirects (GitHub often does 302 to codeload)
            if (response.statusCode >= 300 && response.statusCode < 400 && response.headers.location) {
                log(`[>] Redirecting to download server...`, colors.gray);
                file.close();
                fs.unlink(dest, () => { });
                downloadFile(response.headers.location, dest).then(resolve).catch(reject);
                return;
            }

            if (response.statusCode !== 200) {
                reject(new Error(`Failed to download: ${response.statusCode}`));
                return;
            }

            const totalSize = parseInt(response.headers['content-length'], 10);

            response.on('data', (chunk) => {
                downloadedBytes += chunk.length;
                if (totalSize) {
                    const percent = ((downloadedBytes / totalSize) * 100).toFixed(0);
                    process.stdout.write(`\r[>] Progress: ${percent}% (${(downloadedBytes / 1024).toFixed(0)} KB)    `);
                } else {
                    process.stdout.write(`\r[>] Progress: ${(downloadedBytes / 1024).toFixed(0)} KB    `);
                }
            });

            response.pipe(file);

            file.on('finish', () => {
                process.stdout.write('\n');
                file.close();
                resolve();
            });
        }).on('error', (err) => {
            process.stdout.write('\n');
            fs.unlink(dest, () => { });
            reject(err);
        });

        request.setTimeout(60000, () => {
            request.destroy();
            reject(new Error("Download timeout after 60s (Check your internet connection)"));
        });
    });
}

async function main() {
    log("\n🌌 Antigravity Kit (JZ e RM Edition) - CLI Installer", colors.cyan);
    log("--------------------------------------------------", colors.gray);

    const homeDir = getHomeDir();
    const installDir = path.join(homeDir, KIT_DIR_NAME);
    const tempDir = path.join(homeDir, TEMP_DIR_NAME);
    const zipPath = path.join(tempDir, "kit.zip");

    try {
        // 1. Prepare Paths
        if (fs.existsSync(tempDir)) {
            fs.rmSync(tempDir, { recursive: true, force: true });
        }
        fs.mkdirSync(tempDir, { recursive: true });

        // 2. Download
        log(`[>] Downloading kit from GitHub...`, colors.gray);
        await downloadFile(REPO_ZIP_URL, zipPath);

        // 3. Extract
        log(`[>] Extracting...`, colors.gray);
        // Use tar for extraction (available on Win10+, Mac, Linux)
        try {
            execSync(`tar -xf "${zipPath}" -C "${tempDir}"`);
        } catch (e) {
            // Fallback for older Windows without tar?
            if (process.platform === 'win32') {
                execSync(`powershell -c "Expand-Archive -Path '${zipPath}' -DestinationPath '${tempDir}' -Force"`);
            } else {
                throw e;
            }
        }

        // 4. Move to Final Location
        if (fs.existsSync(installDir)) {
            log(`[!] Removing existing installation...`, colors.yellow);
            fs.rmSync(installDir, { recursive: true, force: true });
        }

        // Find extracted folder (GitHub names it repo-branch, e.g. antigravity-jz-rm-main)
        const extractedName = fs.readdirSync(tempDir).find(n => {
            const fullPath = path.join(tempDir, n);
            return fs.statSync(fullPath).isDirectory() && n !== "__MACOSX";
        });

        if (!extractedName) {
            throw new Error("Could not find extracted folder in temporary directory.");
        }

        const sourcePath = path.join(tempDir, extractedName);
        fs.mkdirSync(path.dirname(installDir), { recursive: true });
        fs.renameSync(sourcePath, installDir);

        // 5. Cleanup
        fs.rmSync(tempDir, { recursive: true, force: true });

        // 6. Auto-Hydration (Sync Kits)
        const syncScript = path.join(installDir, '.agent', 'scripts', 'sync_kits.py');
        if (fs.existsSync(syncScript)) {
            log(`\n🔄 Auto-Hydrating Skills (Vudovn + Awesome Skills)...`, colors.cyan);
            try {
                // Check if python is available
                execSync('python --version', { stdio: 'ignore' });
                execSync(`python "${syncScript}"`, { stdio: 'inherit' });
            } catch (e) {
                log(`[!] Python not found or sync failed. Please run manually: python "${syncScript}"`, colors.yellow);
            }
        }

        // 7. Success
        log(`\n✅ Installation & Hydration Complete!`, colors.green);
        log(`📍 Location: ${installDir}`, colors.gray);
        log(`\n🚀 Next Steps:`, colors.cyan);

        if (process.platform === 'win32') {
            log(`Run this command in your project folder to link it:`, colors.yellow);
            log(`powershell -ExecutionPolicy Bypass -File "${path.join(installDir, 'scripts', 'setup_workspace.ps1')}"\n`, colors.reset);
        } else {
            log(`Run the setup script in your project folder.`, colors.yellow);
        }

    } catch (err) {
        log(`\n❌ Error: ${err.message}`, colors.red);
        if (err.stderr) log(err.stderr.toString(), colors.red);
        process.exit(1);
    }
}

main();

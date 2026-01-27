#!/usr/bin/env node

/**
 * Antigravity Kit (JZ Edition) - Node.js Installer
 * 
 * Provides "npx ag-jz init" functionality.
 * Compatible with Windows, macOS, and Linux.
 */

const fs = require('fs');
const path = require('path');
const https = require('https');
const { execSync } = require('child_process');
const os = require('os');

// Configuration
const REPO_ZIP_URL = "https://github.com/Academico-JZ/antigravity-jz/archive/refs/heads/main.zip";
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
        https.get(url, (response) => {
            if (response.statusCode !== 200) {
                reject(new Error(`Failed to download: ${response.statusCode}`));
                return;
            }
            response.pipe(file);
            file.on('finish', () => {
                file.close();
                resolve();
            });
        }).on('error', (err) => {
            fs.unlink(dest, () => {});
            reject(err);
        });
    });
}

async function main() {
    log("\n🌌 Antigravity Kit (JZ Edition) - CLI Installer", colors.cyan);
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
            // Actually, if they have Node, they likely have tar or unzip. 
            // If strictly Windows Powershell:
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
        
        // Find extracted folder
        const extractedName = fs.readdirSync(tempDir).find(n => n.includes('antigravity-jz'));
        const sourcePath = path.join(tempDir, extractedName);
        
        fs.mkdirSync(path.dirname(installDir), { recursive: true });
        fs.renameSync(sourcePath, installDir);

        // 5. Cleanup
        fs.rmSync(tempDir, { recursive: true, force: true });

        // 6. Success
        log(`\n✅ Installation Complete!`, colors.green);
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

import os
import shutil
import urllib.request
import zipfile
import tempfile
import subprocess
import sys

# Globals
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
# .agent/scripts/sync_kits.py -> .agent
AGENT_DIR = os.path.abspath(os.path.join(SCRIPT_DIR, ".."))

# IDENTITY GUARD: Files that should NEVER be overwritten or deleted by sync
PROTECTED_FILES = [
    "GEMINI.md",
    "README.md",
    "CODEBASE.md",
    "ARCHITECTURE.md",
    "sync_kits.py",
    "setup_workspace.ps1",
    "install.ps1",
    "cli.js"
]

def safe_merge_dir(src, dest):
    """
    Safely merges content from src to dest.
    Does NOT delete files in dest that are missing in src.
    Does NOT overwrite protected files.
    """
    if not os.path.exists(dest):
        os.makedirs(dest)
        print(f"  [+] Created directory: {os.path.basename(dest)}")

    for item in os.listdir(src):
        s = os.path.join(src, item)
        d = os.path.join(dest, item)

        # Check if file is protected
        if item in PROTECTED_FILES:
            print(f"  [🛡️] Identity Guard: Preserving local {item}")
            continue

        try:
            if os.path.isdir(s):
                # Recursively merge directories instead of rmtree
                safe_merge_dir(s, d)
            else:
                # Copy file (overwrite if not protected)
                shutil.copy2(s, d)
                # No print for every file to keep logs clean, only for dirs or special cases
        except Exception as e:
            print(f"     ⚠️ Error syncing {item}: {e}")

def sync_kit(repo_url, kit_name):
    print(f"\n🔄 Sincronizando {kit_name} desde {repo_url}...")
    
    branches = ["main", "master"]
    success = False
    active_branch = None
    
    base_url = repo_url
    if base_url.endswith(".git"):
        base_url = base_url[:-4]
    
    with tempfile.TemporaryDirectory() as temp_dir:
        for branch in branches:
            temp_zip = os.path.join(temp_dir, f"{branch}.zip")
            zip_url = f"{base_url}/archive/refs/heads/{branch}.zip"
            
            try:
                print(f"  [>] Tentando branch '{branch}'...")
                req = urllib.request.Request(zip_url, headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(req) as response, open(temp_zip, 'wb') as out_file:
                    out_file.write(response.read())
                
                success = True
                active_branch = branch
                break
            except Exception:
                continue
        
        if not success:
            print(f"  ❌ Erro: Não foi possível baixar {kit_name}")
            return

        try:
            with zipfile.ZipFile(temp_zip, 'r') as zip_ref:
                zip_ref.extractall(temp_dir)
        except Exception as e:
            print(f"  ❌ Erro ao extrair: {e}")
            return

        extracted_content = os.listdir(temp_dir)
        extracted_folder = None
        for item in extracted_content:
            if os.path.isdir(os.path.join(temp_dir, item)) and item != "__MACOSX":
                extracted_folder = os.path.join(temp_dir, item)
                break
        
        if not extracted_folder:
            print(f"  ❌ Falha na extração de {kit_name}")
            return

        # Sync folders
        sub_folders = ["agents", "skills", "workflows", "scripts"]
        for sub in sub_folders:
            src = os.path.join(extracted_folder, ".agent", sub)
            dest = os.path.join(AGENT_DIR, sub) # Use global AGENT_DIR
            
            if os.path.exists(src):
                print(f"  [>] Unificando {sub} (Identity-Safe Merge)...")
                safe_merge_dir(src, dest)

    print(f"✅ Sincronização de {kit_name} concluída!")

def main():
    # Kit 1 (Awesome Skills)
    sync_kit("https://github.com/sickn33/antigravity-awesome-skills.git", "Awesome Skills")
    
    # Kit 2 (Antigravity Kit)
    sync_kit("https://github.com/vudovn/antigravity-kit.git", "Antigravity Kit")
    
    # 4. Auto-Index Skills
    print("\n📦 Updating Skills Index...")
    indexer_path = os.path.join(AGENT_DIR, "scripts", "generate_index.py")
    if os.path.exists(indexer_path):
        try:
            subprocess.run([sys.executable, indexer_path], check=True)
        except subprocess.CalledProcessError as e:
             print(f"⚠️  Indexer failed with exit code {e.returncode}")
        except Exception as e:
             print(f"⚠️  Indexer execution error: {e}")
    else:
        print(f"⚠️  Indexer script not found at {indexer_path}")

if __name__ == "__main__":
    main()

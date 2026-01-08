"""
Agent-0 Workspace Analyzer
==========================
Scan dan index semua file markdown di workspace Agent-0.

Jalankan: python analyze_workspace.py
Output: workspace_index.json
"""
import os
import json
import re

# ============================================================
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(SCRIPT_DIR)
CWD = os.getcwd()

# Try multiple strategies to find workspace
WORKSPACE_CANDIDATES = ['Agent-0', 'agent-workspace']
WORKSPACE_DIR = None

# Strategy 1: Look relative to script location
for candidate in WORKSPACE_CANDIDATES:
    path = os.path.join(BASE_DIR, candidate)
    if os.path.exists(path):
        WORKSPACE_DIR = path
        break

# Strategy 2: Look relative to current working directory
if not WORKSPACE_DIR:
    for candidate in WORKSPACE_CANDIDATES:
        path = os.path.join(CWD, candidate)
        if os.path.exists(path):
            WORKSPACE_DIR = path
            break

# Strategy 3: Check if CWD itself is the workspace (contains Topic folder)
if not WORKSPACE_DIR:
    if os.path.exists(os.path.join(CWD, 'Topic')):
        WORKSPACE_DIR = CWD

# Strategy 4: Check parent of CWD
if not WORKSPACE_DIR:
    parent_cwd = os.path.dirname(CWD)
    for candidate in WORKSPACE_CANDIDATES:
        path = os.path.join(parent_cwd, candidate)
        if os.path.exists(path):
            WORKSPACE_DIR = path
            break

if not WORKSPACE_DIR:
    print("⚠️ Workspace folder not found!")
    print(f"   Looked in: {BASE_DIR}, {CWD}")
    print(f"   Expected folders: {WORKSPACE_CANDIDATES}")
    print("   Tip: Make sure 'Agent-0/' or 'agent-workspace/' folder exists")
    exit(1)


def extract_info(file_path):
    """Mengekstrak judul dan ringkasan singkat dari file Markdown."""
    title = os.path.basename(file_path)
    summary = ""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            for i, line in enumerate(lines):
                if line.startswith('# '):
                    title = line.replace('# ', '').strip()
                    # Cari baris non-kosong berikutnya sebagai summary
                    for next_line in lines[i+1:]:
                        clean_line = next_line.strip()
                        if clean_line and not clean_line.startswith('#'):
                            summary = clean_line[:150] + "..." if len(clean_line) > 150 else clean_line
                            break
                    break
    except Exception:
        pass
    return title, summary


def analyze_workspace(workspace_path):
    structure = {}
    target_dirs = ['Topic', 'Find', 'Plan', 'Knowledge', 'Research']

    print(f"\n📂 Scanning: {workspace_path}\n" + "="*50)

    for folder in target_dirs:
        folder_path = os.path.join(workspace_path, folder)
        if os.path.exists(folder_path):
            files_info = []
            for filename in os.listdir(folder_path):
                if filename.endswith('.md'):
                    full_path = os.path.join(folder_path, filename)
                    title, summary = extract_info(full_path)
                    files_info.append({
                        "file": filename,
                        "title": title,
                        "summary": summary
                    })
            structure[folder] = {
                "count": len(files_info),
                "items": files_info
            }
            print(f"  ✅ {folder}: {len(files_info)} files")
        else:
            print(f"  ⏭️ {folder}: not found")

    return structure


if __name__ == "__main__":
    results = analyze_workspace(WORKSPACE_DIR)

    output_path = os.path.join(SCRIPT_DIR, "workspace_index.json")
    with open(output_path, "w", encoding='utf-8') as f:
        json.dump(results, f, indent=4, ensure_ascii=False)

    print(f"\n💾 Index saved to: {output_path}")

    # Enhanced output: Show title for each file
    print("\n" + "="*60)
    print("📋 WORKSPACE OVERVIEW")
    print("="*60)

    total_files = 0
    for folder, data in results.items():
        count = data['count']
        total_files += count

        # Folder header with emoji
        emoji_map = {
            "Topic": "📚",
            "Plan": "🏗️",
            "Find": "🔍",
            "Knowledge": "📖",
            "Research": "🔬",
            "Log": "📋"
        }
        emoji = emoji_map.get(folder, "📁")

        print(f"\n{emoji} {folder} ({count} files)")
        print("-" * 40)

        # Sort items: index.md first, then by filename
        items = sorted(data['items'], key=lambda x: (
            0 if 'index' in x['file'].lower() else 1,
            x['file']
        ))

        for item in items:
            title = item['title']
            filename = item['file']

            # Truncate title if too long
            max_title_len = 45
            if len(title) > max_title_len:
                title = title[:max_title_len-3] + "..."

            # Mark index files
            if 'index' in filename.lower():
                print(f"  📌 {title}")
            else:
                print(f"  • {title}")

    print("\n" + "="*60)
    print(f"📊 Total: {total_files} files across {len(results)} folders")
    print("="*60)

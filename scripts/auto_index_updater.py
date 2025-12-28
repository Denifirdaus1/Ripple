"""
Auto Index Updater
===================
Script untuk otomatis update index.md di setiap folder workspace.

Fitur:
1. Scan semua folder target (Topic, Plan, Find, Knowledge, Research)
2. Generate/update index.md dengan daftar file yang ada
3. Preserve existing content jika ada
4. Report perubahan yang dilakukan

Author: Created via Antigravity AI
Date: 2024-12-22
"""

import os
import re
from datetime import datetime
from typing import List, Dict, Tuple, Optional

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

# Folders to manage indexes for
TARGET_FOLDERS = ['Topic', 'Find', 'Plan', 'Research']

# Knowledge has subdirectories, handle separately
KNOWLEDGE_DIR = os.path.join(WORKSPACE_DIR, 'Knowledge')


def extract_title(file_path: str) -> str:
    """Extract H1 title from markdown file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            for line in f:
                if line.startswith('# '):
                    return line[2:].strip()
    except:
        pass
    return os.path.basename(file_path).replace('.md', '')


def extract_summary(file_path: str) -> str:
    """Extract first non-empty paragraph after title"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            found_title = False
            for line in lines:
                if line.startswith('# '):
                    found_title = True
                    continue
                if found_title:
                    stripped = line.strip()
                    if stripped and not stripped.startswith('#') and not stripped.startswith('>'):
                        # Truncate if too long
                        if len(stripped) > 100:
                            return stripped[:97] + "..."
                        return stripped
    except:
        pass
    return ""


def get_files_in_folder(folder_path: str) -> List[Dict]:
    """Get all markdown files in a folder with metadata"""
    files = []
    if not os.path.exists(folder_path):
        return files

    for filename in sorted(os.listdir(folder_path)):
        # Skip index files and files starting with underscore
        if filename.endswith('.md') and filename.lower() != 'index.md' and not filename.startswith('_'):
            file_path = os.path.join(folder_path, filename)
            title = extract_title(file_path)
            summary = extract_summary(file_path)

            files.append({
                'filename': filename,
                'title': title,
                'summary': summary
            })

    return files


def generate_index_content(folder_name: str, files: List[Dict]) -> str:
    """Generate index.md content for a folder"""

    # Emoji mapping
    emoji_map = {
        'Topic': '📚',
        'Plan': '🏗️',
        'Find': '🔍',
        'Research': '🔬',
        'Knowledge': '📖'
    }
    emoji = emoji_map.get(folder_name, '📁')

    content = f"# {emoji} {folder_name} Index\n\n"
    content += f"> Auto-generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n"
    content += "---\n\n"
    content += f"## Daftar {folder_name} ({len(files)} items)\n\n"

    if not files:
        content += "_Belum ada file._\n"
    else:
        content += "| File | Title | Summary |\n"
        content += "|------|-------|--------|\n"

        for f in files:
            # Escape pipe characters in summary
            summary = f['summary'].replace('|', '\\|')
            content += f"| `{f['filename']}` | {f['title']} | {summary} |\n"

    content += "\n---\n"
    content += f"\n_Updated by auto_index_updater.py_\n"

    return content


def update_folder_index(folder_path: str, folder_name: str) -> Tuple[bool, int, str]:
    """
    Update index.md for a folder.
    Returns: (changed, file_count, message)
    """
    index_path = os.path.join(folder_path, 'index.md')
    files = get_files_in_folder(folder_path)

    new_content = generate_index_content(folder_name, files)

    # Check if index exists and compare
    if os.path.exists(index_path):
        with open(index_path, 'r', encoding='utf-8') as f:
            old_content = f.read()

        # Extract just the file list section to compare (ignore timestamp)
        old_files = set(re.findall(r'`([^`]+\.md)`', old_content))
        new_files = set(f['filename'] for f in files)

        if old_files == new_files:
            return False, len(files), "No changes needed"

        # Files changed
        added = new_files - old_files
        removed = old_files - new_files
        msg_parts = []
        if added:
            msg_parts.append(f"+{len(added)} added")
        if removed:
            msg_parts.append(f"-{len(removed)} removed")
        message = ", ".join(msg_parts)
    else:
        message = "Created new index"

    # Write new content
    with open(index_path, 'w', encoding='utf-8') as f:
        f.write(new_content)

    return True, len(files), message


def update_knowledge_indexes() -> List[Tuple[str, bool, int, str]]:
    """
    Update indexes for Knowledge subdirectories.
    Knowledge has domain subfolders, each needs its own index.
    Returns: [(domain_name, changed, file_count, message), ...]
    """
    results = []

    if not os.path.exists(KNOWLEDGE_DIR):
        return results

    # Update master index
    master_index_path = os.path.join(KNOWLEDGE_DIR, 'index.md')
    domains = []

    for item in sorted(os.listdir(KNOWLEDGE_DIR)):
        item_path = os.path.join(KNOWLEDGE_DIR, item)
        if os.path.isdir(item_path):
            # This is a domain folder
            domain_name = item
            changed, count, msg = update_folder_index(item_path, f"Knowledge/{domain_name}")
            results.append((f"Knowledge/{domain_name}", changed, count, msg))
            domains.append({
                'name': domain_name,
                'path': item,
                'count': count
            })

    # Generate master index
    if domains:
        master_content = "# 📖 Knowledge Base Index\n\n"
        master_content += f"> Auto-generated: {datetime.now().strftime('%Y-%m-%d %H:%M')}\n\n"
        master_content += "---\n\n"
        master_content += f"## Domains ({len(domains)} total)\n\n"
        master_content += "| Domain | Files | Link |\n"
        master_content += "|--------|-------|------|\n"

        for d in domains:
            master_content += f"| {d['name']} | {d['count']} | [`{d['path']}/index.md`]({d['path']}/index.md) |\n"

        master_content += "\n---\n"
        master_content += "\n_Updated by auto_index_updater.py_\n"

        with open(master_index_path, 'w', encoding='utf-8') as f:
            f.write(master_content)

        results.append(("Knowledge (Master)", True, len(domains), "Updated master index"))

    return results


# ============================================================
def update_all_indexes():
    """Update all indexes in workspace"""
    print("\n" + "="*60)
    print("📋 AUTO INDEX UPDATER")
    print("="*60)

    all_results = []

    # Update standard folders
    print("\n1️⃣ Updating standard folder indexes...")
    for folder in TARGET_FOLDERS:
        folder_path = os.path.join(WORKSPACE_DIR, folder)
        if os.path.exists(folder_path):
            changed, count, msg = update_folder_index(folder_path, folder)
            all_results.append((folder, changed, count, msg))
            status = "✅" if changed else "⏭️"
            print(f"   {status} {folder}: {count} files - {msg}")
        else:
            print(f"   ⚠️ {folder}: Folder not found")

    # Update Knowledge (special handling)
    print("\n2️⃣ Updating Knowledge indexes...")
    knowledge_results = update_knowledge_indexes()
    for domain, changed, count, msg in knowledge_results:
        status = "✅" if changed else "⏭️"
        print(f"   {status} {domain}: {count} files - {msg}")
    all_results.extend(knowledge_results)

    # Summary
    print("\n" + "="*60)
    print("📊 SUMMARY")
    print("="*60)

    updated = len([r for r in all_results if r[1]])
    skipped = len([r for r in all_results if not r[1]])
    total_files = sum(r[2] for r in all_results)

    print(f"\n   ✅ Updated: {updated} indexes")
    print(f"   ⏭️ Skipped: {skipped} indexes (no changes)")
    print(f"   📄 Total files indexed: {total_files}")

    print("\n" + "="*60)

    return all_results


if __name__ == "__main__":
    update_all_indexes()

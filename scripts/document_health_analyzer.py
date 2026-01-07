"""
Document Health Analyzer
=========================
Script untuk memeriksa kesehatan dokumen di Agent-0 workspace.

Fitur:
1. Broken Link Detection - Cari links ke file yang tidak ada
2. Orphan File Detection - File yang tidak direferensikan di mana pun
3. Index Validation - Periksa apakah semua file terdaftar di index
4. Cross-Reference Map - Peta hubungan antar dokumen
5. Health Score - Skor kesehatan keseluruhan

Author: Created via Antigravity AI
Date: 2024-12-22
"""

import os
import re
import json
from datetime import datetime
from collections import defaultdict
from dataclasses import dataclass, asdict
from typing import List, Dict, Set, Tuple

# ============================================================
SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
BASE_DIR = os.path.dirname(SCRIPT_DIR)
CWD = os.getcwd()
OUTPUT_DIR = SCRIPT_DIR

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

# Folders to analyze
TARGET_FOLDERS = ['Topic', 'Find', 'Plan', 'Knowledge', 'Research', 'Log', 'Prototype']

# Patterns to detect links
LINK_PATTERNS = [
    r'\[([^\]]+)\]\(([^)]+)\)',           # Markdown links: [text](path)
    r'(?:File|Related|See|Ref):\s*`([^`]+)`',  # Inline refs: File: `path`
    r'(?:→|->)\s*`([^`]+)`',              # Arrow refs: → `path`
    r'- File: `([^`]+)`',                 # List refs: - File: `path`
]

# These are not "broken" - they're planned/template references
IGNORE_LINK_PATTERNS = [
    r'^\.agent/',           # .agent/ folder references
    r'^agent-config/',      # agent-config/ references (template)
    r'^_archive/',          # archive references
    r'^autonomous_init',    # template file references  
    r'^README\.md$',        # README files
    r'^\.\.\/',              # parent directory refs (cross-workspace)
]


# ============================================================
@dataclass
class HealthReport:
    """Complete health report for the workspace"""
    timestamp: str
    total_files: int
    broken_links: List[Dict]
    orphan_files: List[str]
    missing_from_index: List[Dict]
    cross_references: Dict[str, List[str]]
    health_score: float
    summary: Dict[str, int]
    recommendations: List[str]


def get_all_md_files(workspace_path: str) -> Dict[str, str]:
    """
    Get all markdown files in workspace.
    Returns: {relative_path: absolute_path}
    """
    files = {}
    for folder in TARGET_FOLDERS:
        folder_path = os.path.join(workspace_path, folder)
        if os.path.exists(folder_path):
            for filename in os.listdir(folder_path):
                if filename.endswith('.md'):
                    rel_path = f"{folder}/{filename}"
                    abs_path = os.path.join(folder_path, filename)
                    files[rel_path] = abs_path
    return files


def extract_links(file_path: str) -> List[Tuple[str, str]]:
    """
    Extract all links/references from a markdown file.
    Returns: [(link_text, link_target), ...]
    """
    links = []
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()

        # Pattern 1: Markdown links [text](path)
        for match in re.finditer(r'\[([^\]]+)\]\(([^)]+)\)', content):
            text, target = match.groups()
            if not target.startswith(('http://', 'https://', '#')):
                links.append((text, target))

        # Pattern 2: Backtick references
        for pattern in [
            r'(?:File|Related|See|Ref):\s*`([^`]+\.md)`',
            r'- (?:File|Related):\s*`([^`]+\.md)`',
            r'(?:→|->)\s*`([^`]+\.md)`',
        ]:
            for match in re.finditer(pattern, content, re.IGNORECASE):
                target = match.group(1)
                links.append((target, target))

        # Pattern 3: Direct file references in lists
        for match in re.finditer(r'^\s*-\s+`([^`]+\.md)`', content, re.MULTILINE):
            target = match.group(1)
            links.append((target, target))

    except Exception as e:
        print(f"  ⚠️ Error reading {file_path}: {e}")

    return links


def normalize_path(base_folder: str, link_target: str) -> str:
    """
    Normalize a link target to a relative path from workspace root.
    """
    # Remove leading ./ or ../
    target = link_target.strip()

    # If it's just a filename, assume same folder
    if '/' not in target and '\\' not in target:
        return f"{base_folder}/{target}"

    # Handle relative paths
    if target.startswith('./'):
        target = target[2:]

    # Handle scripts/ or other known paths
    if target.startswith('scripts/'):
        return target

    # Handle folder/file format
    if '/' in target:
        parts = target.split('/')
        if parts[0] in TARGET_FOLDERS:
            return target

    return f"{base_folder}/{target}"


def should_ignore_link(link_target: str) -> bool:
    """
    Check if a link should be ignored (intentional external/template reference).
    """
    for pattern in IGNORE_LINK_PATTERNS:
        if re.match(pattern, link_target):
            return True
    return False


def find_broken_links(all_files: Dict[str, str]) -> List[Dict]:
    """
    Find all broken links (references to non-existent files).
    Excludes intentional external references (templates, .agent/, etc.)
    """
    broken = []
    all_file_names = set(os.path.basename(p) for p in all_files.keys())
    all_file_paths = set(all_files.keys())

    for rel_path, abs_path in all_files.items():
        folder = rel_path.split('/')[0]
        links = extract_links(abs_path)

        for link_text, link_target in links:
            # Skip if obviously not a file reference
            if not link_target.endswith('.md'):
                continue

            # Skip intentional external/template references
            if should_ignore_link(link_target):
                continue

            normalized = normalize_path(folder, link_target)
            target_basename = os.path.basename(link_target)

            # Check if target exists
            exists = (
                normalized in all_file_paths or
                target_basename in all_file_names or
                os.path.exists(os.path.join(WORKSPACE_DIR, normalized))
            )

            if not exists:
                broken.append({
                    "source_file": rel_path,
                    "broken_link": link_target,
                    "context": link_text[:50] if len(link_text) > 50 else link_text
                })

    return broken


def find_orphan_files(all_files: Dict[str, str]) -> List[str]:
    """
    Find files that are not referenced by any other file.
    """
    # Build reference map
    referenced_files = set()
    all_file_names = {os.path.basename(p): p for p in all_files.keys()}

    for rel_path, abs_path in all_files.items():
        links = extract_links(abs_path)
        for _, link_target in links:
            target_basename = os.path.basename(link_target)
            if target_basename in all_file_names:
                referenced_files.add(all_file_names[target_basename])

    # Find orphans (exclude index files which are entry points)
    orphans = []
    for rel_path in all_files.keys():
        filename = os.path.basename(rel_path)
        # Skip index files (they're entry points, not meant to be referenced)
        if 'index' in filename.lower():
            continue
        if rel_path not in referenced_files:
            orphans.append(rel_path)

    return sorted(orphans)


def check_index_coverage(all_files: Dict[str, str]) -> List[Dict]:
    """
    Check if each folder's index.md contains references to all files in that folder.
    """
    missing = []

    for folder in TARGET_FOLDERS:
        folder_path = os.path.join(WORKSPACE_DIR, folder)
        index_path = os.path.join(folder_path, 'index.md')

        if not os.path.exists(index_path):
            # No index file for this folder
            continue

        # Get files in this folder
        folder_files = [
            os.path.basename(p) 
            for p in all_files.keys() 
            if p.startswith(f"{folder}/") and 'index' not in p.lower()
        ]

        # Read index content
        try:
            with open(index_path, 'r', encoding='utf-8') as f:
                index_content = f.read()
        except:
            continue

        # Check each file
        for filename in folder_files:
            if filename not in index_content:
                missing.append({
                    "folder": folder,
                    "file": filename,
                    "index_file": f"{folder}/index.md"
                })

    return missing


def build_cross_reference_map(all_files: Dict[str, str]) -> Dict[str, List[str]]:
    """
    Build a map of which files reference which other files.
    """
    ref_map = defaultdict(list)
    all_file_names = {os.path.basename(p): p for p in all_files.keys()}

    for rel_path, abs_path in all_files.items():
        links = extract_links(abs_path)
        for _, link_target in links:
            target_basename = os.path.basename(link_target)
            if target_basename in all_file_names:
                target_rel = all_file_names[target_basename]
                if target_rel not in ref_map[rel_path]:
                    ref_map[rel_path].append(target_rel)

    return dict(ref_map)


def calculate_health_score(
    total_files: int,
    broken_count: int,
    orphan_count: int,
    missing_index_count: int
) -> float:
    """
    Calculate overall health score (0-100).
    """
    if total_files == 0:
        return 100.0

    # Weights
    broken_weight = 0.4
    orphan_weight = 0.3
    index_weight = 0.3

    # Calculate penalties
    broken_penalty = min(broken_count / total_files, 1.0) * 100 * broken_weight
    orphan_penalty = min(orphan_count / total_files, 1.0) * 100 * orphan_weight
    index_penalty = min(missing_index_count / total_files, 1.0) * 100 * index_weight

    score = 100 - broken_penalty - orphan_penalty - index_penalty
    return max(0, round(score, 1))


def generate_recommendations(
    broken_links: List[Dict],
    orphan_files: List[str],
    missing_from_index: List[Dict]
) -> List[str]:
    """
    Generate actionable recommendations based on issues found.
    """
    recommendations = []

    if broken_links:
        recommendations.append(
            f"🔗 Fix {len(broken_links)} broken link(s) - update or remove invalid references"
        )

    if orphan_files:
        if len(orphan_files) <= 5:
            recommendations.append(
                f"📄 Review {len(orphan_files)} orphan file(s) - consider adding references or archiving: {', '.join(os.path.basename(f) for f in orphan_files[:3])}"
            )
        else:
            recommendations.append(
                f"📄 Review {len(orphan_files)} orphan file(s) - many files are not referenced by any other document"
            )

    if missing_from_index:
        folders = set(m['folder'] for m in missing_from_index)
        recommendations.append(
            f"📋 Update index.md in {len(folders)} folder(s) - {len(missing_from_index)} file(s) not listed"
        )

    if not recommendations:
        recommendations.append("✅ No critical issues found - workspace is healthy!")

    return recommendations


def analyze_document_health() -> HealthReport:
    """
    Run complete document health analysis.
    """
    print("\n" + "="*60)
    print("📋 DOCUMENT HEALTH ANALYZER")
    print("="*60)

    # Step 1: Get all files
    print("\n1️⃣ Scanning workspace...")
    all_files = get_all_md_files(WORKSPACE_DIR)
    print(f"   Found {len(all_files)} markdown files")

    # Step 2: Find broken links
    print("\n2️⃣ Checking for broken links...")
    broken_links = find_broken_links(all_files)
    print(f"   Found {len(broken_links)} broken link(s)")

    # Step 3: Find orphan files
    print("\n3️⃣ Detecting orphan files...")
    orphan_files = find_orphan_files(all_files)
    print(f"   Found {len(orphan_files)} orphan file(s)")

    # Step 4: Check index coverage
    print("\n4️⃣ Validating index coverage...")
    missing_from_index = check_index_coverage(all_files)
    print(f"   Found {len(missing_from_index)} file(s) missing from index")

    # Step 5: Build cross-reference map
    print("\n5️⃣ Building cross-reference map...")
    cross_refs = build_cross_reference_map(all_files)
    connected_files = len([f for f in cross_refs if cross_refs[f]])
    print(f"   {connected_files} files have outgoing references")

    # Step 6: Calculate health score
    print("\n6️⃣ Calculating health score...")
    health_score = calculate_health_score(
        len(all_files),
        len(broken_links),
        len(orphan_files),
        len(missing_from_index)
    )

    # Generate recommendations
    recommendations = generate_recommendations(
        broken_links, orphan_files, missing_from_index
    )

    # Create report
    report = HealthReport(
        timestamp=datetime.now().isoformat(),
        total_files=len(all_files),
        broken_links=broken_links,
        orphan_files=orphan_files,
        missing_from_index=missing_from_index,
        cross_references=cross_refs,
        health_score=health_score,
        summary={
            "total_files": len(all_files),
            "broken_links": len(broken_links),
            "orphan_files": len(orphan_files),
            "missing_from_index": len(missing_from_index),
            "connected_files": connected_files
        },
        recommendations=recommendations
    )

    return report


def print_report(report: HealthReport):
    """
    Print formatted health report to console.
    """
    print("\n" + "="*60)
    print("📊 HEALTH REPORT")
    print("="*60)

    # Health Score
    score = report.health_score
    if score >= 80:
        status = "🟢 HEALTHY"
    elif score >= 60:
        status = "🟡 NEEDS ATTENTION"
    else:
        status = "🔴 CRITICAL"

    bar_filled = int(score / 5)
    bar_empty = 20 - bar_filled
    bar = "█" * bar_filled + "░" * bar_empty

    print(f"\n{status}")
    print(f"Health Score: [{bar}] {score}/100")

    # Summary
    print(f"\n📈 Summary:")
    print(f"   • Total Files: {report.summary['total_files']}")
    print(f"   • Broken Links: {report.summary['broken_links']}")
    print(f"   • Orphan Files: {report.summary['orphan_files']}")
    print(f"   • Missing from Index: {report.summary['missing_from_index']}")
    print(f"   • Connected Files: {report.summary['connected_files']}")

    # Broken Links Detail
    if report.broken_links:
        print(f"\n🔗 Broken Links ({len(report.broken_links)}):")
        for item in report.broken_links[:10]:
            print(f"   • {item['source_file']} → {item['broken_link']}")
        if len(report.broken_links) > 10:
            print(f"   ... and {len(report.broken_links) - 10} more")

    # Orphan Files Detail
    if report.orphan_files:
        print(f"\n📄 Orphan Files ({len(report.orphan_files)}):")
        for item in report.orphan_files[:10]:
            print(f"   • {item}")
        if len(report.orphan_files) > 10:
            print(f"   ... and {len(report.orphan_files) - 10} more")

    # Missing from Index Detail
    if report.missing_from_index:
        print(f"\n📋 Missing from Index ({len(report.missing_from_index)}):")
        for item in report.missing_from_index[:10]:
            print(f"   • {item['folder']}/{item['file']}")
        if len(report.missing_from_index) > 10:
            print(f"   ... and {len(report.missing_from_index) - 10} more")

    # Recommendations
    print(f"\n💡 Recommendations:")
    for rec in report.recommendations:
        print(f"   {rec}")

    print("\n" + "="*60)


def save_report(report: HealthReport):
    """Save report to JSON file."""
    output_path = os.path.join(OUTPUT_DIR, "document_health_report.json")

    report_dict = asdict(report)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(report_dict, f, indent=2, ensure_ascii=False)

    print(f"\n💾 Report saved to: {output_path}")


# ============================================================
if __name__ == "__main__":
    report = analyze_document_health()
    print_report(report)
    save_report(report)

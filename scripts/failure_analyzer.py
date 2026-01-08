"""
Failure Pattern Analyzer
=========================
Script untuk menganalisis failure log dan mendeteksi pola.

Fitur:
1. Parse failures.md entries
2. Group failures by similarity (Tool + Error Type)
3. Detect new patterns (≥3 similar failures tanpa Pattern ID)
4. Generate analysis report

Author: Created via Antigravity AI
Date: 2024-12-22
"""

import os
import re
import json
from datetime import datetime
from collections import defaultdict
from dataclasses import dataclass, asdict
from typing import List, Dict, Set, Tuple, Optional

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

FAILURES_FILE = os.path.join(WORKSPACE_DIR, "Log", "failures.md")

# Minimum occurrences to be considered a pattern
PATTERN_THRESHOLD = 3


# ============================================================
@dataclass
class FailureEntry:
    """Single failure log entry"""
    id: str
    tool: str
    date: str
    command: str
    error: str
    context: str
    workaround: Optional[str]
    pattern_id: Optional[str]


@dataclass
class FailureReport:
    """Complete failure analysis report"""
    timestamp: str
    total_failures: int
    patterns_identified: int
    unpatterned: int
    archived_patterns: int
    groups: Dict[str, List[str]]
    new_pattern_candidates: List[Dict]
    existing_patterns: List[Dict]
    recommendations: List[str]


def parse_failure_entries(content: str) -> List[FailureEntry]:
    """
    Parse all F-XXX entries from failures.md
    """
    entries = []

    # Pattern to match failure entries
    # Format: ### F-{NNN} | {Tool} | {Date}
    entry_pattern = r'### (F-\d+) \| (\w+) \| (\d{4}-\d{2}-\d{2})'

    # Find all entry headers
    matches = list(re.finditer(entry_pattern, content))

    for i, match in enumerate(matches):
        entry_id = match.group(1)
        tool = match.group(2)
        date = match.group(3)

        # Get content until next entry or section
        start = match.end()
        if i + 1 < len(matches):
            end = matches[i + 1].start()
        else:
            # Find next section (---)
            next_section = content.find('\n---', start)
            end = next_section if next_section != -1 else len(content)

        entry_content = content[start:end]

        # Parse fields
        command = extract_field(entry_content, r'\*\*Command/Params:\*\*\s*`?([^`\n]+)`?')
        error = extract_field(entry_content, r'\*\*Error:\*\*\s*([^\n]+)')
        context = extract_field(entry_content, r'\*\*Context:\*\*\s*([^\n]+)')
        workaround = extract_field(entry_content, r'\*\*Workaround:\*\*\s*([^\n]+)')
        pattern_id = extract_field(entry_content, r'\*\*Pattern ID:\*\*\s*(P-\d+)?')

        entries.append(FailureEntry(
            id=entry_id,
            tool=tool,
            date=date,
            command=command or "",
            error=error or "",
            context=context or "",
            workaround=workaround,
            pattern_id=pattern_id if pattern_id and pattern_id.startswith('P-') else None
        ))

    return entries


def extract_field(content: str, pattern: str) -> Optional[str]:
    """Extract a field value using regex pattern"""
    match = re.search(pattern, content)
    if match:
        value = match.group(1).strip()
        return value if value else None
    return None


def parse_existing_patterns(content: str) -> List[Dict]:
    """
    Parse identified patterns section
    """
    patterns = []

    # Find the "Identified Patterns" section
    section_match = re.search(r'## 🔍 Identified Patterns\s*\n(.*?)(?=\n## |\n---|\Z)', content, re.DOTALL)
    if not section_match:
        return patterns

    section_content = section_match.group(1)

    # Pattern header: ### P-XXX: Name [STATUS]
    pattern_regex = r'### (P-\d+):\s*([^\[\n]+)(?:\[([^\]]+)\])?'

    for match in re.finditer(pattern_regex, section_content):
        pattern_id = match.group(1)
        name = match.group(2).strip()
        status = match.group(3) if match.group(3) else "Active"

        # Get pattern content
        start = match.end()
        next_pattern = re.search(r'\n### P-\d+', section_content[start:])
        end = start + next_pattern.start() if next_pattern else len(section_content)
        pattern_content = section_content[start:end]

        # Extract occurrences
        occurrences_match = re.search(r'\*\*Occurrences:\*\*\s*(\d+)', pattern_content)
        occurrences = int(occurrences_match.group(1)) if occurrences_match else 0

        patterns.append({
            "id": pattern_id,
            "name": name,
            "status": status.strip(),
            "occurrences": occurrences
        })

    return patterns


def count_archived_patterns(content: str) -> int:
    """Count patterns in Archived section"""
    section_match = re.search(r'## 📦 Archived Patterns\s*\n(.*?)(?=\n## |\Z)', content, re.DOTALL)
    if not section_match:
        return 0

    return len(re.findall(r'### P-\d+:', section_match.group(1)))


def normalize_error(error: str) -> str:
    """
    Normalize error message for grouping.
    Remove specific values, keep general pattern.
    """
    # Remove file paths
    error = re.sub(r'[A-Za-z]:\\[^\s]+', '<PATH>', error)
    # Remove specific filenames
    error = re.sub(r'`[^`]+`', '<FILE>', error)
    # Remove quotes content
    error = re.sub(r'"[^"]+"', '<VALUE>', error)
    # Lowercase
    error = error.lower().strip()

    return error


def group_failures(entries: List[FailureEntry]) -> Dict[str, List[str]]:
    """
    Group failures by Tool + normalized error pattern
    """
    groups = defaultdict(list)

    for entry in entries:
        # Create group key: tool|normalized_error
        normalized = normalize_error(entry.error)
        # Simplify to main keywords
        if 'stuck' in normalized or 'timeout' in normalized:
            error_type = 'stuck_timeout'
        elif 'not' in normalized and ('delete' in normalized or 'hapus' in normalized or 'terhapus' in normalized):
            error_type = 'file_not_deleted'
        elif 'not found' in normalized:
            error_type = 'not_found'
        elif 'permission' in normalized or 'access' in normalized:
            error_type = 'permission_denied'
        else:
            # Use first 3 words as key
            words = normalized.split()[:3]
            error_type = '_'.join(words) if words else 'unknown'

        group_key = f"{entry.tool}|{error_type}"
        groups[group_key].append(entry.id)

    return dict(groups)


def find_new_pattern_candidates(
    entries: List[FailureEntry],
    groups: Dict[str, List[str]],
    threshold: int = PATTERN_THRESHOLD
) -> List[Dict]:
    """
    Find groups that qualify as new patterns:
    - >= threshold occurrences
    - At least one entry without Pattern ID
    """
    candidates = []

    # Create lookup for entries
    entry_lookup = {e.id: e for e in entries}

    for group_key, entry_ids in groups.items():
        if len(entry_ids) < threshold:
            continue

        # Check if any entry is unpatterned
        unpatterned = [
            eid for eid in entry_ids 
            if entry_lookup[eid].pattern_id is None
        ]

        if unpatterned:
            tool, error_type = group_key.split('|', 1)
            candidates.append({
                "group_key": group_key,
                "tool": tool,
                "error_type": error_type,
                "total_occurrences": len(entry_ids),
                "unpatterned_count": len(unpatterned),
                "unpatterned_ids": unpatterned,
                "suggested_pattern_name": f"{tool.title()} {error_type.replace('_', ' ').title()}"
            })

    return candidates


def generate_recommendations(
    entries: List[FailureEntry],
    candidates: List[Dict],
    existing_patterns: List[Dict]
) -> List[str]:
    """
    Generate actionable recommendations
    """
    recommendations = []

    if candidates:
        for c in candidates:
            recommendations.append(
                f"🆕 Create pattern for '{c['suggested_pattern_name']}' "
                f"({c['total_occurrences']} occurrences, {c['unpatterned_count']} unpatterned)"
            )

    # Check for patterns that might need retesting (>7 days old)
    for pattern in existing_patterns:
        if pattern['status'].lower() != 'archived':
            recommendations.append(
                f"🔄 Consider retesting pattern {pattern['id']}: {pattern['name']}"
            )

    if not recommendations:
        recommendations.append("✅ No action needed - all failures are patterned!")

    return recommendations


# ============================================================
def analyze_failures() -> FailureReport:
    """
    Run complete failure analysis
    """
    print("\n" + "="*60)
    print("📊 FAILURE PATTERN ANALYZER")
    print("="*60)

    # Read failures.md
    print("\n1️⃣ Reading failure log...")
    try:
        with open(FAILURES_FILE, 'r', encoding='utf-8') as f:
            content = f.read()
    except FileNotFoundError:
        print(f"   ⚠️ File not found: {FAILURES_FILE}")
        return None

    # Parse entries
    print("\n2️⃣ Parsing failure entries...")
    entries = parse_failure_entries(content)
    print(f"   Found {len(entries)} entries")

    # Parse existing patterns
    print("\n3️⃣ Parsing existing patterns...")
    existing_patterns = parse_existing_patterns(content)
    archived_count = count_archived_patterns(content)
    print(f"   Found {len(existing_patterns)} active, {archived_count} archived")

    # Group failures
    print("\n4️⃣ Grouping failures by similarity...")
    groups = group_failures(entries)
    print(f"   Created {len(groups)} groups")

    # Find new pattern candidates
    print("\n5️⃣ Detecting new pattern candidates...")
    candidates = find_new_pattern_candidates(entries, groups)
    print(f"   Found {len(candidates)} potential new patterns")

    # Calculate stats
    patterned = len([e for e in entries if e.pattern_id])
    unpatterned = len(entries) - patterned

    # Generate recommendations
    recommendations = generate_recommendations(entries, candidates, existing_patterns)

    # Create report
    report = FailureReport(
        timestamp=datetime.now().isoformat(),
        total_failures=len(entries),
        patterns_identified=len(existing_patterns),
        unpatterned=unpatterned,
        archived_patterns=archived_count,
        groups=groups,
        new_pattern_candidates=candidates,
        existing_patterns=existing_patterns,
        recommendations=recommendations
    )

    return report


def print_report(report: FailureReport):
    """
    Print formatted report to console
    """
    print("\n" + "="*60)
    print("📊 FAILURE ANALYSIS REPORT")
    print("="*60)

    # Stats
    print(f"\n📈 Statistics:")
    print(f"   • Total Failures: {report.total_failures}")
    print(f"   • Patterns Identified: {report.patterns_identified}")
    print(f"   • Unpatterned: {report.unpatterned}")
    print(f"   • Archived Patterns: {report.archived_patterns}")

    # Groups
    if report.groups:
        print(f"\n📁 Failure Groups ({len(report.groups)}):")
        for group_key, entry_ids in report.groups.items():
            tool, error_type = group_key.split('|', 1)
            print(f"   • {tool} | {error_type}: {len(entry_ids)} entries")

    # New Pattern Candidates
    if report.new_pattern_candidates:
        print(f"\n🆕 New Pattern Candidates:")
        for c in report.new_pattern_candidates:
            print(f"   • {c['suggested_pattern_name']}")
            print(f"     - Occurrences: {c['total_occurrences']}")
            print(f"     - Unpatterned: {c['unpatterned_ids']}")
    else:
        print(f"\n🆕 New Pattern Candidates: (none)")

    # Existing Patterns
    if report.existing_patterns:
        print(f"\n✅ Existing Patterns:")
        for p in report.existing_patterns:
            status_emoji = "⚪" if "archived" in p['status'].lower() else "🟢"
            print(f"   {status_emoji} {p['id']}: {p['name']} ({p['occurrences']} occurrences)")

    # Recommendations
    print(f"\n💡 Recommendations:")
    for rec in report.recommendations:
        print(f"   {rec}")

    print("\n" + "="*60)


def save_report(report: FailureReport):
    """Save report to JSON file"""
    output_path = os.path.join(OUTPUT_DIR, "failure_analysis_report.json")

    report_dict = asdict(report)
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(report_dict, f, indent=2, ensure_ascii=False)

    print(f"\n💾 Report saved to: {output_path}")


# ============================================================
if __name__ == "__main__":
    report = analyze_failures()
    if report:
        print_report(report)
        save_report(report)

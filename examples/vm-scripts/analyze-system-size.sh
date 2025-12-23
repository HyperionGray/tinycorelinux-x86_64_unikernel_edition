#!/bin/bash
# Analyze system size script
# Usage: ./analyze-system-size.sh

set -e

echo "=== TinyCore Linux System Size Analysis ==="
echo

# Check if corepure64 directory exists
if [ ! -d "corepure64" ]; then
    echo "Error: corepure64 directory not found"
    echo "Please ensure TinyCore Linux files are extracted in the current directory."
    exit 1
fi

# Total system size
echo "📊 Total System Size:"
TOTAL_SIZE=$(du -sh corepure64 2>/dev/null | cut -f1)
echo "   $TOTAL_SIZE"
echo

# Component breakdown
echo "📁 Component Breakdown:"
echo "   $(printf "%-20s %s" "Component" "Size")"
echo "   $(printf "%-20s %s" "─────────" "────")"

# Analyze major components
if [ -d "corepure64/boot" ]; then
    BOOT_SIZE=$(du -sh corepure64/boot 2>/dev/null | cut -f1)
    echo "   $(printf "%-20s %s" "Boot files" "$BOOT_SIZE")"
fi

if [ -d "corepure64/etc" ]; then
    ETC_SIZE=$(du -sh corepure64/etc 2>/dev/null | cut -f1)
    echo "   $(printf "%-20s %s" "Configuration" "$ETC_SIZE")"
fi

if [ -d "corepure64/opt" ]; then
    OPT_SIZE=$(du -sh corepure64/opt 2>/dev/null | cut -f1)
    echo "   $(printf "%-20s %s" "Optional files" "$OPT_SIZE")"
fi

# Show largest files
echo
echo "📋 Largest Files (Top 10):"
find corepure64 -type f -exec du -h {} \; 2>/dev/null | sort -hr | head -10 | while read size file; do
    echo "   $size  $(basename "$file")"
done

echo
echo "🎯 Optimization Opportunities:"
echo

# Size reduction estimates
TOTAL_MB=$(du -sm corepure64 2>/dev/null | cut -f1)

CONSERVATIVE_MB=$((TOTAL_MB * 55 / 100))  # 45% reduction
AGGRESSIVE_MB=$((TOTAL_MB * 30 / 100))    # 70% reduction  
EXTREME_MB=$((TOTAL_MB * 15 / 100))       # 85% reduction

echo "   Current size:     ${TOTAL_MB}MB"
echo "   Conservative:     ${CONSERVATIVE_MB}MB (45% reduction)"
echo "   Aggressive:       ${AGGRESSIVE_MB}MB (70% reduction)"
echo "   Extreme:          ${EXTREME_MB}MB (85% reduction)"

echo
echo "💡 Reduction Strategies:"
echo "   • Remove unused kernel modules"
echo "   • Disable unnecessary services"
echo "   • Remove documentation and man pages"
echo "   • Compress binaries and libraries"
echo "   • Remove development tools"
echo "   • Minimize locale data"

echo
echo "⚙️  Apply Optimizations:"
echo "   Conservative: ./apply-config.sh examples/boot-configs/conservative.conf"
echo "   Aggressive:   ./apply-config.sh examples/boot-configs/aggressive.conf"
echo "   Extreme:      ./apply-config.sh examples/boot-configs/extreme.conf"

echo
echo "Analysis complete!"
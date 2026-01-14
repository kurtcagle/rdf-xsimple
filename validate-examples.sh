#!/bin/bash
#
# RDF-XSimple Validation Test Script
#
# Tests all example files against the XSD schema and reports results.
#
# Usage:
#   ./validate-examples.sh
#
# Requirements:
#   - xmllint (libxml2-utils package)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEMA="${SCRIPT_DIR}/schema/rdfxml2.xsd"
EXAMPLES_DIR="${SCRIPT_DIR}/examples"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
TOTAL=0
PASSED=0
FAILED=0

echo "================================================"
echo "RDF-XSimple Schema Validation Tests"
echo "================================================"
echo ""

# Check if xmllint is available
if ! command -v xmllint &> /dev/null; then
    echo -e "${RED}ERROR: xmllint not found${NC}"
    echo "Please install libxml2-utils:"
    echo "  Ubuntu/Debian: sudo apt-get install libxml2-utils"
    echo "  macOS: brew install libxml2"
    exit 1
fi

# Check if schema file exists
if [ ! -f "$SCHEMA" ]; then
    echo -e "${RED}ERROR: Schema file not found: $SCHEMA${NC}"
    exit 1
fi

# Check if examples directory exists
if [ ! -d "$EXAMPLES_DIR" ]; then
    echo -e "${RED}ERROR: Examples directory not found: $EXAMPLES_DIR${NC}"
    exit 1
fi

echo "Schema: $SCHEMA"
echo "Examples: $EXAMPLES_DIR"
echo ""

# Validate each example file
for file in "$EXAMPLES_DIR"/*.rdf; do
    if [ -f "$file" ]; then
        TOTAL=$((TOTAL + 1))
        filename=$(basename "$file")
        
        echo -n "Validating $filename ... "
        
        # Run validation and capture output
        if xmllint --noout --schema "$SCHEMA" "$file" 2>&1 | grep -q "validates"; then
            echo -e "${GREEN}✓ PASS${NC}"
            PASSED=$((PASSED + 1))
        else
            echo -e "${RED}✗ FAIL${NC}"
            FAILED=$((FAILED + 1))
            
            # Show error details
            echo -e "${YELLOW}Error details:${NC}"
            xmllint --noout --schema "$SCHEMA" "$file" 2>&1 | head -n 5
            echo ""
        fi
    fi
done

echo ""
echo "================================================"
echo "Validation Summary"
echo "================================================"
echo "Total files:  $TOTAL"
echo -e "Passed:       ${GREEN}$PASSED${NC}"
echo -e "Failed:       ${RED}$FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    echo -e "${GREEN}All validation tests passed!${NC}"
    exit 0
else
    echo -e "${RED}Some validation tests failed.${NC}"
    exit 1
fi

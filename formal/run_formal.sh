echo ""
echo -e "\e[32mRun Symbiyosys Formal Verification: \e[0m"
echo "---------------------------------------"
sby -f ecc.sby

# ANSI color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo ""
echo ""
echo "Summary:"
# Iterate over folders starting with 'ecc_*'
for folder in ecc_*/ ; do
    # Check if the 'PASS' file exists in the folder
    if [[ -e "${folder}PASS" ]]; then
        # Print the folder name and 'PASS' in green
        echo -e "${folder}: ${GREEN}PASS${NC}"
    else
        # Print the folder name and 'FAIL' in red
        echo -e "${folder}: ${RED}FAIL${NC}"
    fi
done

#!/bin/bash
# GudaSpec Codex Skill Installer
# https://github.com/GuDaStudio/commands

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_NAME="gudaspec"

usage() {
    echo -e "${BLUE}GudaSpec Codex Skill Installer${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -u, --user              Install to user-level (~/.codex/skills/)"
    echo "  -p, --project           Install to project-level (./.codex/skills/)"
    echo "  -t, --target <path>     Install to custom target path"
    echo "  -h, --help              Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 --user"
    echo "  $0 --project"
    echo "  $0 --target /custom/path"
}

install_skill() {
    local target_dir=$1
    local source_dir="$SCRIPT_DIR/$SKILL_NAME"
    local dest_dir="$target_dir/$SKILL_NAME"

    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}Error: '$SKILL_NAME' not found in source directory${NC}"
        return 1
    fi

    echo -e "${BLUE}Installing${NC} $SKILL_NAME -> $dest_dir"

    mkdir -p "$target_dir"

    if [ -d "$dest_dir" ]; then
        echo -e "${YELLOW}  Removing existing installation...${NC}"
        rm -rf "$dest_dir"
    fi

    cp -r "$source_dir" "$dest_dir"

    if [ -f "$dest_dir/.git" ]; then
        rm "$dest_dir/.git"
    fi

    echo -e "${GREEN}  ✓ Installed${NC}"
}

TARGET_PATH=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -u|--user)
            TARGET_PATH="$HOME/.codex/skills"
            shift
            ;;
        -p|--project)
            TARGET_PATH="./.codex/skills"
            shift
            ;;
        -t|--target)
            TARGET_PATH="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
    esac
done

if [ -z "$TARGET_PATH" ]; then
    echo -e "${RED}Error: Please specify installation target (-u, -p, or -t)${NC}"
    echo ""
    usage
    exit 1
fi

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}GudaSpec Codex Skill Installer${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "Target: ${GREEN}$TARGET_PATH${NC}"
echo -e "Skill: ${GREEN}$SKILL_NAME${NC}"
echo ""

install_skill "$TARGET_PATH"

echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}Installation complete!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

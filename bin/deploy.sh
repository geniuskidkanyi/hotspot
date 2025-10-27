#!/bin/bash
# Deployment script for Rails with Thruster
# Author: Muhammed Kanyi (@geniuskidkanyi)

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Starting Rails Deployment ===${NC}"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
    git status -s
    read -p "Continue anyway? (y/n) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Determine environment
ENVIRONMENT=${1:-production}
echo -e "${YELLOW}Deploying to: ${ENVIRONMENT}${NC}"

# Run tests
echo -e "${YELLOW}Running tests...${NC}"
if ! bundle exec rspec; then
    echo -e "${RED}Tests failed! Aborting deployment.${NC}"
    exit 1
fi

# Security check with Brakeman
echo -e "${YELLOW}Running security scan...${NC}"
if ! bundle exec brakeman -q -z; then
    echo -e "${YELLOW}Security issues detected. Review and continue? (y/n)${NC}"
    read -p "" -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Push to git
echo -e "${YELLOW}Pushing to git...${NC}"
git push origin $(git branch --show-current)

# Deploy with Capistrano
echo -e "${YELLOW}Deploying with Capistrano...${NC}"
bundle exec cap $ENVIRONMENT deploy

echo -e "${GREEN}=== Deployment complete! ===${NC}"

# Show status
echo -e "${YELLOW}Checking application status...${NC}"
bundle exec cap $ENVIRONMENT thruster:status
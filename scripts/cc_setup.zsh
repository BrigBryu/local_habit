#!/usr/bin/env zsh
# Helper script to set up the cc alias for Claude Code notifications

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CC_NOTIFY_PATH="$SCRIPT_DIR/cc_notify.zsh"

echo "Setting up Claude Code notification helper..."

# Check if .zshrc exists
if [[ ! -f ~/.zshrc ]]; then
    echo "Creating ~/.zshrc..."
    touch ~/.zshrc
fi

# Check if alias already exists
if grep -q "alias cc=" ~/.zshrc; then
    echo "⚠️  'cc' alias already exists in ~/.zshrc"
    echo "Please manually add or update:"
    echo "alias cc='$CC_NOTIFY_PATH'"
else
    echo "Adding 'cc' alias to ~/.zshrc..."
    echo "" >> ~/.zshrc
    echo "# Claude Code with notifications" >> ~/.zshrc
    echo "alias cc='$CC_NOTIFY_PATH'" >> ~/.zshrc
    echo "✅ Added alias to ~/.zshrc"
    echo "Run 'source ~/.zshrc' or start a new terminal session to use 'cc' command"
fi

echo ""
echo "Usage:"
echo "  cc \"your prompt here\"    # Run Claude Code with notifications"
echo "  cc --help                 # Show Claude Code help"
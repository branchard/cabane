#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_FILE="/etc/garage.toml.template"
CONFIG_FILE="/etc/garage.toml"

# "$$" is escape sequence for a literal "$".
# Swap it out before expansion (bash would otherwise read "$$" as its own PID)
# and restore it once expansion is done.
DOLLAR_PLACEHOLDER="@@CABANE_LITERAL_DOLLAR@@"

template="$(cat "$TEMPLATE_FILE")"
template="${template//\$\$/$DOLLAR_PLACEHOLDER}"

# Expand $VAR / ${VAR} / ${VAR:-default} / ${VAR:?error} / ${VAR:+value}
# Values are only ever substituted as data by the heredoc, never re-evaluated,
# so this is safe even if a variable's value contains shell metacharacters.
rendered="$(eval "cat <<CABANE_RENDER_EOF
$template
CABANE_RENDER_EOF"
)"

printf '%s\n' "${rendered//$DOLLAR_PLACEHOLDER/\$}" > "$CONFIG_FILE"

exec /garage server

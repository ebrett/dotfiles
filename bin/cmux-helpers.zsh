# cmux-helpers.zsh — shared cmux workspace helpers
# Source this file; do not execute directly.

_cmux_find_workspace() {
  local name="$1"
  cmux --json tree --all 2>/dev/null \
    | jq -r --arg n "$name" '.windows[].workspaces[] | select(.title == $n) | .ref' 2>/dev/null \
    | head -1
}

_cmux_select_workspace() {
  local ws_ref="$1"
  local pane_ref
  pane_ref=$(cmux --json tree --workspace "$ws_ref" \
    | jq -r --arg ws "$ws_ref" '[.windows[].workspaces[] | select(.ref == $ws)][0].panes[0].ref' \
    2>/dev/null)
  [[ -n "$pane_ref" ]] && cmux focus-pane --pane "$pane_ref" --workspace "$ws_ref"
}

# Apply color and pin settings from a .cmux-config file.
# Format: color=Blue  pin=true  (lines starting with # are comments)
_cmux_apply_workspace_config() {
  local config_file="$1" ws_ref="$2"
  [[ -f "$config_file" ]] || return 0

  local color pin
  color=$(awk -F= '/^color=[[:alnum:]]/{print $2}' "$config_file" | head -1)
  pin=$(awk   -F= '/^pin=/{print $2}'   "$config_file" | head -1)

  [[ -n "$color" ]] && cmux workspace-action --action set-color --color "$color" --workspace "$ws_ref"
  [[ "$pin" == "true" ]] && cmux workspace-action --action pin --workspace "$ws_ref"
}

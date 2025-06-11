get_current_workspace() {
    swaymsg -t get_workspaces | jq -r '.[] | select(.focused) | .name'
}

get_count_containers() {
    swaymsg -t get_tree | jq -r --arg ws "$1" '
        def count_windows:
            if .nodes == [] then
                if .type == "con" and (.name != null or .app_id != null) then 1 else 0 end
            else
                .nodes | map(count_windows) | add
            end;
        .nodes[].nodes[] | select(.name == $ws) | count_windows
    ' 2>/dev/null || echo 0
}

if (( $(get_count_containers "$(get_current_workspace)") % 2 == 0 )); then
    swaymsg splitv
    swaymsg focus down
else
    swaymsg splith
    swaymsg focus left
fi

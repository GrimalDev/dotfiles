function oc
    set -l ports 4098 4099 4100 4101 4102
    set -l used (ps aux | string match -r 'opencode --port (\d+)' | string match -r '^\d+$')
    set -l available
    for p in $ports
        if not contains $p $used
            set -a available $p
        end
    end
    if test (count $available) -eq 0
        echo "All opencode ports are in use"
        return 1
    end
    opencode --port $available[1]
end

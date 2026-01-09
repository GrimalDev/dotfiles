function rcp -d "Copy files from one remote to another through local machine"
    argparse 'h/help' 'no-compress' 'no-progress' -- $argv
    or return

    if set -q _flag_help
        echo "Usage: rcp [OPTIONS] SOURCE DESTINATION"
        echo ""
        echo "Copy files between remotes through local machine (streaming, no local storage)"
        echo ""
        echo "Arguments:"
        echo "  SOURCE       user@host:/path or /local/path"
        echo "  DESTINATION  user@host:/path or /local/path"
        echo ""
        echo "Options:"
        echo "  --no-compress   Disable compression (default: on)"
        echo "  --no-progress   Disable progress display (default: on)"
        echo "  -h, --help      Show this help message"
        echo ""
        echo "Examples:"
        echo "  rcp user1@host1:/data/file.tar user2@host2:/backup/"
        echo "  rcp --no-compress --no-progress user1@host1:/large.dat user2@host2:/dest/"
        return 0
    end

    if test (count $argv) -ne 2
        echo "Error: Requires exactly 2 arguments (source and destination)" >&2
        echo "Use -h for help" >&2
        return 1
    end

    set -l source $argv[1]
    set -l destination $argv[2]

    # Build SSH command options
    # Compression is on by default since most data benefits from it
    set -l ssh_opts "-o" "Compression=yes"
    
    if set -q _flag_no_compress
        set ssh_opts "-o" "Compression=no"
    end

    # Check if both source and destination are remote (contain :)
    if string match -q "*:*" -- $source; and string match -q "*:*" -- $destination
        # Remote to remote: pipe through local machine
        set -l src_parts (string split ":" -- $source)
        set -l src_host $src_parts[1]
        set -l src_path $src_parts[2]
        
        set -l dst_parts (string split ":" -- $destination)
        set -l dst_host $dst_parts[1]
        set -l dst_path $dst_parts[2]
        
        # Check if source ends with / to copy contents only
        set -l src_dir
        set -l src_file
        if string match -q "*/" -- $src_path
            # Strip trailing slash - tar contents of this directory
            set src_path (string replace -r '/$' '' -- $src_path)
            set src_dir $src_path
            set src_file "."
        else
            # Copy the directory itself
            set src_dir (dirname $src_path)
            set src_file (basename $src_path)
        end
        
        echo "Copying $source → $destination (via localhost)"
        if set -q _flag_no_progress
            ssh $ssh_opts $src_host "tar -czf - -C $src_dir $src_file 2>/dev/null" | \
            ssh $ssh_opts $dst_host "mkdir -p $dst_path && tar -xzf - -C $dst_path 2>/dev/null"
            and echo "Transfer complete!"
        else
            # Use pv if available, otherwise show a simple byte counter
            if command -v pv >/dev/null
                ssh $ssh_opts $src_host "tar -czf - -C $src_dir $src_file 2>/dev/null" | \
                pv | \
                ssh $ssh_opts $dst_host "mkdir -p $dst_path && tar -xzf - -C $dst_path 2>/dev/null"
                and echo "Transfer complete!"
            else
                ssh $ssh_opts $src_host "tar -czf - -C $src_dir $src_file 2>/dev/null" | \
                ssh $ssh_opts $dst_host "mkdir -p $dst_path && tar -xzf - -C $dst_path 2>/dev/null"
                and echo "Transfer complete!"
                echo "Tip: Install 'pv' for progress display (brew install pv)"
            end
        end
    else
        # At least one endpoint is local: use rsync
        set -l rsync_opts "-az" "--no-perms" "--no-owner" "--no-group"
        
        if not set -q _flag_no_progress
            set rsync_opts $rsync_opts "--info=progress2"
        end
        
        echo "Copying $source → $destination"
        rsync $rsync_opts -e "ssh $ssh_opts" $source $destination
    end
end

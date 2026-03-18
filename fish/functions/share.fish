function share
    # Usage:
    #   share /path/to/file_or_folder [port] [timeout_minutes]
    #   share stop
    set -l container_name share_container

    # Handle stop
    if test "$argv[1]" = "stop"
        if docker ps -q -f name=$container_name | grep -q .
            docker rm -f $container_name
            echo "Server stopped (container $container_name)"
        else
            echo "No running server found."
        end
        return
    end

    # Path to serve
    set -l share_path $argv[1]
    if test -z "$share_path"
        echo "Usage: share /path/to/file_or_folder [port] [timeout_minutes]"
        echo "       share stop"
        return 1
    end

    if not test -e $share_path
        echo "Error: '$share_path' does not exist."
        return 1
    end

    # Port
    set -l port 80
    if test (count $argv) -ge 2
        set port $argv[2]
    end

    # Timeout in minutes (default 10)
    set -l timeout_min 10
    if test (count $argv) -ge 3
        set timeout_min $argv[3]
    end
    set -l timeout_sec (math "$timeout_min * 60")

    # Stop any existing container before starting
    docker rm -f $container_name > /dev/null 2>&1

    # Folder
    if test -d $share_path
        set -l nginx_conf /tmp/share_nginx.conf
        echo 'server { listen 80; root /usr/share/nginx/html; autoindex on; }' > $nginx_conf
        echo "Sharing folder $share_path at http://localhost:$port (auto-stop in $timeout_min min)"
        docker run -d --name $container_name -p $port:80 \
            -v (realpath $share_path):/usr/share/nginx/html:ro \
            -v $nginx_conf:/etc/nginx/conf.d/default.conf:ro \
            nginx
    else
        # Single file
        set -l dir (mktemp -d)
        set -l filename (basename $share_path)

        if string match -r '.*\.html?$' $filename
            cp $share_path $dir/index.html
        else
            echo "<!DOCTYPE html>
<html>
<head><title>Serving $filename</title></head>
<body>
<h1>Download $filename</h1>
<a href=\"$filename\">Click here to download</a>
</body>
</html>" > $dir/index.html
            cp $share_path $dir/
        end

        echo "Sharing $filename at http://localhost:$port (auto-stop in $timeout_min min)"
        docker run -d --name $container_name -p $port:80 -v $dir:/usr/share/nginx/html:ro nginx
    end

    # Auto-stop after timeout
    fish -c "sleep $timeout_sec; docker rm -f $container_name" > /dev/null 2>&1 &
    disown
end

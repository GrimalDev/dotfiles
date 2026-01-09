function serve_file
    # Usage:
    #   serve_file /path/to/file [port]
    #   serve_file stop
    set -l container_name serve_file_container

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

    # File to serve
    set -l file_path $argv[1]
    if test -z "$file_path"
        echo "Usage: serve_file /path/to/file [port]"
        echo "       serve_file stop"
        return 1
    end

    if not test -f $file_path
        echo "Error: file '$file_path' does not exist."
        return 1
    end

    # Port
    set -l port 80
    if test (count $argv) -ge 2
        set port $argv[2]
    end

    # Temporary directory
    set -l dir (mktemp -d)
    set -l filename (basename $file_path)

    # HTML or other file
    if string match -r '.*\.html?$' $filename
        cp $file_path $dir/index.html
    else
        echo "<!DOCTYPE html>
<html>
<head><title>Serving $filename</title></head>
<body>
<h1>Download $filename</h1>
<a href=\"$filename\">Click here to download</a>
</body>
</html>" > $dir/index.html
        cp $file_path $dir/
    end

    # Start Docker container
    echo "Serving $filename at http://localhost:$port"
    docker run -d --name $container_name -p $port:80 -v $dir:/usr/share/nginx/html:ro nginx
end

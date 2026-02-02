function qrcode
    if test (count $argv) -eq 0
        echo "Usage: qrcode <url or text>"
        return 1
    end
    set temp_file /tmp/qr_(date +%s).png
    qrtool encode "$argv" -o $temp_file
    osascript -e "set imageData to (read (POSIX file \"$temp_file\") as {«class PNGf»})" -e "set the clipboard to imageData"
    rm $temp_file
    echo "QR code for '$argv' copied to clipboard"
end

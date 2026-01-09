function list_run_files
  if test ! -d .run
      echo "No .run directory"
      return
  end
  set -l files (fd '^*.sh$' -t f -d 1 .run)
  if test (count $files) -eq 0
      echo "no executable files found in .run"
      return
  end
  set -l file_to_run (printf "%s\n" $files | fzf)
  if test -n "$file_to_run"
      commandline -r "bash $file_to_run"
      commandline -f execute
  else
      echo "No file selected"
  end
end

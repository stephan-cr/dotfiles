# -*- mode: gdb-script -*-

set confirm off
set history filename ~/.gdb_history
set history save on
set history expansion off
set pagination off

set extended-prompt (\[\e[0;32m\]thread: \[\e[0m\]\[\e[0;33m\]\t\[\e[0m\], \[\e[0;32m\]frame: \[\e[0m\]\[\e[0m\]\[\e[0;33m\]\f\[\e[0m\])\n\[\e[0;34m\]> \[\e[0m\]

define threads
  info threads
end
document threads
Print threads in target.
end

define watchpoints
  info watchpoints
end
document watchpoints
Print watchpoints in target.
end

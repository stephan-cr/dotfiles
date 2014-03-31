set confirm off
set history save on

set extended-prompt (\[\e[0;32m\]thread: \[\e[0m\]\[\e[0;33m\]\t\[\e[0m\], \[\e[0;32m\]frame: \[\e[0m\]\f \p{print frame-arguments})\n\[\e[0;34m\]> \[\e[0m\]

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

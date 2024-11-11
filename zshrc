# -*- mode: shell-script -*-

# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
ZSH_THEME="gallois"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

zstyle ':omz:update' mode reminder
zstyle ':omz:update' frequency 13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
plugins=(colored-man-pages debian git mercurial python rust shrink-path tig)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

zstyle ':vcs_info:*' enable git hg svn
zstyle ':completion:*' completer _complete _approximate

export GOPATH=$HOME/gocode

export PATH=$PATH:$HOME/bin

if [[ -d "$GOPATH/bin" ]] ; then
    export PATH="$PATH:$GOPATH/bin"
fi

if [[ -d "$HOME/go" ]] ; then
    export GOROOT=$HOME/go
    export PATH="$PATH:$GOROOT/bin"
fi

export PYTHONPATH=$HOME/lib/python

if [[ -d "$HOME/.cargo" ]] ; then
    export PATH="$PATH:$HOME/.cargo/bin"
fi

if [[ -d "$HOME/.local/bin" ]] ; then
    export PATH="$HOME/.local/bin:$PATH"
fi

alias R='R --no-save --quiet'

if [[ -z "$EDITOR" && -x "$(which zile)" ]] ; then
    export EDITOR=zile
fi

# http://wiki.call-cc.org/man/4/Extensions#changing-repository-location
export CHICKEN_REPOSITORY=~/lib/chicken/8

if [[ "$HOST" == "earth5" ]] ; then
    export ALSA_CARD=Generic
    # workaround: not set to "vulkan" (the default) unless amdvlk
    # 2024.Q4.1 is in Arch
    #
    # https://gitlab.gnome.org/GNOME/gtk/-/issues/7056#note_2239402
    export GSK_RENDERER=ngl
    export LIBSEAT_BACKEND=logind
    export VDPAU_DRIVER=radeonsi
fi

if [[ "$XDG_SESSION_TYPE" == "wayland" ]] ; then
    export MOZ_ENABLE_WAYLAND=1
fi

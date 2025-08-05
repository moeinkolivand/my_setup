fastfetch


# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi



# Zinit installation and initialization
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

if [[ ! -d "$ZINIT_HOME" ]]; then
  mkdir -p "$(dirname $ZINIT_HOME)"
  git clone https://github.com/zdharma-continuum/zinit.git "$ZINIT_HOME"
fi

source "${ZINIT_HOME}/zinit.zsh"

# Load plugins with zinit
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-syntax-highlighting
zinit light junegunn/fzf
zinit light zsh-users/zsh-completions
zinit light fdellwing/zsh-bat
zinit light MichaelAquilina/zsh-you-should-use

# Zsh history configuration (must be set before loading plugins)
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000


# History options
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry
setopt HIST_VERIFY               # Don't execute immediately upon history expansion
setopt APPEND_HISTORY            # Append history to the history file (no overwriting)
setopt SHARE_HISTORY             # Share history across terminals
setopt INC_APPEND_HISTORY        # Immediately append to the history file, not just when a term is killed


# Autosuggestions configuration
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE="fg=#666666,underline"
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20


# Ensure bat or batcat is installed
function ensure_bat_installed() {
  if command -v batcat &>/dev/null; then
    alias bat='batcat'
    alias cat='batcat'
  elif command -v bat &>/dev/null; then
    echo "Found bat"
    alias cat='bat'
  else
    echo "bat not found. Attempting to install..."
    if command -v apt &>/dev/null; then
      sudo apt update && sudo apt install -y bat

      # Re-check after install
      if command -v batcat &>/dev/null; then
        mkdir -p ~/.local/bin
        ln -sf /usr/bin/batcat ~/.local/bin/bat
        export PATH="$HOME/.local/bin:$PATH"
        alias bat='batcat'
        alias cat='batcat'
      elif command -v bat &>/dev/null; then
        alias cat='bat'
      else
        echo "Installation failed or bat still not found"
      fi
    else
      echo "apt not found. Please install bat manually."
    fi
  fi
}
ensure_bat_installed

# Set bat theme and options
export BAT_THEME="TwoDark"
export BAT_STYLE="numbers,changes,header"


# Or source our zshrc
# source "${XDG_DATA_HOME:-$HOME/.local/share}/zsh/plugins/@zpm/zshrc"

___MY_VMOPTIONS_SHELL_FILE="${HOME}/.jetbrains.vmoptions.sh"; if [ -f "${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "${___MY_VMOPTIONS_SHELL_FILE}"; fi


export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export TERM=xterm-256color
eval "$(pyenv init -)"
eval "$(pyenv virtualenv-init -)"

source ~/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

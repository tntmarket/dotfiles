set -g theme_nerd_fonts yes
set -g theme_color_scheme dark
set -g theme_display_user no
set -g theme_display_virtualenv yes
set -x VIRTUAL_ENV_DISABLE_PROMPT

eval (gdircolors -c ~/.dircolors)

set GIT_MERGE_AUTOEDIT no
set EDITOR /usr/local/bin/vim

test -e {$HOME}/.iterm2_shell_integration.fish ; and source {$HOME}/.iterm2_shell_integration.fish

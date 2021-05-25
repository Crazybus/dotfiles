i3-msg "workspace 1; append_layout /home/mick/pro/dotfiles/i3/1.json"
i3-msg "workspace 4; append_layout /home/mick/pro/dotfiles/i3/4.json"
i3-msg "workspace 5; append_layout /home/mick/pro/dotfiles/i3/5.json"
i3-msg "workspace 9; append_layout /home/mick/pro/dotfiles/i3/9.json"

firefox &
slack &
alacritty --hold -e zsh -c "moonsla-elastic" & disown

alacritty -e zsh -c "while true; do gcal | ccze --raw-ansi ; sleep 3600; done" &
alacritty -e zsh -c "mutt -R -e \"set sort = reverse-date-received\"" &
spotify &

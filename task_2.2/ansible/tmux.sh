#!/bin/bash

set -e

tmux new-session -d -s monitoring
tmux split-window -v
tmux select-pane -U
  tmux split-window -v
  tmux select-pane -U
  tmux send-keys -t monitoring 'cat infra.txt' C-m
  tmux select-pane -D
  tmux send-keys -t monitoring 'watch -n0.1 curl 192.168.57.6' C-m
tmux select-pane -D
  tmux split-window -v
  tmux select-pane -U
  tmux send-keys -t monitoring 'watch -n0.1 curl 192.168.57.7' C-m
  tmux select-pane -D
tmux send-keys -t monitoring 'watch -n0.1 curl 192.168.57.10' C-m
tmux attach-session -d -t monitoring

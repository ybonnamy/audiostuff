# audiostuff

This project aims at playing music on linux, mixing from different sources, to differents ouputs, while being able to avoid any music interruption thanks to pipewire.

.config : allows to have stable audio sinks and auto linking to these sinks thanks to pipewire/wireplumber
Music/bin/auto_record_tracks.sh : allows to record tracks played on phones/browsers/webradios benefiting the available metadatas from playerctl

wpctl set-default <unlinked SinkA> has been executed so that any new audio source does not disturb any current audio broadcast or recording

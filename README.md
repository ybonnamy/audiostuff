
# audiostuff  
  
This project aims at playing music on linux, mixing from different sources, to differents ouputs, thanks to pipewire. Connecting new sources or outputs can be done while being able to avoid any music interruption and allow pre-listening in a headset as when DJing (mixxx).
  
- .config : allows to have "stable" audio sinks and auto linking to these sinks thanks to pipewire/wireplumber  - "stable" sinks were needed because bluetooth  phones or browsers  disappear and reappear dynamically 
- Music/bin/auto_record_tracks.sh : allows to record tracks played on phones/browsers/webradios benefiting the available metadatas from playerctl  
  
wpctl set-default \<SinkA> has been executed so that any new audio source does not disturb any current audio broadcast or recording

![Screenshot of the result.](/target.png)

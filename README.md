![Wifi Speed](https://github.com/loll31/wifi_speed/blob/main/wifi_speed.png?raw=true)

# wifi_speed
Show MacOS Wifi speed in graph

## Installation
Copy wifi_speed.sh anywhere on your Mac.

## Usage
Start from Terminal. To get Wifi information, sudo password will be asked if user is not root.

```
bash path/to/wifi_speed.sh
```

At first start, the script will create a dedicated Python virtual env in $HOME/.venv_wifi_speed for dependancies installation (mathplotlib).
This venv directory is kept for next runs. To avoid persistance, start script with -c option.

## Help
```
$ bash ./wifi_speed.sh -h
usage: wifi_speed.sh [-c|-h]
Show Wifi device speed in graph
options:
 -c: cleanup venv (/Users/chef/.venv_wifi_speed) after run
 -h: this message
```


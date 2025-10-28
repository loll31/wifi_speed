#!/bin/bash
# affiche la vitesse de la carte Wifi dans un graphe
# (c) LOLL 2025 
# Licence: GNU Public License, version 3

# dossier persistant de l'environnment virtuel
VENVDIR="$HOME/.venv_wifi_speed"
# fichier temporaire
PLOT=$(mktemp)

# usage
[[ "$*" =~ -h ]] && echo "usage: $(basename $0) [-c|-h]
Show Wifi device speed in graph
options:
 -c: cleanup venv ($VENVDIR) after run
 -h: this message" && exit

### Main
# creation de l'environnement virtuel
if [ ! -d "$VENVDIR" ]; then
  python3 -m venv "$VENVDIR" 
  source "$VENVDIR/bin/activate"
  pip3 -q install matplotlib
  if [[ $? -ne 0 ]]; then 
    echo "erreur creation venv"
    exit 1
  fi
else
  # chargement environnement
  source "$VENVDIR/bin/activate"
fi

# script python 
cat <<EOF >$PLOT
import sys
import select
from datetime import datetime
import matplotlib.pyplot as plt
import matplotlib.dates as mdates
plt.rcParams['toolbar'] = 'None'

running = True  # Drapeau de boucle

def handle_close(evt):
    global running
    running = False

x_data = []
y_data = []

plt.ion()
fig, ax = plt.subplots()
fig.canvas.mpl_connect('close_event', handle_close)
line, = ax.plot([], [], marker='o')
ax.set_xlabel("Heure")
ax.set_ylabel("Débit")
ax.set_title("Débit réseau en temps réel")
ax.grid()

time_fmt = mdates.DateFormatter('%H:%M:%S')
ax.xaxis.set_major_formatter(time_fmt)
fig.autofmt_xdate()

while running:
    rlist, _, _ = select.select([sys.stdin], [], [], 0.1)
    if rlist:
        line_in = sys.stdin.readline()
        if not line_in:
            break
        try:
            vals = line_in.strip().split()
            tstamp = " ".join(vals[:2])
            val = vals[2]
            t = datetime.strptime(tstamp, "%Y-%m-%d %H:%M:%S")
            v = float(val)
            x_data.append(t)
            y_data.append(v)
            line.set_data(x_data, y_data)
            ax.relim()
            ax.autoscale_view()
            plt.draw()
            plt.pause(0.01)
        except Exception:
            continue
    else:
        plt.pause(0.1)

plt.ioff()
plt.close(fig)
EOF

while true ; do 
  echo -ne "$(date +%Y-%m-%d' '%H:%M:%S) " 
  sudo wdutil info wifi | grep "Tx Rate" | awk '{print $4}' 
done | python3 $PLOT

# cleanup
deactivate
[ -f "$PLOT" ] && rm "$PLOT"
[[ "$*" =~ -c ]] && rm -rf "$VENVDIR" && echo "info: Virtuel env deleted." 
# fin


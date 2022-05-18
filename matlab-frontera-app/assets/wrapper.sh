
set -x

echo "TACC: job $SLURM_JOB_ID execution at: `date`"

# our node name
NODE_HOSTNAME=`hostname -s`
echo "TACC: running on node $NODE_HOSTNAME"

TAP_FUNCTIONS="/share/doc/slurm/tap_functions"
if [ -f ${TAP_FUNCTIONS} ]; then
    . ${TAP_FUNCTIONS}
else
    echo "TACC:"
    echo "TACC: ERROR - could not find TAP functions file: ${TAP_FUNCTIONS}"
    echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
    echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
    echo "TACC:"
    echo "TACC: job $SLURM_JOB_ID execution finished at: $(date)"
    exit 1
fi

# confirm DCV server is alive
SERVER_TYPE="DCV"
DCV_SERVER_UP=`systemctl is-active dcvserver`
if [ $DCV_SERVER_UP != "active" ]; then
  echo "TACC:"
  echo "TACC: ERROR - could not confirm dcvserver active, systemctl returned '$DCV_SERVER_UP'"
  echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
  echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC:"
  echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
  exit 1
fi

# create an X startup file in /tmp
# source xinitrc-common to ensure xterms can be made
# then source the user's xstartup if it exists
XSTARTUP="/tmp/dcv-startup-$USER"
cat <<- EOF > $XSTARTUP
#!/bin/sh

unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
. /etc/X11/xinit/xinitrc-common
EOF
if [ -x $HOME/.vnc/xstartup ]; then
  cat $HOME/.vnc/xstartup >> $XSTARTUP
else
  echo "exec startxfce4" >> $XSTARTUP
fi
chmod a+rx $XSTARTUP

# if X0 socket exists, then DCV will use a higher X display number and ruin our day
# therefore, cowardly bail out and appeal to an admin to fix the problem
if [ -f /tmp/.X11-unix/X0 ]; then
  echo "TACC:"
  echo "TACC: ERROR - X0 socket already exists. DCV script will fail."
  echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
  echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC:"
  echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
  exit 1
fi

# create DCV session for this job
DCV_HANDLE="${AGAVE_JOB_ID}-session"
dcv create-session --owner ${AGAVE_JOB_OWNER} --init=$XSTARTUP $DCV_HANDLE
if ! `dcv list-sessions | grep -q ${AGAVE_JOB_ID}`; then
  echo "TACC:"
  echo "TACC: WARNING - could not find a DCV session for this job"
  echo "TACC: WARNING - This could be because all DCV licenses are in use."
  echo "TACC: WARNING - Failing over to VNC session."
  echo "TACC: "
  echo "TACC: If you rarely receive a DCV session using this script, "
  echo "TACC: please submit a consulting ticket at the TACC user portal:"
  echo "TACC: https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC: "

  SERVER_TYPE="VNC"
  VNCSERVER_BIN=`which vncserver`
  echo "TACC: using default VNC server $VNCSERVER_BIN"

  echo ${AGAVE_JOB_ID} | vncpasswd -f > vncp.txt

  # launch VNC session
  VNC_DISPLAY=`$VNCSERVER_BIN -geometry ${desktop_resolution} -rfbauth vncp.txt $@ 2>&1 | grep desktop | awk -F: '{print $3}'`
  echo "TACC: got VNC display :$VNC_DISPLAY"

  if [ x$VNC_DISPLAY == "x" ]; then
    echo "TACC: "
    echo "TACC: ERROR - could not find display created by vncserver: $VNCSERVER"
    echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal:"
    echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
    echo "TACC: "
    echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
    exit 1
  fi
fi

if [ "x${SERVER_TYPE}" == "xDCV" ]; then
  LOCAL_PORT=8443  # default DCV port
  DISPLAY=":0"
elif [ "x${SERVER_TYPE}" == "xVNC" ]; then
  LOCAL_PORT=`expr 5900 + $VNC_DISPLAY`
  DISPLAY=":${VNC_DISPLAY}"
else
  echo "TACC: "
  echo "TACC: ERROR - unknown server type '${SERVER_TYPE}'"
  echo "TACC: Please submit a consulting ticket at the TACC user portal"
  echo "TACC: https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC:"
  echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
  exit 1
fi
echo "TACC: local (compute node) ${SERVER_TYPE} port is $LOCAL_PORT"

LOGIN_PORT=$(tap_get_port)
echo "TACC: got login node ${SERVER_TYPE} port $LOGIN_PORT"

# Webhook callback url for job ready notification
# (notifications sent to INTERACTIVE_WEBHOOK_URL (i.e. https://3dem.org/webhooks/interactive/))`
INTERACTIVE_WEBHOOK_URL="${_webhook_base_url}interactive/"

# Wait a few seconds for good measure for the job status to update
sleep 3;
if [ "x${SERVER_TYPE}" == "xDCV" ]; then
  # create reverse tunnel port to login nodes.  Make one tunnel for each login so the user can just
  # connect to frontera.tacc
  for i in `seq 4`; do
      ssh -q -f -g -N -R $LOGIN_PORT:$NODE_HOSTNAME:$LOCAL_PORT login$i
  done
  echo "TACC: Created reverse ports on Frontera logins"
  echo "TACC:          https://frontera.tacc.utexas.edu:$LOGIN_PORT"
  curl -k --data "event_type=WEB&address=https://frontera.tacc.utexas.edu:$LOGIN_PORT&owner=${AGAVE_JOB_OWNER}&job_uuid=${AGAVE_JOB_ID}" $INTERACTIVE_WEBHOOK_URL &
elif [ "x${SERVER_TYPE}" == "xVNC" ]; then

  TAP_CERTFILE=${HOME}/.tap/.${SLURM_JOB_ID}
  # bail if we cannot create a secure session
  if [ ! -f ${TAP_CERTFILE} ]; then
      echo "TACC: ERROR - could not find TLS cert for secure session"
      echo "TACC: job ${SLURM_JOB_ID} execution finished at: $(date)"
      exit 1
  fi

  # fire up websockify to turn the vnc session connection into a websocket connection
  WEBSOCKIFY_CMD="/home1/00832/envision/websockify/run"
  WEBSOCKIFY_PORT=5902
  WEBSOCKIFY_ARGS="--cert=$(cat ${TAP_CERTFILE}) --ssl-only -D ${WEBSOCKIFY_PORT} localhost:${LOCAL_PORT}"
  ${WEBSOCKIFY_CMD} ${WEBSOCKIFY_ARGS} # websockify will daemonize

  WEBSOCKET_PORT=$($LOGIN_PORT)

  # notifications sent to INTERACTIVE_WEBHOOK_URL
  curl -k --data "event_type=VNC&host=stampede2.tacc.utexas.edu&port=$WEBSOCKET_PORT&address=stampede2.tacc.utexas.edu:$LOGIN_PORT&password=${AGAVE_JOB_ID}&owner=${AGAVE_JOB_OWNER}" $INTERACTIVE_WEBHOOK_URL &
else
  # we should never get this message since we just checked this at LOCAL_PORT
  echo "TACC: "
  echo "TACC: ERROR - unknown server type '${SERVER_TYPE}'"
  echo "TACC: Please submit a consulting ticket at the TACC user portal"
  echo "TACC: https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC:"
  echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
  exit 1
fi

# Warn the user when their session is about to close
# see if the user set their own runtime
#TACC_RUNTIME=`qstat -j $JOB_ID | grep h_rt | perl -ne 'print $1 if /h_rt=(\d+)/'`  # qstat returns seconds
#TACC_RUNTIME=`squeue -l -j $SLURM_JOB_ID | grep $SLURM_QUEUE | awk '{print $7}'` # squeue returns HH:MM:SS
TACC_RUNTIME=`squeue -j $SLURM_JOB_ID -h --format '%l'`
if [ x"$TACC_RUNTIME" == "x" ]; then
	TACC_Q_RUNTIME=`sinfo -p $SLURM_QUEUE | grep -m 1 $SLURM_QUEUE | awk '{print $3}'`
	if [ x"$TACC_Q_RUNTIME" != "x" ]; then
		# pnav: this assumes format hh:dd:ss, will convert to seconds below
		#       if days are specified, this won't work
		TACC_RUNTIME=$TACC_Q_RUNTIME
	fi
fi

#if [ x"$TACC_RUNTIME" != "x" ]; then
  # there's a runtime limit, so warn the user when the session will die
  # give 5 minute warning for runtimes > 5 minutes
#        H=`echo $TACC_RUNTIME | awk -F: '{print $1}'`
#        M=`echo $TACC_RUNTIME | awk -F: '{print $2}'`
#        S=`echo $TACC_RUNTIME | awk -F: '{print $3}'`
#        if [ "x$S" != "x" ]; then
            # full HH:MM:SS present
#            H=$(($H * 3600))
#            M=$(($M * 60))
#            TACC_RUNTIME_SEC=$(($H + $M + $S))
#        elif [ "x$M" != "x" ]; then
            # only HH:MM present, treat as MM:SS
#            H=$(($H * 60))
#            TACC_RUNTIME_SEC=$(($H + $M))
#        else
#            TACC_RUNTIME_SEC=$S
#        fi

#  if [ $TACC_RUNTIME_SEC -gt 300 ]; then
#    TACC_RUNTIME_SEC=`expr $TACC_RUNTIME_SEC - 300`
#    sleep $TACC_RUNTIME_SEC && echo "TACC: $USER's $SERVER_TYPE session will end in 5 minutes.  Please save your work now." | wall &
#  fi
#fi

# Load the default TACC modules
module purge
module load TACC
module load matlab/2020b

# set up license file
cat << EOT >> .matlab_license
${_license}
EOT

cat .matlab_license
export LM_LICENSE_FILE=`pwd`/.matlab_license
echo "LM_LICENSE_FILE is : $LM_LICENSE_FILE"

# run an xterm for the user; execution will hold here
export DISPLAY
xterm -r -ls -geometry 80x24+10+10 -title '*** Exit this window to kill your $SERVER_TYPE server ***' -e 'matlab'

# job is done!

echo "TACC: closing ${SERVER_TYPE} session"
if [ "x${SERVER_TYPE}" == "xDCV" ]; then
  dcv close-session ${DCV_HANDLE}
elif [ "x${SERVER_TYPE}" == "xVNC" ]; then
  vncserver -kill ${DISPLAY}
else
  # we should never get this message since we just checked this at LOCAL_PORT
  echo "TACC: "
  echo "TACC: ERROR - unknown server type '${SERVER_TYPE}'"
  echo "TACC: Please submit a consulting ticket at the TACC user portal"
  echo "TACC: https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
  echo "TACC:"
  echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
  exit 1
fi


# wait a brief moment so vncserver can clean up after itself
sleep 1

echo "TACC: release port returned $(tap_release_port ${LOGIN_PORT} 2> /dev/null)"

# remove X11 sockets so DCV will find :0 next time
find /tmp/.X11-unix -user $USER -exec rm -f '{}' \;

echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
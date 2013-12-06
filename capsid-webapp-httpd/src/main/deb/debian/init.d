#!/bin/bash
### BEGIN INIT INFO
# Provides:          capsid
# Required-Start:    $network $local_fs $remote_fs
# Required-Stop:     $remote_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Capsid
# Description:       CaPSID: Computational Pathogen Sequence IDentification
### END INIT INFO

# Author: OBiBa <info@obiba.org>

# PATH should only include /usr/* if it runs after the mountnfs.sh script
PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC=capsid             # Introduce a short description here
NAME=capsid             # Introduce the short server's name here
CAPSID_USER=capsid  # User to use to run the service
DAEMON=/usr/bin/daemon      # Introduce the server's location here
DAEMON_ARGS=""              # Arguments to run the daemon with
MAIN_CLASS=ca.on.oicr.capsid.server.httpd.CapsidJettyServer
TMPDIR=/var/run/$NAME
PIDFILE=$TMPDIR/$NAME.pid
SCRIPTNAME=/etc/init.d/$NAME

# Exit if the package is not installed
[ -x $DAEMON ] || exit 0

# Read configuration variable file if it is present
[ -r /etc/default/$NAME ] && . /etc/default/$NAME

# Load the VERBOSE setting and other rcS variables
. /lib/init/vars.sh

# Define LSB log_* functions.
# Depend on lsb-base (>= 3.0-6) to ensure that this file is present.
. /lib/lsb/init-functions

DAEMON_ARGS="--name=$NAME --user=$CAPSID_USER --pidfile=$PIDFILE --inherit --env=CAPSID_HOME=$CAPSID_HOME --env=CAPSID_LOG=$CAPSID_LOG --output=$CAPSID_LOG/stdout.log --chdir=$CAPSID_HOME"
CLASSPATH="$CAPSID_HOME/conf:$CAPSID_DIST/lib/*"

# Get the status of the daemon process
get_daemon_status()
{
    $DAEMON $DAEMON_ARGS --running || return 1
}

get_running() 
{
    return `ps -U $CAPSID_USER --no-headers -f | egrep -e '(java|daemon)' | grep -c . `
}

get_running_daemon() 
{
    return `ps -U $CAPSID_USER --no-headers -f | egrep -e '(daemon)' | grep -c . `
}

force_stop() 
{
    get_running
    if [ $? -ne 0 ]; then 
        killall -u $CAPSID_USER java || return 3
    fi
}

#
# Function that starts the daemon/service
#
do_start()
{
    # Return
    #   0 if daemon has been started
    #   1 if daemon was already running
    #   2 if daemon could not be started
    $DAEMON $DAEMON_ARGS --running && return 1

    if [ -n "$MAXOPENFILES" ]; then
        ulimit -n $MAXOPENFILES
    fi
    
    $DAEMON $DAEMON_ARGS -- $JAVA $JAVA_ARGS -cp $CLASSPATH -DCAPSID_HOME=$CAPSID_HOME -DCAPSID_DIST=$CAPSID_DIST -DCAPSID_LOG=$CAPSID_LOG $MAIN_CLASS $CAPSID_ARGS || return 2
}

#
# Function that stops the daemon/service
#
do_stop()
{
    # Return
    #   0 if daemon has been stopped
    #   1 if daemon was already stopped
    #   2 if daemon could not be stopped
    #   other if a failure occurred
    get_daemon_status 
    case "$?" in
        0) 
            $DAEMON $DAEMON_ARGS --stop || return 2
        # wait for the process to really terminate
        echo -n "   "
        for n in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20; do
            sleep 1
            echo -n "."
            $DAEMON $DAEMON_ARGS --running || break
        done
        if get_daemon_status; then
                force_stop || return 3
        fi
            ;;
        *)
            force_stop || return 3
            ;;
    esac

    # Many daemons don't delete their pidfiles when they exit.
    rm -f $PIDFILE
    return 0
}


#
# Function that sends a SIGHUP to the daemon/service
#
do_reload() {
	#
	# If the daemon can reload its configuration without
	# restarting (for example, when it is sent a SIGHUP),
	# then implement that here.
	#
	start-stop-daemon --stop --signal 1 --quiet --pidfile $PIDFILE --name $NAME
	return 0
}

#
# Make sure capsid tmp dir exists, otherwise daemon calls will fail
#
if [ ! -d $TMPDIR ]; then 
  mkdir $TMPDIR
  chown -R capsid:adm $TMPDIR
  chmod -R 750 $TMPDIR
fi

case "$1" in
  start)
    log_daemon_msg "Starting $DESC" "$NAME"
    do_start
    case "$?" in
        0|1) log_end_msg 0 ;;
        2) log_end_msg 1 ;;
    esac
    ;;
  stop)
    log_daemon_msg "Stopping $DESC" "$NAME"
    do_stop
    case "$?" in
        0|1) log_end_msg 0 ;;
        2) log_end_msg 1 ;;
    esac
    ;;
  restart|force-reload)
    #
    # If the "reload" option is implemented then remove the
    # 'force-reload' alias
    #
    log_daemon_msg "Restarting $DESC" "$NAME"
    do_stop
    case "$?" in
      0|1)
        do_start
        case "$?" in
          0) log_end_msg 0 ;;
          1) log_end_msg 1 ;; # Old process is still running
          *) log_end_msg 1 ;; # Failed to start
        esac
        ;;
      *)
        # Failed to stop
        log_end_msg 1
        ;;
    esac
    ;;
  status)
      get_daemon_status
      case "$?" in 
         0) echo "$DESC is running with the pid `cat $PIDFILE`";;
         *) 
              get_running_daemon
              procs=$?
              if [ $procs -eq 0 ]; then 
                  echo -n "$DESC is not running"
                  if [ -f $PIDFILE ]; then 
                      echo ", but the pidfile ($PIDFILE) still exists"
                  else 
                      echo
                  fi
              elif [ $procs -eq 1 ]; then 
                  echo "An instance of capsid is running at the moment"
                  echo "but the pidfile $PIDFILE is missing"
              else 
                  echo "$procs instances of capsid are running at the moment"
                  echo "but the pidfile $PIDFILE is missing"
              fi
              ;;
      esac
    ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop|status|restart|force-reload}" >&2
    exit 3
    ;;
esac

exit 0


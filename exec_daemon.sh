#!/bin/bash

NAME="[ EXEC DAEMON ]"
PID="/tmp/exec_daemon.pid"
CMD="ruby exec_daemon.rb"
CMD_START="ruby exec_daemon.rb start"
CMD_END="ruby exec_daemon.rb end"

start()
{
  if [ -e $PID ]; then
    echo "$NAME already started"
    exit 1
  fi
  echo "$NAME START!"
  $CMD_START
  $CMD
  echo "$NAME START END!"
  exit 0
}

stop()
{
  if [ ! -e $PID ]; then
    echo "$NAME not started"
  else
    echo "$NAME STOP!"
    kill -INT `cat ${PID}`
    rm $PID
    $CMD_END
  fi
}

restart()
{
  stop
  sleep 2
  start
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  *)
    echo "Syntax Error: release [start|stop|restart]"
    ;;
esac

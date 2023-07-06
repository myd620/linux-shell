#!/bin/sh
CURRENT_DIR=$(cd `dirname $0`; pwd)
SELF_FULL_PATH=$CURRENT_DIR/`basename $0`
BIN_NAME=xxx
FULL_BIN_NAME=$CURRENT_DIR/bin/$BIN_NAME 
CONF_FILE_NAME=settings.conf
wait_time=1

Usage() {
  echo "command format: \"$0\" start|restart|stop"
}

GetProcNum () {
  # proc_num=`ps -ef | grep -v grep | grep $BIN_NAME | wc -l` //不建议使用这个， 如果脚本名和进程名称一样，会出错
  proc_num=`pgrep $BIN_NAME | wc -l`
  pid=`ps -ef|grep $BIN_NAME|grep -v grep|awk '{print $2}'`
}

add_cron_task() {
  crontab -l > conf && echo "* * * * * $SELF_FULL_PATH check 1> /dev/null" >> conf && crontab conf && rm -f conf
}


Start() {
  GetProcNum
  if [ $proc_num -ge 1 ];then
    echo "$BIN_NAME is running, pid is $pid"
  else
    ulimit -c unlimited
    nohup $FULL_BIN_NAME -c $CURRENT_DIR/etc/$CONF_FILE_NAME  > /dev/null 2>&1 &
    GetProcNum
    if [[ $proc_num == 0 ]]; then
      echo "$BIN_NAME start Failed!"
    else
      echo "$BIN_NAME start OK!"
      add_cron_task
    fi
  fi
}

Stop() {
  echo "stopping service"
#  del_cron_task
  killall  $BIN_NAME
  sleep $wait_time
  GetProcNum
  if [ $proc_num == 0 ]; then
    echo "$BIN_NAME stop successfully."
  else
    echo "$BIN_NAME stop Failed!"
  fi
}

Check() {
  GetProcNum
  if [ $proc_num == 0 ]; then
    echo "service is not running, start!"
    Start
  else
    echo "service is running"
  fi
}


if [ $# -lt 1 ]; then
  Usage
  exit 1
fi




case "$1" in
 start)
  Start
  ;;
 stop)
  Stop
 ;;
 restart)
  Stop
  Start
 ;;
 check)
  Check
 ;;
esac

#!/bin/bash
#    This is a bash script that allows you to easily start/update and shut down the DreamDemon server
#    Copyright (C) 2018 sasichkamega
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.

PROJECT_DIR="/root/Baystation12" #Папка билдосика
PROJECT_NAME="baystation12" #Имя dme файла, но без расширения .dme
PORT=4738 #Внезапно порт
FLAGS="-public -close -trusted" #Параметры запуска (-suidself -public -close -trusted и т.д)

USE_GIT=false #Юзать git для обновлений серва? (true/false) Если билдосик был скачан через git clone

DM_DAEMON=DreamDaemon
DM_MAKER=DreamMaker


dm_status() {
   if [[ -f "$PROJECT_DIR/process.pid" ]]; then
      read DM_PID<"$PROJECT_DIR/process.pid"
      if [[ `ps $DM_PID | grep $DM_DAEMON` ]]; then
         DM_IS_ONLINE=true
      fi
   fi

   if [[ $DM_IS_ONLINE == true ]]
   then
      echo "Состояние сервера: ONLINE"
   else
      echo "Состояние сервера: OFFLINE"
   fi
}
dm_start() {
   if [[ -f "$PROJECT_DIR/process.pid" ]]
   then
      read DM_PID<"$PROJECT_DIR/process.pid"
      if [[ `ps $DM_PID | grep $DM_DAEMON` ]]
      then
         dm_status
      else
         $DM_DAEMON "$PROJECT_DIR/$PROJECT_NAME.dmb" $PORT $FLAGS &
         echo $! > "$PROJECT_DIR/process.pid"
      fi

   else
      $DM_DAEMON "$PROJECT_DIR/$PROJECT_NAME.dmb" $PORT $FLAGS &
      echo $! > "$PROJECT_DIR/process.pid"
   fi
}
dm_stop() {
   DM_IS_ONLINE=""
   DM_PID=""
   if [[ -f "$PROJECT_DIR/process.pid" ]]; then
      read DM_PID<"$PROJECT_DIR/process.pid"
      if [[ `ps $DM_PID | grep $DM_DAEMON` ]]; then
         #kill -s SIGTERM $DM_PID
         kill -KILL $DM_PID
         while [[ `ps $DM_PID | grep $DM_DAEMON` ]]; do
            sleep 1
         done
      fi
      rm "$PROJECT_DIR/process.pid"
   fi
   dm_status
}


dm_reboot() {
   dm_stop
   dm_start
}
dm_compile() {
   $DM_MAKER "$PROJECT_DIR/$PROJECT_NAME.dme"

}
dm_update() {
   if [[ USE_GIT != true ]]
   then
      git -C $PROJECT_DIR pull
      dm_compile
   else
      echo "Обновление через git отключено"
   fi
}

show_help() {
   echo "                _      _     _                                          __  "
   echo "               (_)    | |   | |                                      _  \ \ "
   echo "  ___  __ _ ___ _  ___| |__ | | ____ _ _ __ ___   ___  __ _  __ _   (_)  | |"
   echo " / __|/ _\` / __| |/ __| '_ \| |/ / _\` | '_ \` _ \ / _ \/ _\` |/ _\` |       | |"
   echo " \__ \ (_| \__ \ | (__| | | |   < (_| | | | | | |  __/ (_| | (_| |   _   | |"
   echo " |___/\__,_|___/_|\___|_| |_|_|\_\__,_|_| |_| |_|\___|\__, |\__,_|  (_)  | |"
   echo "                                                       __/ |            /_/ "
   echo "Комманды:                                             |___/                 "
   echo "  status  -- показать статус сервера"
   echo "  start   -- запустить на $PORT порту"
   echo "  stop    -- остановить "
   echo "  reboot  -- перезапустить "
   echo "  update  -- обновить"
   echo "  compile -- скомпилировать"

   echo "Пример:"
   echo "  `basename $BASH_SOURCE` start         -- запустить серв"
   echo "  `basename $BASH_SOURCE` update reboot -- обновить, а после перезапустить сервер"
   echo "  `basename $BASH_SOURCE` stop update   -- остановить и обновить"
}

case $1 in
   --help)
      show_help
      exit 1
      ;;
   --h)
      show_help
      exit 1
      ;;
   -help)
      show_help
      exit 1
      ;;
   -h)
      show_help
      exit 1
      ;;
esac



for n in $@
do
   case $n in
      status)
         ;;
      start)
         ;;
      stop)
         ;;
      reboot)
         ;;
      update)
         ;;
      compile)
         ;;
      *)
         echo "Неизвестная комманда: $n"
         echo "  --help для вызова справки"
         exit 1
         ;;
   esac
done

SHOW_STATUS=true
for n in $@
do
   SHOW_STATUS=false
   case $n in
      status)
         dm_status
         ;;
      start)
         dm_start
         ;;
      stop)
         dm_stop
         ;;
      reboot)
         dm_reboot
         ;;
      update)
         dm_update
         ;;
      compile)
         dm_compile
         ;;
   esac
done

if [[ $SHOW_STATUS == true ]]; then
   dm_status
fi

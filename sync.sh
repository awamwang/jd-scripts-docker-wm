#!/bin/bash
# git config --global http.sslBackend "openssl"
# git config --global http.sslCAInfo "/etc/ssl1.1/cert.pem"

# echo "140.82.114.4 github.com" > /etc/hosts
# service networking restart

trap 'cp /jd-scripts-docker/sync.sh /sync' Exit
(
  exec 2<>/dev/null
  set -e
  cd /jd-scripts-docker
  git checkout .
  git pull
) || {
  # git clone https://github.com/chinnkarahoi/jd-scripts-docker.git /jd-scripts-docker_tmp
  # git clone https://github.com/awamwang/jd-scripts-docker-wm.git /jd-scripts-docker_tmp
  git clone https://hub.fastgit.org/awamwang/jd-scripts-docker-wm.git
  mv /jd-scripts-docker-wm /jd-scripts-docker_tmp
  [ -d /jd-scripts-docker_tmp ] && {
    rm -rf /jd-scripts-docker
    mv /jd-scripts-docker_tmp /jd-scripts-docker
  }
}
(
  exec 2<>/dev/null
  set -e
  cd /scripts
  git checkout .
  git pull
) || {
  #git clone --branch=master https://github.com/chinnkarahoi/jd_scripts.git /scripts_tmp
  # git clone --branch=main https://github.com/JDHelloWorld/jd_scripts.git /scripts_tmp
  # git clone --branch=main https://github.com/awamwang/jd_scripts.git /scripts_tmp
  git clone https://hub.fastgit.xyz/chinnkarahoi/jd_scripts.git
  mv /jd_scripts /scripts_tmp
  [ -d /scripts_tmp ] && {
    rm -rf /scripts
    mv /scripts_tmp /scripts
  }
}
(
  exec 2<>/dev/null
  set -e
  cd /loon
  git checkout .
  git pull
) || {
  # git clone --branch=main https://github.com/chinnkarahoi/Loon.git /loon_tmp
  # git clone --branch=main https://github.com/awamwang/jd-scripts-loon.git /loon_tmp
  git clone https://hub.fastgit.xyz/chinnkarahoi/Loon.git
  mv /Loon /loon_tmp
  [ -d /loon_tmp ] && {
    rm -rf /loon
    rm -rf /loon_tmp/backup
    rm -rf /loon_tmp/backUp
    mv /loon_tmp /loon
  }
}
(
  exec 2<>/dev/null
  set -e
  cd /JD
  git checkout .
  git pull
) || {
  # git clone --branch=main https://github.com/awamwang/JD_tencent_scf.git /JD_tmp
  # git clone --branch=main https://github.com/zero205/JD_tencent_scf.git /JD_tmp
  git clone https://hub.fastgit.xyz/zero205/JD_tencent_scf.git
  mv /JD_tencent_scf /JD_tmp
  [ -d /JD_tmp ] && {
    rm -rf /JD
    rm -rf /JD_tmp/backup
    rm -rf /JD_tmp/backUp
    mv /JD_tmp /JD
  }
}
cd /scripts || exit 1
cp /loon/*.js /scripts
# mkdir /scripts/docker
# cp /loon/docker/crontab_list.sh /scripts/docker/
cp /JD/*.js /scripts

echo "清理废弃"
rm /scripts/jd_carnivalcity.js
rm /scripts/jd_beauty.js
rm /scripts/jd_beauty_ex.js

echo "开始安装"
npm install || npm install --registry=https://registry.npm.taobao.org || exit 1
npm install -g png-js dotenv || npm install -g png-js dotenv --registry=https://registry.npm.taobao.org || exit 1
[ -f /crontab.list ] && {
  echo "存在旧的crontab.list"
  cp /crontab.list /crontab.list.old
}
cat /etc/os-release | grep -q ubuntu && {
  cp /jd-scripts-docker/crontab.list /crontab.list
  crontab -r
} || {
  echo "构造crontab.list"
  cat /scripts/docker/crontab_list.sh | grep 'node' | sed 's/>>.*$//' | awk '
  BEGIN{
    print("55 */1 * * *  bash /jd-scripts-docker/cron_wrapper bash /sync")
  }
  {
    for(i=1;i<=5;i++)printf("%s ",$i);
    printf("bash /jd-scripts-docker/cron_wrapper \"");
    for(i=6;i<=NF;i++)printf(" %s", $i);
    print "\"";
  }
  ' > /crontab.list
  cat /loon/docker/crontab_list.sh | grep 'node' | sed 's/>>.*$//' | awk '
  {
    for(i=1;i<=5;i++)printf("%s ",$i);
    printf("bash /jd-scripts-docker/cron_wrapper \"");
    for(i=6;i<=NF;i++)printf(" %s", $i);
    print "\"";
  }
  ' >> /crontab.list
  cat /custom.list >> /crontab.list
}

crontab /crontab.list || {
  cp /crontab.list.old /crontab.list
  crontab /crontab.list
}
crontab -l

#!/bin/bash
set -x

if [ -z "$USERGID" ] ; then
   USERGID=1000
fi
if [ -n "$USERID" ] ; then
   sed -i /etc/passwd -e "s,jenkins:x:1000:1000,jenkins:x:$USERID:$USERGID,"
else
   USERID=1000
fi

if [ -e "/var/run/docker.sock" ] ; then
   DOCKERGROUP=$(stat -c "%g" /var/run/docker.sock)
   if [ "$DOCKERGROUP" != "0" ] ; then
        groupmod -g $DOCKERGROUP docker 2>/dev/null || groupadd -g $DOCKERGROUP docker
        usermod -aG docker jenkins
   fi
fi
/usr/bin/add-koji-cert.sh
if [ -e /usr/share/jenkins/ref/plugins.txt ] ; then
   sudo -E -u jenkins HOME=$JENKINS_HOME PATH=$PATH /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
fi

chown $USERID.$USERGID $JENKINS_HOME
exec /sbin/tini -- sudo -E -u jenkins HOME=$JENKINS_HOME PATH=$PATH /usr/local/bin/jenkins.sh 

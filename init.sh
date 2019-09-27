#!/bin/bash


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
chown $USERID.$USERGID $JENKINS_HOME
PLUGINS=$(mktemp)
if [ -e /usr/share/jenkins/ref/plugins.txt -a "$INSTALL_PLUGINS" = "1" ] ; then
   cat /usr/share/jenkins/ref/plugins.txt > $PLUGINS
fi
if [ -e $JENKINS_HOME/plugins.txt -a "$INSTALL_PLUGINS" = "1" ] ; then
   cat $JENKINS_HOME/plugins.txt > $PLUGINS
fi
if [ -n "$(cat $PLUGINS)" ] ; then
    sudo -E -u jenkins HOME=$JENKINS_HOME PATH=$PATH /usr/local/bin/install-plugins.sh < $PLUGINS
fi
rm -f $PLUGINS
exec /sbin/tini -- sudo -E -u jenkins HOME=$JENKINS_HOME PATH=$PATH /usr/local/bin/jenkins.sh 

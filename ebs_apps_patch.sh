#!/bin/bash
# +===========================================================================+
# | FILENAME
# |   ebs_apps_patch.sh
# |
# | DESCRIPTION
# |   This script is used to download and apply patch on EBS R12.2 including if a patch is applied or not, running prepare,cutover phases,etc
# |
# | USAGE
# |    sh ebs_apps_patch.sh download_patch [patch number]
# |    sh ebs_apps_patch.sh prep_phase
# |    sh ebs_apps_patch.sh check_patch_applied [patch number]
# |    sh ebs_apps_patch.sh apply_phase [patch number]
# |    sh ebs_apps_patch.sh NLS_apply_phase [patch number]
# |    sh ebs_apps_patch.sh cutover_phase
# |    sh ebs_apps_patch.sh full_phase
# |    sh ebs_apps_patch.sh fs_clone
# |    sh ebs_apps_patch.sh adop_status
# |
# | PLATFORM
# |   Linux X86_64
# |
# | NOTES
# |
# | HISTORY
# | Indraneil Seal       09/13/2023      Created
# |
# |
# +===========================================================================+


# Check whether patch is applied

function check_patch_applied {
   sqlplus apps/$APPS_PWD << EOD
   select bug_number,creation_date,LANGUAGE from ad_bugs where bug_number='$PATCH_ID';
   select name from v\$database;
   exit
EOD
}

# Download patch on server
function download_patch {
    echo "Download patch on server ..."
    /home/applmgr/Neil_scripts/auto_patch/jdk1.7.0_301/jre/bin/java -jar /home/applmgr/Neil_scripts/auto_patch/getMOSPatch.jar patch=$PATCH_ID  platform=226P,3L MOSUser=$MAILTO MOSPass=$MOSPass
}

# Start prepare phase
#function prep_phase {
#    echo "Start prepare phase"
#     { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=prepare  || { echo "Prepare phase has failed. Please check the logs!!" | mailx -s "Online patching status in $TWO_TASK" $MAILTO ; exit 1; }
#}

function prep_phase {
    LOGFILE=/home/applmgr/Neil_scripts/auto_patch/prep_phase_`date +"%Y%m%d%H%M"`.log
    echo "Start prepare phase ..." >> $LOGFILE
    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=prepare
    errcode=$?
    if [ $errcode -ne 0 ]
    then
      echo "" >> $LOGFILE
      echo "$now" >> $LOGFILE
      echo "  $0 ERROR $errcode: Executing prepare phase on $TWO_TASK" >> $LOGFILE
      echo "" >> $LOGFILE
      echo "$0 exiting...." >> $LOGFILE
      cat $LOGFILE |mailx -s "Prepare phase FAILED on `hostname`" $MAILTO
      exit $errcode
fi
    echo "" >> $LOGFILE
    echo "$now" >> $LOGFILE
    echo "Execution of prepare phase successful on $TWO_TASK" >> $LOGFILE
    echo "" >> $LOGFILE
    echo "$0 exiting...." >> $LOGFILE
    cat $LOGFILE |mailx -s "Prepare phase SUCCESSFUL on `hostname`" $MAILTO

}


# Start apply phase
#function apply_phase {
#    echo "Start apply phase ..."
#    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=apply patches=$PATCH_ID  || { echo "Apply phase has failed"; exit 1; }
#}

#now=`date`
#LOGFILE=/home/applmgr/Neil_scripts/auto_patch/apply_phase_`date +"%Y%m%d%H%M"`.log
function apply_phase {
    LOGFILE=/home/applmgr/Neil_scripts/auto_patch/apply_phase_`date +"%Y%m%d%H%M"`.log
    echo "Start apply phase ..." >> $LOGFILE
    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=apply patches=$PATCH_ID
    errcode=$?
    if [ $errcode -ne 0 ]
    then
      echo "" >> $LOGFILE
      echo "$now" >> $LOGFILE
      echo "  $0 ERROR $errcode: Executing patch apply phase on $TWO_TASK" >> $LOGFILE
      echo "" >> $LOGFILE
      echo "$0 exiting...." >> $LOGFILE
      cat $LOGFILE |mailx -s "Patch $PATCH_ID apply FAILED on `hostname`" $MAILTO
      exit $errcode
fi
    echo "" >> $LOGFILE
    echo "$now" >> $LOGFILE
    echo "Execution of patch apply phase successful on $TWO_TASK" >> $LOGFILE
    echo "" >> $LOGFILE
    echo "$0 exiting...." >> $LOGFILE
    cat $LOGFILE |mailx -s "Patch $PATCH_ID apply SUCCESSFUL on `hostname`" $MAILTO

}


# Start NLS apply phase
#function NLS_apply_phase {
#    echo "Start NLS apply phase ..."
#    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=apply patches=${PATCH_ID}_FRC:u${PATCH_ID}.drv  || { echo "NLS Apply phase has failed"; exit 1; }
#}

#now=`date`
#LOGFILE=/home/applmgr/Neil_scripts/auto_patch/NLS_apply_phase_`date +"%Y%m%d%H%M"`.log
function NLS_apply_phase {
    LOGFILE=/home/applmgr/Neil_scripts/auto_patch/NLS_apply_phase_`date +"%Y%m%d%H%M"`.log
    echo "Start NLS apply phase ..." >> $LOGFILE
    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=apply patches=${PATCH_ID}_FRC:u${PATCH_ID}.drv
    errcode=$?
    if [ $errcode -ne 0 ]
    then
      echo "" >> $LOGFILE
      echo "$now" >> $LOGFILE
      echo "  $0 ERROR $errcode: Executing NLS patch apply phase on $TWO_TASK" >> $LOGFILE
      echo "" >> $LOGFILE
      echo "$0 exiting...." >> $LOGFILE
      cat $LOGFILE |mailx -s "NLS patch apply FAILED on `hostname`" $MAILTO
      exit $errcode
fi
    echo "" >> $LOGFILE
    echo "$now" >> $LOGFILE
    echo "Execution of NLS patch apply phase successful on $TWO_TASK" >> $LOGFILE
    echo "" >> $LOGFILE
    echo "$0 exiting...." >> $LOGFILE
    cat $LOGFILE |mailx -s "NLS patch apply phase SUCCESSFUL on `hostname`" $MAILTO

}


# Start Finalize, Cutover, Cleanup phase
#function cutover_phase {
#    echo "Start cutover phase ..."
#    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=finalize,cutover,cleanup  || { echo "Finalize/Cutover/Cleanup phase has failed"; exit 1; }
#}

#now=`date`
#LOGFILE=/home/applmgr/Neil_scripts/auto_patch/cutover_phase_`date +"%Y%m%d%H%M"`.log
function cutover_phase {
    LOGFILE=/home/applmgr/Neil_scripts/auto_patch/cutover_phase_`date +"%Y%m%d%H%M"`.log
    echo "Start cutover_phase phase ..." >> $LOGFILE
    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=finalize,cutover,cleanup
    errcode=$?
    if [ $errcode -ne 0 ]
    then
      echo "" >> $LOGFILE
      echo "$now" >> $LOGFILE
      echo "  $0 ERROR $errcode: Executing cutover phase on $TWO_TASK" >> $LOGFILE
      echo "" >> $LOGFILE
      echo "$0 exiting...." >> $LOGFILE
      cat $LOGFILE |mailx -s "Cutover phase FAILED on `hostname`" $MAILTO
      exit $errcode
fi
    echo "" >> $LOGFILE
    echo "$now" >> $LOGFILE
    echo "Execution of cutover phase successful on $TWO_TASK" >> $LOGFILE
    echo "" >> $LOGFILE
    echo "$0 exiting...." >> $LOGFILE
    cat $LOGFILE |mailx -s "Cutover phase SUCCESSFUL on `hostname`" $MAILTO

}



# Start full phase
#function full_phase {
#    echo "Start full phase ..."
#    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=prepare,finalize,cutover,cleanup  || { echo "Full phase has failed"; exit 1; }
#}

#now=`date`
#LOGFILE=/home/applmgr/Neil_scripts/auto_patch/full_phase_`date +"%Y%m%d%H%M"`.log
function full_phase {
    LOGFILE=/home/applmgr/Neil_scripts/auto_patch/full_phase_`date +"%Y%m%d%H%M"`.log
    echo "Start full_phase phase ..." >> $LOGFILE
    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=prepare,finalize,cutover,cleanup
    errcode=$?
    if [ $errcode -ne 0 ]
    then
      echo "" >> $LOGFILE
      echo "$now" >> $LOGFILE
      echo "  $0 ERROR $errcode: Executing Full phase on $TWO_TASK" >> $LOGFILE
      echo "" >> $LOGFILE
      echo "$0 exiting...." >> $LOGFILE
      cat $LOGFILE |mailx -s "Full phase FAILED on `hostname`" $MAILTO
      exit $errcode
fi
    echo "" >> $LOGFILE
    echo "$now" >> $LOGFILE
    echo "Execution of Full phase successful on $TWO_TASK" >> $LOGFILE
    echo "" >> $LOGFILE
    echo "$0 exiting...." >> $LOGFILE
    cat $LOGFILE |mailx -s "Full phase SUCCESSFUL on `hostname`" $MAILTO

}


# Start fs_clone phase
#function fs_clone {
#    echo "Start fs_clone phase ..."
#    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=fs_clone  || { echo "Fs_clone phase has failed"; exit 1; }
#}

#now=`date`
#LOGFILE=/home/applmgr/Neil_scripts/auto_patch/fs_clone_`date +"%Y%m%d%H%M"`.log
function fs_clone {
    LOGFILE=/home/applmgr/Neil_scripts/auto_patch/fs_clone_`date +"%Y%m%d%H%M"`.log
    echo "Start fs_clone phase ..." >> $LOGFILE
    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=fs_clone
    errcode=$?
    if [ $errcode -ne 0 ]
    then
      echo "" >> $LOGFILE
      echo "$now" >> $LOGFILE
      echo "  $0 ERROR $errcode: Executing fs_clone on $TWO_TASK" >> $LOGFILE
      echo "" >> $LOGFILE
      echo "$0 exiting...." >> $LOGFILE
      cat $LOGFILE |mailx -s "FS_CLONE FAILED on `hostname`" $MAILTO
      exit $errcode
fi
    echo "" >> $LOGFILE
    echo "$now" >> $LOGFILE
    echo "Execution of fs_clone successful on $TWO_TASK" >> $LOGFILE
    echo "" >> $LOGFILE
    echo "$0 exiting...." >> $LOGFILE
    cat $LOGFILE |mailx -s "FS_CLONE SUCCESSFUL on `hostname`" $MAILTO

}


function fs_clone_force {
    LOGFILE=/home/applmgr/Neil_scripts/auto_patch/fs_clone_force_`date +"%Y%m%d%H%M"`.log
    echo "Start fs_clone phase ..." >> $LOGFILE
    { echo $APPS_PWD ; echo $SYSTEM_PWD; echo $WEBLOGIC_PWD ; } | adop phase=fs_clone force=yes
    errcode=$?
    if [ $errcode -ne 0 ]
    then
      echo "" >> $LOGFILE
      echo "$now" >> $LOGFILE
      echo "  $0 ERROR $errcode: Executing fs_clone on $TWO_TASK" >> $LOGFILE
      echo "" >> $LOGFILE
      echo "$0 exiting...." >> $LOGFILE
      cat $LOGFILE |mailx -s "FS_CLONE FAILED on `hostname`" $MAILTO
      exit $errcode
fi
    echo "" >> $LOGFILE
    echo "$now" >> $LOGFILE
    echo "Execution of fs_clone successful on $TWO_TASK" >> $LOGFILE
    echo "" >> $LOGFILE
    echo "$0 exiting...." >> $LOGFILE
    cat $LOGFILE |mailx -s "FS_CLONE SUCCESSFUL on `hostname`" $MAILTO

}

# Start adop_status phase

#now=`date`
#LOGFILE=/home/applmgr/Neil_scripts/auto_patch/adop_status_`date +"%Y%m%d%H%M"`.log
function adop_status {
    LOGFILE=/home/applmgr/Neil_scripts/auto_patch/adop_status_`date +"%Y%m%d%H%M"`.log
    echo "Start adop_status phase ..." >> $LOGFILE
    { echo $APPS_PWD ; } | adop -status -details
    errcode=$?
    if [ $errcode -ne 0 ]
    then
      echo "" >> $LOGFILE
      echo "$now" >> $LOGFILE
      echo "  $0 ERROR $errcode: Executing adop_status on $TWO_TASK" >> $LOGFILE
      echo "" >> $LOGFILE
      echo "$0 exiting...." >> $LOGFILE
      cat $LOGFILE |mailx -s "Adop Status FAILED on `hostname`" $MAILTO
      exit $errcode
fi
    echo "" >> $LOGFILE
    echo "$now" >> $LOGFILE
    echo "Execution of adop_status successful on $TWO_TASK" >> $LOGFILE
    echo "" >> $LOGFILE
    echo "$0 exiting...." >> $LOGFILE
    cat $LOGFILE |mailx -s "Adop Status SUCCESSFUL on `hostname`" $MAILTO

}


##########################
#      Main              #
##########################
. /ebs/EBS/R122/EBSapps.env run
## where EBS APPS_BASE = /ebs/EBS/R122

PATCH_TOP_DIR=/home/applmgr/Neil_scripts/auto_patch
PATCH_ID=$2
APPS_PWD=<apps_password>
SYSTEM_PWD=<system_password>
WEBLOGIC_PWD=<weblogic_password>
MAILTO="username@domain"
MOSPass=<MOSPassword>
now=`date`

case "$1" in
'prep_phase')
   prep_phase
;;
'download_patch')
   download_patch
;;
'apply_phase')
   apply_phase
;;
'check_patch_applied')
   check_patch_applied
;;
'full_phase')
   full_phase
;;
'NLS_apply_phase')
   NLS_apply_phase
;;
'cutover_phase')
   cutover_phase
;;
'fs_clone')
   fs_clone
;;
'adop_status')
   adop_status
;;
'fs_clone_force')
   fs_clone_force
;;
*)
   echo "Usage: sh ebs_apps_patch.sh [download_patch|prep_phase|check_patch_applied|apply_phase|NLS_apply_phase|cutover_phase|full_phase|download_patch|fs_clone|fs_clone_force|adop_status] [patch number]"
esac

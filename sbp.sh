#!/bin/bash
umask 027
##=======================================================================================================================================================================
##---Begin of Input Parameters---------#
##=======================================================================================================================================================================
trap "exit 1" TERM
export TOP_PID=$$
# if 10 parameter, call the script with root user, if 9, call with <hanasid>adm. need to call this script twice
if [ "$#" -eq 7 ]; then 
        DB_SID=${1}
        patchtype=${2} #oracle or grid
        oraversion=${3} #10,11,12,18,19,23
        orabasepath=${4} #/oracle/BASE
        orapatchmediapath=${5}
        scriptdir="${6}"
        orapatch=${7} #1919, 1922, 1923, 1926, 1927

else
        echo "Parameter missing"
        exit
fi

DB_SID=$(echo "${DB_SID}" | tr '[:lower:]' '[:upper:]')

        if [ "$oraversion" == "19" ];then
            if [ "$orapatch" == "1919" ];then
                ihrdbmspath="/oracle/$DB_SID/19.0.0"
                ohrdbmspath="/oracle/$DB_SID/19"
                orahomepath="/oracle/GRID/19.0.0"
                oragridhomepath="/oracle/GRID/19.0.0"
                opatchprepname="OPatch-pre-SBP_191900230418_202305"
                opatchmediafile="OPATCH19P_2305-70004508.ZIP"
                gridmediapatchfile="OPATCH19P_2305-70004550.ZIP"
                sapbundleprepname="SBP_191900230418_202305"
                sapbundlemediafile="SAP19P_2305-70004508.ZIP"
                mopatchprepname="MOPatch-pre-SBP_191900230418_202305"
                gridpatchmediafile="SGR19P_2305-70004550.ZIP"
            elif [ "$orapatch" == "1922" ];then
                ihrdbmspath="/oracle/$DB_SID/19.0.0"
                ohrdbmspath="/oracle/$DB_SID/19"
                orahomepath="/oracle/GRID/19.0.0"
                oragridhomepath="/oracle/GRID/19.0.0"
                opatchprepname="OPatch-pre-SBP_192200240116_202402"
                opatchmediafile="OPATCH19P_2402-70004508.ZIP"
                gridmediapatchfile="OPATCH19P_2402-70004550.ZIP"
                sapbundleprepname="SBP_192200240116_202402"
                sapbundlemediafile="SAP19P_2402-70004508.ZIP"
                mopatchprepname="MOPatch-pre-SBP_192200240116_202402"
                gridpatchmediafile="SGR19P_2402-70004550.ZIP"
           elif [ "$orapatch" == "1923" ];then
                ihrdbmspath="/oracle/$DB_SID/19.0.0"
                ohrdbmspath="/oracle/$DB_SID/19"
                orahomepath="/oracle/GRID/19.0.0"
                oragridhomepath="/oracle/GRID/19.0.0"
                opatchprepname="OPatch-pre-SBP_192300240416_202405"
                opatchmediafile="OPATCH19P_2405-70004508.ZIP"
                gridmediapatchfile="OPATCH19P_2405-70004550.ZIP"
                sapbundleprepname="SBP_192300240416_202405"
                sapbundlemediafile="SAP19P_2405-70004508.ZIP"
                mopatchprepname="MOPatch-pre-SBP_192300240416_202405"
                gridpatchmediafile="SGR19P_2405-70004550.ZIP"
           elif [ "$orapatch" == "1926" ];then
                ihrdbmspath="/oracle/$DB_SID/19.0.0"
                ohrdbmspath="/oracle/$DB_SID/19"
                orahomepath="/oracle/GRID/19.0.0"
                oragridhomepath="/oracle/GRID/19.0.0"
                opatchprepname="OPatch-pre-SBP_192600250121_202502"
                opatchmediafile="OPATCH19P_2502-70004508.ZIP"
                gridmediapatchfile="OPATCH19P_2502-70004550.ZIP"
                sapbundleprepname="SBP_192600250121_202502"
                sapbundlemediafile="SAP19P_2502-70004508.ZIP"
                mopatchprepname="MOPatch-pre-SBP_192600250121_202502"
                gridpatchmediafile="SGR19P_2502-70004550.ZIP"
           elif [ "$orapatch" == "1927" ];then
                ihrdbmspath="/oracle/$DB_SID/19.0.0"
                ohrdbmspath="/oracle/$DB_SID/19"
                orahomepath="/oracle/GRID/19.0.0"
                oragridhomepath="/oracle/GRID/19.0.0"
                opatchprepname="OPatch-pre-SBP_192700250415_202505"
                opatchmediafile="OPATCH19P_2505-70004508.ZIP"
                gridmediapatchfile="OPATCH19P_2505-70004550.ZIP"
                sapbundleprepname="SBP_192700250415_202505"
                sapbundlemediafile="SAP19V2P_2505-70004508.ZIP"
                mopatchprepname="MOPatch-pre-SBP_192700250415_202505"
                gridpatchmediafile="SGR19V2P_2505-70004550.ZIP"
            fi

        else
                echo "The Selected Oracle Version $oraversion is not Valid"
        fi

hostname=$(hostname)
patchtype=$(echo "${patchtype}" | tr '[:lower:]' '[:upper:]')
dbowner=$(echo "${dbowner}" | tr '[:upper:]' '[:lower:]')
IHRDBMS="$ihrdbmspath"
OHRDBMS="$ohrdbmspath"
ORACLE_SID=$DB_SID
SBPFUSER=/sbin/fuser
ORACLE_BASE="$orabasepath"
ORACLE_HOME="$orahomepath"
OHGRID="$oragridhomepath"
script_dir=$scriptdir/$DB_SID/$hostname/oraclepatch
##=======================================================================================================================================================================
## --- Function for writing the log -------#
##=======================================================================================================================================================================

log()
{
  echo "${functionCode}:${returnMessage}" >> "${script_dir}/oraclepatch"
}


##=======================================================================================================================================================================
##--- Function for printing the result
##=======================================================================================================================================================================

printresult()
{
  echo  "+-----------------------------------------------------------------------------+"
  echo "| Date/Time : $(date)" | awk '{print $0 substr("                                                                    ",1,78-length($0)) "|"}'
  echo  " ${functionName} - ${returnMessage} "
  echo  "+-----------------------------------------------------------------------------+"
}

##=======================================================================================================================================================================
#--- Create the script directory if it doesn't exists, if exists delete the script directory and recreates it
##=======================================================================================================================================================================

initialize_script_dir()
{
         functionName="Initializing Script Directory"
        functionCode="INIT_SCRIPT_DIRECTORY"
        if [ ! -d "${script_dir}" ]; then
                echo "${script_dir} does not exist"
                echo "creating ${script_dir}"
                if mkdir -p "${script_dir}" ; then
                        chmod 777 "$scriptdir"
                        chmod 777 "$scriptdir"/"$DB_SID"
                        chmod 777 "$scriptdir"/"$DB_SID"/"$hostname"
                        chown -R oracle:oinstall "$scriptdir"/"$DB_SID"/"$hostname"
                        returnMessage="Success"
                        printresult functionName returnMessage
                else
                        returnMessage="Failed"
                        printresult functionName returnMessage
                        kill -s TERM $TOP_PID
               fi
        fi
}

#============================================================================================================================================
#---- Set Environment Variable
#=============================================================================================================================================

set_ora_env()
{
        functionName="Set Oracle Environment Variable"
        functionCode="DET_ORACLE_ENVIRONMENT"


         if [ "${patchtype}" == "ORACLE" ]; then
                export IHRDBMS="$ihrdbmspath"
                export OHRDBMS="$ohrdbmspath"
                export ORACLE_SID=$DB_SID
                export SBPFUSER=/sbin/fuser
        elif [ "${patchtype}" == "GRID" ]; then
                export ORACLE_BASE="$orabasepath"
                export ORACLE_HOME="$orahomepath"
                export OHGRID="$oragridhomepath"
        fi
        
}

##=======================================================================================================================================================================
#--- Prepare for Patch upgrade
##=======================================================================================================================================================================

oracle_patch_prep()
{
    functionName="Oracle Patch upgrade Preparation "
    functionCode="ORACLE_PATCH_PREPARATION"

   mv "$IHRDBMS"/OPatch "$IHRDBMS"/"$opatchprepname"
            # shellcheck disable=SC2181
            if [ $? == 0 ]; then
            echo "mv $IHRDBMS/OPatch $IHRDBMS/$opatchprepname done"
            else
            echo "mv $IHRDBMS/OPatch $IHRDBMS/$opatchprepname, exiting"
            returnMessage="Failed"
            printresult functionName returnMessage 
            log functionCode returnMessage
            kill -s TERM $TOP_PID
            fi
    unzip -qd "$IHRDBMS" "$orapatchmediapath"/"$opatchmediafile" -x SIGNATURE.SMF
            # shellcheck disable=SC2181
            if [ $? == 0 ]; then
            echo "unzip -qd $IHRDBMS $orapatchmediapath/$opatchmediafile -x SIGNATURE.SMF done"
            else
            echo "unzip -qd $IHRDBMS $orapatchmediapath/$opatchmediafile -x SIGNATURE.SMF, exiting"
            returnMessage="Failed"
            printresult functionName returnMessage 
            log functionCode returnMessage
            kill -s TERM $TOP_PID
           fi

    unzip -qd "$IHRDBMS"/sapbundle "$orapatchmediapath"/"$sapbundlemediafile" "$sapbundleprepname"/MOPatch/*
            # shellcheck disable=SC2181
            if [ $? == 0 ]; then
            echo "unzip -qd $IHRDBMS/sapbundle $orapatchmediapath/$sapbundlemediafile $sapbundleprepname/MOPatch/* done"
            else
            echo "unzip -qd $IHRDBMS/sapbundle $orapatchmediapath/$sapbundlemediafile $sapbundleprepname/MOPatch/*, exiting"
            returnMessage="Failed"
            printresult functionName returnMessage 
            log functionCode returnMessage
            kill -s TERM $TOP_PID
            fi
     test -d "$IHRDBMS"/MOPatch && mv "$IHRDBMS"/MOPatch "$IHRDBMS"/"$mopatchprepname"
     $SBPFUSER "$IHRDBMS"/bin/oracle
     mv "$IHRDBMS"/sapbundle/"$sapbundleprepname"/MOPatch "$IHRDBMS"/MOPatch
            # shellcheck disable=SC2181
            if [ $? == 0 ]; then
            echo "mv $IHRDBMS/sapbundle/$sapbundleprepname/MOPatch $IHRDBMS/MOPatch done"
            returnMessage="Success"
            printresult functionName returnMessage 
            log functionCode returnMessage
            else
            echo "mv $IHRDBMS/sapbundle/$sapbundleprepname/MOPatch $IHRDBMS/MOPatch, exiting"
            returnMessage="Failed"
            printresult functionName returnMessage 
            log functionCode returnMessage
            kill -s TERM $TOP_PID
            fi
}

##=======================================================================================================================================================================
#--- Prepare for GRID upgrade
##=======================================================================================================================================================================

grid_patch_prep()
{
    functionName="GRID Patch upgrade Preparation "
    functionCode="GRID_PATCH_PREPARATION"

   chown oracle:oinstall /oracle/GRID/19.0.0/bin/oradism
   chmod 0750 /oracle/GRID/19.0.0/bin/oradism
   mv "$OHGRID"/OPatch "$OHGRID"/"$opatchprepname"
            # shellcheck disable=SC2181
            if [ $? == 0 ]; then
            echo "mv $OHGRID/OPatch $OHGRID/$opatchprepname done"
            else
            echo "mv $OHGRID/OPatch $OHGRID/$opatchprepname, exiting"
            returnMessage="Failed"
            printresult functionName returnMessage 
            log functionCode returnMessage
            kill -s TERM $TOP_PID
            fi
    unzip -qd "$OHGRID" "$orapatchmediapath"/"$gridmediapatchfile" -x SIGNATURE.SMF
            # shellcheck disable=SC2181
            if [ $? == 0 ]; then
            echo "unzip -qd $OHGRID $orapatchmediapath/$gridmediapatchfile -x SIGNATURE.SMF done"
            else
            echo "unzip -qd $OHGRID $orapatchmediapath/$gridmediapatchfile -x SIGNATURE.SMF"
            returnMessage="Failed"
            printresult functionName returnMessage 
            log functionCode returnMessage
            kill -s TERM $TOP_PID
            fi
    unzip -qd "$OHGRID"/sapbundle "$orapatchmediapath"/"$gridpatchmediafile" "$sapbundleprepname"/MOPatch/*
            # shellcheck disable=SC2181
            if [ $? == 0 ]; then
            echo "unzip -qd $OHGRID/sapbundle $orapatchmediapath/$gridpatchmediafile '$sapbundleprepname/MOPatch/*' done"
            else
            echo "unzip -qd $OHGRID/sapbundle $orapatchmediapath/$gridpatchmediafile '$sapbundleprepname/MOPatch/*', exiting"
            returnMessage="Failed"
            printresult functionName returnMessage 
            log functionCode returnMessage
            kill -s TERM $TOP_PID
            fi
    test -d "$OHGRID"/MOPatch && mv "$OHGRID"/MOPatch "$OHGRID"/"$mopatchprepname"

    mv "$OHGRID"/sapbundle/"$sapbundleprepname"/MOPatch "$OHGRID"/MOPatch
            # shellcheck disable=SC2181
            if [ $? == 0 ]; then
            echo "mv $OHGRID/sapbundle/$sapbundleprepname/MOPatch $OHGRID/MOPatch done"
            returnMessage="Success"
            printresult functionName returnMessage 
            log functionCode returnMessage
            else
            echo "mv $OHGRID/sapbundle/$sapbundleprepname/MOPatch $OHGRID/MOPatch, exiting"
            returnMessage="Failed"
            printresult functionName returnMessage 
            log functionCode returnMessage
            kill -s TERM $TOP_PID
            fi

}

##=======================================================================================================================================================================
#--- Oracle Patch upgrade
##=======================================================================================================================================================================

oracle_Patch_upgrade_schedule()
{
    functionName="Oracle Patch Upgrade"
    functionCode="ORACLE_PATCH_UPGRADE"

    LOGFILE="${script_dir}/sbppatch.log"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)

    # Backup existing log if present
    if [ -f "$LOGFILE" ]; then
        mv "$LOGFILE" "${LOGFILE%.log}_$TIMESTAMP.log"
        echo -ne "\n [INFO] Previous SBP log moved to ${LOGFILE%.log}_$TIMESTAMP.log \n"
    fi

    echo -ne "\n [INFO] Scheduling Oracle SBP Patch for DB $DB_SID... \n"
    
    # Schedule patch (non-blocking)
    nohup env ORACLE_HOME="$IHRDBMS" "$IHRDBMS"/MOPatch/mopatch.sh -v -s "$orapatchmediapath"/"$sapbundlemediafile" > "${script_dir}"/sbppatch.log 2>&1 &
    
    if [ $? -eq 0 ]; then
        echo -ne "\n Oracle SBP Patch scheduled successfully for DB $DB_SID \n"
        echo -ne "\n Please monitor log file: ${script_dir}/sbppatch.log \n"
        returnMessage="Scheduled - Monitor Logs"
        printresult functionName returnMessage
        log functionCode returnMessage
    else
        echo -ne "\n Failed to schedule Oracle SBP Patch for DB $DB_SID \n"
        returnMessage="Scheduling Failed"
        printresult functionName returnMessage
        log functionCode returnMessage
        kill -s TERM $TOP_PID
    fi
}

##=======================================================================================================================================================================
#--- Oracle Patch upgrade 
##=======================================================================================================================================================================

oracle_grid_upgrade_schedule()
{
    functionName="Oracle Grid Upgrade"
    functionCode="ORACLE_GRID_UPGRADE"

    LOGFILE="${script_dir}/gridpatch.log"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)

    # Backup existing log if present
    if [ -f "$LOGFILE" ]; then
        mv "$LOGFILE" "${LOGFILE%.log}_$TIMESTAMP.log"
        echo -ne "\n [INFO] Previous GRID log moved to ${LOGFILE%.log}_$TIMESTAMP.log \n"
    fi

    echo -ne "\n [INFO] Scheduling Oracle Grid Patch for DB $DB_SID... \n"
    
    # Schedule patch (non-blocking)
    nohup env ORACLE_HOME="$OHGRID" "$OHGRID"/MOPatch/mopatch.sh -v -s "$orapatchmediapath"/"$gridpatchmediafile" > "${script_dir}"/gridpatch.log 2>&1 &
    
    if [ $? -eq 0 ]; then
        echo -ne "\n Oracle GRID Patch scheduled successfully for DB $DB_SID \n"
        echo -ne "\n Please monitor log file: ${script_dir}/gridpatch.log \n"
        returnMessage="Scheduled - Monitor Logs"
        printresult functionName returnMessage
        log functionCode returnMessage
    else
        echo -ne "\n Failed to schedule Oracle GRID Patch for DB $DB_SID \n"
        returnMessage="Scheduling Failed"
        printresult functionName returnMessage
        log functionCode returnMessage
        kill -s TERM $TOP_PID
    fi
}

oracle_patch_status() {
    LOGFILE="${script_dir}/sbppatch.log"
    functionName="Oracle Patch Status"
    functionCode="ORACLE_PATCH_MONITOR"

    process="$sapbundlemediafile"
    echo -ne "\n [INFO] Monitoring Oracle SBP Patch log for DB $DB_SID... \n"

    # Initial process count check
    count=$(ps -aef | grep "$process" | grep -v grep | wc -l)

    while [[ $count -gt 0 ]]; do
        if grep "Overall Status: COMPLETE" "$LOGFILE" > /dev/null 2>&1; then
            cat "$LOGFILE"
            echo -ne "\n ✅ Oracle SBP Patch Completed Successfully for DB $DB_SID \n"
            returnMessage="Finishedsuccess"
            printresult "$functionName" "$returnMessage"
            log "$functionCode" "$returnMessage"
            return 0

        elif grep "Overall Status: INCOMPLETE" "$LOGFILE" > /dev/null 2>&1; then
            cat "$LOGFILE"
            echo -ne "\n ❌ Oracle SBP Patch Failed for DB $DB_SID \n"
            returnMessage="Failed"
            printresult "$functionName" "$returnMessage"
            log "$functionCode" "$returnMessage"
            kill -s TERM $TOP_PID

        else
            echo -ne "Oracle GRID upgrade is in Progress"
            tail -20 "$LOGFILE"
            returnMessage="InProgress"
            printresult "$functionName" "$returnMessage"
            log "$functionCode" "$returnMessage"
            sleep 120
        fi

        # Refresh process count after sleep
        count=$(ps -aef | grep "$process" | grep -v grep | wc -l)
    done

    # Once out of loop, process is not running — final check
    if grep "Overall Status: COMPLETE" "$LOGFILE" > /dev/null 2>&1; then
        echo -ne "\n ✅ Oracle SBP Patch Completed Successfully for DB $DB_SID \n"
		cat "$LOGFILE"
        returnMessage="Finishedsuccess"
		printresult "$functionName" "$returnMessage"
		log "$functionCode" "$returnMessage"
    elif grep "Overall Status: INCOMPLETE" "$LOGFILE" > /dev/null 2>&1; then
        echo -ne "\n ❌ Oracle SBP Patch Failed for DB $DB_SID \n"
		cat "$LOGFILE"
        returnMessage="Failed"
		printresult "$functionName" "$returnMessage"
		log "$functionCode" "$returnMessage"
		kill -s TERM $TOP_PID
    else
        echo -ne "\n ❌ Oracle SBP Patch process not running and patch status is unknown \n"
		cat "$LOGFILE"
        returnMessage="Failed"
		printresult "$functionName" "$returnMessage"
		log "$functionCode" "$returnMessage"
		kill -s TERM $TOP_PID
    fi
}

grid_patch_status() {
   LOGFILE="${script_dir}/gridpatch.log"
    functionName="Oracle Grid Patch Status"
    functionCode="GRID_PATCH_MONITOR"

    process="$gridpatchmediafile"
    echo -ne "\n [INFO] Monitoring Oracle GRID Patch log for DB $DB_SID... \n"

    # Initial process count check
    count=$(ps -aef | grep "$process" | grep -v grep | wc -l)

    while [[ $count -gt 0 ]]; do
        if grep "Overall Status: COMPLETE" "$LOGFILE" > /dev/null 2>&1; then
            cat "$LOGFILE"
            echo -ne "\n ✅ Oracle GRID Patch Completed Successfully for DB $DB_SID \n"
            returnMessage="Finishedsuccess"
            printresult "$functionName" "$returnMessage"
            log "$functionCode" "$returnMessage"
            return 0

        elif grep "Overall Status: INCOMPLETE" "$LOGFILE" > /dev/null 2>&1; then
            cat "$LOGFILE"
            cat "\n ❌ Oracle GRID Patch Failed for DB $DB_SID \n"
            returnMessage="Failed"
            printresult "$functionName" "$returnMessage"
            log "$functionCode" "$returnMessage"
            kill -s TERM $TOP_PID

        else
            echo -ne "Oracle GRID upgrade is in Progress"
            tail -20 "$LOGFILE"
            returnMessage="InProgress"
            printresult "$functionName" "$returnMessage"
            log "$functionCode" "$returnMessage"
            sleep 120
        fi

        # Refresh process count after sleep
        count=$(ps -aef | grep "$process" | grep -v grep | wc -l)
    done

    # Once out of loop, process is not running — final check
    if grep "Overall Status: COMPLETE" "$LOGFILE" > /dev/null 2>&1; then
        echo -ne "\n ✅ Oracle GRID Patch Completed Successfully for DB $DB_SID \n"
		cat "$LOGFILE"
        returnMessage="Finishedsuccess"
		printresult "$functionName" "$returnMessage"
		log "$functionCode" "$returnMessage"
    elif grep "Overall Status: INCOMPLETE" "$LOGFILE" > /dev/null 2>&1; then
        echo -ne "\n ❌ Oracle GRID Patch Failed for DB $DB_SID \n"
		cat "$LOGFILE"
        returnMessage="Failed"
		printresult "$functionName" "$returnMessage"
		log "$functionCode" "$returnMessage"
		kill -s TERM $TOP_PID
    else
        echo -ne "\n ❌ Oracle GRID Patch process not running and patch status is unknown \n"
		cat "$LOGFILE"
        returnMessage="Failed"
		printresult "$functionName" "$returnMessage"
		log "$functionCode" "$returnMessage"
		kill -s TERM $TOP_PID
    fi
}

##=======================================================================================================================================================================
#--- It call all the function one by one
##=======================================================================================================================================================================

                initialize_script_dir
                set_ora_env
                if [ "${patchtype}" == "ORACLE" ]; then
                        oracle_patch_prep
                        oracle_Patch_upgrade_schedule
                        oracle_patch_status
                elif [ "${patchtype}" == "GRID" ]; then
                        grid_patch_prep
                        oracle_grid_upgrade_schedule
                        grid_patch_status
                fi
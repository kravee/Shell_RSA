#!/bin/ksh
# Written By   : Evgeniy Kravets
# Written On   : 30 Aug 2018
# EMAIL        : evgeniy [DOT] kravets [AT] rsa [DOT] com
# Description  : The script extract the installed patches from the UAT AAH env
#              : 
# Updated On   :
#              :
#              :

. $CYPE_HOME/runtime/gen/config/setenv_from_profile.ksh
set_app_regions
set_env_from_profile

ALL_PATCHES="/tmp/all_patches_$$"
if [[ ! -f $ALL_PATCHES ]]; then
   touch $ALL_PATCHES
else
   \rm $ALL_PATCHES
   touch $ALL_PATCHES
fi

TEMP_FILE="/tmp/full_all_patches_$$"
if [[ ! -f $TEMP_FILE ]]; then
   touch $TEMP_FILE
else
   \rm $TEMP_FILE
   touch $TEMP_FILE
fi

#####OUTPUT_RESULT="/tmp/output_result_$$"
#####if [[ ! -f $OUTPUT_RESULT ]]; then
#####   touch $OUTPUT_RESULT
#####else
#####   \rm $OUTPUT_RESULT
#####   touch $OUTPUT_RESULT
#####fi
#####

echo "The script connects to all servers to accumulating the data, it can take a couple min"

for CHECK_HOST in ${ALL_HOSTS}
do
        if [[ `hostname` != ${CHECK_HOST} ]]; then
                PATCHES=`ssh cyftp@${CHECK_HOST} /cype_home/support/evg/check_patches.sh`
        else 
                PATCHES=`/cype_home/support/evg/check_patches.sh`
        fi
        for i in $PATCHES
        do
                echo "${CHECK_HOST}|${i}" >> ${ALL_PATCHES}
        done
done
cat ${ALL_PATCHES} | awk -F'|' '{print $2}' | sort | uniq >> ${TEMP_FILE}
patch_number=1
echo "PATCH# ${ALL_HOSTS}" ####>> $OUTPUT_RESULT
while [ $patch_number -le 500 ]
do
  current_patch=`cut -d- -f1 ${TEMP_FILE} | grep _${patch_number}_ | head -1`
  if [[ -n ${current_patch} ]]
  then
                PACH_CHECK="${current_patch}"
                for CHECK_HOST in ${ALL_HOSTS}
                do
                        PACH_PRESENTED=`cat ${ALL_PATCHES} | grep ${CHECK_HOST} | grep ${current_patch}`
                        if [[ -n ${PACH_PRESENTED} ]]; then
                                CHECK_RESULT="OK"
                        else
                                CHECK_RESULT="NONE"
                        fi
                        PACH_CHECK=`echo "$PACH_CHECK ${CHECK_RESULT}"`
                done
                echo "${PACH_CHECK}" ####>> $OUTPUT_RESULT
  fi
  current_patch=""
  patch_number=`expr $patch_number + 1`
done

rm $TEMP_FILE $ALL_PATCHES

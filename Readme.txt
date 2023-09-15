Below is sequence of steps to download and apply EBS patch through this tool.

Step 1: Check ADOP Status to confirm if there is any running patch cycle
•	sh ebs_apps_patch.sh adop_status

Step 2: Start a prepare phase
•	sh ebs_apps_patch.sh prep_phase

Step 3. Download patches & copy patches to $PATCH_TOP
•	sh ebs_apps_patch.sh download_patch <PATCH_ID>
(After download, copy the patches to $PATCH_TOP manually and make sure to unzip them prior to apply phase)

Step 4. Apply phase
•	sh ebs_apps_patch.sh apply_phase [patch number]
•	sh ebs_apps_patch.sh NLS_apply_phase [patch number]

(In case of NLS languages other than American English,you need to download and apply both American english and the NLS language patches)

Step 5: Check patch applied
•	sh ebs_apps_patch.sh check_patch_applied [patch number]

Step 6: Finalize, cutover & cleanup(combined into one single step)
•	sh ebs_apps_patch.sh cutover_phase

Step 7: Finally, run fs_clone to sync run and patch file systems
•	sh ebs_apps_patch.sh fs_clone

Step 8: Check ADOP Status 
•	sh ebs_apps_patch.sh adop_status

At times, there is a requirement to run an empty patch cycle to check if cutover is working. For that, you can run below command
•	sh ebs_apps_patch.sh full_phase

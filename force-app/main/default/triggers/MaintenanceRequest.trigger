trigger MaintenanceRequest on Case (after update) {
    if(Trigger.isUpdate && Trigger.isAfter){
        // Map < Id, Case> oldMap = new Map < Id, Case > ();
        // oldMap = Trigger.oldMap;
        MaintenanceRequestHelper.renewMaintenanceRequest(Trigger.new,Trigger.oldMap);
    }  
}
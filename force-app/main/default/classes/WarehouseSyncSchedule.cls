public with sharing class WarehouseSyncSchedule implements Schedulable{
    public WarehouseSyncSchedule() {

    }

    public void execute(SchedulableContext conntext){
        System.enqueueJob(new WarehouseCalloutService());
    }
}
public with sharing class MaintenanceRequestHelper {

    public static void renewMaintenanceRequest(List<Case> maintenanceRequests,Map<Id,Case> oldMap){
        List<Case> validCases = new List<Case>();
        List<Case> casesToInsert = new List<Case>();
        List<Case> casesToUpdate = new List<Case>();
        List<Equipment_Maintenance_Item__c> equipmentItemsToInsert = new List<Equipment_Maintenance_Item__c>();
        for(Case c: maintenanceRequests){
            Case oldCase = oldMap.get(c.Id);
            if( (oldCase.status != c.status) && (c.type == 'Repair'||c.type == 'Routine Maintenance') && c.status == 'Closed'){
                validCases.add(c);
            }
        }
        
        Set<Id> caseIds = (new Map<Id,Case>(validCases)).keySet();
        List<Equipment_Maintenance_Item__c> emis = [select  id, Equipment__r.Maintenance_Cycle__c, Maintenance_Request__c, Maintenance_Request__r.id, Quantity__c from Equipment_Maintenance_Item__c where Maintenance_Request__c in :caseIds];

        for(Case c :validCases){
            Decimal shortestCycle;
            Case newCase = new Case(
                parentId = c.id,
                Vehicle__c = c.Vehicle__c,
                type = 'Routine Maintenance',
                Subject = 'Routine maintenance renewal',
                Date_Reported__C = date.today()
            );
            casesToInsert.add(newCase);
        }
        if(casesToInsert.size()>0){
            insert casesToInsert;
        }

        for(Case c: casesToInsert){
            Decimal shortestCycle;
            for(Equipment_Maintenance_Item__c emi: emis){
                if(emi.Maintenance_Request__r.id != c.parentId){
                    continue;
                }
                // Find shortest maintenance cycle to defice case due date
                if(shortestCycle==null){
                    shortestCycle = emi.Equipment__r.Maintenance_Cycle__c;
                }
                if(emi.Equipment__r.Maintenance_Cycle__c < shortestCycle){
                    shortestCycle = emi.Equipment__r.Maintenance_Cycle__c;
                }

                // Clone the emis and assign them to the case
                Equipment_Maintenance_Item__c newEmi = emi.clone();
                newEmi.Maintenance_Request__c = c.id;
                equipmentItemsToInsert.add(newEmi);
            }
            if(shortestCycle!=null){
                c.Date_Due__c = System.today()+(Integer)shortestCycle;
                casesToUpdate.add(c);
            }
        }
        if(casesToUpdate.size()>0){
            update casesToUpdate;
        }
        if(equipmentItemsToInsert.size()>0){
            insert equipmentItemsToInsert;
        }

    }
}
@isTest
private class MaintenanceRequestHelperTest {

    @isTest
    static void updateSingleCaseToClosed() {
        Case c = [select id, Vehicle__c, (select id from Equipment_Maintenance_Items__r) from Case where Type in ('Repair','Routine Maintenance') limit 1];
        List<Equipment_Maintenance_Item__c> oldEmis = [Select id, Equipment__c from Equipment_Maintenance_Item__c where Maintenance_Request__c =: c.id order by Equipment__c ASC];
        // Run test
        Test.startTest();
        c.Status = 'Closed';
        update c;
        Test.stopTest();

        // Verify results
        Case newCase = [Select id, Vehicle__c, Date_Due__c, (select id from Equipment_Maintenance_Items__r) from Case where ParentId =: c.id];
        List<Equipment_Maintenance_Item__c> newEmis = [Select id, Equipment__c from Equipment_Maintenance_Item__c where Maintenance_Request__c =: newCase.id order by Equipment__c ASC];
        System.assertEquals(c.Vehicle__c, newCase.Vehicle__c);
        System.assertEquals(c.Equipment_Maintenance_Items__r.size(), newCase.Equipment_Maintenance_Items__r.size());
        System.assertEquals(12, Date.today().daysBetween(newCase.Date_Due__c));
        System.assertEquals(oldEmis.size(), newEmis.size());
        for(Integer i = 0;i<newEmis.size();i++){
            System.assertEquals(oldEmis[i].Equipment__c, newEmis[i].Equipment__c);
        }
    }

    @Istest
    static void updateBulkCasesToClosed() {
        List<Case> cases = [select id, Vehicle__c, (select id from Equipment_Maintenance_Items__r) from Case where Type in ('Repair','Routine Maintenance')];
        List<Case> casesToUpdate = new List<Case>();
        Vehicle__c vehicle = [select id from Vehicle__c limit 1];
        // Run test
        Test.startTest();
        for(Case c :cases){
            c.Status = 'Closed';
            casesToUpdate.add(c);
        }
        update casesToUpdate;
        Test.stopTest();

        // Verify results
        List<Case> newCases = [Select id, Vehicle__c, (select id from Equipment_Maintenance_Items__r) from Case where Type in ('Repair','Routine Maintenance')];
        List<Equipment_Maintenance_Item__c> emis = [Select id from Equipment_Maintenance_Item__c];
        System.assertEquals(600, newCases.size());
        System.assertEquals(1803, emis.size());
    }


    @IsTest
    static void updateCasesNegativeTest(){
        Case negativeCase = [select id, Vehicle__c, (select id from Equipment_Maintenance_Items__r) from Case where (NOT Type in ('Repair','Routine Maintenance')) limit 1];
        // Run test
        Test.startTest();
        negativeCase.Status = 'Closed';
        update negativeCase;
        Test.stopTest();

        // Verify results
        List<Case> cases = [select id, Vehicle__c, parentId, (select id from Equipment_Maintenance_Items__r) from Case where (NOT Type in ('Repair','Routine Maintenance')) limit 1];
        System.assertEquals(1,cases.size());
        for(Case c: cases){
            System.assertNotEquals(negativeCase.id,c.ParentId);
        }
    }

    @TestSetup
    static void makeData(){

        // Vehicle
        Vehicle__c v = new Vehicle__c(
            Name = 'Vehicle Test',
            Type__c = 'Economy',
            Model__c = '2024 SP'
        );
        insert v;

        // Equipment
        List<Product2> productsToInsert = new List<Product2>();
        Product2 p1 = new Product2(
            Name = 'Product1 Test',
            Maintenance_Cycle__c = 50,
            Cost__c = 30000,
            Current_Inventory__c = 50,
            Lifespan_Months__c = 12,
            Replacement_Part__c =true
        );
        productsToInsert.add(p1);
        Product2 p2 = new Product2(
            Name = 'Product2 Test',
            Maintenance_Cycle__c = 100,
            Cost__c = 50000,
            Current_Inventory__c = 30,
            Lifespan_Months__c = 6,
            Replacement_Part__c =true
        );
        productsToInsert.add(p2);
        Product2 p3 = new Product2(
            Name = 'Product3 Test',
            Maintenance_Cycle__c = 12,
            Cost__c = 700,
            Current_Inventory__c = 1,
            Lifespan_Months__c = 6,
            Replacement_Part__c =true
        );
        productsToInsert.add(p3);
        insert productsToInsert;

        // Maintenance Requests
        List<Case> casesToInsert = new List<Case>();
        for(Integer i =0;i<301; i++){
            Case c = null;
            if( i <150){
                c = new Case(
                    Status = 'New',
                    Type = 'Repair',
                    Origin = 'Web',
                    Description = 'NewRequest',
                    Vehicle__c = v.id
                );
            }
            else if(i>149 && i<300){
                c = new Case(
                    Status = 'Working',
                    Type = 'Routine Maintenance',
                    Origin = 'Phone',
                    Description = 'NewRequest',
                    Vehicle__c = v.id
                );
            }
            else {
                c = new Case(
                    Status = 'New',
                    Type = 'Other',
                    Origin = 'Web',
                    Description = 'Negative Test',
                    Vehicle__c = v.id
                );
            }
            casesToInsert.add(c);
            
        }
        insert casesToInsert;

        //Equipment Maintenance Items
        List<Equipment_Maintenance_Item__c> emisToInsert = new List<Equipment_Maintenance_Item__c>();
        for(Case c: casesToInsert){
            for(Integer i=0;i<3;i++){
                Equipment_Maintenance_Item__c emi = null;
                if(i==0){
                    emi = new Equipment_Maintenance_Item__c(
                        Equipment__c = p1.id,
                        Maintenance_Request__c = c.id,
                        Quantity__c = 2
                    );
                }else if(i==1){
                    emi = new Equipment_Maintenance_Item__c(
                        Equipment__c = p2.id,
                        Maintenance_Request__c = c.id,
                        Quantity__c = 10
                    );
                }else{
                    emi = new Equipment_Maintenance_Item__c(
                        Equipment__c = p3.id,
                        Maintenance_Request__c = c.id,
                        Quantity__c = 5
                    );
                }
                emisToInsert.add(emi);
            }
        }
        insert emisToInsert;
    }

}
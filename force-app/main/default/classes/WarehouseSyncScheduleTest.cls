@isTest
private class WarehouseSyncScheduleTest {

    public static String CRON_EXP = '0 0 1 * * ? 2024';

    @isTest
    static void myUnitTest() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        String jobId = System.schedule('WarehouseSyncScheduleJobTest', CRON_EXP, new WarehouseSyncSchedule());
        CronTrigger ct = [SELECT CronExpression, TimesTriggered, CronJobDetail.Name FROM CronTrigger WHERE Id = :jobId];
        Test.stopTest();
        System.assertEquals(CRON_EXP, ct.CronExpression);
        System.assertEquals('WarehouseSyncScheduleJobTest', ct.CronJobDetail.Name);
    }


    @TestSetup
    static void makeData(){
        // Equipment
        List<Product2> productsToInsert = new List<Product2>();
        Product2 p1 = new Product2(
            Name = 'Test1',
            Maintenance_Cycle__c = 50,
            Cost__c = 30000,
            Current_Inventory__c = 50,
            Lifespan_Months__c = 12,
            Warehouse_SKU__c = '100003',
            Replacement_Part__c =true
        );
        Product2 p2 = new Product2(
            Name = 'Product2 Test',
            Maintenance_Cycle__c = 100,
            Cost__c = 50000,
            Current_Inventory__c = 30,
            Lifespan_Months__c = 6,
            Warehouse_SKU__c = '100004',
            Replacement_Part__c =true
        );
        productsToInsert.add(p1);
        productsToInsert.add(p2);
        insert productsToInsert;
    }
}
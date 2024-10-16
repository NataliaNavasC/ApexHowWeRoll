@isTest
private class WarehouseCalloutServiceTest {

    @isTest
    static void testWarehouseCalloutService() {
        Test.setMock(HttpCalloutMock.class, new WarehouseCalloutServiceMock());
        Test.startTest();
        System.enqueueJob(new WarehouseCalloutService());
        Test.stopTest();
        List<Product2> products = [select id, Name from Product2 ORDER BY Warehouse_SKU__c ASC];
        System.assertEquals(3, products.size());
        System.assertEquals('Generator 1000 kW', products[0].Name);
        System.assertEquals('Cooling Fan', products[1].Name);
        System.assertEquals('Fuse 20A', products[2].Name);
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
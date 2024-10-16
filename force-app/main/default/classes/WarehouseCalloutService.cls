public with sharing class WarehouseCalloutService implements Queueable, Database.AllowsCallouts{
    
    public static final String BASE_URL = 'https://th-superbadge-apex.herokuapp.com/';

    public void execute(QueueableContext context){
        HttpResponse response = sendHpptRequest(BASE_URL+'equipment','GET');

        // If response is successful, parse the JSON response
        if(response.getStatusCode()==200){
            List<Object> results = (List<Object>) JSON.deserializeUntyped(response.getBody());
            List<Product2> productsToUpsert = new List<Product2>();
            System.debug(results.size());
            
            for(Object o : results){
                System.debug(o);
                Map<String,Object> equipment = (Map<String,Object>) o;
                Product2 p = new Product2(
                    Name = (String) equipment.get('name'),
                    Replacement_Part__c = True,
                    Cost__c = (Double) equipment.get('cost'),
                    Current_Inventory__c = (Integer) equipment.get('quantity'),
                    Lifespan_Months__c = (Integer) equipment.get('lifespan'),
                    Maintenance_Cycle__c = (Integer) equipment.get('maintenanceperiod'),
                    Warehouse_SKU__c = (String) equipment.get('sku')
                );
                productsToUpsert.add(p);
            }

            if(productsToUpsert.size() > 0){
                upsert productsToUpsert Warehouse_SKU__c;
            }
        }
    }

    public HttpResponse sendHpptRequest(String URL, String method){
        // Setup http requets
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(URL);
        request.setMethod(method);

        // Send request
        HttpResponse response = http.send(request);
        return response;
    }
}
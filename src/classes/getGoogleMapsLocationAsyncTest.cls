@isTest 
global class getGoogleMapsLocationAsyncTest implements HttpCalloutMock{

    public static String getBody(){
        String body = '';
        body += '{';
        body += '   "results" : [';
        body += '      {';
        body += '         "address_components" : [';
        body += '            {';
        body += '               "long_name" : "13600",';
        body += '               "short_name" : "13600",';
        body += '               "types" : [ "street_number" ]';
        body += '            },';
        body += '            {';
        body += '               "long_name" : "Industrial Park Boulevard",';
        body += '               "short_name" : "Industrial Park Blvd",';
        body += '               "types" : [ "route" ]';
        body += '            },';
        body += '            {';
        body += '               "long_name" : "Minneapolis",';
        body += '               "short_name" : "Minneapolis",';
        body += '               "types" : [ "locality", "political" ]';
        body += '            },';
        body += '            {';
        body += '               "long_name" : "Hennepin County",';
        body += '               "short_name" : "Hennepin County",';
        body += '               "types" : [ "administrative_area_level_2", "political" ]';
        body += '            },';
        body += '            {';
        body += '               "long_name" : "Minnesota",';
        body += '               "short_name" : "MN",';
        body += '               "types" : [ "administrative_area_level_1", "political" ]';
        body += '            },';
        body += '            {';
        body += '               "long_name" : "United States",';
        body += '               "short_name" : "US",';
        body += '               "types" : [ "country", "political" ]';
        body += '            },';
        body += '            {';
        body += '               "long_name" : "55441",';
        body += '               "short_name" : "55441",';
        body += '               "types" : [ "postal_code" ]';
        body += '            },';
        body += '            {';
        body += '               "long_name" : "3743",';
        body += '               "short_name" : "3743",';
        body += '               "types" : [ "postal_code_suffix" ]';
        body += '            }';
        body += '         ],';
        body += '         "formatted_address" : "13600 Industrial Park Blvd, Minneapolis, MN 55441, USA",';
        body += '         "geometry" : {';
        body += '            "location" : {';
        body += '               "lat" : 45.0039908,';
        body += '               "lng" : -93.4528457';
        body += '            },';
        body += '            "location_type" : "ROOFTOP",';
        body += '            "viewport" : {';
        body += '               "northeast" : {';
        body += '                  "lat" : 45.00533978029149,';
        body += '                  "lng" : -93.4514967197085';
        body += '               },';
        body += '               "southwest" : {';
        body += '                  "lat" : 45.0026418197085,';
        body += '                  "lng" : -93.45419468029151';
        body += '               }';
        body += '            }';
        body += '         },';
        body += '         "partial_match" : true,';
        body += '         "place_id" : "ChIJnXiWoDhKs1IRFEYzsG4s5mo",';
        body += '         "types" : [ "street_address" ]';
        body += '      }';
        body += '   ],';
        body += '   "status" : "OK"';
        body += '}';
        
        return body;
    }
    
    global HTTPResponse respond(HTTPRequest req) {
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'applicaton/json');
        res.setBody(getBody());        
        res.setStatusCode(200);
        return res;    
    }
     static testMethod void updateAddress() {
       Test.startTest();
       Test.setMock(HttpCalloutMock.class, new getGoogleMapsLocationAsyncTest());

       AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
       ts1.AVA_SFCORE__Active_Setting__c = true;
       ts1.Name='Test Account';
       insert ts1;
     
       Account account = new Account();
       account.Name = 'TEST';
       account.Type = 'Other';
       account.BillingStreet = '13600 Industrial Park Blvd';
       account.BillingCity = 'Plymouth';
       account.BillingCountry = 'United States';
       account.BillingState = 'Minnesota';
       account.BillingPostalCode = '55441';
       insert account;
       
       Address__c address = new Address__c();
       address.Entity_Account__c=account.Id;
       address.Address_Line_1__c='13600 Industrial Park Blvd';
       address.City__c = 'Plymouth';
       address.Country__c = 'United States';
       address.State_Province__c = 'Minnesota';
       address.Postal_Code__c = '55441';
       insert address;

       Asset asset = new Asset();
       asset.Name = 'TEST';
       asset.AccountId = account.id;
       asset.Asset_Address__c = address.id;
       insert asset;
       
       getGoogleMapsLocationAsync.batchUpdateLocations();
       Test.stopTest();
       address = [select Id, Geographic_Location__Latitude__s, Geographic_Location__Longitude__s from Address__c where Id = :address.Id];

       System.assertEquals(45.0039908, address.Geographic_Location__Latitude__s);
       System.assertEquals(-93.4528457, address.Geographic_Location__Longitude__s);
    }
    static testMethod void FindNearbyLeads() {
        
        FindNearbyLeads.getNearby(null, null);
        FindNearbyLeads.getNearbyAccounts(null, null);
        FindNearbyLeads.getNearbyAssets(null, null);

       AVA_SFCORE__TaxNowSetting__c ts1 = new AVA_SFCORE__TaxNowSetting__c();
       ts1.AVA_SFCORE__Active_Setting__c = true;
       ts1.Name='Test Account';
       insert ts1;
     
       Account account = new Account();
       account.Name = 'TEST';
       account.Type = 'Other';
       account.BillingStreet = '13600 Industrial Park Blvd';
       account.BillingCity = 'Plymouth';
       account.BillingCountry = 'United States';
       account.BillingState = 'Minnesota';
       account.BillingPostalCode = '55441';
       insert account;
       
       Address__c address = new Address__c();
       address.Entity_Account__c=account.Id;
       address.Address_Line_1__c='13600 Industrial Park Blvd';
       address.City__c = 'Plymouth';
       address.Country__c = 'United States';
       address.State_Province__c = 'Minnesota';
       address.Postal_Code__c = '55441';
       insert address;

       Asset asset = new Asset();
       asset.Name = 'TEST';
       asset.AccountId = account.id;
       asset.Asset_Address__c = address.id;
       insert asset;

        System.assertNotEquals(null, FindNearByLeads.createLeadFromAsset(asset.Id));

        ApexPages.StandardController sc = new ApexPages.StandardController(asset);
        new FindNearbyLeads(sc);
        
        List<Asset> l = new List<Asset>();
        l.add(asset);
        ApexPages.StandardSetController ssc = new ApexPages.StandardSetController(l);
        new FindNearbyLeads(ssc);
    }
}
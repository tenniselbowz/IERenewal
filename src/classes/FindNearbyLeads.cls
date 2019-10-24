global with sharing class FindNearbyLeads {

    public FindNearbyLeads(ApexPages.StandardController controller) {

    }


    public FindNearbyLeads(ApexPages.StandardSetController controller) { }

    @RemoteAction
    // Find leads nearest a geolocation
    global static List<Lead> getNearby(String lat, String lon) {

        // If geolocation isn't set, use San Francisco
        if(lat == null || lon == null || lat.equals('') || lon.equals('')) {
            lat = '37.77493';
            lon = '-122.419416';
        }
        
        // SOQL query to get the nearest leads
        String queryString =
            'SELECT Id, Name, Company, LeadSource, Street, Phone, City, PostalCode, Country, State, OwnerId ' +//, Location__Latitude__s, Location__Longitude__s, Location__c
            'FROM Lead ' +
            //'WHERE DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') < 2000 ' +
            'WHERE (OwnerId = \'' + UserInfo.getUserId() + '\' ' +
            'OR OwnerId=\'005i0000001JySJAA0\') ' +
            'AND Status in (\'Open\', \'Contacted\') ' +
            //'ORDER BY DISTANCE(Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') ASC ' +            
            'LIMIT 20';

        // Run and return the query results
        return(database.Query(queryString));
    }

    @RemoteAction
    // Find accounts nearest a geolocation
    global static List<Account> getNearbyAccounts(String lat, String lon) {

        // If geolocation isn't set, use San Francisco
        if(lat == null || lon == null || lat.equals('') || lon.equals('')) {
            lat = '37.77493';
            lon = '-122.419416';
        }
        
        // SOQL query to get the nearest leads
        String queryString =
            'SELECT Id, Name, AccountNumber, BillingStreet, Phone, BillingCity, BillingPostalCode, BillingCountry, BillingState, OwnerId, BillingLatitude, BillingLongitude, National_Account__c ' +
            'FROM Account ' +
            'WHERE DISTANCE(BillingAddress, GEOLOCATION('+lat+','+lon+'), \'mi\') < 2000 ' +
            //'AND OwnerId = \'' + UserInfo.getUserId() + '\' ' +
            'ORDER BY DISTANCE(BillingAddress, GEOLOCATION('+lat+','+lon+'), \'mi\') ASC ' +            
            'LIMIT 20';

        // Run and return the query results
        return(database.Query(queryString));
    }

    @RemoteAction
    // Find accounts nearest a geolocation
    global static List<Asset> getNearbyAssets(String lat, String lon) {

        // If geolocation isn't set, use San Francisco
        if(lat == null || lon == null || lat.equals('') || lon.equals('')) {
            lat = '37.77493';
            lon = '-122.419416';
        }
        
        // SOQL query to get the nearest leads
        String queryString =
            'SELECT Id, Name, SerialNumber, Asset_Address__r.Address_Line_1__c, Asset_Address__r.City__c, Asset_Address__r.Postal_Code__c, Asset_Address__r.Country__c, Asset_Address__r.State_Province__c, Account.OwnerId, Asset_Address__r.Geographic_Location__latitude__s, Asset_Address__r.Geographic_Location__longitude__s ' +
            ', Model_Type__c '+
            'FROM Asset ' +
            'WHERE DISTANCE(Asset_Address__r.Geographic_Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') < 100 ' +
            //'AND Account.OwnerId = \'' + UserInfo.getUserId() + '\' ' +
            'ORDER BY DISTANCE(Asset_Address__r.Geographic_Location__c, GEOLOCATION('+lat+','+lon+'), \'mi\') ASC ' +            
            'LIMIT 100';

        // Run and return the query results
        return(database.Query(queryString));
    }
    
    webservice static String createLeadFromAsset(String assetId){
        Asset a = [select Id, Name from Asset where Id=:assetId];
        Lead l = new Lead();
        l.LastName=a.Name;
        l.Company = a.Name;
        l.LeadSource = 'Web';
        l.Email = 'test@test.com';
        insert l;
        
        return l.Id;
    }

}
global with sharing class getGoogleMapsLocationAsync implements Schedulable {
  
  public static boolean isLocationUpdate = false;
  
  global void execute(SchedulableContext SC) {
      getGoogleMapsLocationAsync.batchUpdateLocations();
  }
    
  public static void batchUpdateLocations(){
      List<Address__c> adds = [select Id, Geographic_Location__latitude__s, Address_Line_1__c, City__c, Country__c, State_Province__c from Address__c where Geographic_Location__latitude__s = null and Address_Line_1__c != null and City__c != null and Country__c != null and State_Province__c != null LIMIT 100];
      if(adds.size()>0){
          Set<Id> ids = (new Map<Id,Address__c>(adds)).keySet();
          getLocation(ids);
          if(ids.size()==100){//more to process
              Datetime now = Datetime.now().addMinutes(3);
              System.schedule('AddressGeolocationUpdate_'+now.getTime(), now.second()+' ' + now.minute()+ ' '+now.hour()+' '+now.day()+' '+now.month()+' ? '+now.year(), new getGoogleMapsLocationAsync());
          }
      }
  }
  
  @future(callout=true)
  public static void getLocation(Set<Id> listObjectIds){
      //identify id's for object and then lookup up objects
      if(!listObjectIds.isEmpty()) {
            //Retrieve fields needed for the external call.
            List<Address__c> listJSONAddress = [select Id, Name, Address_Line_1__c, City__c, State_Province__c, Postal_Code__c, Country__c, Geographic_Location__latitude__s, Geographic_Location__longitude__s from Address__c where Id in :listObjectIds];
            List<Address__c> listToUpdate = new List<Address__c>();
            for(Address__c a : listJSONAddress){
                String address = '';
                //Only when lattitude and longitude is null and address is not null
                if(String.ISNOTBLANK(a.Address_Line_1__c)){
                    //Lookup address and update location with result
                    address += a.Address_Line_1__c +', ';
            
                    if (String.IsNotBlank(a.City__c))
                        address += a.City__c +', ';
            
                    if (String.IsNotBlank(a.State_Province__c))
                        address += a.State_Province__c +' ';
            
                    if (String.IsNotBlank(a.Postal_Code__c))
                        address += a.Postal_Code__c +', ';
            
                    if (String.IsNotBlank(a.Country__c))
                        address += a.Country__c;
                    address = EncodingUtil.urlEncode(address, 'UTF-8');
                    
                    double[] d = getCoordinates(address);
                    double lat = d[0];
                    double lon = d[1];
                    // update coordinates if we get back
                    if (true/*lat != null && lat != 0.0*/){
                        System.Debug('Updating Address: '+a.Name);
                        a.Geographic_Location__Latitude__s = lat;
                        a.Geographic_Location__Longitude__s = lon;
                        listToUpdate.add(a);
                        List<Address__c> otherAddresses = [select Id, Name, Address_Line_1__c, City__c, State_Province__c, Postal_Code__c, Country__c, Geographic_Location__latitude__s, Geographic_Location__longitude__s from Address__c where Id !=:a.Id and Geographic_Location__latitude__s !=:lat and Address_Line_1__c = :a.Address_Line_1__c and City__c = :a.City__c and State_Province__c = :a.State_Province__c and Postal_Code__c = :a.Postal_Code__c and Country__c = :a.Country__c and (Geographic_Location__latitude__s = null or Geographic_Location__latitude__s=0.0)];
                        for(Address__c oa :otherAddresses){
                            oa.Geographic_Location__Latitude__s = lat;
                            oa.Geographic_Location__Longitude__s = lon;
                            listToUpdate.add(oa);
                        }
                    }                    
                }
            }
            if(listToUpdate.size()>0){
                Set<Address__c> myset = new Set<Address__c>();
                List<Address__c> result = new List<Address__c>();
                myset.addAll(listToUpdate);
                result.addAll(myset);
                isLocationUpdate = true;
                System.debug('Trigger to be deactivated');
                update result;
                isLocationUpdate = false;
                System.debug('Trigger to be re-activated');
            }
        }   
     }
  
  @RemoteAction
  global static double[] getCoordinates(String address){
    double[] d = new double[]{0, 0};
  
    System.Debug('Address: '+address);
    // call webservice with address 
    // build callout
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    req.setHeader('Accept','application/json');
    req.setEndpoint('https://maps.googleapis.com/maps/api/geocode/json?address='+address.replaceAll(' ', '+')+'&sensor=false&key=AIzaSyB2kMfdTgk--VRUVYLo4QrOJ7ImRvfibMQ');
    req.setMethod('GET');
    req.setTimeout(60000);

    try{
        // callout
        HttpResponse res = h.send(req);

        // parse coordinates from response
        JSONParser parser = JSON.createParser(res.getBody());

        while (parser.nextToken() != null) {
            //System.Debug('Token: '+parser.getText());
            if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
                (parser.getText() == 'location')){
                   parser.nextToken(); // object start

                   while (parser.nextToken() != JSONToken.END_OBJECT){
                       String txt = parser.getText();
                       //System.Debug('Location Token: '+txt);
                       parser.nextToken();
                       if (txt == 'lat'){
                           d[0] = parser.getDoubleValue();                           
                       } else if (txt == 'lng') {
                           d[1] = parser.getDoubleValue();
                       }
                   }
                   System.Debug ('Lat: '+ d[0] +' Lng: '+ d[1]);
                   break;
            }
        }

    } catch (Exception e) {
        System.Debug(Logginglevel.ERROR, 'EXCEPTION'+e.getMessage());
    }
    return d;
  }
  
    public getGoogleMapsLocationAsync() { }
    public getGoogleMapsLocationAsync(ApexPages.StandardController controller) { }
    public getGoogleMapsLocationAsync(ApexPages.StandardSetController controller) { }  
}
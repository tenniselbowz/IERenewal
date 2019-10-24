global with sharing class AssetSelectorCont {
	global AssetSelectorCont(Object obj) {}
	  @RemoteAction
    global static List<Asset> getAssetBySerialNumber (String searchTerm) {
        String termToSearch =  searchTerm + '%';
        List<Asset> assets = [Select Id, Serial_Number_ID__c, Name from Asset 
                                        where Serial_Number_ID__c LIKE: termToSearch
                                        And Serial_Number_ID__c != null
                                        order by NAME ASC limit 10];
        return assets;    
    }
}
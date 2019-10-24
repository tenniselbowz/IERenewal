public without sharing class AssetTriggerHandler {
  /*********************************************************************
  * NOTE: The following set of Test Classes will test this trigger code.
  * These would all need to be run to get > 75% code coverage.
  * 
  * AssetTriggerHandler_Test
  * Batch_IE_DeactPrevMonthExpSubAndSta_Test
  * ResetGWotGoAsset_Test
  * WarrantyOracleHandlerTest
  **********************************************************************/
    
    public static void onBeforeUpdate(list<Asset> newList, map<Id, Asset> oldMap)
    {
        setIeSyncStatus(newList, oldMap);
    }
    
    public static void onAfterUpdate(map<Id, Asset> newMap, map<Id, Asset> oldMap)
    {
        processGatewayAsset(newMap, oldMap);
        //processSubscriptions(newMap,oldMap);
        //doIntelSync(newMap, oldMap);

        //Synching Oracle Startup Dates
        sendStartupDates(newMap, oldMap);
    }
    
    public static void onBeforeInsert(list<Asset> newList)
    {
        setIeSyncStatus(newList, null);
    }
    
    public static void onAfterInsert(map<Id, Asset> newMap)
    {
        processGatewayAsset(newMap, null);
        //processSubscriptions(newMap, null);
        sendStartupDates(newMap, null);
    } 
    
    public static void onBeforeDelete(map<Id, Asset> oldMap)
    {
        for(Asset a : oldMap.values())
        {
            if( a.Record_Usage__c != null)
                a.addError('This record cannot be deleted because it is integrated with other systems or tied to other critical information within Salesforce.');
                
        }
        
    }
    
    private static void sendStartupDates(map<Id, Asset> newMap, map<Id, Asset> oldMap){
        //Synching Oracle Startup Dates
        Set<Id> l = new Set<Id>();
        for(Asset a : newMap.values()){
            if(WarrantyOracleHandler.settingWarrantyInfo || a.Warehouse_ID__c == null || a.Warehouse_ID__c == ''){
                //Do Nothing...
            } else if(a.Startup_Date__c == null && (a.Warranty_Items__c==null || (oldMap != null && a.Startup_Date__c != oldMap.get(a.Id).Startup_Date__c))){
                if(!System.isFuture() && !System.isBatch())
                    WarrantyOracleHandler.getWarrantyInfo(a.Id);
            } else if(a.Startup_Date__c != null && oldMap != null && a.Startup_Date__c != oldMap.get(a.Id).Startup_Date__c){
                l.add(a.Id);
            }
        }
        if(l.size()>0 && !System.isFuture() && !System.isBatch())
            WarrantyOracleHandler.sendStartupDateList(l);
    }

    
    public static void setIeSyncStatus(list<Asset> newList, map<Id, Asset> oldMap)
    {
        system.debug(':::::::setIeSyncStatus newList:::::: ' + newList);
        system.debug(':::::::setIeSyncStatus oldMap:::::: ' + oldMap);

        set<Id> productIds = new set<Id>();
        map<Id, Boolean> productIsIeMap = new map<Id, Boolean>();
        for(Asset a : newList)
        {
            if(oldMap != null && oldMap.get(a.Id).IE_Updated_Date__c != a.IE_Updated_Date__c
               && a.IE_Updated_Date__c != null
               && oldMap.get(a.Id).IE_Updated_Date__c < oldMap.get(a.Id).LastModifiedDate){a.AddError('Salesforce Last Modified Date is more Recent then IE Updates');
            }
            
            productIds.add(a.Product2Id);
        }
        
        for(Product2 p : [Select Id, IE__c from Product2 where Id in :productIds])
        {
            productIsIeMap.put(p.Id, p.IE__c);
        }
        
        if(TriggerUtility.limitIeServiceIntegration || TriggerUtility.limitIntegrationBatch){return;
        } 
        
        for(Asset a : newList)
        {
            system.debug(':::::::setIeSyncStatus asset:::::: ' + a);

            if(a.IE_Asset__c && a.IE_Sync_Status__c != 'Pending' && ((oldMap == null || oldMap.get(A.Id).IE_Sync_Status__c != 'Pending')|| productIsIeMap.get(a.Product2Id)) )
            {
                if ((a.Name != 'Dummy GWotGo Unit Asset') && (a.Name != 'Holding GWotGo Unit Asset')) {
                    system.debug(':::::::setIeSyncStatus set status to Pending::::::');

                    a.IE_Sync_Status__c = 'Pending';
                }
            }
            
            if(a.IE_Asset__c && (oldMap==null || oldMap.get(a.Id).IE_Asset__c != true))
            {
                if(a.Record_Usage__c != null && !a.Record_Usage__c.contains('IE')){a.Record_Usage__c +=  ';IE';
				} else if(a.Record_Usage__c == null) {a.Record_Usage__c =  'IE';
                }
            }
        }
        
    }
    

    public static void processGatewayAsset(map<Id, Asset> newMap, map<Id, Asset> oldMap)
    {
        /*
          - Check for existing gateway asset on current gateway asset's parent equipment asset.
		  - If an existing one is found, set its status to obsolete.
          - ** Flag the Unit Asset as an IE Asset.

		  (A "set" cannot have duplicates, this is handled automatically)
        */
        
        system.debug(':::::::processGatewayAsset newMap:::::: ' + newMap);
        system.debug(':::::::processGatewayAsset oldMap:::::: ' + oldMap);

        if(TriggerUtility.limitIeServiceIntegration || TriggerUtility.limitIntegrationBatch){return;
        } 
        
        set<Id> newIdSet = new set<Id>();
        set<Id> newObsGWIdSet = new set<Id>();
        for(Asset a : newMap.values())
        {
            if(a.Status != 'Obsolete')
                newIdSet.add(a.Id);
            else if (a.Status == 'Obsolete' && (a.Name == 'Intelligent Equipment Gateway' || String.isNotEmpty(a.SIM_Card_ICCID__c))){newObsGWIdSet.add(a.Id);
			}
        }
        system.debug(':::::::processGatewayAsset newIdSet :::::: ' + newIdSet);
        system.debug(':::::::processGatewayAsset newObsGWIdSet :::::: ' + newObsGWIdSet);


        set<Id> parentAssetIdsForNewObsGW = new set<Id>();
        // collect parent assets for new obsolete GWs
        for(Asset a : [Select Id, Parent_Asset__c 
                         from Asset 
                        where Id in :newObsGWIdSet 
                          and GWotGo__c != true])  // ignore GWotGo assets
        {
            if(a.Parent_Asset__c != null)
                parentAssetIdsForNewObsGW.add(a.Parent_Asset__c);
        }


        set<Id> parentAssetIds = new set<Id>();
		set<Id> parentAssetIdsForReplacedGW = new set<Id>();
        list<Asset> obsoleteAssets = new list<Asset>();
        list<Asset> parentAssets = new list<Asset>();
        
        //collect the IE Gateway Assets
        for(Asset a : [Select Id, Parent_Asset__c 
                         from Asset 
                        where Id in :newIdSet 
                          and Product2.Product_Group__c = 'IE Gateway' 
                          and GWotGo__c != true  // ignore GWotGo assets
                          and Status != 'Obsolete'])
        {
            if(a.Parent_Asset__c != null)
                parentAssetIds.add(a.Parent_Asset__c);
        }

            
        //pull the parent Assets' existing gateway assets that are not the current gateway assets and mark them as Obsolete
        if(parentAssetIds.size() > 0)
        {
            for(Asset a : [Select Id, Parent_Asset__c
                             from Asset 
                            where Parent_Asset__c in :parentAssetIds 
                              and Parent_Asset__c != null
                              and (NOT( Id in :newIdSet) )
                              and Status != 'Obsolete'
                              and GWotGo__c != true  // never set GWotGo assets to Obsolete
                              and Product2.Product_Group__c = 'IE Gateway'])    
            {
                    a.Status = 'Obsolete';
                    obsoleteAssets.add(a);
					parentAssetIdsForReplacedGW.add(a.Parent_Asset__c);
					system.debug('processGatewayAsset: Setting obsolete GW, Id=' + a.Id + ', Parent Asset Id=' + a.Parent_Asset__c);
            }
        }
        
        
        set<Id> EMMparentAssetIds = new set<Id>();
        //collect the IE EMM Assets
        for(Asset a : [Select Id, Parent_Asset__c 
                         from Asset 
                        where Id in :newIdSet 
                          and Product2.Product_Group__c = 'IE EMM' 
                          and Status != 'Obsolete'])
        {
            EMMparentAssetIds.add(a.Parent_Asset__c);
        }
            
        //pull the parent Assets' existing IE EMM assets that are not the current IE EMM assets and mark them as Obsolete
        if(EMMparentAssetIds.size() > 0)
        {
            for(Asset a : [Select Id,  Parent_Asset__c
                             from Asset 
                            where Parent_Asset__c in :EMMparentAssetIds 
                              and Parent_Asset__c != null
                              and (NOT( Id in :newIdSet) )
                              and Status != 'Obsolete'
                              and Product2.Product_Group__c = 'IE EMM'])    
            {
                    a.Status = 'Obsolete';
                    obsoleteAssets.add(a);
                    parentAssetIds.add(a.Parent_Asset__c);
            }
        }
        
		system.debug(':::::::processGatewayAsset parentAssetIds :::::: ' + parentAssetIds);

        
        //pull the parent Assets so their IE flag can be set
        if(parentAssetIds.size() > 0)
        {
            for(Asset a : [Select Id 
                             from Asset 
                            where Id in :parentAssetIds 
                              and (IE_Asset__c = false or IE_Sync_Status__c != 'Pending')]) 
            {
                    system.debug(':::::::processGatewayAsset set status to Pending for asset :::::: ' + a);

                    a.IE_Asset__c = true;
                    a.IE_Sync_Status__c = 'Pending';
                    parentAssets.add(a);
            }
        }


        //Update fields for the parent Assets who have a new obsolete GW.
        //Only do the update if there is no other GW associated with the asset that is not obsolete.
        //Set the IE_Asset__c field to false since it is not an ie asset anymore on the ie side
        //Clear out the IE_ID__c field since it is not an ie asset anymore on the ie side
        if(parentAssetIdsForNewObsGW.size() > 0)
        {
            for(Asset a : [Select Id, IE_Asset__c, IE_ID__c,
                            (Select Id, Name, SerialNumber, SIM_Card_Active__c, Product2.Name, SIM_Card_ICCID__c, Device_ID__c, MAC_Address__c, GWotGo__c From Assets__r where  Product2.Product_Group__c = 'IE Gateway' and Status != 'Obsolete' and (NOT( Id in :newObsGWIdSet)))
                            from Asset 
                            where Id in :parentAssetIdsForNewObsGW]) 
            {
                    List<Asset> relatedAssets = a.Assets__r;
                    if (relatedAssets.isEmpty())
                    {
                        // Only perform the update if the unit asset doesn't have any other valid GW associated with it
                        system.debug(':::::::processGatewayAsset update parent asset for new obsolete GW :::::: ' + a);

                        a.IE_Asset__c = false;
                        a.IE_ID__c = null;
                        a.IE_Sync_Status__c = 'Processed';
                        parentAssets.add(a);
                    }
            }
        }


        //*** Collect the IE GWotGo Assets and their Parent unit and process them ***
        list<Asset> parentAssetsForGWotGo = new list<Asset>();
        for(Asset a : [Select Id, Parent_Asset__c 
                         from Asset 
                        where Id in :newIdSet 
                          //and Product2.Product_Group__c = 'IE Gateway' 
                          and GWotGo__c = true 
                          and Status != 'Obsolete'])
        {
            if (a.Parent_Asset__c != null) {
                Asset unitAsset = [SELECT Id, Name, IE_Sync_Status__c from Asset Where Id = :a.Parent_Asset__c];

                if ((unitAsset.Name != 'Dummy GWotGo Unit Asset') && (unitAsset.Name != 'Holding GWotGo Unit Asset')) {
                    if (oldMap == null || (a.Parent_Asset__c != oldMap.get(a.Id).Parent_Asset__c)) {
                        // This unit asset is associated with a GWotGo asset that just moved to it from another unit from a Reset operation
                        // Set status to 'Processed' so the hourly IE batch job ignores it
                        system.debug(':::::::processGatewayAsset set status to Processed for unit asset for GWotGo :::::: ' + unitAsset);
                        unitAsset.IE_Sync_Status__c = 'Processed';
                    }
                    else {
                        system.debug(':::::::processGatewayAsset set status to Pending for unit asset for GWotGo :::::: ' + unitAsset);
                        unitAsset.IE_Sync_Status__c = 'Pending';
                    }
                }
                else {
                    system.debug(':::::::processGatewayAsset set status to Processed for Dummy/Holding unit asset for GWotGo :::::: ' + unitAsset);
                    unitAsset.IE_Sync_Status__c = 'Processed';
                }

                parentAssetsForGWotGo.add(unitAsset);
            }
        }



		// Reprocess the subscriptions for the GW replacement
		system.debug(':::::::processGatewayAsset parentAssetIdsForReplacedGW :::::: ' + parentAssetIdsForReplacedGW);
		if(parentAssetIdsForReplacedGW.size() > 0)
		reprocessSubscriptionsForGWReplacement(parentAssetIdsForReplacedGW);

        //update the obsolete assets
		system.debug(':::::::processGatewayAsset obsoleteAssets :::::: ' + obsoleteAssets);
        if(obsoleteAssets.size() > 0)
            update obsoleteAssets;
            
        //update the parent assets for non-GWotGo
		system.debug(':::::::processGatewayAsset parentAssets :::::: ' + parentAssets);
        if(parentAssets.size() > 0)
            update parentAssets;
        
        //update the parent assets for GWotGo
		system.debug(':::::::processGatewayAsset parentAssetsForGWotGo :::::: ' + parentAssetsForGWotGo);
        if(parentAssetsForGWotGo.size() > 0)
            update parentAssetsForGWotGo;

    }


	private static void reprocessSubscriptionsForGWReplacement(set<Id> unitAssetIdSet)
	{
		list<Subscription__c> existingSubscriptionList = new list<Subscription__c>();

		for(Subscription__c s : [Select Id, TriggerInvokedByAPI__c
                                 from Subscription__c
                                 where Asset__c in :unitAssetIdSet])
        {
            s.TriggerInvokedByAPI__c = true;
            existingSubscriptionList.add(s);
        }
         
         
        if(existingSubscriptionList.size() > 0)
           update existingSubscriptionList;

	}


/*
    public static void processSubscriptions(map<Id, Asset> newMap, map<Id, Asset> oldMap)
    {
         
         set<Id> assetIdSet = new set<Id>();
         set<Id> commissionedAssetIdSet = new set<Id>();
         
         for(Asset a : newMap.values())
         {
            if(a.Commissioned__c == true && (oldMap != null && oldMap.get(a.Id).Commissioned__c == false) )
                commissionedAssetIdSet.add(a.Id);
                
            if(a.IE_Asset__c == true && (oldMap == null || oldMap.get(a.Id).IE_Asset__c == false))
                assetIdSet.add(a.Id);
         }
         list<Subscription__c> subscriptionList = new list<Subscription__c>();
         list<Subscription__c> existingSubscriptionList = new list<Subscription__c>();
         list<Contact_Subscription__c> contactSubscriptions = new list<Contact_Subscription__c>();
         list<Contact> daiknContacts = new list<Contact>();
         
         for(Subscription__c s : [Select Id, Term_Years__c, Type__c
                                    from Subscription__c
                                   where Asset__c in :commissionedAssetIdSet 
                                     and Asset__c != null
                                     and Type__c  != 'Daikin']) 
         {
            s.Start_Date__c = System.today();
            s.End_Date__c = System.today().addDays((Integer.valueOf(365 * (s.Term_Years__c==null?0:s.Term_Years__c)) ));
            existingSubscriptionList.add(s);
         }
         
         
         if(existingSubscriptionList.size() > 0)
            update existingSubscriptionList;
         

        // - ** NON GATEWAY ASSETS ** Create Daikin Subscription Record using "Daikin" Account and Contacts flagged as to be included(contacts flagged, 
        //      contact custom setting)
        //  -- When there are no existing Daikin Subscriotions and the IE_Asset__c flag is true and was previously false
        

         map<Id, Id> ExistingDaikinSubscriptionMap = new map<Id,Id>();
         
         for(Subscription__c s : [Select Id, Asset__c from Subscription__c where Asset__c in :assetIdSet and Type__c  = 'Daikin'])
            ExistingDaikinSubscriptionMap.put(s.Asset__c, s.Id);
            
         for(Id assetId : assetIdSet)   
         {
            if(!ExistingDaikinSubscriptionMap.containsKey(assetId))
            {
                subscriptionList.add(new Subscription__c(Asset__c = assetId
                                                        ,Buyer_Id__c = IE_Service_Configuration__c.getInstance().DaikinAccountId__c
                                                        ,Type__c  = 'Daikin'
                                                        ,Active__c = true));
            }
         }
            
         if(subscriptionList.size() > 0)
            insert subscriptionList;
            
         //create contact subscriptions
         
         //retrieve the "Daikin" account and then the flagged contacts
         for(Contact c : [Select Id, IE_Daikin_Subscription_Role__c
                            from Contact
                           where IE_Daikin_Subscription_Role__c != null
                             and AccountId = :IE_Service_Configuration__c.getInstance().DaikinAccountId__c ])
         {
             list<String> roleList = c.IE_Daikin_Subscription_Role__c.split(';');
             for(Subscription__c s : subscriptionList)
             {
                
                    contactSubscriptions.add(new Contact_Subscription__c(Contact__c = c.Id
                                                                        ,Subscription__c = s.Id
                                                                        ,Asset__c = s.Asset__c
                                                                        ,Role__c = c.IE_Daikin_Subscription_Role__c));
                                                                        
                                                                        
             }
         }
         
         if(contactSubscriptions.size() > 0)
            insert contactSubscriptions;
         
    }
*/


    /*
    public static void doIntelSync(map<Id, Asset> newMap, map<Id, Asset> oldMap) {
        List<Asset> assetsToSync = AssetIntegrationService.filterAssetsToSync(newMap.values(), oldMap, AssetIntegrationService.filterFields);
        System.debug('^^^ assetsToSync: ' + assetsToSync);
        for (Asset ast : assetsToSync) {
            ID jobID = System.enqueueJob(new SendAssetToIntel(ast.Id));
            System.debug('jobbbbb: ' + jobID);
        }
    }*/
 
}
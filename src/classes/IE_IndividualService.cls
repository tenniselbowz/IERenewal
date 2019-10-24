@RestResource(urlMapping='/IEIndividualService/*')
global without sharing class IE_IndividualService {
    
     
    @HttpPost
    global Static IE_IntegrationObjects.IE_UserListResponse doPost(list<IE_IntegrationObjects.IE_User> Individuals)
    {
        return processRequest(Individuals);
    }
    
    @httpPut
    global Static IE_IntegrationObjects.IE_UserListResponse doPut(list<IE_IntegrationObjects.IE_User> Individuals)
    {
        return processRequest(Individuals);
    }
    
    global Static IE_IntegrationObjects.IE_UserListResponse processRequest(list<IE_IntegrationObjects.IE_User> Individuals)
    {
        //disable trigger functionality
        TriggerUtility.limitIeServiceIntegration = true;
		TriggerUtility.limitContactExecution = true;
        
        System.Debug('::::Individuals::::'+Individuals);
        IE_IntegrationObjects.IE_UserListResponse response = new IE_IntegrationObjects.IE_UserListResponse();
        response.Individuals = Individuals;
        response.errors = new list<IE_IntegrationObjects.IE_Error>();

        //list<Contact_Subscription__c> contactSubscriptions = new  list<Contact_Subscription__c>();
        //map<Integer, list<IE_IntegrationObjects.IE_Role>> contactRoleMap = new map<Integer, list<IE_IntegrationObjects.IE_Role>>();
        //map<Integer, IE_IntegrationObjects.IE_Address> individualIeAddressMap = new map<Integer, IE_IntegrationObjects.IE_Address>();

        map<Integer, Address__c> individualAddressMap = new map<Integer, Address__c>();
        list<Contact> contacts = new list<Contact>();
        
        
        Integer y= 0;
        set<Id> AssetIds = new set<Id>();
        map<string,Subscription__c> SubscriptionAssetMap = new map<string,Subscription__c>();  // map using the unit asset
		map<string,Subscription__c> SubscriptionGWotGoAssetMap = new map<string,Subscription__c>();  // map using the GWotGo asset
        
        IE_Service_Configuration__c serviceConfig = IE_Service_Configuration__c.getInstance();
        
        //=====================================================
        //iterate through the request retrieving the Contacts, 
        //Map of Accounts, Map of Account Addresses and Map of Contact Addresses
        for(IE_IntegrationObjects.IE_User u : Individuals)
        {
            Integer x = 0;
            //add the Contacts
            contacts.add(new Contact (FirstName         =   u.FirstName
                                    , Middle_Name__c    =   u.MiddleName
                                    , LastName          =   u.LastName
                                    , Email             =   u.EmailAddress
                                    , IE_Username__c    =   u.Username
                                    , IE_Accessed__c    =   (u.Accessed == null ? false : Boolean.valueOf(u.Accessed))
                                    , IE_Inactive__c    =   (u.Inactive == null ? false : Boolean.valueOf(u.Inactive))
                                    , MobilePhone       =   u.CellPhone
                                    , Phone             =   u.WorkPhone
                                    , AccountId         =   u.OrganizationSFDCId
                                    , IE_ID__c          =   u.IEId
                                    , IE_Updated_Date__c=   u.LastModifiedDate 
                                    , Id                =   u.SFDCId
                                    , IE_Contact__c     =   true
                                    , RecordTypeId      = serviceConfig.Contact_RecordType__c
                                    ));//
            
            //add the Contact Addresses
            if(u.Address != null)
            {
                individualAddressMap.put(x,new Address__c(Address_Line_1__c     = u.Address.AddressLine1
                                                        , Address_Line_2__c     = u.Address.AddressLine2
                                                        , Address_Line_3__c     = u.Address.AddressLine3
                                                        , Address_Line_4__c     = u.Address.AddressLine4
                                                        , City__c               = u.Address.City
                                                        , Country__c          	= TriggerUtility.getCountryFromIsoCode(u.Address.Country)
                                                        , Country_ISO_Code__c   = u.Address.Country
                                                        , State_Province_ISO_Code__c = u.Address.StateCode
                                                        , State_Province__c     = TriggerUtility.getStateFromCountryStateIsoCode(u.Address.Country, u.Address.StateCode)
                                                        , Postal_Code__c        = u.Address.ZipCode
                                                        , IE_ID__c              = u.Address.IEId
                                                        , IE_Updated_Date__c    = u.Address.LastModifiedDate
                                                        , IE_Address__c         = true
                                                        , RecordTypeId          = serviceConfig.Address_RecordType__c
                                                        , Id                    = u.Address.SFDCId  ));
            }
            
            x++;
            for(IE_IntegrationObjects.IE_Role role : u.Roles)
            {
				if (String.isNotBlank(role.UnitSFDCId))
					// only add it if it's not null, not empty and not whitespace
					AssetIds.add(role.UnitSFDCId);  // This will hold both Unit Asset Ids and GWotGo Asset Ids
            }
            
            
        }
        
		System.Debug('::::Contacts:::: ' + contacts);
		System.Debug('::::AssetIds:::: ' + AssetIds);
        
        //=====================================================
        Map<Id, Integer> contactIdToIndividualsIndex = new Map<Id, Integer>();
        // create the Contact records
        if(contacts.size() > 0)
        {
            list<Database.UpsertResult> results = database.upsert(contacts, false);
            Integer x = 0;
            for(Database.UpsertResult r : results)
            {
                response.Individuals[x].SFDCId = r.getId();
                contactIdToIndividualsIndex.put(contacts[x].Id, x);
                if(!r.isSuccess())
                {
                    response.Individuals[x].errors = new list<IE_IntegrationObjects.IE_Error>(); 
                    for(Database.Error err : r.getErrors())
                    {
                        response.Individuals[x].errors.add(new IE_IntegrationObjects.IE_Error('SALESFORCE_DML_ERROR', err.message));  
                        response.errors.add(new IE_IntegrationObjects.IE_Error('SALESFORCE_DML_ERROR', err.message)); 
                    }
                      
                }
                x++;
            }
        }
        
        //if the associated contact record has an error, remove the address record from the map
        for(Integer z : individualAddressMap.keySet())
        {
            if(response.Individuals[z].errors != null && response.Individuals[z].errors.size() > 0)
                individualAddressMap.get(z).addError('ERROR ON INDIVIDUAL: '+response.Individuals[z].errors[0].ErrorMessage);
        }
        
        
        //=====================================================
        // insert the new addresses for each Contact
        List<Address__c> addresses = new List<Address__c>();
        List<Address__c> addressesToUpdate = new List<Address__c>();
        List<Contact_Address__c> contactAddresses = new List<Contact_Address__c>();

        Map<Id, Address__c> oldAddressesWithJunctions = new Map<Id, Address__c>([SELECT Address_Line_1__c
                                              , Address_Line_2__c
                                              , Address_Line_3__c
                                              , Address_Line_4__c
                                              , City__c
                                              , Country__c
                                              , State_Province__c
                                              , Postal_Code__c
                                              , Name
                                              , OwnerId
                                              , Address_Name__c
                                              , Id
                                              , DCW_ID__c
                                              , Warehouse_Id__c
                                              , IE_ID__c
                                              , State_Province_ISO_Code__c
                                              , Country_ISO_Code__c
                                              , (SELECT Id
                                                  , Name
                                                  , Contact__c
                                                  , Address__c
                                                  , Active__c
                                                  , Mail_To__c
                                                  , Physical__c
                                                  , Contact__r.AccountId
                                                  , Primary_Mail_To__c
                                                from Contact_Addresses__r where Contact__c IN :contacts)
                                            from Address__c where Id IN :individualAddressMap.values() ]);
        //Add each address object to list
        //Add default junction for contact to list too (no address id yet, some of addresses still need to be inserted)
        for(Integer i : individualAddressMap.keySet()){
            // Filter addresses from contacts with errors
            if(contacts[i].Id != null){
                Address__c newAddress = individualAddressMap.get(i);
                addresses.add(newAddress);
                contactAddresses.add(new Contact_Address__c(Contact__c         = contacts[i].Id
                                                           ,Mail_To__c         = true
                                                           ,Primary_Mail_To__c = true));
                //Get addresses that are already on DB
                if(newAddress.Id !=null && oldAddressesWithJunctions.containsKey(newAddress.Id)){
                    newAddress.DCW_ID__c = oldAddressesWithJunctions.get(newAddress.Id).DCW_ID__c;
                    newAddress.Warehouse_Id__c = oldAddressesWithJunctions.get(newAddress.Id).Warehouse_Id__c;
                    addressesToUpdate.add(newAddress);
                }
            }
        }
        //Get actions for all addresses on DB based on values on DB
        Map<Id, String> addressActions = AddressTriggerHandler.validateAddressCanUpdate(new Map<Id, Address__c>(addressesToUpdate), oldAddressesWithJunctions, new Set<Id>());
        for(Integer i=0; i<addresses.size(); i++){
            Address__c newAddress = addresses[i];
            if(newAddress.Id != null){
                String action = addressActions.get(newAddress.Id);
                System.debug('ACTION: '+ action);
                //It hasn't changed, no need to update
                if(action==null){
                    addresses.remove(i);
                    contactAddresses.remove(i);
                    i--;
                }else {
                    // If there is no need to create new junction, get existing junction for that contact and add to the corresponding index on list
                    if(action == AddressTriggerHandler.CREATE_ADDRESS_AND_UPDATE_JUNCTION
                        || action == AddressTriggerHandler.PROCEED_WITH_UPDATE){
                        
                        Id contactId = contactAddresses[i].Contact__c;
                        for(Contact_Address__c contactAddress : oldAddressesWithJunctions.get(newAddress.Id).Contact_Addresses__r){
                            if(contactAddress.Contact__c == contactId){
                                contactAddresses[i] = contactAddress;
                                break;
                            }
                        }
                    }  
                    // If new address needs to be inserted, null id from corresponding address so that it inserts it
                    // Populates IE_Id based on prev address
                    // Nulls address lookup from junction (is going to be a new Id) 
                    if(action == AddressTriggerHandler.CREATE_ADDRESS_AND_INSERT_JUNCTION 
                        || action == AddressTriggerHandler.CREATE_ADDRESS_AND_UPDATE_JUNCTION){

                        newAddress.IE_ID__c = oldAddressesWithJunctions.get(newAddress.Id).IE_ID__c;
                        newAddress.DCW_ID__c = null;
                        newAddress.Warehouse_Id__c = null;
                        newAddress.Id = null;
                        contactAddresses[i].Address__c = null;
                    }    
                }
            }
        }
        List<Contact_Address__c> contactAddressesWithAddress = new List<Contact_Address__c>();
        // Upserts addresses  
        if(addresses.size() > 0)
        {
            List<Database.UpsertResult> results = database.upsert(addresses, false);
            
            for(Integer x = 0; x<results.size(); x++)
            {
                Database.UpsertResult r = results[x];

                Contact_Address__c contactAddress = contactAddresses[x];
                Integer individualsIndex = contactIdToIndividualsIndex.get(contactAddress.Contact__c);
                //If successful populates address of junction and response
                // Flters junctions without addresses (associated with an error)
                 System.debug('RESPONSE' + response);
                System.debug('contactAddress' + contactAddresses);
                System.debug('contactIdToIndividualsIndex' + contactIdToIndividualsIndex);

                if(r.isSuccess()){
                    contactAddress.Address__c = r.getId();
                    contactAddressesWithAddress.add(contactAddress);

                    response.Individuals[individualsIndex].Address.SFDCId = r.getId();
                //If not sucessful adds errors to response
                } else {
                    response.Individuals[individualsIndex].Address.errors = new list<IE_IntegrationObjects.IE_Error>(); 
                    for(Database.Error err : r.getErrors())
                    {
                        response.Individuals[individualsIndex].Address.errors.add(new IE_IntegrationObjects.IE_Error('SALESFORCE_DML_ERROR', err.message));   
                        response.errors.add(new IE_IntegrationObjects.IE_Error('SALESFORCE_DML_ERROR', err.message));  
                        
                    }  
                }
            }
        }
        //Inserts junctions
        if(contactAddressesWithAddress.size() > 0)
        {
            List<Database.UpsertResult> results = database.upsert(contactAddressesWithAddress, false);
            
            for(Integer x = 0; x<results.size(); x++)
            {  
                
                Database.UpsertResult r = results[x];
                Integer individualsIndex = contactIdToIndividualsIndex.get(contactAddresses[x].Contact__c);
                //Adds errors
                if(!r.isSuccess()){
                    response.Individuals[individualsIndex].Address.errors = new list<IE_IntegrationObjects.IE_Error>(); 
                    for(Database.Error err : r.getErrors())
                    {
                        response.Individuals[individualsIndex].Address.errors.add(new IE_IntegrationObjects.IE_Error('SALESFORCE_DML_ERROR', err.message));   
                        response.errors.add(new IE_IntegrationObjects.IE_Error('SALESFORCE_DML_ERROR', err.message));  
                        
                    }  
                }
            }
        }
        
        //=====================================================
        //add the Subscriptions/Roles 
        
        //retrieve the subscriptions associated with the roles' Asset Ids
		boolean standardSubTypeExists = false;
        map<Id, list<Subscription__c>> repSubscriptionMap = new map<Id, list<Subscription__c>>();
        for(Subscription__c s : [Select Id, Asset__c, Type__c, GWotGoAsset__c from Subscription__c where Asset__c in :AssetIds]) // loop through Unit Assets
        {
			if (s.Type__c == 'Standard') standardSubTypeExists = true;

            SubscriptionAssetMap.put(s.Asset__c+s.Type__c, s);
            if(repSubscriptionMap.containsKey(s.Asset__c))
            {
                list<Subscription__c> subs = repSubscriptionMap.get(s.Asset__c);
                subs.add(s);
            }
            else
            {
                repSubscriptionMap.put(s.Asset__c, new list<Subscription__c>{s});
            }
        }
		System.Debug('::::SubscriptionAssetMap:::: ' + SubscriptionAssetMap);
		System.Debug('::::repSubscriptionMap:::: ' + repSubscriptionMap);

		for(Subscription__c s : [Select Id, Asset__c, Type__c, GWotGoAsset__c from Subscription__c where GWotGoAsset__c in :AssetIds]) // loop through GWotGo Assets
        {   
            SubscriptionGWotGoAssetMap.put(s.GWotGoAsset__c+s.Type__c, s);
        }
		System.Debug('::::SubscriptionGWotGoAssetMap:::: ' + SubscriptionGWotGoAssetMap);
        

        //=====================================================
        // associate the subscriptions to the contacts
        
        //First, drop any existing contact_Subscription records
		//Except those whose Asset is the Dummy or Holding GWotGo Unit asset or records whose Role is RenewalAdministrator
		map<string, Id> csToGWotGoAssetMap = new map<string, Id>();
		map<string, Boolean> csToGWotGoPermAssocMap = new map<string, Boolean>();
        list<Contact_Subscription__c> subscriptionDropList = new list<Contact_Subscription__c>();
		list<Contact_Subscription__c> csUpdateList = new list<Contact_Subscription__c>();
        for(Contact_Subscription__c cs : [Select Id, Role__c, Contact__c, Asset__c, Subscription__c, GWotGoAsset__c, GWotGoPermAssoc__c, Asset__r.Name from Contact_Subscription__c where contact__c in :contacts and Asset__r.Name != 'Dummy GWotGo Unit Asset' and Asset__r.Name != 'Holding GWotGo Unit Asset'])
		{
			// Store GWotGo info for retrieval when creating the new CS records for a contact
			// The combination of the fields, Contact+Role+Asset+Subscription should be unique for the cs record
			csToGWotGoAssetMap.put(cs.Contact__c+cs.Role__c+cs.Asset__c+cs.Subscription__c, cs.GWotGoAsset__c);
			csToGWotGoPermAssocMap.put(cs.Contact__c+cs.Role__c+cs.Asset__c+cs.Subscription__c, cs.GWotGoPermAssoc__c);

            // Check if the role contains RenewalAdministrator and don't drop these records.
			// Role__c may contain 1 role OR 2 or more roles separated by semicolons.
			// If Role__c just contains RenewalAdministrator then don't add to the drop list.
			// If Role__c contains RenewalAdministrator as part of a list of roles then just remove all the other roles and do an Update.
			list<String> rolesList = cs.Role__c.split(';');
			if ((rolesList.size() == 1) && (rolesList[0] != 'RenewalAdministrator'))
				subscriptionDropList.add(cs);
			else if (rolesList.size() > 1)
			{
				Set<String> s = new Set<String>(rolesList);
				if (!s.contains('RenewalAdministrator'))
					subscriptionDropList.add(cs);
				else
				{
					// Contains RenewalAdministrator role, so keep it and remove the rest of the roles
					cs.Role__c = 'RenewalAdministrator';
					csUpdateList.add(cs);
				}
			}
		}
		System.Debug('::::subscriptionDropList:::: ' + subscriptionDropList);
		System.Debug('::::csUpdateList:::: ' + csUpdateList);
		System.Debug('::::csToGWotGoAssetMap:::: ' + csToGWotGoAssetMap);
		System.Debug('::::csToGWotGoPermAssocMap:::: ' + csToGWotGoPermAssocMap);

		if(csUpdateList.size() > 0)
            update csUpdateList;
            
        if(subscriptionDropList.size() > 0)
            delete subscriptionDropList;
            
            
        //list<IE_IntegrationObjects.IE_Role> roles = new list<IE_IntegrationObjects.IE_Role>();
        list<Contact_Subscription__c> subscriptionList = new list<Contact_Subscription__c>();
        for(IE_IntegrationObjects.IE_User u : Individuals)
        {
            for(IE_IntegrationObjects.IE_Role role : u.Roles)
            {
				// Valid Subscription Types in SF: Standard
				// These types will eventually be obsoleted: CustomRead, TechReadWrite, TechRead, Daikin (not IE)

				// Valid Contact-Subscription Role Types in SF: Administrator, RenewalAdministrator (not IE), SalesRep (not IE)
				// These roles will eventually be obsoleted: CustomerAdministrator, TechnicianAdministrator, Customer, Technician, EquipmentAdministrator, Engineer (not IE)

				// Stores the Subscription Type
				string subType = 'Standard'; //initialize to new default subscription type

				// Special case where the Role is Administrator but there is no Standard subscription type
				if (role.Type == 'Administrator' && !standardSubTypeExists) subType = 'TechReadWrite';

                
                if(role.Type.contains('Customer')) // Contact Roles: CustomerAdministrator, Customer
                { 
                    subType = 'CustomRead';
                }
                if(role.Type.contains('Technician')) // Contact Roles: TechnicianAdministrator, Technician
                {
                    subType = 'TechReadWrite';
                }
                if(role.Type.contains('EquipmentAdministrator') || role.Type.contains('Engineer')) // Contact Roles: EquipmentAdministrator, Engineer
                {
                    subType = 'Daikin';
                }
                
                if(SubscriptionAssetMap.containsKey(role.UnitSFDCId + subType) )
                {
                    subscriptionList.add(new Contact_Subscription__c( Role__c           =   role.Type
                                                                    , Asset__c          =   role.UnitSFDCId
                                                                    , Master_Admin__c   =   (role.MasterAdmin == null ? false : Boolean.valueOf(role.MasterAdmin)) 
                                                                    , Subscription__c   =   SubscriptionAssetMap.get(role.UnitSFDCId + subType).Id
                                                                    , Contact__c        =   u.SFDCId
																	, GWotGoAsset__c	=	csToGWotGoAssetMap.get(u.SFDCId+role.Type+role.UnitSFDCId+SubscriptionAssetMap.get(role.UnitSFDCId + subType).Id)
																	, GWotGoPermAssoc__c	=	(csToGWotGoPermAssocMap.get(u.SFDCId+role.Type+role.UnitSFDCId+SubscriptionAssetMap.get(role.UnitSFDCId + subType).Id) == null ? false :csToGWotGoPermAssocMap.get(u.SFDCId+role.Type+role.UnitSFDCId+SubscriptionAssetMap.get(role.UnitSFDCId + subType).Id))
                                                                    ));
                    //roles.add(role);
                }
                else if(role.Type == 'SalesRep' && repSubscriptionMap.containsKey(role.UnitSFDCId))
                { // TBD - I don't think this else statement ever gets hit because IE side doesn't know anything about SalesRep role, so role.type <> 'SalesRep'
                    for(Subscription__c s : repSubscriptionMap.get(role.UnitSFDCId))
                    {
                        subscriptionList.add(new Contact_Subscription__c( Role__c           =   'SalesRep'
                                                                        , Asset__c          =   role.UnitSFDCId
                                                                        , Master_Admin__c   =   (role.MasterAdmin == null ? false : Boolean.valueOf(role.MasterAdmin)) 
                                                                        , Subscription__c   =   s.Id
                                                                        , Contact__c        =   u.SFDCId
																		, GWotGoAsset__c	=	csToGWotGoAssetMap.get(u.SFDCId+'SalesRep'+role.UnitSFDCId+s.Id)
																		, GWotGoPermAssoc__c	=	(csToGWotGoPermAssocMap.get(u.SFDCId+'SalesRep'+role.UnitSFDCId+s.Id) == null ? false : csToGWotGoPermAssocMap.get(u.SFDCId+'SalesRep'+role.UnitSFDCId+s.Id))
                                                                    ));
                        //roles.add(role);
                    }
                }

				if (SubscriptionGWotGoAssetMap.containsKey(role.UnitSFDCId + subType))
                {
                    subscriptionList.add(new Contact_Subscription__c( Role__c           =   role.Type
                                                                    , Asset__c          =   SubscriptionGWotGoAssetMap.get(role.UnitSFDCId + subType).Asset__c
                                                                    , Master_Admin__c   =   (role.MasterAdmin == null ? false : Boolean.valueOf(role.MasterAdmin)) 
                                                                    , Subscription__c   =   SubscriptionGWotGoAssetMap.get(role.UnitSFDCId + subType).Id
                                                                    , Contact__c        =   u.SFDCId
																	, GWotGoAsset__c	=	role.UnitSFDCId  //csToGWotGoAssetMap.get(u.SFDCId+role.Type+SubscriptionGWotGoAssetMap.get(role.UnitSFDCId + subType).Asset__c+SubscriptionGWotGoAssetMap.get(role.UnitSFDCId + subType).Id)
																	, GWotGoPermAssoc__c	=	(csToGWotGoPermAssocMap.get(u.SFDCId+role.Type+SubscriptionGWotGoAssetMap.get(role.UnitSFDCId + subType).Asset__c+SubscriptionGWotGoAssetMap.get(role.UnitSFDCId + subType).Id) == null ? false : csToGWotGoPermAssocMap.get(u.SFDCId+role.Type+SubscriptionGWotGoAssetMap.get(role.UnitSFDCId + subType).Asset__c+SubscriptionGWotGoAssetMap.get(role.UnitSFDCId + subType).Id))
                                                                    ));
                }

            }
        }
        System.Debug('::::subscriptionList:::: ' + subscriptionList);
        
        
        
        //=============================
        // insert Contact Subscriptions
        if(subscriptionList.size() > 0)
        {
            Integer i = 0;
            list<Database.SaveResult> results = database.insert(subscriptionList, false);
            for(Database.SaveResult r : results)
            {
                if(!r.isSuccess())
                {
                    //roles[i].errors = new list<IE_IntegrationObjects.IE_Error>();
                    for(Database.Error err : r.getErrors())
                    {
                        //roles[i].errors.add(new IE_IntegrationObjects.IE_Error('SALESFORCE_DML_ERROR', err.message));
                        response.errors.add(new IE_IntegrationObjects.IE_Error('SALESFORCE_DML_ERROR', err.message));
                    }
                }
                i++;
            }
        }

		System.Debug('::::response:::: ' + response);

        return response;
    }
}
@RestResource(urlMapping='/RetrieveAsset/*')
global with sharing class RetrieveAssetService {
 
 	global class SubscriptionInfo
 	{
 		public integer RenewalCounter{get;set;}
        public date EndDate{get;set;}
        public string ConnectivityType{get;set;}
        public decimal TermYears{get;set;}
 	}

 	global class ContactInfo
 	{
 		public string Name{get;set;}
 		public string Email{get;set;}
 	}

    global class ServiceAsset
    {
        public string   AssetId{get;set;}
        public string   SerialNumber{get;set;}
        public string   Model{get;set;}
        public string   ProductName{get;set;}
        public boolean  Valid{get;set;}
        public string CodeStringFormat{get;set;}
        public list<string> CodeValues{get;set;}

        public string CodeString{get;set;}
        public string JobName{get;set;}
        public string UnitTag{get;set;}
        public string JobAddressLine1{get;set;}
        public string JobAddressCity{get;set;}
        public string JobAddressState{get;set;}
        public string JobAddressCountry{get;set;}
        public string JobAddressPostalCode{get;set;}
        public string GWSerialNumber{get;set;}
		public boolean GWOnTheGo{get;set;}
        public string GWICCID{get;set;}
        public string GWDeviceID{get;set;}
        public string GWMACAddress{get;set;}
        public string EMMSerialNumber{get;set;}
		public string GWResetSuccessful{get;set;}

        // IE Renewal fields
        public boolean IEAsset{get;set;}
        public boolean SIMCardActive{get;set;}
        public List<SubscriptionInfo> Subscriptions{get;set;}
        public list<ContactInfo> SubscriptionRenewalOwnersEmail{get;set;}

		public boolean UnitIESupportedModel{get;set;}
		public list<ContactInfo> GWContacts{get;set;}
    }
    
    
    @HttpGet
    global Static ServiceAsset getAsset()
    {
		// Pass in SN of the unit asset or GWotGo asset
        string serialNum = RestContext.request.params.get('SerialNumber'); 
        ServiceAsset response = new ServiceAsset();
        response.SerialNumber = serialNum;
        response.Valid = false;
        response.SIMCardActive = false;
        response.Subscriptions = null;
        response.SubscriptionRenewalOwnersEmail = null;
		response.IEAsset = false;
		response.UnitIESupportedModel = false;
		response.GWContacts = null;
		response.GWOnTheGo = false;
        
        for(Asset a : [select SerialNumber
                            , Product2.ProductCode
                            , Product2.Name
                            , Id
							, Name
                            , Format_Number__c
                            , Current_Code_String_Breakdown__c
                            , Code_String_Breakdown__c
                            , IE_Asset__c
                            , Code_String__c
                            , Job_Name__c
                            , Tag__c
                            , Asset_Address_Line_1__c
                            , Asset_City__c
                            , Asset_State_Province__c
                            , Asset_Country__c
                            , Asset_Postal_Code__c
							, SIM_Card_Active__c
							, SIM_Card_ICCID__c
							, Device_ID__c
							, MAC_Address__c
							, GWotGo__c
							, ResetSuccessful__c
							, Status
                            , (Select Id, Name, SerialNumber, SIM_Card_Active__c, Product2.Name, SIM_Card_ICCID__c, Device_ID__c, MAC_Address__c, GWotGo__c From Assets__r where Status != 'Obsolete')
                            , (Select Id, Type__c, Name, Connectivity_Type__c, End_Date__c, Term_Years__c, Renewal_Counter__c, Renewal_Date__c, Serial_Number__c, Start_Date__c, Last_Renewal_Date__c From Subscriptions__r)
                            , (Select Name, Role__c, Subscription__c, Contact__r.Name, Contact__r.Email From Contact_Subscriptions__r)

							// Sub-queries used for when GWotGo SN is passed in
							, (Select Id, Type__c, Name, Connectivity_Type__c, End_Date__c, Term_Years__c, Renewal_Counter__c, Renewal_Date__c, Serial_Number__c, Start_Date__c, Last_Renewal_Date__c, GWotGoAsset__c From Subscriptions1__r)
                            , (Select Name, Role__c, Subscription__c, Contact__r.Name, Contact__r.Email, GWotGoAsset__c, GWotGoPermAssoc__c From Contact_Subscriptions1__r)
                        from Asset
                       where SerialNumber = :serialNum])    
        {
			if ((a.Product2.Name == 'Intelligent Equipment Gateway') || (a.Name == 'Intelligent Equipment Gateway')) {
				if (a.Status != 'Obsolete')  //((a.Status != 'Obsolete') && (a.SIM_Card_Active__c != false))
				{
					// Serial number passed in is a Gateway asset
					System.debug(logginglevel.error, 'Serial number passed in is a Gateway asset = ' + serialNum);

					response.SerialNumber = a.SerialNumber;  //just set to GW SN since there is no parent asset
					response.Model = a.Product2.ProductCode;
					response.ProductName = a.Product2.Name;
					response.AssetId = a.Id;
					response.Valid = true;
					response.SIMCardActive = a.SIM_Card_Active__c;
					response.GWSerialNumber = a.SerialNumber;
					response.GWICCID = a.SIM_Card_ICCID__c;
					response.GWDeviceID = a.Device_ID__c;
					response.GWMACAddress = a.MAC_Address__c;
					response.GWOnTheGo = a.GWotGo__c;
					response.GWResetSuccessful = a.ResetSuccessful__c;

					List<Contact_Subscription__c> subscriptionContacts = a.Contact_Subscriptions1__r;
					list<ContactInfo> contactList = new List<ContactInfo>();
					list<ContactInfo> contactList2 = new List<ContactInfo>();
					for (Contact_Subscription__c cs: subscriptionContacts) {
						// Get list of Permanent contacts
            			if (cs.GWotGoPermAssoc__c == true) {
            				ContactInfo ci = new ContactInfo();
            				ci.Name = cs.Contact__r.Name;
            				ci.Email = cs.Contact__r.Email;

							// Only add to the contactList if the contact with this email doesn't exist already
							boolean found = false;
							for (ContactInfo ciTemp: contactList) {
								if (String.isNotEmpty(ciTemp.Email) && ciTemp.Email.containsIgnoreCase(ci.Email)) {
									found = true;
								}
							}

            				if (!found) contactList.add(ci);
            			}

						// Get list of contacts that are RenewalAdministrator
						String roles = cs.Role__c;
            			if (String.isNotEmpty(roles) && roles.contains('RenewalAdministrator')) {
            				ContactInfo ci = new ContactInfo();
            				ci.Name = cs.Contact__r.Name;
            				ci.Email = cs.Contact__r.Email;

							// Only add to the contactList2 if the contact with this email doesn't exist already
							boolean found = false;
							for (ContactInfo ciTemp: contactList2) {
								if (String.isNotEmpty(ciTemp.Email) && ciTemp.Email.containsIgnoreCase(ci.Email)) {
									found = true;
								}
							}

            				if (!found) contactList2.add(ci);
            			}
					}
					response.GWContacts = contactList;
					response.SubscriptionRenewalOwnersEmail = contactList2;


					List<Subscription__c> subscriptionList = a.Subscriptions1__r;
					list<SubscriptionInfo> subscriptionInfoList = new List<SubscriptionInfo>();
					for (Subscription__c s: subscriptionList) {
            			if (s.Type__c == 'TechReadWrite' || s.Type__c == 'Standard') {
            				SubscriptionInfo si = new SubscriptionInfo();
							si.TermYears = s.Term_Years__c;

							if (s.Renewal_Counter__c != null)
            					si.RenewalCounter = s.Renewal_Counter__c.intValue();
							else
								si.RenewalCounter = 0;

            				si.EndDate = s.End_Date__c.date();
            				si.ConnectivityType = s.Connectivity_Type__c;
            				subscriptionInfoList.add(si);
            			}
					}
					response.Subscriptions = subscriptionInfoList;
				}
				else {
					// Serial number passed in is a Gateway asset but its status is Obsolete so skip it
					System.debug(logginglevel.error, 'Serial number passed in is a Gateway asset but its Obsolete so its skipped = ' + serialNum);
				}
			}
			else {
				// Serial number passed in is a unit (equipment) asset
				System.debug(logginglevel.error, 'Serial number passed in is a unit (equipment) asset = ' + serialNum);
				
				string codeStringBreakDown = '';
            
				if(a.Current_Code_String_Breakdown__c != null) 
					codeStringBreakDown = a.Current_Code_String_Breakdown__c;
				else  
					codeStringBreakDown = a.Code_String_Breakdown__c;
                
				response.SerialNumber   = a.SerialNumber;
				response.Model          = a.Product2.ProductCode;
				response.ProductName    = a.Product2.Name;
				response.AssetId        = a.Id;
				response.Valid          = true;
				response.CodeStringFormat = a.Format_Number__c;
				response.CodeValues = IERenewal_ExtWebServiceCallouts.getCodeStringValues(codeStringBreakDown); //Batch_Sync_IE_Unit.getCodeStringValues(codeStringBreakDown);
            
				response.CodeString = a.Code_String__c;
				response.JobName = a.Job_Name__c;
				response.UnitTag = a.Tag__c;
				response.JobAddressLine1 = a.Asset_Address_Line_1__c;
				response.JobAddressCity = a.Asset_City__c;
				response.JobAddressState = a.Asset_State_Province__c;
				response.JobAddressCountry = a.Asset_Country__c;
				response.JobAddressPostalCode = a.Asset_Postal_Code__c;

				response.IEAsset = a.IE_Asset__c;
				response.UnitIESupportedModel = isIESupportedModel(a.Code_String__c); //isIESupportedModel(a.Product2.ProductCode);

				List<Asset> relatedAssets = a.Assets__r;
				for (Asset ast: relatedAssets) {
            		if ((ast.Product2.Name == 'Intelligent Equipment Gateway') || (ast.Name == 'Intelligent Equipment Gateway')) {
            			response.SIMCardActive = ast.SIM_Card_Active__c;
						response.GWSerialNumber = ast.SerialNumber;
						response.GWICCID = ast.SIM_Card_ICCID__c;
						response.GWDeviceID = ast.Device_ID__c;
						response.GWMACAddress = ast.MAC_Address__c;
						response.GWOnTheGo = ast.GWotGo__c;
            		}
					else if ((ast.Product2.Name == 'Intelligent Equipment Energy Management Module') || (ast.Name == 'Intelligent Equipment Energy Management Module')) {
						response.EMMSerialNumber = ast.SerialNumber;
					}
				}

				List<Contact_Subscription__c> subscriptionContacts = a.Contact_Subscriptions__r;
				list<ContactInfo> contactList = new List<ContactInfo>();
				for (Contact_Subscription__c cs: subscriptionContacts) {
            		String roles = cs.Role__c;
            		if (String.isNotEmpty(roles) && roles.contains('RenewalAdministrator')) {
            			ContactInfo ci = new ContactInfo();
            			ci.Name = cs.Contact__r.Name;
            			ci.Email = cs.Contact__r.Email;

						// Only add to the contactList if the contact with this email doesn't exist already
						boolean found = false;
						for (ContactInfo ciTemp: contactList) {
							if (String.isNotEmpty(ciTemp.Email) && ciTemp.Email.containsIgnoreCase(ci.Email)) {
								found = true;
							}
						}

            			if (!found) contactList.add(ci);
            		}
				}
				response.SubscriptionRenewalOwnersEmail = contactList;

				List<Subscription__c> subscriptionList = a.Subscriptions__r;
				list<SubscriptionInfo> subscriptionInfoList = new List<SubscriptionInfo>();
				for (Subscription__c s: subscriptionList) {
            		if (s.Type__c == 'TechReadWrite' || s.Type__c == 'Standard') {
            			SubscriptionInfo si = new SubscriptionInfo();
						si.TermYears = s.Term_Years__c;

						if (s.Renewal_Counter__c != null)
            				si.RenewalCounter = s.Renewal_Counter__c.intValue();
						else
							si.RenewalCounter = 0;

            			si.EndDate = s.End_Date__c.date();
            			si.ConnectivityType = s.Connectivity_Type__c;
            			subscriptionInfoList.add(si);
            		}
				}
				response.Subscriptions = subscriptionInfoList;
			}

        } // for-loop

		System.debug(logginglevel.error, 'RetrieveAssetService Response object = ' + response);
        
        return response;
    }


	public static Boolean isIESupportedModel(String model)
    {
        Boolean supported = false;
		string prefix = null;
		string letter = '';

		if (String.isNotEmpty(model) && (model.length() >= 3))
		{
			prefix = model.substring(0, 3);

			//For AGZ model look at the 7th character in the string to get the corresponding letter for verification (D or E).
			//We will only see a 3 digit tonnage in the model, e.g., AGZ055D or AGZ190E

			//For WME models look at the 9th character in the string to get the vintage code letter for verification.
			//Accept all vintage code letters except (C), e.g., WME0700SS, WME1000DB

			if (prefix.trim().equalsIgnoreCase('AGZ') && (model.length() >= 7))
				letter = model.substring(6, 7);
			else if (prefix.trim().equalsIgnoreCase('WME') && (model.length() >= 9))
				letter = model.substring(8, 9);

			if (prefix.trim().equalsIgnoreCase('DPS')) {
				// Rebel
				supported = true;
			}
			else if (prefix.trim().equalsIgnoreCase('MPS')) {
				// Mav-II
				supported = true;
			}
			else if (prefix.trim().equalsIgnoreCase('RAH') || prefix.trim().equalsIgnoreCase('RDS') ||
					prefix.trim().equalsIgnoreCase('RDT') || prefix.trim().equalsIgnoreCase('RFS') ||
					prefix.trim().equalsIgnoreCase('RPR') || prefix.trim().equalsIgnoreCase('RPS')) {
				// Roofpak
				supported = true;
			}
			else if (prefix.trim().equalsIgnoreCase('AGZ') && (letter.equalsIgnoreCase('D') || letter.equalsIgnoreCase('E'))) {
				// Trailblazer
				supported = true;
			}
			else if (prefix.trim().equalsIgnoreCase('AWV') || prefix.trim().equalsIgnoreCase('AWS')) {
				// Pathfinder
				supported = true;
			}
			else if (prefix.trim().equalsIgnoreCase('AMZ')) {
				// Scroll Air Cooled Chiller
				supported = true;
			}
			else if (prefix.trim().equalsIgnoreCase('WMC')) {
				// Centrifugal Water Cooled Chiller
				supported = true;
			}
			else if (prefix.trim().equalsIgnoreCase('WME') && !letter.equalsIgnoreCase('C')) {
				// Water Cooled Magnetic Bearing Centrifugal Chiller
				supported = true;
			}
		}

        System.debug(logginglevel.error, 'Model = ' + model + ' prefix = ' + prefix + ' letter = ' + letter + ' IE supported model = ' + supported);
        return supported;
    }

}

/* ***Use this SOQL query in the Workbench to return desired records***
select SerialNumber
                            , Product2.ProductCode
                            , Product2.Name
                            , Id
							, Name
                            , Format_Number__c
                            , Current_Code_String_Breakdown__c
                            , Code_String_Breakdown__c
                            , IE_Asset__c
                            , Code_String__c
                            , Job_Name__c
                            , Tag__c
                            , Asset_Address_Line_1__c
                            , Asset_City__c
                            , Asset_State_Province__c
                            , Asset_Country__c
                            , Asset_Postal_Code__c
							, SIM_Card_Active__c
							, SIM_Card_ICCID__c
							, Device_ID__c
							, MAC_Address__c
							, GWotGo__c
                            , (Select Id, Name, SerialNumber, SIM_Card_Active__c, Product2.Name, SIM_Card_ICCID__c, Device_ID__c, MAC_Address__c, GWotGo__c From Assets__r where Status != 'Obsolete')
                            , (Select Id, Type__c, Name, Connectivity_Type__c, End_Date__c, Term_Years__c, Renewal_Counter__c, Renewal_Date__c, Serial_Number__c, Start_Date__c, Last_Renewal_Date__c From Subscriptions__r)
                            , (Select Name, Role__c, Subscription__c, Contact__r.Name, Contact__r.Email From Contact_Subscriptions__r)
							// Sub-queries used for when GWotGo SN is passed in
							, (Select Id, Type__c, Name, Serial_Number__c, GWotGoAsset__c From Subscriptions1__r)
                            , (Select Name, Role__c, Contact__r.Name, Contact__r.Email, GWotGoAsset__c, GWotGoPermAssoc__c From Contact_Subscriptions1__r)
                        from Asset
                       where SerialNumber = 'FBOU150900980'
*/

// ***Testing the webservice in Workbench REST Explorer***
// Use the Get HTTP method on the following REST API Service URI: /services/apexrest/RetrieveAsset?SerialNumber=FBOU150900980
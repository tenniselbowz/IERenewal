public with sharing class IERenewal_ExtWebServiceCallouts {
	/*********************************************************************
	  * NOTE: The following set of Test Classes will test this class.
	  * These would all need to be run to get > 75% code coverage.
	  * 
	  * Batch_IE_DeactPrevMonthExpSubAndSta_Test
	  * Batch_IE_ProcObsGWAssets_Test
	  * Batch_IE_CallExtWebServices_Test
	  * ResetGWotGoAsset_Test
	  * IERenewal_ExtWebServiceCallouts_Test
	  **********************************************************************/

	public static void processIESubscriptionOrder(list<Subscription__c> subscriptions, list<Integration_Error__c> integrationErrorList)
	{
		// Call the AT&T CC Web Service API

		// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'processIESubscriptionOrder errors: ';
		String simCardICCID = null;
    	boolean hasErrors = false;
		boolean hasIETimeout = false;


    	try {
	    	// Pull the AT&T credentials from a custom setting 
			ATT_Jasper_API_REST_Services_Config__c serviceConfig = ATT_Jasper_API_REST_Services_Config__c.getInstance();

			IERenewal_ATTJasperAPIServiceResponseObj putDeviceRespObj = new IERenewal_ATTJasperAPIServiceResponseObj();
			IERenewal_ATTJasperAPIServiceAccess restPutDevice = new IERenewal_ATTJasperAPIServiceAccess(serviceConfig.Base_URL__c, serviceConfig.API_Key__c, 'devices', serviceConfig.User_Name__c, serviceConfig.Enterprise_Account_Id__c);

			IERenewal_ATTJasperAPIServiceResponseObj getDeviceRespObj = new IERenewal_ATTJasperAPIServiceResponseObj();
			IERenewal_ATTJasperAPIServiceAccess restGetDevice = new IERenewal_ATTJasperAPIServiceAccess(serviceConfig.Base_URL__c, serviceConfig.API_Key__c, 'devices', serviceConfig.User_Name__c, serviceConfig.Enterprise_Account_Id__c);


			// Bulkify Parent Asset SOQL query
			map<Id, Asset> parentAssetMap = new map<Id, Asset>();
	        set<Id> parentAssetIds = new set<Id>();
	        for (Subscription__c s : subscriptions)
	        {
	            if (s.Asset__c != null)
	                parentAssetIds.add(s.Asset__c);
	        }
	        for (Asset a : [SELECT Id, Order__c, AccountId, Product2.ProductCode, Product2.Name, SerialNumber, Tag__c from Asset where Id in :parentAssetIds])
	        	parentAssetMap.put(a.Id, a);


	        // Bulkify Order__c SOQL query
			map<Id, Order__c> orderMap = new map<Id, Order__c>();
	        set<Id> orderIds = new set<Id>();
	        for (Asset a : parentAssetMap.values())
	        {
	            if (a.Order__c != null)
	                orderIds.add(a.Order__c);
	        }
	        for (Order__c o : [SELECT Id, Order_Type_ID__c from Order__c Where Id in :orderIds])
	        	orderMap.put(o.Id, o);


	        // Bulkify Gateway Asset SOQL query
			map<Id, Asset> gatewayAssetMap = new map<Id, Asset>();
	        set<Id> gatewayParentAssetIds = new set<Id>();
	        for (Asset a : parentAssetMap.values())
	        {
	            if (a.Id != null)
	                gatewayParentAssetIds.add(a.Id);
	        }
	        for (Asset a : [SELECT Id, Parent_Asset__c, SIM_Card_Active__c, SIM_Card_ICCID__c, MAC_Address__c, Status, GWotGo__c from Asset Where (Name = 'Intelligent Equipment Gateway' OR Product2.Name = 'Intelligent Equipment Gateway') AND Status != 'Obsolete' AND Parent_Asset__c in :gatewayParentAssetIds])
	        	gatewayAssetMap.put(a.Parent_Asset__c, a);




			for (Subscription__c s : subscriptions)
			{
				if ((s.TriggerInvokedByAPI__c == true) && (s.Type__c == 'TechReadWrite' || s.Type__c == 'TechRead' || s.Type__c == 'Standard'))
				{
					// Only process if trigger was invoked by an ETL Insert or an IE Renewal Web Service Call Update or could be used by a Batch Job
					// Only process subscriptions of TechReadWrite type since the pair have the same Parent asset and GW asset OR if the type is just Standard.

					Asset parentAsset=null;
					Order__c theOrder=null;
					Asset gatewayAsset=null;
					simCardICCID = null;

					parentAsset = parentAssetMap.get(s.Asset__c);

					if (parentAsset != null) {
						theOrder = orderMap.get(parentAsset.Order__c);

						if (theOrder != null) {
							gatewayAsset = gatewayAssetMap.get(parentAsset.Id);

							if (gatewayAsset != null) {
								if (String.isNotBlank(gatewayAsset.SIM_Card_ICCID__c)) {
									if (!gatewayAsset.SIM_Card_ICCID__c.trim().isNumeric()) {
			            				// Sim Card ICCID should be a 20 digit number, remove any leading or trailing text
			            				// ASCII code integer values for characters '0' to '9' are 48 to 57
			            				Integer[] chars = gatewayAsset.SIM_Card_ICCID__c.trim().getChars();
			            				list<Integer> charArray = new List<Integer>();
			            				for (Integer i : chars) {
			            					if ((i >= 48) && (i <= 57))
			            						charArray.add(i);
			            				}

			            				simCardICCID = String.fromCharArray(charArray);
			            			}
			            			else {
			            				simCardICCID = gatewayAsset.SIM_Card_ICCID__c.trim();
			            			}
								}
							}
						}
					}
		            

					if (simCardICCID != null) {
						// Get device info for sim card iccid
						if (!Test.isRunningTest()) {
							// Test isn't running so call the service
			            	getDeviceRespObj = restGetDevice.getDeviceByICCID(simCardICCID, integrationErrorList);

							System.debug(LoggingLevel.ERROR, getDeviceRespObj);

			            	if (getDeviceRespObj.getResponseCode() != 200) {
			            		hasErrors = true;
			            		errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + getDeviceRespObj.getResponseCode() + ', from call to get device info by sim card iccid!';
								continue; //skip to the next iteration of the loop
			            	}
			        	}
			        	else {
			        		// Test is running so mock a response
			        		getDeviceRespObj.setResponseCode(200);
			        		if (theOrder.Order_Type_ID__c == 'Domestic')
			        			// Set current device response to a domestic plan
			        			getDeviceRespObj.setResponseData('{"iccid":"89011704258018735310","imsi":"310170801873531","msisdn":"882350801873531","imei":"351579050703680","status":"ACTIVATION_READY","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA","customer":"Daikin Test","endConsumerId":null,"dateActivated":"2015-01-30 20:18:11.755+0000","dateAdded":"2014-02-14 00:11:35.784+0000","dateUpdated":"2017-01-23 19:41:44.491+0000","dateShipped":"2014-03-04 00:00:00.000+0000","accountId":"100414901","fixedIPAddress":null,"operatorCustom1":"","operatorCustom2":"","operatorCustom3":"","operatorCustom4":"","operatorCustom5":"","accountCustom1":"","accountCustom2":"","accountCustom3":"","accountCustom4":"","accountCustom5":"","accountCustom6":"","accountCustom7":"","accountCustom8":"","accountCustom9":"","accountCustom10":"","customerCustom1":"","customerCustom2":"","customerCustom3":"","customerCustom4":"","customerCustom5":"","simNotes":null,"deviceID":"Controls Lab/Simulator","modemID":"00600c:816eec","globalSimType":""}');
			        		else
			        			// Set current device response to a international plan
			        			getDeviceRespObj.setResponseData('{"iccid":"89011704258018735310","imsi":"310170801873531","msisdn":"882350801873531","imei":"351579050703680","status":"ACTIVATION_READY","ratePlan":"Daikin Applied - 50MB US_CAN_MEX Plan","communicationPlan":"Daikin Applied - AT&T Data MT - INT","customer":"Daikin Test","endConsumerId":null,"dateActivated":"2015-01-30 20:18:11.755+0000","dateAdded":"2014-02-14 00:11:35.784+0000","dateUpdated":"2017-01-23 19:41:44.491+0000","dateShipped":"2014-03-04 00:00:00.000+0000","accountId":"100414901","fixedIPAddress":null,"operatorCustom1":"","operatorCustom2":"","operatorCustom3":"","operatorCustom4":"","operatorCustom5":"","accountCustom1":"","accountCustom2":"","accountCustom3":"","accountCustom4":"","accountCustom5":"","accountCustom6":"","accountCustom7":"","accountCustom8":"","accountCustom9":"","accountCustom10":"","customerCustom1":"","customerCustom2":"","customerCustom3":"","customerCustom4":"","customerCustom5":"","simNotes":null,"deviceID":"Controls Lab/Simulator","modemID":"00600c:816eec","globalSimType":""}');
			        	}
			            DeviceDetailsResponse getDeviceInfoResponse = new DeviceDetailsResponse();
			            getDeviceInfoResponse = (DeviceDetailsResponse)JSON.deserialize(getDeviceRespObj.getResponseData(), DeviceDetailsResponse.class);

						System.debug(LoggingLevel.ERROR, 'Status=' + getDeviceInfoResponse.status + ', Device Id=' + getDeviceInfoResponse.deviceID + ', Modem Id=' + getDeviceInfoResponse.modemID);


			            // If subscription connectivity type is Cellular then call the AT&T CC Web Service API to set the SIM card status to "ACTIVATED"
			            if (s.Connectivity_Type__c == 'Cellular') {
			            	// first check if the status is already set to "ACTIVATED" and if it is then do nothing
			            	if (getDeviceInfoResponse.status != 'ACTIVATED') {
			            		if (!Test.isRunningTest()) {
			            			// Test isn't running so call the service
			            			putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, 'ACTIVATED', null, null, null, null, null, integrationErrorList);

			            			if (putDeviceRespObj.getResponseCode() != 200) {
			            				hasErrors = true;
			            				errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to set the sim card status to Activation Ready!';
			            			}
			            		}
			            		else {
					        		// Test is running so mock a response
					        		putDeviceRespObj.setResponseCode(200);
					        		putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
					        	}
			            	}
			            }


			            // If it's a Kit/Factory order then call the AT&T CC Web Service API to set the following parameters:
			            // Customer = "DaikinDX"  NOTE: This parameter is not set anymore
			            // Device ID = <Model-Serial# (Order Tag)>, limited to 50 characters and cannot contain commas (,) or asterisks (*)
			            // Modem ID = <MAC Address>
			            if (((s.Term_Years__c == 5.25) || (s.Term_Years__c == 3.25) || (s.Term_Years__c == 1.25) || (s.Term_Years__c == 0.50) || (s.Term_Years__c == 0.25)) && 
							((s.Renewal_Counter__c == 0) || (s.Renewal_Counter__c == null))) 
						{
			            	String deviceId = parentAsset.Product2.ProductCode + ' - ' + parentAsset.SerialNumber + ' (' + parentAsset.Tag__c + ')';
							// Replace any (,) or (*) with (_) and limit to max of 50 characters if necessary
							deviceId = deviceId.replace(',', '_');
							deviceId = deviceId.replace('*', '_');
							if (deviceId.length() > 50)
								deviceId = deviceId.substring(0, 49);


							string macaddr = gatewayAsset.MAC_Address__c;
							string macaddr2;
							if (String.isNotBlank(macaddr) && (macaddr.length() == 12))
							{
								Integer[] chars = macaddr.getChars();
								list<Integer> charArray = new List<Integer>();
								integer cnt = 0;
								for (Integer i : chars) {
									cnt++;
									charArray.add(i);
									if (cnt == 6)
										charArray.add(58); // add a colon (ascii 58) after 6th character
								}
								macaddr2 = String.fromCharArray(charArray);
							}
							else {
								macaddr2 = macaddr;
							}


		            		if (!Test.isRunningTest()) {
		            			// Test isn't running so call the service
		            			putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, null, null, null, null, deviceId, macaddr2, integrationErrorList);

		            			if (putDeviceRespObj.getResponseCode() != 200) {
			            			hasErrors = true;
			            			errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to set parameters for Kit/Factory order!';
			            		}
		            		}
		            		else {
				        		// Test is running so mock a response
				        		putDeviceRespObj.setResponseCode(200);
				        		putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
				        	}
			            }


						// NOTE: These parameters will not be set anymore
			            // Call the AT&T CC Web Service API to set the SIM card data rate plan and communication plan
			            // to the appropriate values based on job location of International or Domestic
			            /*if (theOrder.Order_Type_ID__c == 'International') {
			            	// First check what the current rate plan is
			            	// If it's a domestic plan then set to the equivalent international plan and set communication plan
			            	// If it's already set to an international plan then check communication plan
			            	String commPlan = 'DataXoom - AT&T Data MT - INT RES-157';  // International Communication plan
			            	String intlPlan = GetIntlPlan(getDeviceInfoResponse.ratePlan);

							if (!Test.isRunningTest()) {
			            		// Test isn't running so call the service
			            		putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, null, intlPlan, commPlan, null, null, null, integrationErrorList);

			            		if (putDeviceRespObj.getResponseCode() != 200) {
			            			hasErrors = true;
			            			errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to set data rate plan!';
			            		}
			            	}
			            	else {
					        	// Test is running so mock a response
					        	putDeviceRespObj.setResponseCode(200);
					        	putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
					        }
			            }
			            else if (theOrder.Order_Type_ID__c == 'Domestic') {
			            	// First check what the current rate plan is
			            	// If it's a international plan then set to the equivalent domestic plan and set communication plan
			            	// If it's already set to an domestic plan then check communication plan
			            	String commPlan = 'DataXoom - AT&T Data MT - IFA RES-155';  // Domestic Communication plan
			            	String domesticPlan = GetDomesticPlan(getDeviceInfoResponse.ratePlan);

							if (!Test.isRunningTest()) {
			            		// Test isn't running so call the service
			            		putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, null, domesticPlan, commPlan, null, null, null, integrationErrorList);

			            		if (putDeviceRespObj.getResponseCode() != 200) {
			            			hasErrors = true;
			            			errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to set data rate plan!';
			            		}
			            	}
			            	else {
					        	// Test is running so mock a response
					        	putDeviceRespObj.setResponseCode(200);
					        	putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
					        }
			            }*/

					}
	        	}
			}
    	}
    	catch (Exception e) {
			//Do not rethrow exception, so IE processing can continue. Just log the error.

			hasErrors = true;
			errorMsg = errorMsg + ' | ' + 'CALLOUT_EXCEPTION ' + e.getMessage() + ' | IE process not aborted but SIM card ' + simCardICCID + ' may need to be Activated manually';
			
			System.debug(errorMsg);

			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
									, Error_Description__c = 'processIESubscriptionOrder'
									, Integration_Object__c = 'AT&T Control Center'
									, Integration_Point__c = 'IE'
									, Request_Data__c = errorMsg));
	
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;
   		}

	}


	public static void updateSimCardObjectCellularInfo(Asset gwAsset, Asset unitAsset, Subscription__c subn, list<Integration_Error__c> integrationErrorList)
	{
		// Call the AT&T CC Web Service API

		// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'updateSimCardObjectCellularInfo errors: ';
    	String simCardICCID = null;
		boolean hasErrors = false;
		boolean hasIETimeout = false;


    	try {
	    	// Pull the AT&T credentials from a custom setting 
			ATT_Jasper_API_REST_Services_Config__c serviceConfig = ATT_Jasper_API_REST_Services_Config__c.getInstance();

			IERenewal_ATTJasperAPIServiceResponseObj putDeviceRespObj = new IERenewal_ATTJasperAPIServiceResponseObj();
			IERenewal_ATTJasperAPIServiceAccess restPutDevice = new IERenewal_ATTJasperAPIServiceAccess(serviceConfig.Base_URL__c, serviceConfig.API_Key__c, 'devices', serviceConfig.User_Name__c, serviceConfig.Enterprise_Account_Id__c);

			IERenewal_ATTJasperAPIServiceResponseObj getDeviceRespObj = new IERenewal_ATTJasperAPIServiceResponseObj();
			IERenewal_ATTJasperAPIServiceAccess restGetDevice = new IERenewal_ATTJasperAPIServiceAccess(serviceConfig.Base_URL__c, serviceConfig.API_Key__c, 'devices', serviceConfig.User_Name__c, serviceConfig.Enterprise_Account_Id__c);

			simCardICCID = null;
			Order__c theOrder = null;
			String holdingOrderTypeId = null;

			if (unitAsset.Name != 'Holding GWotGo Unit Asset') {
				if ((unitAsset != null) && (unitAsset.Order__c != null))
					theOrder = [SELECT Id, Order_Type_ID__c from Order__c Where Id = :unitAsset.Order__c];
				else {
					generalException ex = new generalException();
					if (unitAsset == null)
						ex.setMessage('Unit Asset does not exist in salesforce');
					else 
						ex.setMessage('The unit asset is not associated with any order');
					throw ex;
				}
			}
			else {
				// The unit asset is the "Holding GWotGo Unit Asset" which doesn't have an actual order so fake one
				holdingOrderTypeId = 'Domestic';
			}

			
			if ((theOrder != null) || (holdingOrderTypeId == 'Domestic')) {
				if (gwAsset != null) {
					if (String.isNotBlank(gwAsset.SIM_Card_ICCID__c)) {
						if (!gwAsset.SIM_Card_ICCID__c.trim().isNumeric()) {
			            	// Sim Card ICCID should be a 20 digit number, remove any leading or trailing text
			            	// ASCII code integer values for characters '0' to '9' are 48 to 57
			            	Integer[] chars = gwAsset.SIM_Card_ICCID__c.trim().getChars();
			            	list<Integer> charArray = new List<Integer>();
			            	for (Integer i : chars) {
			            		if ((i >= 48) && (i <= 57))
			            			charArray.add(i);
			            	}

			            	simCardICCID = String.fromCharArray(charArray);
			            }
			            else {
			            	simCardICCID = gwAsset.SIM_Card_ICCID__c.trim();
			            }
					}
				}
			}


			if (simCardICCID != null) {
				// Get device info for sim card iccid
				if (!Test.isRunningTest()) {
					// Test isn't running so call the service
			        getDeviceRespObj = restGetDevice.getDeviceByICCID(simCardICCID, integrationErrorList);

					System.debug(LoggingLevel.ERROR, getDeviceRespObj);

			        if (getDeviceRespObj.getResponseCode() != 200) {
			            hasErrors = true;
			            errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + getDeviceRespObj.getResponseCode() + ', from call to get device info by sim card iccid!';
			        }
			    }
			    else {
			        // Test is running so mock a response
			        getDeviceRespObj.setResponseCode(200);
					if (theOrder != null) {
						if (theOrder.Order_Type_ID__c == 'Domestic')
			        		// Set current device response to a domestic plan
			        		getDeviceRespObj.setResponseData('{"iccid":"89011704258018735310","imsi":"310170801873531","msisdn":"882350801873531","imei":"351579050703680","status":"ACTIVATION_READY","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA","customer":"Daikin Test","endConsumerId":null,"dateActivated":"2015-01-30 20:18:11.755+0000","dateAdded":"2014-02-14 00:11:35.784+0000","dateUpdated":"2017-01-23 19:41:44.491+0000","dateShipped":"2014-03-04 00:00:00.000+0000","accountId":"100414901","fixedIPAddress":null,"operatorCustom1":"","operatorCustom2":"","operatorCustom3":"","operatorCustom4":"","operatorCustom5":"","accountCustom1":"","accountCustom2":"","accountCustom3":"","accountCustom4":"","accountCustom5":"","accountCustom6":"","accountCustom7":"","accountCustom8":"","accountCustom9":"","accountCustom10":"","customerCustom1":"","customerCustom2":"","customerCustom3":"","customerCustom4":"","customerCustom5":"","simNotes":null,"deviceID":"Controls Lab/Simulator","modemID":"00600c:816eec","globalSimType":""}');
						else
			        		// Set current device response to a international plan
			        		getDeviceRespObj.setResponseData('{"iccid":"89011704258018735310","imsi":"310170801873531","msisdn":"882350801873531","imei":"351579050703680","status":"ACTIVATION_READY","ratePlan":"Daikin Applied - 50MB US_CAN_MEX Plan","communicationPlan":"Daikin Applied - AT&T Data MT - INT","customer":"Daikin Test","endConsumerId":null,"dateActivated":"2015-01-30 20:18:11.755+0000","dateAdded":"2014-02-14 00:11:35.784+0000","dateUpdated":"2017-01-23 19:41:44.491+0000","dateShipped":"2014-03-04 00:00:00.000+0000","accountId":"100414901","fixedIPAddress":null,"operatorCustom1":"","operatorCustom2":"","operatorCustom3":"","operatorCustom4":"","operatorCustom5":"","accountCustom1":"","accountCustom2":"","accountCustom3":"","accountCustom4":"","accountCustom5":"","accountCustom6":"","accountCustom7":"","accountCustom8":"","accountCustom9":"","accountCustom10":"","customerCustom1":"","customerCustom2":"","customerCustom3":"","customerCustom4":"","customerCustom5":"","simNotes":null,"deviceID":"Controls Lab/Simulator","modemID":"00600c:816eec","globalSimType":""}');
					}
					else if (holdingOrderTypeId == 'Domestic') {
						// Set current device response to a domestic plan
			        	getDeviceRespObj.setResponseData('{"iccid":"89011704258018735310","imsi":"310170801873531","msisdn":"882350801873531","imei":"351579050703680","status":"ACTIVATION_READY","ratePlan":"Daikin Applied - 50MB Plan","communicationPlan":"Daikin Applied - AT&T Data MT - IFA","customer":"Daikin Test","endConsumerId":null,"dateActivated":"2015-01-30 20:18:11.755+0000","dateAdded":"2014-02-14 00:11:35.784+0000","dateUpdated":"2017-01-23 19:41:44.491+0000","dateShipped":"2014-03-04 00:00:00.000+0000","accountId":"100414901","fixedIPAddress":null,"operatorCustom1":"","operatorCustom2":"","operatorCustom3":"","operatorCustom4":"","operatorCustom5":"","accountCustom1":"","accountCustom2":"","accountCustom3":"","accountCustom4":"","accountCustom5":"","accountCustom6":"","accountCustom7":"","accountCustom8":"","accountCustom9":"","accountCustom10":"","customerCustom1":"","customerCustom2":"","customerCustom3":"","customerCustom4":"","customerCustom5":"","simNotes":null,"deviceID":"Controls Lab/Simulator","modemID":"00600c:816eec","globalSimType":""}');
					}
			    }

				if (getDeviceRespObj.getResponseCode() == 200)
				{
			    DeviceDetailsResponse getDeviceInfoResponse = new DeviceDetailsResponse();
			    getDeviceInfoResponse = (DeviceDetailsResponse)JSON.deserialize(getDeviceRespObj.getResponseData(), DeviceDetailsResponse.class);

				System.debug(LoggingLevel.ERROR, 'Status=' + getDeviceInfoResponse.status + ', Device Id=' + getDeviceInfoResponse.deviceID + ', Modem Id=' + getDeviceInfoResponse.modemID);


			    // If subscription connectivity type is Cellular then call the AT&T CC Web Service API to set the SIM card status to "ACTIVATED"
			    if (subn.Connectivity_Type__c == 'Cellular') {
			        // first check if the status is already set to "ACTIVATED" and if it is then do nothing
			        if (getDeviceInfoResponse.status != 'ACTIVATED') {
			            if (!Test.isRunningTest()) {
			            	// Test isn't running so call the service
			            	putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, 'ACTIVATED', null, null, null, null, null, integrationErrorList);

			            	if (putDeviceRespObj.getResponseCode() != 200) {
			            		hasErrors = true;
			            		errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to set the sim card status to Activation Ready!';
			            	}
			            }
			            else {
					        // Test is running so mock a response
					        putDeviceRespObj.setResponseCode(200);
					        putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
					    }
			        }
			    }


			    // If it's a Kit/Factory order then call the AT&T CC Web Service API to set the following parameters:
			    // Customer = "DaikinDX"  NOTE: This parameter is not set anymore
			    // Device ID = <Model-Serial# (Order Tag)>, limited to 50 characters and cannot contain commas (,) or asterisks (*)
			    // Modem ID = <MAC Address>
				if (((subn.Term_Years__c == 5.25) || (subn.Term_Years__c == 3.25) || (subn.Term_Years__c == 1.25) || (subn.Term_Years__c == 0.50) || (subn.Term_Years__c == 0.25)) && 
					((subn.Renewal_Counter__c == 0) || (subn.Renewal_Counter__c == null)))
				{
			        String deviceId = unitAsset.Product2.ProductCode + ' - ' + unitAsset.SerialNumber + ' (' + unitAsset.Tag__c + ')';
					if (gwAsset.GWotGo__c == true)
						deviceId = 'GotG_' + deviceId;

					// Replace any (,) or (*) with (_) and limit to max of 50 characters if necessary
					deviceId = deviceId.replace(',', '_');
					deviceId = deviceId.replace('*', '_');

					if (deviceId.length() > 50)
						deviceId = deviceId.substring(0, 49);


					string macaddr = gwAsset.MAC_Address__c;
					string macaddr2;
					if (String.isNotBlank(macaddr) && (macaddr.length() == 12))
					{
						Integer[] chars = macaddr.getChars();
						list<Integer> charArray = new List<Integer>();
						integer cnt = 0;
						for (Integer i : chars) {
							cnt++;
							charArray.add(i);
							if (cnt == 6)
								charArray.add(58); // add a colon (ascii 58) after 6th character
						}
						macaddr2 = String.fromCharArray(charArray);
					}
					else {
						macaddr2 = macaddr;
					}


		            if (!Test.isRunningTest()) {
		            	// Test isn't running so call the service
		            	putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, null, null, null, null, deviceId, macaddr2, integrationErrorList);

		            	if (putDeviceRespObj.getResponseCode() != 200) {
			            	hasErrors = true;
			            	errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to set parameters for Kit/Factory order!';
			            }
		            }
		            else {
				        // Test is running so mock a response
				        putDeviceRespObj.setResponseCode(200);
				        putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
				    }
			    }


				// NOTE: These parameters will not be set anymore
			    // Call the AT&T CC Web Service API to set the SIM card data rate plan and communication plan
			    // to the appropriate values based on job location of International or Domestic
				/*
				if (theOrder != null) {
					if (theOrder.Order_Type_ID__c == 'International') {
						// First check what the current rate plan is
						// If it's a domestic plan then set to the equivalent international plan and set communication plan
						// If it's already set to an international plan then check communication plan
						String commPlan = 'DataXoom - AT&T Data MT - INT RES-157';  // International Communication plan
						String intlPlan = GetIntlPlan(getDeviceInfoResponse.ratePlan);

						if (!Test.isRunningTest()) {
			            	// Test isn't running so call the service
			            	putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, null, intlPlan, commPlan, null, null, null, integrationErrorList);

			            	if (putDeviceRespObj.getResponseCode() != 200) {
			            		hasErrors = true;
			            		errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to set data rate plan!';
			            	}
						}
						else {
							// Test is running so mock a response
							putDeviceRespObj.setResponseCode(200);
							putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
						}
					}
					else if (theOrder.Order_Type_ID__c == 'Domestic') {
						// First check what the current rate plan is
						// If it's a international plan then set to the equivalent domestic plan and set communication plan
						// If it's already set to an domestic plan then check communication plan
						String commPlan = 'DataXoom - AT&T Data MT - IFA RES-155';  // Domestic Communication plan
						String domesticPlan = GetDomesticPlan(getDeviceInfoResponse.ratePlan);

						if (!Test.isRunningTest()) {
			            	// Test isn't running so call the service
			            	putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, null, domesticPlan, commPlan, null, null, null, integrationErrorList);

			            	if (putDeviceRespObj.getResponseCode() != 200) {
			            		hasErrors = true;
			            		errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to set data rate plan!';
			            	}
						}
						else {
							// Test is running so mock a response
							putDeviceRespObj.setResponseCode(200);
							putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
						}
					}
				}
				else if (holdingOrderTypeId == 'Domestic') {
					// First check what the current rate plan is
					// If it's a international plan then set to the equivalent domestic plan and set communication plan
					// If it's already set to an domestic plan then check communication plan
					String commPlan = 'DataXoom - AT&T Data MT - IFA RES-155';  // Domestic Communication plan
					String domesticPlan = GetDomesticPlan(getDeviceInfoResponse.ratePlan);

					if (!Test.isRunningTest()) {
			            // Test isn't running so call the service
			            putDeviceRespObj = restPutDevice.updateDeviceByICCID(simCardICCID, null, domesticPlan, commPlan, null, null, null, integrationErrorList);

			            if (putDeviceRespObj.getResponseCode() != 200) {
			            	hasErrors = true;
			            	errorMsg = errorMsg + ' | ' + 'SIM Card ICCID = ' + simCardICCID + ', Response code = ' + putDeviceRespObj.getResponseCode() + ', from call to set data rate plan!';
			            }
					}
					else {
						// Test is running so mock a response
						putDeviceRespObj.setResponseCode(200);
						putDeviceRespObj.setResponseData('{"iccid":"89011704258018735310"}');
					}
				}*/

				} // getDeviceRespObj.getResponseCode() == 200
			} // simCardICCID != null
    	}
    	catch (Exception e) {
			//Do not rethrow exception, so IE processing can continue. Just log the error.

			hasErrors = true;
			errorMsg = errorMsg + ' | ' + 'CALLOUT_EXCEPTION ' + e.getMessage() + ' | IE process not aborted but SIM card ' + simCardICCID + ' may need to be Activated manually';
			
			System.debug(errorMsg);

			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
									, Error_Description__c = 'updateSimCardObjectCellularInfo'
									, Integration_Object__c = 'AT&T Control Center'
									, Integration_Point__c = 'IE'
									, Request_Data__c = errorMsg));
	
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;
   		}

	}


	public static void syncIeCloudIndividuals(list<Contact> contactList, map<Id, Contact> contactMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList, list<Subscription__c> subscriptions)
	{
    	Integer CONTACT_BATCH_SIZE = 10;

    	TriggerUtility.limitIntegrationBatch = true;

		List<Contact> contacts = new list<Contact>();

		if (!contactList.isEmpty()) {
			// Get the contacts from the provided list passed in
			contacts = contactList;
		}
		else {
			// Get the contacts that are in a Pending status
    		contacts = [Select Id
							, FirstName
							, LastName
							, Middle_Name__c
							, Email
							, Phone
							, MobilePhone
							, IE_Username__c
							, IE_Accessed__c
							, IE_Inactive__c
							, LastModifiedDate
							, IE_Updated_Date__c
							, IE_ID__c
							, IE_Contact__c
							, IE_Sync_Status__c
							, AccountId
        					//address data
							, (Select Address__r.Country__c
									, Address__r.Postal_Code__c
									, Address__r.State_Province__c
									, Address__r.State_Province_ISO_Code__c
									, Address__r.Country_ISO_Code__c
									, Address__r.County__c
									, Address__r.City__c
									, Address__r.Address_Line_4__c
									, Address__r.Address_Line_3__c
									, Address__r.Address_Line_2__c
									, Address__r.Address_Line_1__c
									, Address__r.Name
									, Address__r.IE_ID__c
									, Address__c 
									, Address__r.LastModifiedDate
									From Contact_Addresses__r
							) 
        					//role data
        					//,(Select Role__c, Master_Admin__c, Asset__c From Contact_Subscriptions__r)
        				from Contact  
        				where IE_Sync_Status__c = 'Pending'
        				and IE_Contact__c = true];
		}

        if (!contacts.isEmpty()) {
			// Check if the number of contacts in the list is > CONTACT_BATCH_SIZE and break it up into multiple chunks and
			// call the ie service for each chunk to avoid any timeouts processing a large Request object.
			integer numOfContacts = contacts.size();
			if (numOfContacts > CONTACT_BATCH_SIZE) {
				integer loopCnt = numOfContacts/CONTACT_BATCH_SIZE;
				integer rem = Math.mod(numOfContacts, CONTACT_BATCH_SIZE);
				integer startIdx = 0;

				for (Integer i = 0; i < loopCnt; i++) {
				  List<SObject> tempContactList = new list<SObject>();
				  integer endIdx = startIdx + CONTACT_BATCH_SIZE;
				  for (Integer j = startIdx; j < endIdx; j++) {
				    tempContactList.add(contacts[j]);
				  }
				  // Process each chunk of contacts
				  if (rem > 0)
				    // There is a remaining chunk so we don't save result on this call
				    processContacts(tempContactList, contactMap, addressMap, integrationErrorList, false, false, null, subscriptions);
				  else if (i == loopCnt-1)
				    // There is no remaining chunk and this is the final iteration of the loop so we want to save result on this final call
				    processContacts(tempContactList, contactMap, addressMap, integrationErrorList, true, false, null, subscriptions);
				  else
				    // There is no remaining chunk and this is not the final iteration of the loop so we don't save result on this call
				    processContacts(tempContactList, contactMap, addressMap, integrationErrorList, false, false, null, subscriptions);

				  startIdx = startIdx + CONTACT_BATCH_SIZE;
				}
				if (rem > 0) {
				  // Process the remaining chunk of contacts
				  List<SObject> tempContactList = new list<SObject>();
				  integer endIdx = startIdx + rem;
				  for (Integer i = startIdx; i < endIdx; i++) {
				    tempContactList.add(contacts[i]);
				  }
				  // This is the remaining chunk so we want to save result on this final call
				  processContacts(tempContactList, contactMap, addressMap, integrationErrorList, true, false, null, subscriptions);
				}
			}
			else {
				// Only one chunk to process so we want to save result on this final call
				processContacts(contacts, contactMap, addressMap, integrationErrorList, true, false, null, subscriptions);
			}
        }
	}


	public static void syncIeCloudIndividuals2(list<Contact> contacts, map<Id, Contact> contactMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList, Asset gwAsset)
	{
    	Integer CONTACT_BATCH_SIZE = 10;

    	TriggerUtility.limitIntegrationBatch = true;

		list<Subscription__c> subscriptions = new list<Subscription__c>();

        if (!contacts.isEmpty()) {
			// Check if the number of contacts in the list is > CONTACT_BATCH_SIZE and break it up into multiple chunks and
			// call the ie service for each chunk to avoid any timeouts processing a large Request object.
			integer numOfContacts = contacts.size();
			if (numOfContacts > CONTACT_BATCH_SIZE) {
				integer loopCnt = numOfContacts/CONTACT_BATCH_SIZE;
				integer rem = Math.mod(numOfContacts, CONTACT_BATCH_SIZE);
				integer startIdx = 0;

				for (Integer i = 0; i < loopCnt; i++) {
				  List<SObject> tempContactList = new list<SObject>();
				  integer endIdx = startIdx + CONTACT_BATCH_SIZE;
				  for (Integer j = startIdx; j < endIdx; j++) {
				    tempContactList.add(contacts[j]);
				  }
				  // Process each chunk of contacts
				  if (rem > 0)
				    // There is a remaining chunk so we don't save result on this call
				    processContacts(tempContactList, contactMap, addressMap, integrationErrorList, false, true, gwAsset, subscriptions);
				  else if (i == loopCnt-1)
				    // There is no remaining chunk and this is the final iteration of the loop so we want to save result on this final call
				    processContacts(tempContactList, contactMap, addressMap, integrationErrorList, true, true, gwAsset, subscriptions);
				  else
				    // There is no remaining chunk and this is not the final iteration of the loop so we don't save result on this call
				    processContacts(tempContactList, contactMap, addressMap, integrationErrorList, false, true, gwAsset, subscriptions);

				  startIdx = startIdx + CONTACT_BATCH_SIZE;
				}
				if (rem > 0) {
				  // Process the remaining chunk of contacts
				  List<SObject> tempContactList = new list<SObject>();
				  integer endIdx = startIdx + rem;
				  for (Integer i = startIdx; i < endIdx; i++) {
				    tempContactList.add(contacts[i]);
				  }
				  // This is the remaining chunk so we want to save result on this final call
				  processContacts(tempContactList, contactMap, addressMap, integrationErrorList, true, true, gwAsset, subscriptions);
				}
			}
			else {
				// Only one chunk to process so we want to save result on this final call
				processContacts(contacts, contactMap, addressMap, integrationErrorList, true, true, gwAsset, subscriptions);
			}
        }
	}


	public static void processContacts(List<SObject> contacts, map<Id, Contact> contactMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList, Boolean saveResults, Boolean gwotgoUnitReset, Asset gwAsset, list<Subscription__c> subscriptions)
    {
    	boolean hasErrors = false;
		boolean hasIETimeout = false;

		list<String> serialNumberList = new list<String>();
		for (Subscription__c s : subscriptions) serialNumberList.add(s.Serial_Number__c);

    	// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'syncIeCloudIndividuals errors: ';

		//populate the objects for integration
		IE_IntegrationObjects.IE_UserList IndividualsPost = new IE_IntegrationObjects.IE_UserList();
		IndividualsPost.Individuals = new list<IE_IntegrationObjects.IE_User>();
		IE_IntegrationObjects.IE_UserList IndividualsPut = new IE_IntegrationObjects.IE_UserList();
		IndividualsPut.Individuals = new list<IE_IntegrationObjects.IE_User>();

		//define the response objects
		IE_IntegrationObjects.IE_UserListResponse IndividualsPostResponse = new IE_IntegrationObjects.IE_UserListResponse();
		IE_IntegrationObjects.IE_UserListResponse IndividualsPutResponse = new IE_IntegrationObjects.IE_UserListResponse();


		//get the greater of the two - most recently modified contact_subscription record or the last modified date on the contact record
		map<Id, DateTime> maxSubscriptionDate = new map<Id, DateTime>();
		for(AggregateResult ar : [Select Contact__c, max(LastModifiedDate) dt from Contact_Subscription__c where Contact__c in :(List<Contact>)contacts group by Contact__c])
		{
		  maxSubscriptionDate.put(String.ValueOf(ar.get('Contact__c')), (DateTime)ar.get('dt'));
		}

		for(SObject s : contacts)
		{
		  Contact c = (Contact)s;
		  Contact_Address__c[] caList = c.getSObjects('Contact_Addresses__r');
		  IE_IntegrationObjects.IE_Address address = new IE_IntegrationObjects.IE_Address();
		  if (caList != null)
		  {
		    //get the address data
		  
		      for(Contact_Address__c addr : caList)
		      {
		        address.AddressLine1 = addr.Address__r.Address_Line_1__c;
		        address.AddressLine2 = addr.Address__r.Address_Line_2__c;
		        address.AddressLine3 = addr.Address__r.Address_Line_3__c;
		        address.AddressLine4 = addr.Address__r.Address_Line_4__c;
		        address.City     = addr.Address__r.City__c;
		        address.Country    = addr.Address__r.Country_ISO_Code__c;  
		        address.StateCode    = addr.Address__r.State_Province_ISO_Code__c;
		        address.ZipCode    = addr.Address__r.Postal_Code__c;
		        address.SFDCId     = addr.Address__r.Id;
		        address.IEId     = addr.Address__r.IE_ID__c;

				address.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
		        /*address.LastModifiedDate = DateTime.newInstance(addr.Address__r.LastModifiedDate.dateGmt()
		                                 ,addr.Address__r.LastModifiedDate.timeGmt());*/

		        addressMap.put(addr.Address__r.Id, addr.Address__r);
		        break;
		      }
		  }

		  
		  //Contact_Subscription__c[] csList = c.getSObjects('Contact_Subscriptions__r');
		  list<Contact_Subscription__c> csList = new list<Contact_Subscription__c>();
		  if (gwotgoUnitReset == true)
		  {
			// Get all contact-subscription records for the contact that are not associated with the Dummy or Holding asset AND the 1 record associated with the GWotGo asset in question (which may currently be associated with the Dummy or Holding asset)
			// Filtering out all contact-subscription records for the contact that are associated with the Dummy or Holding asset whose GWotGo asset is not being processed.
			csList = [Select Role__c, Master_Admin__c, Asset__c, GWotGoAsset__c, Asset__r.SerialNumber, Asset__r.IE_ID__c, Asset__r.Name, Asset__r.IE_Asset__c From Contact_Subscription__c where (Contact__c = :c.Id and Asset__r.Name != 'Dummy GWotGo Unit Asset' and Asset__r.Name != 'Holding GWotGo Unit Asset' and Asset__r.IE_Asset__c = true) OR (Contact__c = :c.Id and GWotGoAsset__c = :gwAsset.Id)];
		  }
		  else
			csList = [Select Role__c, Master_Admin__c, Asset__c, GWotGoAsset__c, Asset__r.SerialNumber, Asset__r.IE_ID__c, Asset__r.Name, Asset__r.IE_Asset__c From Contact_Subscription__c where Contact__c = :c.Id and Asset__r.Name != 'Dummy GWotGo Unit Asset' and Asset__r.Name != 'Holding GWotGo Unit Asset' and Asset__r.IE_Asset__c = true];

		  list<IE_IntegrationObjects.IE_Role> ieRoles = new list<IE_IntegrationObjects.IE_Role>();
		  if (csList != null)
		  {
		    for(Contact_Subscription__c sub : csList)
		    {
				if (serialNumberList.contains(sub.Asset__r.SerialNumber) || String.isNotEmpty(sub.Asset__r.IE_ID__c) || (gwotgoUnitReset == true))
				{
					//get the Roles
					list<String> equipmentRoles = sub.Role__c.split(';');
					for(String r : equipmentRoles)
					{
						// Only add the role if it is Administrator.
						// NOTE: The following roles will still be supported but will eventually be obsoleted {CustomerAdministrator,TechnicianAdministrator,Customer,Technician,EquipmentAdministrator}
						// IE service ignores the roles {SalesRep, Engineer, RenewalAdministrator}
						if (r.equalsIgnoreCase('Administrator') ||
							r.equalsIgnoreCase('CustomerAdministrator') || r.equalsIgnoreCase('Customer') ||
							r.equalsIgnoreCase('TechnicianAdministrator') || r.equalsIgnoreCase('Technician') ||
							r.equalsIgnoreCase('EquipmentAdministrator'))
						{
							IE_IntegrationObjects.IE_Role role = new IE_IntegrationObjects.IE_Role();
							role.Type = r;

							if (sub.GWotGoAsset__c != null)
								role.UnitSFDCId = sub.GWotGoAsset__c;  // Here we set the SFDCId to the Id of the GWotGo asset
							else
								role.UnitSFDCId = sub.Asset__c;

							role.MasterAdmin = String.valueOf(sub.Master_Admin__c); 
							if(role.MasterAdmin == null) role.MasterAdmin = 'false';
							ieRoles.add(role);
						}
					}
				}
		    }
		  }
		  
		  if (!ieRoles.isEmpty())
		  {
				// Contact contains 1 or more valid IE Roles, so go ahead and process this contact.

				//create the Individual and add it to the list
				DateTime maxDate = c.LastModifiedDate;
				if(maxSubscriptionDate.containsKey(c.Id))
				{
					if(maxSubscriptionDate.get(c.Id) > maxDate)
						maxDate = maxSubscriptionDate.get(c.Id);
				}
				IE_IntegrationObjects.IE_User ieUser = new IE_IntegrationObjects.IE_User();
				ieUser.FirstName  = c.FirstName;
				ieUser.MiddleName   = c.Middle_Name__c;
				ieUser.LastName   = c.LastName;
				ieUser.EmailAddress = c.email;
				ieUser.Roles    = ieRoles;
				ieUser.Address    = address;
				ieUser.CellPhone  = c.MobilePhone;
				ieUser.WorkPhone  = c.Phone;
				ieUser.SFDCId     = c.Id;
				ieUser.UserName   = c.IE_Username__c;
				ieUser.OrganizationSFDCId = c.AccountId;
				ieUser.IEId     = c.IE_ID__c;

				ieUser.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
				//ieUser.LastModifiedDate = DateTime.newInstance(maxDate.dateGmt(), maxDate.timeGmt());
		  
				if(c.IE_ID__c == null)
					IndividualsPost.Individuals.add(ieUser);
				else
					IndividualsPut.Individuals.add(ieUser);
		  }
		  else {
			// There are no ie roles so set the status to 'Processed' so its not 'Pending' anymore and if the IE Id is -1 then set to empty string
			c.IE_Sync_Status__c = 'Processed';
			if (c.IE_ID__c == '-1') c.IE_ID__c = '';
		  }
		  
		  //store the contact in the map to retrieve response status
		  contactMap.put(c.Id, c);  
		}

		//
		// call the service - Determine PUT or POST
		//

		String jsonPostResponse = '';
		String jsonPutResponse = '';

		//Process the POST

		try {
		 if(IndividualsPost.Individuals != null && IndividualsPost.Individuals.size() > 0)
		 {
		   System.debug('::::::INDIVIDUALS POST::::::'+JSON.serialize(IndividualsPost));
		   
		   HTTPResponse response = null;

		   if (!Test.isRunningTest()) {
		      // Test isn't running so call the service
		      response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().IndividualService__c
		                                                            , 'POST'
		                                                            , JSON.serialize(IndividualsPost));
		   }
		   else {
				// Test is running so mock a response
				if (Batch_IE_CallExtWebServices.crash_syncIeCloudIndividuals_TestByException) {
					response.setStatusCode(200); //exception will be thrown since response object is null
				}
				else {
					response = new HTTPResponse();
					if (Batch_IE_CallExtWebServices.crash_syncIeCloudIndividuals_TestByResponseStatusCode) {
						response.setStatusCode(0); //set the response status code to something other than 200
					}
					else {
						response.setStatusCode(200);
						response.setBody(JSON.serialize(IndividualsPost));
					}
				}
		   }
		   
		   if(response.getStatusCode() == 200)
		   {
		        //iterate over the response checking for errors maybe we just return the body
		        if(Test.isRunningTest())
		          jsonPostResponse = JSON.serialize(IndividualsPost);//for testing purposes since we can't make a call-out
		        else
		          jsonPostResponse = response.getBody();
		        system.debug(':::: INDIVIDUALS jsonPostResponse:::::'+jsonPostResponse);
		        IndividualsPostResponse = (IE_IntegrationObjects.IE_UserListResponse)JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_UserListResponse.class);
		   }
		   else {
		      //log the error

		      // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
		      String reqData = JSON.serialize(IndividualsPost);
		      if (reqData.length() > 131072) {
		        reqData = reqData.substring(0, 131071);
		      }

		      integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound POST'
		                            , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
		                            , Integration_Object__c = 'Contact'
		                            , Integration_Point__c = 'IE'
		                            , Request_Data__c =  reqData));
		      hasErrors = true;
		      errorMsg = errorMsg + ' | ' + 'Post Transmission Error ['+response.getStatusCode()+']';
		   }
		 }
		}
		catch(Exception e)
		{
			//log the error

			// Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
			String reqData = JSON.serialize(IndividualsPost);
			if (reqData.length() > 131072) {
				reqData = reqData.substring(0, 131071);
			}

			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound POST'
			                        , Error_Description__c = 'CALLOUT_EXCEPTION ' + e.getMessage()
			                        , Integration_Object__c = 'Contact'
			                        , Integration_Point__c = 'IE'
			                        , Request_Data__c = reqData ));
			hasErrors = true;
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;

			errorMsg = errorMsg + ' | ' + 'Post CALLOUT_EXCEPTION ' + e.getMessage();
		}

		//Process the PUT

		try {
		 if(IndividualsPut.Individuals != null && IndividualsPut.Individuals.size() > 0)
		 {
		   System.debug(':::::INDIVIDUALS PUT:::::'+JSON.serialize(IndividualsPut));

		   HTTPResponse response = null;
		   if (!Test.isRunningTest()) {
		      // Test isn't running so call the service
		      response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().IndividualService__c
		                                                            , 'PUT'
		                                                            , JSON.serialize(IndividualsPut));
		   }
		   else {
				// Test is running so mock a response
				if (Batch_IE_CallExtWebServices.crash_syncIeCloudIndividuals_TestByException) {
					response.setStatusCode(200); //exception will be thrown since response object is null
				}
				else {
					response = new HTTPResponse();
					if (Batch_IE_CallExtWebServices.crash_syncIeCloudIndividuals_TestByResponseStatusCode) {
						response.setStatusCode(0); //set the response status code to something other than 200
					}
					else {
						response.setStatusCode(200);
						response.setBody(JSON.serialize(IndividualsPut));
					}
				}
		    }
		   
		   if(response.getStatusCode() == 200)
		   { 
		        //iterate over the response checking for errors maybe we just return the body
		        if(Test.isRunningTest())
		          jsonPutResponse = JSON.serialize(IndividualsPut);//for testing purposes since we can't make a call-out
		        else
		          jsonPutResponse = response.getBody();
		          
		        system.debug(':::: INDIVIDUALS jsonPutResponse:::::'+jsonPutResponse);
		        IndividualsPutResponse = (IE_IntegrationObjects.IE_UserListResponse)JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_UserListResponse.class);
		   }
		   else { 
		      //log the error

		      // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
		      String reqData = JSON.serialize(IndividualsPut);
		      if (reqData.length() > 131072) {
		        reqData = reqData.substring(0, 131071);
		      }

		      integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound PUT'
		                            , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+' ] '//+response.getHeader()+']'
		                            , Integration_Object__c = 'Contact'
		                            , Integration_Point__c = 'IE'
		                            , Request_Data__c = reqData));
		      hasErrors = true;
		      errorMsg = errorMsg + ' | ' + 'Put Transmission Error ['+response.getStatusCode()+']';
		   }
		 }
		}
		catch(Exception e)
		{
			//log the error

			// Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
			String reqData = JSON.serialize(IndividualsPut);
			if (reqData.length() > 131072) {
				reqData = reqData.substring(0, 131071);
			}

			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound PUT'
			                        , Error_Description__c = 'CALLOUT_EXCEPTION '+ e.getMessage()
			                        , Integration_Object__c = 'Contact'
			                        , Integration_Point__c = 'IE'
			                        , Request_Data__c =  reqData));
			hasErrors = true;
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;
			
			errorMsg = errorMsg + ' | ' + 'Put CALLOUT_EXCEPTION ' + e.getMessage();
		}


		if(!hasErrors)
		{
			if(IndividualsPostResponse.Individuals != null && IndividualsPostResponse.Individuals.size() > 0)
				processIeIndividualsResponse(IndividualsPostResponse, hasErrors, contactMap, addressMap, integrationErrorList);

			if(IndividualsPutResponse.Individuals != null && IndividualsPutResponse.Individuals.size() > 0)
				processIeIndividualsResponse(IndividualsPutResponse, hasErrors, contactMap, addressMap, integrationErrorList);

			/*if (saveResults) {
				//update the records with the IE Keys
				update contactMap.values();
				if(addressMap.size() > 0)
				  update addressMap.values();
			}*/
		}

		/*if (saveResults && integrationErrorList.size() > 0)
		  insert integrationErrorList;*/

		// Only Rethrow a new exception if there wasn't an IE Timeout exception thrown
		if (hasErrors && !hasIETimeout) throw new syncIeCloudIndividualsException(errorMsg);

    }


	public static void processIeIndividualsResponse(IE_IntegrationObjects.IE_UserListResponse Individuals, boolean hasErrors, 
                                map<Id, Contact> contactMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList)
    {
       	//Parse the response for errors
       	// retrieve the IE IDs and update the base as well as the child objects if they are null
       	// update the status to Processed
       
       	//log errors
       	//update the status to Error
       	
       	TriggerUtility.limitIntegrationBatch = true;
       	for(IE_IntegrationObjects.IE_User individual : Individuals.Individuals)
       	{

       		/*if(Test.isRunningTest()) {
	            //For testing purposes only
	            individual.errors = new list<IE_IntegrationObjects.IE_Error>();
	            IE_IntegrationObjects.IE_Error err = new IE_IntegrationObjects.IE_Error('error code', 'error msg');
	            individual.errors.add(err);

	            individual.Address.errors = new list<IE_IntegrationObjects.IE_Error>();
	            individual.Address.errors.add(err);
          	}*/
       		
       			
       		if(individual.errors != null && individual.errors.size() > 0 )
       		{
	            // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
	            String reqData = JSON.serialize(individual);
	            if (reqData.length() > 131072) {
	              reqData = reqData.substring(0, 131071);
	            }

	       		contactMap.get(individual.SFDCId).IE_Sync_Status__c = 'Error';
	       		integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
       															, Error_Description__c = String.ValueOf(individual.errors)
       															, Integration_Object__c = 'Contact'
       															, Integration_Object_Id__c = individual.SFDCId
       															, Integration_Point__c = 'IE'
       															, Request_Data__c = reqData ));
       		}
       		else
       		{
       			contactMap.get(individual.SFDCId).IE_Sync_Status__c = 'Processed';

				if (String.isNotEmpty(individual.IEId))
       				contactMap.get(individual.SFDCId).IE_Id__c = individual.IEId;

				contactMap.get(individual.SFDCId).IE_Contact__c = true;  // set this to true in case it wasn't set earlier
       		}
       		
       		if(individual.Address != null && addressMap.containsKey(individual.Address.SFDCId))
       		{
       			if(individual.Address.errors != null && individual.Address.errors.size() > 0)
	       		{
		            // Request_Data__c is a Long Text Area(131072) Field, make sure data added is not too large
		            String reqData = JSON.serialize(individual);
		            if (reqData.length() > 131072) {
		              reqData = reqData.substring(0, 131071);
		            }

	       			addressMap.get(individual.Address.SFDCId).IE_Sync_Status__c = 'Error';
	       			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
	       															, Error_Description__c = String.ValueOf(individual.Address.errors)
	       															, Integration_Object__c = 'Address'
	       															, Integration_Object_Id__c = individual.Address.SFDCId
	       															, Integration_Point__c = 'IE'
	       															, Request_Data__c = reqData ));
	       		}
	       		else
	       		{
	       			if(addressMap.containsKey(individual.Address.SFDCId))
	       			{
       					addressMap.get(individual.Address.SFDCId).IE_Sync_Status__c = 'Processed';

						if (String.isNotEmpty(individual.Address.IEId))
							addressMap.get(individual.Address.SFDCId).IE_Id__c = individual.Address.IEId;

						addressMap.get(individual.Address.SFDCId).IE_Address__c = true;  // set this to true in case it wasn't set earlier
	       			}
	       		}
       		}
       	}
    }


	/*public static void syncIeCloudOrganizations(map<Id, Account> accountMap, list<Integration_Error__c> integrationErrorList)
	{
		TriggerUtility.limitIntegrationBatch = true;

		List<Account> accounts = [select Name
								  , (Select Address__r.Country__c
								          , Address__r.Postal_Code__c
								          , Address__r.State_Province__c
								          , Address__r.County__c
								          , Address__r.City__c
								          , Address__r.Address_Line_4__c
								          , Address__r.Address_Line_3__c
								          , Address__r.Address_Line_2__c
								          , Address__r.Address_Line_1__c
								          , Address__r.Name
								          , Address__r.IE_ID__c
										  , Address__r.State_Province_ISO_Code__c
										  , Address__r.Country_ISO_Code__c
								          , Address__c 
								          , Address__r.LastModifiedDate
								       From Account_Addresses__r
								      )
									,Phone
									,IE_ID__c
									,IE_Updated_Date__c
									,Id
									,LastModifiedDate
							  from Account  
							 where IE_Sync_Status__c = 'Pending' and IE_Account__c = true];

		boolean hasErrors = false;

    	// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'syncIeCloudOrganizations errors: ';

		//populate the objects for integration
		IE_IntegrationObjects.IE_OrganizationList ieAccountPost = new IE_IntegrationObjects.IE_OrganizationList();
		IE_IntegrationObjects.IE_OrganizationList ieAccountPut = new IE_IntegrationObjects.IE_OrganizationList();
		ieAccountPost.Organizations = new list<IE_IntegrationObjects.IE_Organization>();
		ieAccountPut.Organizations = new list<IE_IntegrationObjects.IE_Organization>();

		IE_IntegrationObjects.IE_OrganizationListResponse ieAccountPostResponse = new IE_IntegrationObjects.IE_OrganizationListResponse();
		IE_IntegrationObjects.IE_OrganizationListResponse ieAccountPutResponse = new IE_IntegrationObjects.IE_OrganizationListResponse();

		//map<Id, Account> accountMap = new map<Id, Account>();
		//list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();
		map<Id, Address__c> addressMap = new map<Id, Address__c>();

		if (!accounts.isEmpty()) {
			for (Account a : accounts)
			{
					//get the address data
					IE_IntegrationObjects.IE_Address address = new IE_IntegrationObjects.IE_Address();
					for(Account_Address__c addr : a.Account_Addresses__r)
					{
			   			address.AddressLine1 = addr.Address__r.Address_Line_1__c;
						address.AddressLine2 = addr.Address__r.Address_Line_2__c;
						address.AddressLine3 = addr.Address__r.Address_Line_3__c;
						address.AddressLine4 = addr.Address__r.Address_Line_4__c;
						address.City 		 = addr.Address__r.City__c;
						address.Country 	 = addr.Address__r.Country_ISO_Code__c;  
						address.StateCode 	 = addr.Address__r.State_Province_ISO_Code__c;
						address.ZipCode 	 = addr.Address__r.Postal_Code__c;
						address.SFDCId		 = addr.Address__r.Id;
						address.IEId		 = addr.Address__r.IE_ID__c;

						address.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
						//address.LastModifiedDate = DateTime.newInstance(addr.Address__r.LastModifiedDate.dateGmt()
																	   //,addr.Address__r.LastModifiedDate.timeGmt());

						addressMap.put(addr.Address__r.Id, addr.Address__r);
						break;
					}

				    //create the Organization and add it to the list
					IE_IntegrationObjects.IE_Organization ieAccount = new IE_IntegrationObjects.IE_Organization();
					ieAccount.Address = address;
					ieAccount.OrganizationName = a.Name;
					ieAccount.PhoneNumber = a.Phone;
					ieAccount.SFDCId = a.Id;
					ieAccount.IEId	= a.IE_ID__c;

					ieAccount.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
					//ieAccount.LastModifiedDate	= DateTime.newInstance(a.LastModifiedDate.dateGmt()
																   //,a.LastModifiedDate.timeGmt());

				    if(a.IE_ID__c == null)
						ieAccountPost.Organizations.add(ieAccount);
					else
						ieAccountPut.Organizations.add(ieAccount);
					
					//store the Account in the map to retrieve response status
					accountMap.put(a.Id, a);	
			}

			//
			// call the service - Determine PUT or POST
			//

			String jsonPostResponse = '';
			String jsonPutResponse = '';

			//Process the POST
			try{
			   if(ieAccountPost.Organizations != null && ieAccountPost.Organizations.size() > 0)
			   {
					system.debug(':::ieAccountPost:::'+JSON.serialize(ieAccountPost));
					HTTPResponse response = null;

					if (!Test.isRunningTest()) {
						// Test isn't running so call the service
						response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().OrganizationService__c
			                                                                 , 'POST'
			                                                                 , JSON.serialize(ieAccountPost));
					}
					else {
						// Test is running so mock a response
						if (Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByException) {
							response.setStatusCode(200); //exception will be thrown since response object is null
						}
						else {
							response = new HTTPResponse();
							if (Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByResponseStatusCode) {
								response.setStatusCode(0); //set the response status code to something other than 200
							}
							else {
								response.setStatusCode(200);
								response.setBody(JSON.serialize(ieAccountPost));
							}
						}
					}

			       
			        if(response.getStatusCode() == 200)
			        { 
			            //iterate over the response checking for errors maybe we just return the body
			            if(Test.isRunningTest())
			            	jsonPostResponse = JSON.serialize(ieAccountPost);//for testing purposes since we can't make a call-out
			            else
			            	jsonPostResponse = response.getBody();
			            	
			            system.debug(':::ieAccountPost Response:::'+jsonPostResponse);
			            ieAccountPostResponse = (IE_IntegrationObjects.IE_OrganizationListResponse)JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_OrganizationListResponse.class);
			        }
			        else {
			        	//log the error
			        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
																		, Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
																		, Integration_Object__c = 'Account'
																		, Integration_Point__c = 'IE'
																		, Request_Data__c = JSON.serialize(ieAccountPost) ));
						hasErrors = true;
						errorMsg = errorMsg + ' | ' + 'Post Transmission Error ['+response.getStatusCode()+']';
			        }
			   }
			}
			catch(Exception e)
			{
					//log the error
					integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
																		, Error_Description__c = 'CALLOUT_EXCEPTION'
																		, Integration_Object__c = 'Account'
																		, Integration_Point__c = 'IE'
																		, Request_Data__c = e.getMessage() ));
					hasErrors = true;
					errorMsg = errorMsg + ' | ' + 'Post CALLOUT_EXCEPTION ' + e.getMessage();
			}

			//Process the PUT 
			try{
			   if (ieAccountPut.Organizations != null && ieAccountPut.Organizations.size() > 0)
			   {
					system.debug(':::ieAccountPut:::'+JSON.serialize(ieAccountPut));
					HTTPResponse response = null;

					if (!Test.isRunningTest()) {
						// Test isn't running so call the service
						response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().OrganizationService__c
			                                                                 , 'PUT'
			                                                                 , JSON.serialize(ieAccountPut));
					}
					else {
						// Test is running so mock a response
						if (Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByException) {
							response.setStatusCode(200); //exception will be thrown since response object is null
						}
						else {
							response = new HTTPResponse();
							if (Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByResponseStatusCode) {
								response.setStatusCode(0); //set the response status code to something other than 200
							}
							else {
								response.setStatusCode(200);
								response.setBody(JSON.serialize(ieAccountPut));
							}
						}
					}

			       
			        if(response.getStatusCode() == 200)
			        {
			            //iterate over the response checking for errors maybe we just return the body
			            if(Test.isRunningTest())
			            	jsonPutResponse = JSON.serialize(ieAccountPut);//for testing purposes since we can't make a call-out
			            else
			            	jsonPutResponse = response.getBody();
			            	
						system.debug(':::ieAccountPut Response:::'+jsonPutResponse);
			            ieAccountPutResponse = (IE_IntegrationObjects.IE_OrganizationListResponse)JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_OrganizationListResponse.class);
			        }
			        else { 
			        	//log the error
			        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
			   															, Error_Description__c = 'Transmission Error ['+response.getStatusCode()+' ] '//+response.getHeader()+']'
			   															, Integration_Object__c = 'Account'
			   															, Integration_Point__c = 'IE'
			   															, Request_Data__c = JSON.serialize(ieAccountPut) ));
						hasErrors = true;
						errorMsg = errorMsg + ' | ' + 'Put Transmission Error ['+response.getStatusCode()+']';
			        }
			   }
			}
			catch(Exception e)
			{
					//log the error
					integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
																	, Error_Description__c = 'CALLOUT_EXCEPTION'
																	, Integration_Object__c = 'Account'
																	, Integration_Point__c = 'IE'
																	, Request_Data__c = e.getMessage() ));
					hasErrors = true;
					errorMsg = errorMsg + ' | ' + 'Put CALLOUT_EXCEPTION ' + e.getMessage();
			}


			if(!hasErrors)
			{
			   //process the responses adding IE Ids and/or Logging Errors
			   if(ieAccountPostResponse.Organizations != null && ieAccountPostResponse.Organizations.size() > 0)
			   		processIeOrganizationsResponse(ieAccountPostResponse, hasErrors, accountMap, integrationErrorList);
			   if(ieAccountPutResponse.Organizations != null && ieAccountPutResponse.Organizations.size() > 0)
			   		processIeOrganizationsResponse(ieAccountPutResponse, hasErrors, accountMap, integrationErrorList);
			   
			   //update the records with the IE Keys
			   //update accountMap.values();
			}
			   
			//if(integrationErrorList.size() > 0)
					//insert integrationErrorList;

			if (hasErrors) {
				throw new syncIeCloudOrganizationsException(errorMsg);
			}
		}
	}*/


	public static void syncIeCloudOrganizations2(list<Account> accounts, map<Id, Account> accountMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList)
	{
		TriggerUtility.limitIntegrationBatch = true;

		boolean hasErrors = false;

    	// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'syncIeCloudOrganizations2 errors: ';

		//populate the objects for integration
		IE_IntegrationObjects.IE_OrganizationList ieAccountPost = new IE_IntegrationObjects.IE_OrganizationList();
		IE_IntegrationObjects.IE_OrganizationList ieAccountPut = new IE_IntegrationObjects.IE_OrganizationList();
		ieAccountPost.Organizations = new list<IE_IntegrationObjects.IE_Organization>();
		ieAccountPut.Organizations = new list<IE_IntegrationObjects.IE_Organization>();

		IE_IntegrationObjects.IE_OrganizationListResponse ieAccountPostResponse = new IE_IntegrationObjects.IE_OrganizationListResponse();
		IE_IntegrationObjects.IE_OrganizationListResponse ieAccountPutResponse = new IE_IntegrationObjects.IE_OrganizationListResponse();

		//map<Id, Address__c> addressMap = new map<Id, Address__c>();

		if (!accounts.isEmpty()) {
			for (Account a : accounts)
			{
					//get the address data
					IE_IntegrationObjects.IE_Address address = new IE_IntegrationObjects.IE_Address();
					for(Account_Address__c addr : a.Account_Addresses__r)
					{
			   			address.AddressLine1 = addr.Address__r.Address_Line_1__c;
						address.AddressLine2 = addr.Address__r.Address_Line_2__c;
						address.AddressLine3 = addr.Address__r.Address_Line_3__c;
						address.AddressLine4 = addr.Address__r.Address_Line_4__c;
						address.City 		 = addr.Address__r.City__c;
						address.Country 	 = addr.Address__r.Country_ISO_Code__c;  
						address.StateCode 	 = addr.Address__r.State_Province_ISO_Code__c;
						address.ZipCode 	 = addr.Address__r.Postal_Code__c;
						address.SFDCId		 = addr.Address__r.Id;
						address.IEId		 = addr.Address__r.IE_ID__c;

						address.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
						/*address.LastModifiedDate = DateTime.newInstance(addr.Address__r.LastModifiedDate.dateGmt()
																	   ,addr.Address__r.LastModifiedDate.timeGmt());*/

						addressMap.put(addr.Address__r.Id, addr.Address__r);
						break;
					}

				    //create the Organization and add it to the list
					IE_IntegrationObjects.IE_Organization ieAccount = new IE_IntegrationObjects.IE_Organization();
					ieAccount.Address = address;
					ieAccount.OrganizationName = a.Name;
					ieAccount.PhoneNumber = a.Phone;
					ieAccount.SFDCId = a.Id;
					ieAccount.IEId	= a.IE_ID__c;

					ieAccount.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
					/*ieAccount.LastModifiedDate	= DateTime.newInstance(a.LastModifiedDate.dateGmt()
																   ,a.LastModifiedDate.timeGmt());*/

				    if(a.IE_ID__c == null)
						ieAccountPost.Organizations.add(ieAccount);
					else
						ieAccountPut.Organizations.add(ieAccount);
					
					//store the Account in the map to retrieve response status
					accountMap.put(a.Id, a);	
			}

			//
			// call the service - Determine PUT or POST
			//

			String jsonPostResponse = '';
			String jsonPutResponse = '';

			//Process the POST
			try{
			   if(ieAccountPost.Organizations != null && ieAccountPost.Organizations.size() > 0)
			   {
					system.debug(':::ieAccountPost:::'+JSON.serialize(ieAccountPost));
					HTTPResponse response = null;

					if (!Test.isRunningTest()) {
						// Test isn't running so call the service
						response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().OrganizationService__c
			                                                                 , 'POST'
			                                                                 , JSON.serialize(ieAccountPost));
					}
					else {
						// Test is running so mock a response
						if (Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByException) {
							response.setStatusCode(200); //exception will be thrown since response object is null
						}
						else {
							response = new HTTPResponse();
							if (Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByResponseStatusCode) {
								response.setStatusCode(0); //set the response status code to something other than 200
							}
							else {
								response.setStatusCode(200);
								response.setBody(JSON.serialize(ieAccountPost));
							}
						}
					}

			       
			        if(response.getStatusCode() == 200)
			        { 
			            //iterate over the response checking for errors maybe we just return the body
			            if(Test.isRunningTest())
			            	jsonPostResponse = JSON.serialize(ieAccountPost);//for testing purposes since we can't make a call-out
			            else
			            	jsonPostResponse = response.getBody();
			            	
			            system.debug(':::ieAccountPost Response:::'+jsonPostResponse);	
			            ieAccountPostResponse = (IE_IntegrationObjects.IE_OrganizationListResponse)JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_OrganizationListResponse.class);
			        }
			        else {
			        	//log the error
			        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
																		, Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
																		, Integration_Object__c = 'Account'
																		, Integration_Point__c = 'IE'
																		, Request_Data__c = JSON.serialize(ieAccountPost) ));
						hasErrors = true;
						errorMsg = errorMsg + ' | ' + 'Post Transmission Error ['+response.getStatusCode()+']';
			        }
			   }
			}
			catch(Exception e)
			{
					//log the error
					integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
																		, Error_Description__c = 'CALLOUT_EXCEPTION'
																		, Integration_Object__c = 'Account'
																		, Integration_Point__c = 'IE'
																		, Request_Data__c = e.getMessage() ));
					hasErrors = true;
					errorMsg = errorMsg + ' | ' + 'Post CALLOUT_EXCEPTION ' + e.getMessage();
			}

			//Process the PUT 
			try{
			   if (ieAccountPut.Organizations != null && ieAccountPut.Organizations.size() > 0)
			   {
					system.debug(':::ieAccountPut:::'+JSON.serialize(ieAccountPut));
					HTTPResponse response = null;

					if (!Test.isRunningTest()) {
						// Test isn't running so call the service
						response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().OrganizationService__c
			                                                                 , 'PUT'
			                                                                 , JSON.serialize(ieAccountPut));
					}
					else {
						// Test is running so mock a response
						if (Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByException) {
							response.setStatusCode(200); //exception will be thrown since response object is null
						}
						else {
							response = new HTTPResponse();
							if (Batch_IE_CallExtWebServices.crash_syncIeCloudOrganizations_TestByResponseStatusCode) {
								response.setStatusCode(0); //set the response status code to something other than 200
							}
							else {
								response.setStatusCode(200);
								response.setBody(JSON.serialize(ieAccountPut));
							}
						}
					}

			       
			        if(response.getStatusCode() == 200)
			        {
			            //iterate over the response checking for errors maybe we just return the body
			            if(Test.isRunningTest())
			            	jsonPutResponse = JSON.serialize(ieAccountPut);//for testing purposes since we can't make a call-out
			            else
			            	jsonPutResponse = response.getBody();
			            	
						system.debug(':::ieAccountPut Response:::'+jsonPutResponse);
			            ieAccountPutResponse = (IE_IntegrationObjects.IE_OrganizationListResponse)JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_OrganizationListResponse.class);
			        }
			        else { 
			        	//log the error
			        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
			   															, Error_Description__c = 'Transmission Error ['+response.getStatusCode()+' ] '//+response.getHeader()+']'
			   															, Integration_Object__c = 'Account'
			   															, Integration_Point__c = 'IE'
			   															, Request_Data__c = JSON.serialize(ieAccountPut) ));
						hasErrors = true;
						errorMsg = errorMsg + ' | ' + 'Put Transmission Error ['+response.getStatusCode()+']';
			        }
			   }
			}
			catch(Exception e)
			{
					//log the error
					integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
																	, Error_Description__c = 'CALLOUT_EXCEPTION'
																	, Integration_Object__c = 'Account'
																	, Integration_Point__c = 'IE'
																	, Request_Data__c = e.getMessage() ));
					hasErrors = true;
					errorMsg = errorMsg + ' | ' + 'Put CALLOUT_EXCEPTION ' + e.getMessage();
			}


			if(!hasErrors)
			{
			   //process the responses adding IE Ids and/or Logging Errors
			   if(ieAccountPostResponse.Organizations != null && ieAccountPostResponse.Organizations.size() > 0)
			   		processIeOrganizationsResponse(ieAccountPostResponse, hasErrors, accountMap, addressMap, integrationErrorList);
			   if(ieAccountPutResponse.Organizations != null && ieAccountPutResponse.Organizations.size() > 0)
			   		processIeOrganizationsResponse(ieAccountPutResponse, hasErrors, accountMap, addressMap, integrationErrorList);
			}
			   

			if (hasErrors) {
				throw new syncIeCloudOrganizationsException(errorMsg);
			}
		}
	}


	public static void processIeOrganizationsResponse(IE_IntegrationObjects.IE_OrganizationListResponse AccountList, boolean hasErrors,  
                                 map<Id, Account> accountMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList)
    {
    	list<IE_IntegrationObjects.IE_Organization> Accounts = AccountList.Organizations;
       	//Parse the response for errors
       	// retrieve the IE IDs and update the base as well as the child objects if they are null
       	// update the status to Processed
       
       	//log errors
       	//update the status to Error
       	for(IE_IntegrationObjects.IE_Organization account : Accounts)
       	{
       		if(account.Errors != null && account.errors.size() >0)
       		{
       			accountMap.get(account.SFDCId).IE_Sync_Status__c = 'Error';
       			integrationErrorList.add(new Integration_Error__c(Direction__c 			= 'Outbound'
       															, Error_Description__c 	= String.ValueOf(account.errors)
       															, Integration_Object__c = 'Account'
       															, Integration_Object_Id__c = account.SFDCId
       															, Integration_Point__c  = 'IE'
       															, Request_Data__c 		= JSON.serialize(account) ));
       		}
       		else
       		{
       			accountMap.get(account.SFDCId).IE_Sync_Status__c = 'Processed';

				if (String.isNotEmpty(account.IEId))
       				accountMap.get(account.SFDCId).IE_Id__c = account.IEId;

				accountMap.get(account.SFDCId).IE_Account__c = true;  // set this to true in case it wasn't set earlier
       		}

			if(account.Address != null && addressMap.containsKey(account.Address.SFDCId))
            {
                
                if(account.Address.errors != null && account.Address.errors.size() > 0)
                {
                    if(addressMap.containsKey(account.Address.SFDCId))
                      addressMap.get(account.Address.SFDCId).IE_Sync_Status__c = 'Error';
                        
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                    , Error_Description__c = String.ValueOf(account.Address.errors)
                                                                    , Integration_Object__c = 'Address'
                                                                    , Integration_Object_Id__c = account.Address.SFDCId
                                                                    , Integration_Point__c = 'IE'
                                                                    , Request_Data__c = JSON.serialize(account) ));
                }
            
                else
                {
                    if(addressMap.containsKey(account.Address.SFDCId))
                    {
                        addressMap.get(account.Address.SFDCId).IE_Sync_Status__c = 'Processed';

						if (String.isNotEmpty(account.Address.IEId))
							addressMap.get(account.Address.SFDCId).IE_Id__c = account.Address.IEId;

						addressMap.get(account.Address.SFDCId).IE_Address__c = true;  // set this to true in case it wasn't set earlier
                    }
                }
            }

       	}
    }


	public static void syncIeCloudSubscriptions(list<Subscription__c> subscriptions, map<Id, Subscription__c> subscriptionMap, list<Integration_Error__c> integrationErrorList)
	{
		// Call the IE API/Service Portal Web Service to update the Status
    	// of the IE Subscription in the MS Azure Cloud IE database.

		Integer SUBSCRIPTION_BATCH_SIZE = 10;
		
    	TriggerUtility.limitIntegrationBatch = true; // set this to true since subscriptions may be updated which will invoke the SubscriptionTriggerHandler

		
		if (!subscriptions.isEmpty()) {
			// Check if the number of subscriptions in the list is > SUBSCRIPTION_BATCH_SIZE and break it up into multiple chunks and
			// call the ie service for each chunk to avoid any timeouts processing a large Request object.
			integer numOfSubscriptions = subscriptions.size();
			if (numOfSubscriptions > SUBSCRIPTION_BATCH_SIZE) {
				integer loopCnt = numOfSubscriptions/SUBSCRIPTION_BATCH_SIZE;
				integer rem = Math.mod(numOfSubscriptions, SUBSCRIPTION_BATCH_SIZE);
				integer startIdx = 0;

				for (Integer i = 0; i < loopCnt; i++) {
				  List<SObject> tempSubscriptionList = new list<SObject>();
				  integer endIdx = startIdx + SUBSCRIPTION_BATCH_SIZE;
				  for (Integer j = startIdx; j < endIdx; j++) {
				    tempSubscriptionList.add(subscriptions[j]);
				  }
				  // Process each chunk of subscriptions
				  if (rem > 0)
				    // There is a remaining chunk so we don't save result on this call
				    processSubscriptions(tempSubscriptionList, subscriptionMap, integrationErrorList, false);
				  else if (i == loopCnt-1)
				    // There is no remaining chunk and this is the final iteration of the loop so we want to save result on this final call
				    processSubscriptions(tempSubscriptionList, subscriptionMap, integrationErrorList, true);
				  else
				    // There is no remaining chunk and this is not the final iteration of the loop so we don't save result on this call
				    processSubscriptions(tempSubscriptionList, subscriptionMap, integrationErrorList, false);

				  startIdx = startIdx + SUBSCRIPTION_BATCH_SIZE;
				}
				if (rem > 0) {
				  // Process the remaining chunk of subscriptions
				  List<SObject> tempSubscriptionList = new list<SObject>();
				  integer endIdx = startIdx + rem;
				  for (Integer i = startIdx; i < endIdx; i++) {
				    tempSubscriptionList.add(subscriptions[i]);
				  }
				  // This is the remaining chunk so we want to save result on this final call
				  processSubscriptions(tempSubscriptionList, subscriptionMap, integrationErrorList, true);
				}
			}
			else {
				// Only one chunk to process so we want to save result on this final call
				processSubscriptions(subscriptions, subscriptionMap, integrationErrorList, true);
			}
        }
	}

	
	
	public static void processSubscriptions(List<SObject> subscriptions, map<Id, Subscription__c> subscriptionMap, list<Integration_Error__c> integrationErrorList, Boolean saveResults)
	{
		boolean hasErrors = false;

    	// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'syncIeCloudSubscriptions errors: ';

		//populate the objects for integration
		IE_IntegrationObjects.IE_SubscriptionList ieSubscriptionPost = new IE_IntegrationObjects.IE_SubscriptionList();
				ieSubscriptionPost.Subscriptions = new list<IE_IntegrationObjects.IE_Subscription>();
		IE_IntegrationObjects.IE_SubscriptionList ieSubscriptionPut = new IE_IntegrationObjects.IE_SubscriptionList();
				ieSubscriptionPut.Subscriptions = new list<IE_IntegrationObjects.IE_Subscription>();

		//define the response objects
		IE_IntegrationObjects.IE_SubscriptionListResponse ieSubscriptionPostResponse = new IE_IntegrationObjects.IE_SubscriptionListResponse();
		IE_IntegrationObjects.IE_SubscriptionListResponse ieSubscriptionPutResponse = new IE_IntegrationObjects.IE_SubscriptionListResponse();
				

		//map<Id, Subscription__c> subscriptionMap = new map<Id, Subscription__c>();
		//list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();

		for (SObject so : subscriptions)
		{
			Subscription__c s = (Subscription__c)so;
			
			//if (s.TriggerInvokedByAPI__c == true)
			//{
				// Only process if trigger was invoked by an ETL Insert or an IE Renewal Web Service Call Update or could be used by a Batch Job

				//create the ie subscription object and add it to the list
				IE_IntegrationObjects.IE_Subscription ieSubscription = new IE_IntegrationObjects.IE_Subscription();
				ieSubscription.Type			= s.Type__c;
				ieSubscription.StartDate	= s.Start_Date__c;
				ieSubscription.EndDate		= s.End_Date__c;
				ieSubscription.BuyerID		= s.Buyer_ID__c;
				ieSubscription.IEId			= s.IE_ID__c;
				ieSubscription.SFDCId		= s.Id;
				ieSubscription.LastModifiedDate	= s.LastModifiedDate;
				ieSubscription.Active 		= s.Active__c;
				if (s.GWotGoAsset__c != null)
					ieSubscription.UnitSFDCId = s.GWotGoAsset__c;  // Here we set the SFDCId to the Id of the GWotGo asset
				else
					ieSubscription.UnitSFDCId = s.Asset__c;

				
				if(s.IE_ID__c == null)
					ieSubscriptionPost.Subscriptions.add(ieSubscription);
				else
					ieSubscriptionPut.Subscriptions.add(ieSubscription);
				

				//store the Subscription__c in the map to retrieve response status
				subscriptionMap.put(s.Id, s);

			//}
			//System.debug(LoggingLevel.ERROR,'syncIeCloudSubscription1: Active__c = ' + s.Active__c + ' TriggerInvokedByAPI__c = ' + s.TriggerInvokedByAPI__c + ' End_Date__c = ' + s.End_Date__c);

		}

		//
		// call the service - Determine PUT or POST
		//

		String jsonPostResponse = '';
		String jsonPutResponse = '';
		
		//Process the POST
		try {
		   if (ieSubscriptionPost != null && ieSubscriptionPost.Subscriptions.size() > 0)
		   {
		       System.Debug(':::ieSubscriptionPost:::'+JSON.serialize(ieSubscriptionPost));
		       HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().SubscriptionService__c
		                                                                 , 'POST'
		                                                                 , JSON.serialize(ieSubscriptionPost));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_CallExtWebServices.crash_syncIeCloudSubscriptions_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_CallExtWebServices.crash_syncIeCloudSubscriptions_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(ieSubscriptionPost));
	        			}
	        		}
	        	}


		       if(response.getStatusCode() == 200)
		       {
		            //iterate over the response checking for errors maybe we just return the body
		            if(Test.isRunningTest())
		            	jsonPostResponse = JSON.serialize(ieSubscriptionPost);//for testing purposes since we can make a call-out
		            else
		            	jsonPostResponse = response.getBody();
		            	
		            System.Debug(':::ieSubscriptionPost Response:::'+jsonPostResponse);
		       	
		            ieSubscriptionPostResponse = (IE_IntegrationObjects.IE_SubscriptionListResponse)JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_SubscriptionListResponse.class);
		       }
		       else { 
		        	//log the error
		        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound POST'
																	, Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
																	, Integration_Object__c = 'Subscription__c'
																	, Integration_Point__c = 'IE'
																	, Request_Data__c = JSON.serialize(ieSubscriptionPost) ));
					hasErrors = true;
					errorMsg = errorMsg + ' | ' + 'Post Transmission Error ['+response.getStatusCode()+']';
		       }
		   }
		}
		catch (Exception e)
		{
			//log the error
			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound POST'
																, Error_Description__c = 'CALLOUT_EXCEPTION'
																, Integration_Object__c = 'Subscription__c'
																, Integration_Point__c = 'IE'
																, Request_Data__c = e.getMessage() ));
			hasErrors = true;
			errorMsg = errorMsg + ' | ' + 'Post CALLOUT_EXCEPTION ' + e.getMessage();
		}


		//Process the PUT 
		try {
		   if (ieSubscriptionPut != null && ieSubscriptionPut.Subscriptions.size() > 0)
		   {
		       System.Debug(':::ieSubscriptionPut:::'+JSON.serialize(ieSubscriptionPut));
		       HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().SubscriptionService__c
		                                                                 , 'PUT'
		                                                                 , JSON.serialize(ieSubscriptionPut));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_CallExtWebServices.crash_syncIeCloudSubscriptions_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_CallExtWebServices.crash_syncIeCloudSubscriptions_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(ieSubscriptionPut));
	        			}
	        		}
	        	}

		       
		       if(response.getStatusCode() == 200)
		        { 
		            //iterate over the response checking for errors maybe we just return the body
		            if(Test.isRunningTest())
		            	jsonPutResponse = JSON.serialize(ieSubscriptionPut);//for testing purposes since we can make a call-out
		            else
		            	jsonPutResponse = response.getBody();
		            	
		            System.Debug(':::ieSubscriptionPut Response:::'+jsonPutResponse);
		            	
		            ieSubscriptionPutResponse = (IE_IntegrationObjects.IE_SubscriptionListResponse)JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_SubscriptionListResponse.class);
		        }
		        else{ 
		        	//log the error
		        	integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound PUT'
		   															, Error_Description__c = 'Transmission Error ['+response.getStatusCode()+' ] '//+response.getHeader()+']'
		   															, Integration_Object__c = 'Subscription__c'
		   															, Integration_Point__c = 'IE'
		   															, Request_Data__c = JSON.serialize(ieSubscriptionPut) ));
					hasErrors = true;
					errorMsg = errorMsg + ' | ' + 'Put Transmission Error ['+response.getStatusCode()+']';
		        }
		   }
		}
		catch (Exception e)
		{
			//log the error
			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound PUT'
															, Error_Description__c = 'CALLOUT_EXCEPTION'
															, Integration_Object__c = 'Subscription__c'
															, Integration_Point__c = 'IE'
															, Request_Data__c = 'Response: '+jsonPostResponse+jsonPutResponse+e.getMessage() ));
			hasErrors = true;
			errorMsg = errorMsg + ' | ' + 'Put CALLOUT_EXCEPTION ' + e.getMessage();
		}


		if (!hasErrors) {
			//process the responses adding IE Ids and/or Logging Errors
			if(ieSubscriptionPostResponse.Subscriptions != null && ieSubscriptionPostResponse.Subscriptions.size() > 0)
					processIeSubscriptionsResponse(ieSubscriptionPostResponse, hasErrors, subscriptionMap, integrationErrorList);
			if(ieSubscriptionPutResponse.Subscriptions != null && ieSubscriptionPutResponse.Subscriptions.size() > 0)
					processIeSubscriptionsResponse(ieSubscriptionPutResponse, hasErrors, subscriptionMap, integrationErrorList);


			//update the records with the IE Keys
			/*if (subscriptionMap.size() > 0)
	       		update subscriptionMap.values();*/
       	}


		/*if (integrationErrorList.size() > 0)
			insert integrationErrorList;*/


		if (hasErrors) {
			throw new syncIeCloudSubscriptionsException(errorMsg);
		}
	}


	public static void processIeSubscriptionsResponse(IE_IntegrationObjects.IE_SubscriptionListResponse Subscriptions, boolean hasErrors,  
                                 map<Id, Subscription__c> subscriptionMap, list<Integration_Error__c> integrationErrorList)
    {
    	
       	//Parse the response for errors
       	// retrieve the IE IDs and update the base as well as the child objects if they are null
       	// update the status to Processed
       
       	//log errors
       	//update the status to Error
       	for(IE_IntegrationObjects.IE_Subscription subscription : Subscriptions.Subscriptions)
       	{ 
       		if (subscription.errors != null && subscription.errors.size() > 0)
       		{
       			subscriptionMap.get(subscription.SFDCId).IE_Sync_Status__c 				= 'Error';
       			integrationErrorList.add(new Integration_Error__c(Direction__c 			= 'Outbound'
       															, Error_Description__c 	= String.ValueOf(subscription.errors)
       															, Integration_Object__c = 'Subscription__c'
       															, Integration_Object_Id__c = subscription.SFDCId
       															, Integration_Point__c 	= 'IE'
       															, Request_Data__c 		= JSON.serialize(subscription) ));
       		}
       		else
       		{
       			subscriptionMap.get(subscription.SFDCId).IE_Sync_Status__c = 'Processed';

				if (String.isNotEmpty(subscription.IEId))
       				subscriptionMap.get(subscription.SFDCId).IE_Id__c = subscription.IEId;
       		}
       	}
    }


    public static void syncIeCloudSIMCardActiveStatus(list<Asset> gwAssets, map<Id, Asset> assetMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList)
    {
    	// Call the IE API/Service Portal Web Service to only update the SIM Card Active Status for the GW asset
    	// of the IE Unit (asset) in the MS Azure Cloud IE database.
		
		// NOTE: Each GW Asset has an associated parent unit asset.
		
		Integer UNIT_BATCH_SIZE = 10;

    	TriggerUtility.limitIntegrationBatch = true; // set this to true since assets may be updated which will invoke the AssetTriggerHandler

		if (!gwAssets.isEmpty()) {
			// Check if the number of gateway assets is > UNIT_BATCH_SIZE and break it up into multiple chunks and
			// call the ie service for each chunk to avoid any timeouts processing a large Request object.
			
			integer numOfGWAssets = gwAssets.size();
			if (numOfGWAssets > UNIT_BATCH_SIZE) {
				integer loopCnt = numOfGWAssets/UNIT_BATCH_SIZE;
				integer rem = Math.mod(numOfGWAssets, UNIT_BATCH_SIZE);
				integer startIdx = 0;

				for (Integer i = 0; i < loopCnt; i++) {
				  List<Asset> tempGWAssetList = new list<Asset>();
				  integer endIdx = startIdx + UNIT_BATCH_SIZE;
				  for (Integer j = startIdx; j < endIdx; j++) {
				    tempGWAssetList.add(gwAssets[j]);
				  }
				  // Process each chunk of GW assets
				  if (rem > 0)
				    // There is a remaining chunk so we don't save result on this call
				    processSIMCardActiveStatus(tempGWAssetList, assetMap, addressMap, integrationErrorList, false);
				  else if (i == loopCnt-1)
				    // There is no remaining chunk and this is the final iteration of the loop so we want to save result on this final call
				    processSIMCardActiveStatus(tempGWAssetList, assetMap, addressMap, integrationErrorList, true);
				  else
				    // There is no remaining chunk and this is not the final iteration of the loop so we don't save result on this call
				    processSIMCardActiveStatus(tempGWAssetList, assetMap, addressMap, integrationErrorList, false);

				  startIdx = startIdx + UNIT_BATCH_SIZE;
				}
				if (rem > 0) {
				  // Process the remaining chunk of GW assets
				  List<Asset> tempGWAssetList = new list<Asset>();
				  integer endIdx = startIdx + rem;
				  for (Integer i = startIdx; i < endIdx; i++) {
				    tempGWAssetList.add(gwAssets[i]);
				  }
				  // This is the remaining chunk so we want to save result on this final call
				  processSIMCardActiveStatus(tempGWAssetList, assetMap, addressMap, integrationErrorList, true);
				}
			}
			else {
				// Only one chunk to process so we want to save result on this final call
				processSIMCardActiveStatus(gwAssets, assetMap, addressMap, integrationErrorList, true);
			}
        }
	}
	
	
	public static void processSIMCardActiveStatus(List<Asset> gwAssets, map<Id, Asset> assetMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList, Boolean saveResults)
	{
		boolean hasErrors = false;
		boolean hasIETimeout = false;
		
		// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'syncIeCloudSIMCardActiveStatus errors: ';
		
		//populate the objects for integration
		IE_IntegrationObjects.IE_UnitList UnitsPost = new IE_IntegrationObjects.IE_UnitList();
	    UnitsPost.Units = new list<IE_IntegrationObjects.IE_Unit>();
	    IE_IntegrationObjects.IE_UnitList  UnitsPut = new IE_IntegrationObjects.IE_UnitList();
	    UnitsPut.Units = new list<IE_IntegrationObjects.IE_Unit>();
		
		//define the response objects
		IE_IntegrationObjects.IE_UnitListResponse UnitsPostResponse = new IE_IntegrationObjects.IE_UnitListResponse();
	    IE_IntegrationObjects.IE_UnitListResponse  UnitsPutResponse = new IE_IntegrationObjects.IE_UnitListResponse();
		
		//map<Id, Asset> assetMap = new map<Id, Asset>();
	    //map<Id, Address__c> addressMap = new map<Id, Address__c>();
	    //list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();

		// Mapping structure for GWotGo to its unit asset
		map<Id, Id> GWotGo_unitAssetMap = new map<Id, Id>();

	    // Bulkify Asset SOQL query
		map<Id, Asset> parentAssetMap = new map<Id, Asset>();
        set<Id> parentAssetIds = new set<Id>();
        for (Asset a : gwAssets)
        {
            if (a.Parent_Asset__c != null)
                parentAssetIds.add(a.Parent_Asset__c);
        }
        for (Asset a : [Select Id
	                  , SerialNumber
	                  , Tag__c
	                  , SO_Number__c
	                  , Job_Name__c
	                  , Device_ID__c
	                  , SIM_Card_ICCID__c
	                  , SIM_Card_Active__c
	                  , Format_Number__c
	                  , Commissioned__c
	                  , IE_ID__c
	                  , IE_Asset__c
	                  , IE_Sync_Status__c
	                  , IE_Updated_Date__c
	                  , Current_Code_String_Breakdown__c
	                  , Code_String_Breakdown__c
	                  , LastModifiedDate
	                  //address data
	                  , Asset_Address__c
	                  , Asset_Address__r.Country__c
	                  , Asset_Address__r.Postal_Code__c
	                  , Asset_Address__r.State_Province__c
	                  , Asset_Address__r.County__c
	                  , Asset_Address__r.State_Province_ISO_Code__c
	                  , Asset_Address__r.Country_ISO_Code__c
	                  , Asset_Address__r.City__c
	                  , Asset_Address__r.Address_Line_4__c 
	                  , Asset_Address__r.Address_Line_3__c
	                  , Asset_Address__r.Address_Line_2__c
	                  , Asset_Address__r.Address_Line_1__c
	                  , Asset_Address__r.Name
	                  , Asset_Address__r.IE_ID__c
	                  , Asset_Address__r.Id 
	                  , Asset_Address__r.LastModifiedDate
	                  //related assets (gateway and emm)
	                  /*,(Select Id
	                          , SerialNumber
	                          , Tag__c
	                          , SO_Number__c
	                          , Job_Name__c
	                          , Device_ID__c
	                          , SIM_Card_ICCID__c
	                          , SIM_Card_Active__c
	                          , Format_Number__c
	                          , Commissioned__c
	                          , IE_ID__c
	                          , IE_Updated_Date__c
	                          , LastModifiedDate
	                      From Assets__r
	                     where Status != 'Obsolete'
	                    )*/
	             from Asset
	             where Id in :parentAssetIds])
        	parentAssetMap.put(a.Id, a);

		
	    for (Asset gwAsset : gwAssets)
	    {
	    	// first get the parent asset
	    	Asset parentAsset=null;

			parentAsset = parentAssetMap.get(gwAsset.Parent_Asset__c);


			if (parentAsset != null) {
		        //get the address data
		        IE_IntegrationObjects.IE_Address address = new IE_IntegrationObjects.IE_Address();
		        
		        address.AddressLine1 = parentAsset.Asset_Address__r.Address_Line_1__c;
		        address.AddressLine2 = parentAsset.Asset_Address__r.Address_Line_2__c;
		        address.AddressLine3 = parentAsset.Asset_Address__r.Address_Line_3__c;
		        address.AddressLine4 = parentAsset.Asset_Address__r.Address_Line_4__c;
		        address.City         = parentAsset.Asset_Address__r.City__c;
		        address.Country      = parentAsset.Asset_Address__r.Country_ISO_Code__c;  
		        address.StateCode    = parentAsset.Asset_Address__r.State_Province_ISO_Code__c;
		        address.ZipCode      = parentAsset.Asset_Address__r.Postal_Code__c;
		        address.SFDCId       = parentAsset.Asset_Address__r.Id;
		        address.IEId         = parentAsset.Asset_Address__r.IE_ID__c;
		        if(parentAsset.Asset_Address__c != null)
		        {
					address.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
		            /*address.LastModifiedDate = DateTime.newInstance(parentAsset.Asset_Address__r.LastModifiedDate.dateGmt()
		                                                           ,parentAsset.Asset_Address__r.LastModifiedDate.timeGmt());*/

		            addressMap.put(parentAsset.Asset_Address__r.Id, parentAsset.Asset_Address__r);
		        }
		         
		        
		        //create the Individual and add it to the list
		        IE_IntegrationObjects.IE_Unit ieUnit = new IE_IntegrationObjects.IE_Unit();
		        ieUnit.UnitAddress      =   address;
		        ieUnit.SerialNumber     =   parentAsset.SerialNumber;
		        ieUnit.UnitTag          =   parentAsset.Tag__c;
		        ieUnit.SalesOrderNumber =   parentAsset.SO_Number__c;
		        ieUnit.JobName          =   parentAsset.Job_Name__c;
		        //ieUnit.MACAddress       =   parentAsset.Device_ID__c;  // MAC Address not applicable for parent asset
		        //ieUnit.SIMCardICCID     =   parentAsset.SIM_Card_ICCID__c;  // Sim Card ICCID not applicable for parent asset
		        //ieUnit.IsSimCardActive  =   parentAsset.SIM_Card_Active__c;  // SIM Card Active Status not applicable for parent asset
		        ieUnit.CodeStringFormat =   parentAsset.Format_Number__c;
		        
		        //add the code string values
		        string codeStringBreakDown = '';
		        
		        if(parentAsset.Current_Code_String_Breakdown__c != null) 
		            codeStringBreakDown = parentAsset.Current_Code_String_Breakdown__c;
		        else  
		            codeStringBreakDown = parentAsset.Code_String_Breakdown__c;
		        
		        ieUnit.CodeValues = getCodeStringValues(codeStringBreakDown);
		        
		        ieUnit.Commissioned     =   parentAsset.Commissioned__c;
		        ieUnit.IEId             =   parentAsset.IE_ID__c;

				if (gwAsset.GWotGo__c == true)
				{
					ieUnit.SFDCId = gwAsset.Id;  // Here we set the SFDCId to the Id of the GWotGo asset
					GWotGo_unitAssetMap.put(gwAsset.Id, parentAsset.Id);
				}
				else
					ieUnit.SFDCId = parentAsset.Id;

		        ieUnit.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
				/*ieUnit.LastModifiedDate = DateTime.newInstance(parentAsset.LastModifiedDate.dateGmt()
		                                                      ,parentAsset.LastModifiedDate.timeGmt());*/

		        ieUnit.MACAddress       =   gwAsset.Device_ID__c;
		        ieUnit.SIMCardICCID     =   gwAsset.SIM_Card_ICCID__c;
		        ieUnit.IsSimCardActive  =   gwAsset.SIM_Card_Active__c;

		        /*if(parentAsset.Assets__r != null && parentAsset.Assets__r.size() > 0)
		        {
		        	// For related assets there will be a GW and EMM asset, only interested in getting the value from the GW asset
		            for(Asset ax : parentAsset.Assets__r)
		            {
		                if(ax.Device_ID__c != null)
		                    ieUnit.MACAddress       =   ax.Device_ID__c;

		                if(ax.SIM_Card_ICCID__c != null)    
		                    ieUnit.SIMCardICCID     =   ax.SIM_Card_ICCID__c;

		                if((ax.SIM_Card_ICCID__c != null) && (ax.SIM_Card_Active__c != null))
		                	ieUnit.IsSimCardActive = gwAsset.SIM_Card_Active__c;  // SIM Card Active Status on GW asset
		            }
		        }*/

		        if(parentAsset.IE_ID__c == null)
		            UnitsPost.Units.add(ieUnit);
		        else
		            UnitsPut.Units.add(ieUnit);
		        
		        //store the Asset in the map to retrieve response status
		        assetMap.put(parentAsset.Id, parentAsset);
        	}
	    }
	       
        //
        // call the service - Determine PUT or POST
        //
       
        String jsonPostResponse = '';
        String jsonPutResponse = '';

        //Process the POST
        try{
           if(UnitsPost.Units != null && UnitsPost.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitList  Units = UnitsPost;
               System.debug('syncIeCloudSIMCardActiveStatus POST Asset: '+JSON.serialize(Units));

               HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitService__c
                                                                         , 'POST'
                                                                         , JSON.serialize(Units));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_ProcObsGWAssets.crash_syncIeCloudSIMCardActiveStatus_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_ProcObsGWAssets.crash_syncIeCloudSIMCardActiveStatus_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(Units));
	        			}
	        		}
	        	}

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPostResponse = JSON.serialize(Units);//for testing purposes since we can make a call-out
                    else
                        jsonPostResponse = response.getBody();
                    
                    System.debug('syncIeCloudSIMCardActiveStatus POST UNITS RESPONSE: '+jsonPostResponse);
                    UnitsPostResponse = (IE_IntegrationObjects.IE_UnitListResponse )JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_UnitListResponse.class);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPost) ));
                    hasErrors = true;
                    errorMsg = errorMsg + ' | ' + 'Post Transmission Error ['+response.getStatusCode()+']';
                }
           }
       	}
       	catch(Exception e)
       	{
            //log the error
            System.debug('syncIeCloudSIMCardActiveStatus POST CALLOUT EXCEPTION: '+ e);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;

            errorMsg = errorMsg + ' | ' + 'Post CALLOUT_EXCEPTION ' + e.getMessage();
       	}
	    

	    // Process the Put
	    try{
           if(UnitsPut.Units != null && UnitsPut.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitList  Units = UnitsPut;
               System.debug('syncIeCloudSIMCardActiveStatus PUT Asset: '+JSON.serialize(Units));

               HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitService__c
                                                                         , 'PUT'
                                                                         , JSON.serialize(Units));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_ProcObsGWAssets.crash_syncIeCloudSIMCardActiveStatus_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_ProcObsGWAssets.crash_syncIeCloudSIMCardActiveStatus_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(Units));
	        			}
	        		}
	        	}

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPutResponse = JSON.serialize(Units);//for testing purposes since we can make a call-out
                    else
                        jsonPutResponse = response.getBody();
                        
                    UnitsPutResponse = (IE_IntegrationObjects.IE_UnitListResponse )JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_UnitListResponse.class);
                    System.debug('syncIeCloudSIMCardActiveStatus PUT UNITS RESPONSE: '+UnitsPutResponse);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPut) ));
                    hasErrors = true;
                    errorMsg = errorMsg + ' | ' + 'Put Transmission Error ['+response.getStatusCode()+']';
                }
           }
       	}
       	catch(Exception e)
       	{
            //log the error
            System.debug('syncIeCloudSIMCardActiveStatus PUT CALLOUT EXCEPTION: '+ e);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;

            errorMsg = errorMsg + ' | ' + 'Put CALLOUT_EXCEPTION ' + e.getMessage();
       	}
	    

        if(!hasErrors)
        {
           if(UnitsPostResponse.Units != null && UnitsPostResponse.Units.size() > 0)
                processIeUnitsResponse(UnitsPostResponse, hasErrors, assetMap, addressMap, GWotGo_unitAssetMap, integrationErrorList);

           if(UnitsPutResponse.Units != null && UnitsPutResponse.Units.size() > 0)
                processIeUnitsResponse(UnitsPutResponse, hasErrors, assetMap, addressMap, GWotGo_unitAssetMap, integrationErrorList);
           
           //update the records with the IE Keys
           /*if (assetMap.size() > 0)
           		update assetMap.values();

           if (addressMap.size() > 0)
                update addressMap.values();*/
        }
           
        /*if(integrationErrorList.size() > 0)
            insert integrationErrorList;*/


		if (hasErrors && !hasIETimeout) throw new syncIeCloudSIMCardActiveStatusException(errorMsg);  // Only Rethrow a new exception if there wasn't an IE Timeout exception thrown

	}


    public static void syncIeCloudUnits(list<Subscription__c> subscriptions, map<Id, Asset> assetMap, map<Id, Asset> relatedAssetMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList)
    {
    	// Call the IE API/Service Portal Web Service to update the Connectivity Type and SIM Card Active Status
    	// of the IE Unit (asset) in the MS Azure Cloud IE database.

		// NOTE: This gets called with a list of TechReadWrite/CustomRead type subscription pairs for each batch OR just a Standard subscription type.
		// The number of records depends on the batch size in the schedular.
		// Since there may be a pair of Subscription records (TechReadWrite, CustomRead) for an order, 
   		// just get the subscription whose type is TechReadWrite, since they both have the same parent unit asset;
		// OR just 1 subscription record of type Standard.


		Integer UNIT_BATCH_SIZE = 10;
		
		// list to contain the subscriptions of type TechReadWrite and Standard
		List<Subscription__c> subscriptionList = new list<Subscription__c>();
		
    	TriggerUtility.limitIntegrationBatch = true; // set this to true since assets may be updated which will invoke the AssetTriggerHandler

		for (Subscription__c s : subscriptions)
		{
			if ((s.Asset__c != null) && (s.Type__c == 'TechReadWrite' || s.Type__c == 'TechRead' || s.Type__c == 'Standard'))
				subscriptionList.add(s);
		}

			
		if (!subscriptionList.isEmpty()) {
			// Check if the number of subscriptions in the list is > UNIT_BATCH_SIZE and break it up into multiple chunks and
			// call the ie service for each chunk to avoid any timeouts processing a large Request object.
			
			integer numOfSubscriptions = subscriptionList.size();
			if (numOfSubscriptions > UNIT_BATCH_SIZE) {
				integer loopCnt = numOfSubscriptions/UNIT_BATCH_SIZE;
				integer rem = Math.mod(numOfSubscriptions, UNIT_BATCH_SIZE);
				integer startIdx = 0;

				for (Integer i = 0; i < loopCnt; i++) {
				  List<Subscription__c> tempSubscriptionList = new list<Subscription__c>();
				  integer endIdx = startIdx + UNIT_BATCH_SIZE;
				  for (Integer j = startIdx; j < endIdx; j++) {
				    tempSubscriptionList.add(subscriptionList[j]);
				  }
				  // Process each chunk of subscriptions
				  if (rem > 0)
				    // There is a remaining chunk so we don't save result on this call
				    processUnits(tempSubscriptionList, assetMap, relatedAssetMap, addressMap, integrationErrorList, false);
				  else if (i == loopCnt-1)
				    // There is no remaining chunk and this is the final iteration of the loop so we want to save result on this final call
				    processUnits(tempSubscriptionList, assetMap, relatedAssetMap, addressMap, integrationErrorList, true);
				  else
				    // There is no remaining chunk and this is not the final iteration of the loop so we don't save result on this call
				    processUnits(tempSubscriptionList, assetMap, relatedAssetMap, addressMap, integrationErrorList, false);

				  startIdx = startIdx + UNIT_BATCH_SIZE;
				}
				if (rem > 0) {
				  // Process the remaining chunk of subscriptions
				  List<Subscription__c> tempSubscriptionList = new list<Subscription__c>();
				  integer endIdx = startIdx + rem;
				  for (Integer i = startIdx; i < endIdx; i++) {
				    tempSubscriptionList.add(subscriptionList[i]);
				  }
				  // This is the remaining chunk so we want to save result on this final call
				  processUnits(tempSubscriptionList, assetMap, relatedAssetMap, addressMap, integrationErrorList, true);
				}
			}
			else {
				// Only one chunk to process so we want to save result on this final call
				processUnits(subscriptionList, assetMap, relatedAssetMap, addressMap, integrationErrorList, true);
			}
        }
	}

	
	public static void processUnits(List<Subscription__c> subscriptions, map<Id, Asset> assetMap, map<Id, Asset> relatedAssetMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList, Boolean saveResults)
	{
		boolean hasErrors = false;
		
		// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'syncIeCloudUnits errors: ';
		
		//populate the objects for integration
		IE_IntegrationObjects.IE_UnitList UnitsPost = new IE_IntegrationObjects.IE_UnitList ();
		UnitsPost.Units = new list<IE_IntegrationObjects.IE_Unit>();
		IE_IntegrationObjects.IE_UnitList  UnitsPut = new IE_IntegrationObjects.IE_UnitList ();
		UnitsPut.Units = new list<IE_IntegrationObjects.IE_Unit>();

		//define the response objects
		IE_IntegrationObjects.IE_UnitListResponse UnitsPostResponse = new IE_IntegrationObjects.IE_UnitListResponse();
		IE_IntegrationObjects.IE_UnitListResponse UnitsPutResponse = new IE_IntegrationObjects.IE_UnitListResponse();
		
		//map<Id, Asset> assetMap = new map<Id, Asset>();
		//map<Id, Asset> relatedAssetMap = new map<Id, Asset>();
		//map<Id, Address__c> addressMap = new map<Id, Address__c>();
		//list<Integration_Error__c> integrationErrorList = new list<Integration_Error__c>();

		// Mapping structure for GWotGo to its unit asset
		map<Id, Id> GWotGo_unitAssetMap = new map<Id, Id>();

		// Bulkify Asset SOQL query
		map<Id, Asset> parentAssetMap = new map<Id, Asset>();
        set<Id> parentAssetIds = new set<Id>();
        for (Subscription__c s : subscriptions)
        {
           parentAssetIds.add(s.Asset__c);
        }
        for (Asset a : [Select Id
	                  , SerialNumber
	                  , Tag__c
	                  , SO_Number__c
	                  , Job_Name__c
	                  , Device_ID__c
	                  , SIM_Card_ICCID__c
	                  , SIM_Card_Active__c
	                  , Format_Number__c
	                  , Commissioned__c
	                  , IE_ID__c
	                  , IE_Asset__c
	                  , IE_Sync_Status__c
	                  , IE_Updated_Date__c
	                  , Current_Code_String_Breakdown__c
	                  , Code_String_Breakdown__c
	                  , LastModifiedDate
	                  //address data
	                  , Asset_Address__c
	                  , Asset_Address__r.Country__c
	                  , Asset_Address__r.Postal_Code__c
	                  , Asset_Address__r.State_Province__c
	                  , Asset_Address__r.County__c
	                  , Asset_Address__r.State_Province_ISO_Code__c
	                  , Asset_Address__r.Country_ISO_Code__c
	                  , Asset_Address__r.City__c
	                  , Asset_Address__r.Address_Line_4__c 
	                  , Asset_Address__r.Address_Line_3__c
	                  , Asset_Address__r.Address_Line_2__c
	                  , Asset_Address__r.Address_Line_1__c
	                  , Asset_Address__r.Name
	                  , Asset_Address__r.IE_ID__c
	                  , Asset_Address__r.Id 
	                  , Asset_Address__r.LastModifiedDate
	                  //related assets (gateway and emm)
	                  ,(Select Id
	                          , SerialNumber
	                          , Tag__c
	                          , SO_Number__c
	                          , Job_Name__c
	                          , Device_ID__c
	                          , SIM_Card_ICCID__c
	                          , SIM_Card_Active__c
	                          , Format_Number__c
	                          , Commissioned__c
	                          , IE_ID__c
	                          , IE_Updated_Date__c
	                          , LastModifiedDate
	                      From Assets__r
	                     where Status != 'Obsolete'
	                    )
	             from Asset
	             where Id in :parentAssetIds])
        	parentAssetMap.put(a.Id, a);

		
		for (Subscription__c s : subscriptions)
		{
			if ((s.TriggerInvokedByAPI__c == true) && (s.Type__c == 'TechReadWrite' || s.Type__c == 'TechRead' || s.Type__c == 'Standard'))
			{
				// Only process if trigger was invoked by an ETL Insert or an IE Renewal Web Service Call Update or could be used by a Batch Job

				// First get the asset
				Asset parentAsset=null;

				parentAsset = parentAssetMap.get(s.Asset__c);

				if (parentAsset != null)
				{
					if (parentAsset.Asset_Address__c != null)
					{
						// Asset needs an address otherwise coherent sync will fail

						//get the address data
						IE_IntegrationObjects.IE_Address ieAddress = new IE_IntegrationObjects.IE_Address();
		            
						ieAddress.AddressLine1 = parentAsset.Asset_Address__r.Address_Line_1__c;
						ieAddress.AddressLine2 = parentAsset.Asset_Address__r.Address_Line_2__c;
						ieAddress.AddressLine3 = parentAsset.Asset_Address__r.Address_Line_3__c;
						ieAddress.AddressLine4 = parentAsset.Asset_Address__r.Address_Line_4__c;
						ieAddress.City         = parentAsset.Asset_Address__r.City__c;
						ieAddress.Country      = parentAsset.Asset_Address__r.Country_ISO_Code__c;  
						ieAddress.StateCode    = parentAsset.Asset_Address__r.State_Province_ISO_Code__c;
						ieAddress.ZipCode      = parentAsset.Asset_Address__r.Postal_Code__c;
						ieAddress.SFDCId       = parentAsset.Asset_Address__r.Id;
						ieAddress.IEId         = parentAsset.Asset_Address__r.IE_ID__c;

						ieAddress.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
						/*ieAddress.LastModifiedDate = DateTime.newInstance(parentAsset.Asset_Address__r.LastModifiedDate.dateGmt()
																		  ,parentAsset.Asset_Address__r.LastModifiedDate.timeGmt());*/

						addressMap.put(parentAsset.Asset_Address__r.Id, parentAsset.Asset_Address__r);
		             
		            
						//create the ie unit object and add it to the list
						IE_IntegrationObjects.IE_Unit ieUnit = new IE_IntegrationObjects.IE_Unit();
						ieUnit.UnitAddress      =   ieAddress;
						ieUnit.ConnectivityType =   s.Connectivity_Type__c;  // Cellular or WiFi/LAN
						ieUnit.SerialNumber     =   parentAsset.SerialNumber;
						ieUnit.UnitTag          =   parentAsset.Tag__c;
						ieUnit.SalesOrderNumber =   parentAsset.SO_Number__c;
						ieUnit.JobName          =   parentAsset.Job_Name__c;
						ieUnit.MACAddress       =   parentAsset.Device_ID__c;  // MAC Address not applicable for parent asset
						ieUnit.SIMCardICCID     =   parentAsset.SIM_Card_ICCID__c;  // Sim Card ICCID not applicable for parent asset
						ieUnit.IsSimCardActive  =   parentAsset.SIM_Card_Active__c;  // SIM Card Active Status not applicable for parent asset
						ieUnit.CodeStringFormat =   parentAsset.Format_Number__c;
		            
						//add the code string values
						string codeStringBreakDown = '';
		            
						if(parentAsset.Current_Code_String_Breakdown__c != null) 
							codeStringBreakDown = parentAsset.Current_Code_String_Breakdown__c;
						else  
							codeStringBreakDown = parentAsset.Code_String_Breakdown__c;
		            
						ieUnit.CodeValues = getCodeStringValues(codeStringBreakDown);
		            
						ieUnit.Commissioned     =   parentAsset.Commissioned__c;
						ieUnit.IEId             =   parentAsset.IE_ID__c;

						if (s.GWotGoAsset__c != null)
						{
							ieUnit.SFDCId = s.GWotGoAsset__c;  // Here we set the SFDCId to the Id of the GWotGo asset
							GWotGo_unitAssetMap.put(s.GWotGoAsset__c, parentAsset.Id);
						}
						else
							ieUnit.SFDCId = parentAsset.Id;
						
						ieUnit.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
						/*ieUnit.LastModifiedDate = DateTime.newInstance(parentAsset.LastModifiedDate.dateGmt()
																	  ,parentAsset.LastModifiedDate.timeGmt());*/

						if (parentAsset.Assets__r != null && parentAsset.Assets__r.size() > 0)
						{
		            		// For related assets there will be a GW and EMM asset, only interested in getting the value from the GW asset
		            		integer idx = 0;
							for(Asset ax : parentAsset.Assets__r)
							{
								if(ax.Device_ID__c != null)
									ieUnit.MACAddress       =   ax.Device_ID__c;
		                    
								if(ax.SIM_Card_ICCID__c != null)
									ieUnit.SIMCardICCID     =   ax.SIM_Card_ICCID__c;

								if((ax.SIM_Card_ICCID__c != null) && (ax.SIM_Card_Active__c != null)) {
									if (s.Connectivity_Type__c == 'Cellular') {
			                    		// Set SIM Card Active Status on GW asset to True
			                    		ax.SIM_Card_Active__c = true;  // equiv to parentAsset.Assets__r[idx].SIM_Card_Active__c = true;
			                    		ieUnit.IsSimCardActive = true;
									}
									else {
			                    		// Set SIM Card Active Status on GW asset to False
			                    		ax.SIM_Card_Active__c = false;
			                    		ieUnit.IsSimCardActive = false;
									}
		                		}
								// Store the related asset in the map
								relatedAssetMap.put(ax.Id, ax);
							}
						}
						if(parentAsset.IE_ID__c == null)
							UnitsPost.Units.add(ieUnit);
						else
							UnitsPut.Units.add(ieUnit);
		            
						// Store the parent asset in the map to retrieve response status
						assetMap.put(parentAsset.Id, parentAsset);
					} // if (parentAsset.Asset_Address__c != null)
					else 
					{
						// Log that this asset is missing its address
						integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
												, Error_Description__c = 'Missing address information for asset ' + parentAsset.SerialNumber
												, Integration_Object__c = 'Asset'
												, Integration_Point__c = 'IE'
												, Request_Data__c = 'Cannot by synced with Coherent until address is provided' ));
					}
				} // if (parentAsset != null)
			}
		} // for-loop on subscriptions


		//
		// call the service - Determine PUT or POST
		//

		String jsonPostResponse = '';
		String jsonPutResponse = '';
		
		//Process the POST
       	try{
           if(UnitsPost.Units != null && UnitsPost.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitList  Units = UnitsPost;
               System.debug('syncIeCloudUnits POST Asset: '+JSON.serialize(Units));

               HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitService__c
                                                                         , 'POST'
                                                                         , JSON.serialize(Units));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(Units));
	        			}
	        		}
	        	}

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPostResponse = JSON.serialize(Units);//for testing purposes since we can make a call-out
                    else
                        jsonPostResponse = response.getBody();
                    
                    System.debug('syncIeCloudUnits POST UNITS RESPONSE: '+jsonPostResponse);
                    UnitsPostResponse = (IE_IntegrationObjects.IE_UnitListResponse )JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_UnitListResponse.class);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPost) ));
                    hasErrors = true;
                    errorMsg = errorMsg + ' | ' + 'Post Transmission Error ['+response.getStatusCode()+']';
                }
           }
       	}
       	catch(Exception e)
       	{
            //log the error
            System.debug('syncIeCloudUnits POST CALLOUT EXCEPTION: '+ e);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
            errorMsg = errorMsg + ' | ' + 'Post CALLOUT_EXCEPTION ' + e.getMessage();
       	}
       
       	//Process the PUT
       	try{
           if(UnitsPut.Units != null && UnitsPut.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitList  Units = UnitsPut;
               System.debug('syncIeCloudUnits PUT Asset: '+JSON.serialize(Units));

               HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitService__c
                                                                         , 'PUT'
                                                                         , JSON.serialize(Units));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(Units));
	        			}
	        		}
	        	}

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPutResponse = JSON.serialize(Units);//for testing purposes since we can make a call-out
                    else
                        jsonPutResponse = response.getBody();
                        
                    UnitsPutResponse = (IE_IntegrationObjects.IE_UnitListResponse )JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_UnitListResponse.class);
                    System.debug('syncIeCloudUnits PUT UNITS RESPONSE: '+UnitsPutResponse);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPut) ));
                    hasErrors = true;
                    errorMsg = errorMsg + ' | ' + 'Put Transmission Error ['+response.getStatusCode()+']';
                }
           }
       	}
       	catch(Exception e)
       	{
            //log the error
            System.debug('syncIeCloudUnits PUT CALLOUT EXCEPTION: '+ e);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
            errorMsg = errorMsg + ' | ' + 'Put CALLOUT_EXCEPTION ' + e.getMessage();
       	}
       
       	if (!hasErrors)
       	{
           if(UnitsPostResponse.Units != null && UnitsPostResponse.Units.size() > 0)
                processIeUnitsResponse(UnitsPostResponse, hasErrors, assetMap, addressMap, GWotGo_unitAssetMap, integrationErrorList);
           if(UnitsPutResponse.Units != null && UnitsPutResponse.Units.size() > 0)
                processIeUnitsResponse(UnitsPutResponse, hasErrors, assetMap, addressMap, GWotGo_unitAssetMap, integrationErrorList);
           
           //update the records with the IE Keys
           /*if (assetMap.size() > 0) 
           		update assetMap.values();

           if (relatedAssetMap.size() > 0)
           		update relatedAssetMap.values();

           if(addressMap.size() > 0)
				update addressMap.values();*/
       	}
           
       	/*if(integrationErrorList.size() > 0)
            insert integrationErrorList;*/


        if (hasErrors) {
			throw new syncIeCloudUnitsException(errorMsg);
		}
	}


    public static void processIeUnitsResponse(IE_IntegrationObjects.IE_UnitListResponse Units, boolean hasErrors, 
		map<Id, Asset> assetMap, map<Id, Address__c> addressMap, map<Id, Id> GWotGo_unitAssetMap, list<Integration_Error__c> integrationErrorList)
    {
    	//Parse the response for errors
        // retrieve the IE IDs and update the base as well as the child objects if they are null
        // update the status to Processed
       
        //log errors
        //update the status to Error
        for(IE_IntegrationObjects.IE_Unit unit : Units.Units)
        {
            if(unit.errors != null && unit.errors.size() > 0)
            {
                if (assetMap.containsKey(unit.SFDCId)) assetMap.get(unit.SFDCId).IE_Sync_Status__c = 'Error';  // unit.SFDCId is a unit asset
				else assetMap.get(GWotGo_unitAssetMap.get(unit.SFDCId)).IE_Sync_Status__c = 'Error';  // unit.SFDCId is a GWotGo so get its unit asset from its map first
					
                integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = String.ValueOf(unit.errors)
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Object_Id__c = unit.SFDCId
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(unit) ));

				for (IE_IntegrationObjects.IE_Error err : unit.errors)
					if (err.ErrorCode == 'Error') hasErrors = true;
            }
            else
            {
				if (assetMap.containsKey(unit.SFDCId)) {
					// unit.SFDCId is a unit asset
					assetMap.get(unit.SFDCId).IE_Sync_Status__c = 'Processed';

					if (String.isNotEmpty(unit.IEId)) assetMap.get(unit.SFDCId).IE_Id__c = unit.IEId;
				}
				else {
					// unit.SFDCId is a GWotGo so get its unit asset from its map first
					assetMap.get(GWotGo_unitAssetMap.get(unit.SFDCId)).IE_Sync_Status__c = 'Processed';

					if (String.isNotEmpty(unit.IEId)) assetMap.get(GWotGo_unitAssetMap.get(unit.SFDCId)).IE_Id__c = unit.IEId;
				}
            }
            
            if(unit.UnitAddress != null && addressMap.containsKey(unit.UnitAddress.SFDCId))
            {
                if(unit.UnitAddress.errors != null && unit.UnitAddress.errors.size() > 0)
                {
                    if(addressMap.containsKey(unit.UnitAddress.SFDCId))
                      addressMap.get(unit.UnitAddress.SFDCId).IE_Sync_Status__c = 'Error';
                        
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                    , Error_Description__c = String.ValueOf(unit.UnitAddress.errors)
                                                                    , Integration_Object__c = 'Address'
                                                                    , Integration_Object_Id__c = unit.UnitAddress.SFDCId
                                                                    , Integration_Point__c = 'IE'
                                                                    , Request_Data__c = JSON.serialize(unit) ));

					for (IE_IntegrationObjects.IE_Error err : unit.UnitAddress.errors)
						if (err.ErrorCode == 'Error') hasErrors = true;
                }
                else
                {
                    if(addressMap.containsKey(unit.UnitAddress.SFDCId))
                    {
                        addressMap.get(unit.UnitAddress.SFDCId).IE_Sync_Status__c = 'Processed';

						if (String.isNotEmpty(unit.UnitAddress.IEId))
							addressMap.get(unit.UnitAddress.SFDCId).IE_Id__c = unit.UnitAddress.IEId;

						addressMap.get(unit.UnitAddress.SFDCId).IE_Address__c = true;  // set this to true in case it wasn't set earlier
                    }
                }
            }
        }
    }


	public static void syncIeCloudUnitForGWotGo(Asset unitAsset, Asset gwAsset, string connectivityType, map<Id, Asset> assetMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList, boolean doPutOperation)
    {
    	// Call the IE API/Service Portal Web Service to sync up the given IE Unit asset in the MS Azure Cloud IE database.

    	TriggerUtility.limitIntegrationBatch = true; // set this to true since assets may be updated which will invoke the AssetTriggerHandler

    	// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'syncIeCloudUnitForGWotGo errors: ';

    	//populate the objects for integration
    	boolean hasErrors = false;
		boolean hasIETimeout = false;
		IE_IntegrationObjects.IE_UnitList UnitsPost = new IE_IntegrationObjects.IE_UnitList ();
		UnitsPost.Units = new list<IE_IntegrationObjects.IE_Unit>();
		IE_IntegrationObjects.IE_UnitList  UnitsPut = new IE_IntegrationObjects.IE_UnitList ();
		UnitsPut.Units = new list<IE_IntegrationObjects.IE_Unit>();

		IE_IntegrationObjects.IE_UnitListResponse UnitsPostResponse = new IE_IntegrationObjects.IE_UnitListResponse();
		IE_IntegrationObjects.IE_UnitListResponse UnitsPutResponse = new IE_IntegrationObjects.IE_UnitListResponse();


		if (unitAsset.Asset_Address__c != null)
		{
			// Asset needs an address otherwise coherent sync will fail

			//get the address data
			IE_IntegrationObjects.IE_Address ieAddress = new IE_IntegrationObjects.IE_Address();
		            
			ieAddress.AddressLine1 = unitAsset.Asset_Address__r.Address_Line_1__c;
			ieAddress.AddressLine2 = unitAsset.Asset_Address__r.Address_Line_2__c;
			ieAddress.AddressLine3 = unitAsset.Asset_Address__r.Address_Line_3__c;
			ieAddress.AddressLine4 = unitAsset.Asset_Address__r.Address_Line_4__c;
			ieAddress.City         = unitAsset.Asset_Address__r.City__c;
			ieAddress.Country      = unitAsset.Asset_Address__r.Country_ISO_Code__c;  
			ieAddress.StateCode    = unitAsset.Asset_Address__r.State_Province_ISO_Code__c;
			ieAddress.ZipCode      = unitAsset.Asset_Address__r.Postal_Code__c;
			ieAddress.SFDCId       = unitAsset.Asset_Address__r.Id;
			ieAddress.IEId         = unitAsset.Asset_Address__r.IE_ID__c;

			ieAddress.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
			/*ieAddress.LastModifiedDate = DateTime.newInstance(unitAsset.Asset_Address__r.LastModifiedDate.dateGmt()
																,unitAsset.Asset_Address__r.LastModifiedDate.timeGmt());*/

			addressMap.put(unitAsset.Asset_Address__r.Id, unitAsset.Asset_Address__r);
		             
		            
			//create the ie unit object and add it to the list
			IE_IntegrationObjects.IE_Unit ieUnit = new IE_IntegrationObjects.IE_Unit();
			ieUnit.UnitAddress      =   ieAddress;
			ieUnit.ConnectivityType =   connectivityType;  // Cellular or WiFi/LAN

			if (doPutOperation == true)
				ieUnit.SerialNumber = gwAsset.Id;  // Here we set the SN to the GW asset Id since it is unique and we are moving it to the Holding Asset in SF
			else
				ieUnit.SerialNumber = unitAsset.SerialNumber;

			ieUnit.UnitTag          =   unitAsset.Tag__c;
			ieUnit.SalesOrderNumber =   unitAsset.SO_Number__c;
			ieUnit.JobName          =   unitAsset.Job_Name__c;
			//ieUnit.MACAddress       =   unitAsset.Device_ID__c;  // MAC Address not applicable for parent asset
			//ieUnit.SIMCardICCID     =   unitAsset.SIM_Card_ICCID__c;  // Sim Card ICCID not applicable for parent asset
			//ieUnit.IsSimCardActive  =   unitAsset.SIM_Card_Active__c;  // SIM Card Active Status not applicable for parent asset
			ieUnit.CodeStringFormat =   unitAsset.Format_Number__c;
		            
			//add the code string values
			string codeStringBreakDown = '';
		            
			if(unitAsset.Current_Code_String_Breakdown__c != null) 
				codeStringBreakDown = unitAsset.Current_Code_String_Breakdown__c;
			else  
				codeStringBreakDown = unitAsset.Code_String_Breakdown__c;
		            
			ieUnit.CodeValues = getCodeStringValues(codeStringBreakDown);
		            
			ieUnit.Commissioned     =   gwAsset.Commissioned__c;
			ieUnit.IEId             =   null;  //unitAsset.IE_ID__c;  Here we set IE Id to null (in case it already had a value) since we are creating a new unit record for this GWotGo asset
			ieUnit.SFDCId           =   gwAsset.Id; // Here we set the SFDCId to the Id of the GWotGo asset

			ieUnit.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
			// ieUnit.LastModifiedDate = DateTime.newInstance(unitAsset.LastModifiedDate.dateGmt(), unitAsset.LastModifiedDate.timeGmt());

			ieUnit.MACAddress       =   gwAsset.Device_ID__c;
		    ieUnit.SIMCardICCID     =   gwAsset.SIM_Card_ICCID__c;
		    ieUnit.IsSimCardActive  =   gwAsset.SIM_Card_Active__c;


			if (doPutOperation == true) {
				// Force a PUT operation since we are moving an existing GWotGo off its current Unit and over to the Holding Unit in SF
				UnitsPut.Units.add(ieUnit);
			}
			else {
				// Force a POST operation since we are moving a new GWotGo asset off the Dummy Unit onto the Unit Asset in SF
				UnitsPost.Units.add(ieUnit);
			}
		            
			// Store the parent asset in the map to retrieve response status
			assetMap.put(unitAsset.Id, unitAsset);
		} // if (unitAsset.Asset_Address__c != null)
		else 
		{
			// Log that this asset is missing its address
			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
									, Error_Description__c = 'Missing address information for asset ' + unitAsset.SerialNumber
									, Integration_Object__c = 'Asset'
									, Integration_Point__c = 'IE'
									, Request_Data__c = 'Cannot by synced with Coherent until address is provided' ));
		}


		//
		// call the service - Determine PUT or POST
		//

		String jsonPostResponse = '';
		String jsonPutResponse = '';

		//Process the POST
       	try{
           if(UnitsPost.Units != null && UnitsPost.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitList  Units = UnitsPost;
               System.debug('syncIeCloudUnitForGWotGo POST Asset: '+JSON.serialize(Units));

               HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitService__c
                                                                         , 'POST'
                                                                         , JSON.serialize(Units));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(Units));
	        			}
	        		}
	        	}

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPostResponse = JSON.serialize(Units);//for testing purposes since we can't make a call-out
                    else
                        jsonPostResponse = response.getBody();
                    
                    System.debug('syncIeCloudUnitForGWotGo POST UNITS RESPONSE: '+jsonPostResponse);
                    UnitsPostResponse = (IE_IntegrationObjects.IE_UnitListResponse )JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_UnitListResponse.class);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPost) ));
                    hasErrors = true;
                    errorMsg = errorMsg + ' | ' + 'Post Transmission Error ['+response.getStatusCode()+']';
                }
           }
       	}
       	catch(Exception e)
       	{
            //log the error
            System.debug('syncIeCloudUnitForGWotGo POST CALLOUT EXCEPTION: '+ e);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;

            errorMsg = errorMsg + ' | ' + 'Post CALLOUT_EXCEPTION ' + e.getMessage();
       	}
       
       	//Process the PUT
       	try{
           if(UnitsPut.Units != null && UnitsPut.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitList  Units = UnitsPut;
               System.debug('syncIeCloudUnitForGWotGo PUT Asset: '+JSON.serialize(Units));

               HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitService__c
                                                                         , 'PUT'
                                                                         , JSON.serialize(Units));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(Units));
	        			}
	        		}
	        	}

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPutResponse = JSON.serialize(Units);//for testing purposes since we can't make a call-out
                    else
                        jsonPutResponse = response.getBody();
                        
                    UnitsPutResponse = (IE_IntegrationObjects.IE_UnitListResponse )JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_UnitListResponse.class);
                    System.debug('syncIeCloudUnitForGWotGo PUT UNITS RESPONSE: '+UnitsPutResponse);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPut) ));
                    hasErrors = true;
                    errorMsg = errorMsg + ' | ' + 'Put Transmission Error ['+response.getStatusCode()+']';
                }
           }
       	}
       	catch(Exception e)
       	{
            //log the error
            System.debug('syncIeCloudUnitForGWotGo PUT CALLOUT EXCEPTION: '+ e);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;

            errorMsg = errorMsg + ' | ' + 'Put CALLOUT_EXCEPTION ' + e.getMessage();
       	}
       
       	if (!hasErrors)
       	{
           if(UnitsPostResponse.Units != null && UnitsPostResponse.Units.size() > 0)
                processIeUnitForGWotGoResponse(UnitsPostResponse, unitAsset, assetMap, addressMap, integrationErrorList);
           if(UnitsPutResponse.Units != null && UnitsPutResponse.Units.size() > 0)
                processIeUnitForGWotGoResponse(UnitsPutResponse, unitAsset, assetMap, addressMap, integrationErrorList);
        }

        if (hasErrors && !hasIETimeout) throw new syncIeCloudUnitsException(errorMsg); // Only Rethrow a new exception if there wasn't an IE Timeout exception thrown

    }


	public static void processIeUnitForGWotGoResponse(IE_IntegrationObjects.IE_UnitListResponse Units, Asset unitAsset, 
                                map<Id, Asset> assetMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList)
    {
    	//Parse the response for errors
        // retrieve the IE IDs and update the base as well as the child objects if they are null
        // update the status to Processed
       
        //log errors
        //update the status to Error
        for(IE_IntegrationObjects.IE_Unit unit : Units.Units)
        {
            if(unit.errors != null && unit.errors.size() > 0)
            {
                //assetMap.get(unit.SFDCId).IE_Sync_Status__c = 'Error';
				assetMap.get(unitAsset.Id).IE_Sync_Status__c = 'Error';

                integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = String.ValueOf(unit.errors)
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Object_Id__c = unitAsset.Id   //unit.SFDCId
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(unit) ));
            }
            else
            {
                //assetMap.get(unit.SFDCId).IE_Sync_Status__c = 'Processed';
                //assetMap.get(unit.SFDCId).IE_Id__c = unit.IEId;
				assetMap.get(unitAsset.Id).IE_Sync_Status__c = 'Processed';
				if (String.isNotEmpty(unit.IEId))
					assetMap.get(unitAsset.Id).IE_Id__c = unit.IEId;
            }
            
            if(unit.UnitAddress != null && addressMap.containsKey(unit.UnitAddress.SFDCId))
            {
                if(unit.UnitAddress.errors != null && unit.UnitAddress.errors.size() > 0)
                {
                    if(addressMap.containsKey(unit.UnitAddress.SFDCId))
                      addressMap.get(unit.UnitAddress.SFDCId).IE_Sync_Status__c = 'Error';
                        
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                    , Error_Description__c = String.ValueOf(unit.UnitAddress.errors)
                                                                    , Integration_Object__c = 'Address'
                                                                    , Integration_Object_Id__c = unit.UnitAddress.SFDCId
                                                                    , Integration_Point__c = 'IE'
                                                                    , Request_Data__c = JSON.serialize(unit) ));
                }
                else
                {
                    if(addressMap.containsKey(unit.UnitAddress.SFDCId))
                    {
                        addressMap.get(unit.UnitAddress.SFDCId).IE_Sync_Status__c = 'Processed';

						if (String.isNotEmpty(unit.UnitAddress.IEId))
							addressMap.get(unit.UnitAddress.SFDCId).IE_Id__c = unit.UnitAddress.IEId;

						addressMap.get(unit.UnitAddress.SFDCId).IE_Address__c = true;  // set this to true in case it wasn't set earlier
                    }
                }
            }
        }
    }


	public static void syncIeCloudUnitReset(Asset unitAsset, Asset gwAsset, map<Id, Asset> assetMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList)
	{
    	// Call the IE API/Service Portal Web Service to reset/sync up the given IE Unit asset and GWotGo asset in the MS Azure Cloud IE database.

    	TriggerUtility.limitIntegrationBatch = true; // set this to true since assets may be updated which will invoke the AssetTriggerHandler

    	// Error message string that is used to collect any errors/exceptions information
    	String errorMsg = 'syncIeCloudUnitReset errors: ';

    	//populate the objects for integration
    	boolean hasErrors = false;
		boolean hasIETimeout = false;
		IE_IntegrationObjects.IE_UnitResetList UnitsPost = new IE_IntegrationObjects.IE_UnitResetList ();
		UnitsPost.Units = new list<IE_IntegrationObjects.IE_UnitReset>();
		IE_IntegrationObjects.IE_UnitResetList  UnitsPut = new IE_IntegrationObjects.IE_UnitResetList ();
		UnitsPut.Units = new list<IE_IntegrationObjects.IE_UnitReset>();

		IE_IntegrationObjects.IE_UnitResetListResponse UnitsPostResponse = new IE_IntegrationObjects.IE_UnitResetListResponse();
		IE_IntegrationObjects.IE_UnitResetListResponse UnitsPutResponse = new IE_IntegrationObjects.IE_UnitResetListResponse();

		if (unitAsset.Asset_Address__c != null)
		{
			// Asset needs an address otherwise coherent sync will fail

			//get the address data
			IE_IntegrationObjects.IE_Address ieAddress = new IE_IntegrationObjects.IE_Address();
		            
			ieAddress.AddressLine1 = unitAsset.Asset_Address__r.Address_Line_1__c;
			ieAddress.AddressLine2 = unitAsset.Asset_Address__r.Address_Line_2__c;
			ieAddress.AddressLine3 = unitAsset.Asset_Address__r.Address_Line_3__c;
			ieAddress.AddressLine4 = unitAsset.Asset_Address__r.Address_Line_4__c;
			ieAddress.City         = unitAsset.Asset_Address__r.City__c;
			ieAddress.Country      = unitAsset.Asset_Address__r.Country_ISO_Code__c;  
			ieAddress.StateCode    = unitAsset.Asset_Address__r.State_Province_ISO_Code__c;
			ieAddress.ZipCode      = unitAsset.Asset_Address__r.Postal_Code__c;
			ieAddress.SFDCId       = unitAsset.Asset_Address__r.Id;
			ieAddress.IEId         = unitAsset.Asset_Address__r.IE_ID__c;

			ieAddress.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
			/*ieAddress.LastModifiedDate = DateTime.newInstance(unitAsset.Asset_Address__r.LastModifiedDate.dateGmt()
																,unitAsset.Asset_Address__r.LastModifiedDate.timeGmt());*/

			addressMap.put(unitAsset.Asset_Address__r.Id, unitAsset.Asset_Address__r);
		             
		            
			//create the ie unit object and add it to the list
			IE_IntegrationObjects.IE_UnitReset ieUnit = new IE_IntegrationObjects.IE_UnitReset();
			ieUnit.UnitAddress      =   ieAddress;
			ieUnit.SerialNumber = unitAsset.SerialNumber;
			ieUnit.UnitTag          =   unitAsset.Tag__c;
			ieUnit.SalesOrderNumber =   unitAsset.SO_Number__c;
			ieUnit.JobName          =   unitAsset.Job_Name__c;
			//ieUnit.MACAddress       =   unitAsset.Device_ID__c;  // MAC Address not applicable for parent asset
			//ieUnit.SIMCardICCID     =   unitAsset.SIM_Card_ICCID__c;  // Sim Card ICCID not applicable for parent asset
			ieUnit.CodeStringFormat =   unitAsset.Format_Number__c;
		            
			//add the code string values
			string codeStringBreakDown = '';
		            
			if(unitAsset.Current_Code_String_Breakdown__c != null) 
				codeStringBreakDown = unitAsset.Current_Code_String_Breakdown__c;
			else  
				codeStringBreakDown = unitAsset.Code_String_Breakdown__c;
		            
			ieUnit.CodeValues = getCodeStringValues(codeStringBreakDown);
		            
			ieUnit.Commissioned     =   gwAsset.Commissioned__c;
			ieUnit.IEId             =   null;  //unitAsset.IE_ID__c;  Here we set IE Id to null (in case it already had a value) since we are resetting this GWotGo asset with a new unit
			ieUnit.SFDCId           =   gwAsset.Id;  // Here we set the SFDCId to the Id of the GWotGo asset

			ieUnit.LastModifiedDate = Datetime.now(); // current date and time in the GMT time zone
			// DateTime.newInstance(unitAsset.LastModifiedDate.dateGmt(), unitAsset.LastModifiedDate.timeGmt());

			ieUnit.MACAddress = gwAsset.Device_ID__c;
			ieUnit.SIMCardICCID = gwAsset.SIM_Card_ICCID__c;

			//if(unitAsset.IE_ID__c == null)
				UnitsPost.Units.add(ieUnit);  // IE Unit Reset Operation only allows for a POST
			//else
				//UnitsPut.Units.add(ieUnit);
		            
			// Store the parent asset in the map to retrieve response status
			assetMap.put(unitAsset.Id, unitAsset);
			System.debug('syncIeCloudUnitReset: assetMap 1' + assetMap);
		}
		else 
		{
			// Log that this asset is missing its address
			integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
									, Error_Description__c = 'Missing address information for asset ' + unitAsset.SerialNumber
									, Integration_Object__c = 'Asset'
									, Integration_Point__c = 'IE'
									, Request_Data__c = 'Cannot by synced with Coherent until address is provided' ));
		}


		//
		// call the service - Determine PUT or POST
		//

		String jsonPostResponse = '';
		String jsonPutResponse = '';

		//Process the POST
       	try{
           if(UnitsPost.Units != null && UnitsPost.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitResetList  Units = UnitsPost;
               System.debug('syncIeCloudUnitReset POST Asset: '+JSON.serialize(Units));

               HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitResetService__c
                                                                         , 'POST'
                                                                         , JSON.serialize(Units));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(Units));
	        			}
	        		}
	        	}

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPostResponse = JSON.serialize(Units);//for testing purposes since we can't make a call-out
                    else
                        jsonPostResponse = response.getBody();
                    
                    System.debug('syncIeCloudUnitReset POST UNITS RESPONSE: '+jsonPostResponse);
                    UnitsPostResponse = (IE_IntegrationObjects.IE_UnitResetListResponse )JSON.deserialize(jsonPostResponse, IE_IntegrationObjects.IE_UnitResetListResponse.class);
					System.debug('syncIeCloudUnitReset UnitsPostResponse: '+UnitsPostResponse);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPost) ));
                    hasErrors = true;
                    errorMsg = errorMsg + ' | ' + 'Post Transmission Error ['+response.getStatusCode()+']';
                }
           }
       	}
       	catch(Exception e)
       	{
            //log the error
            System.debug('syncIeCloudUnitReset POST CALLOUT EXCEPTION: '+ e);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;

            errorMsg = errorMsg + ' | ' + 'Post CALLOUT_EXCEPTION ' + e.getMessage();
       	}
       
       	//Process the PUT
       	/*try{
           if(UnitsPut.Units != null && UnitsPut.Units.size() > 0)
           {
               IE_IntegrationObjects.IE_UnitResetList  Units = UnitsPut;
               System.debug('syncIeCloudUnitReset PUT Asset: '+JSON.serialize(Units));

               HTTPResponse response = null;

		       if (!Test.isRunningTest()) {
        			// Test isn't running so call the service
        			response = IE_IntegrationObjects.sendIeRequest(IE_Service_Configuration__c.getInstance().UnitResetService__c
                                                                         , 'PUT'
                                                                         , JSON.serialize(Units));
        		}
        		else {
	        		// Test is running so mock a response
	        		if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByException) {
	        			response.setStatusCode(200); //exception will be thrown since response object is null
	        		}
	        		else {
	        			response = new HTTPResponse();
	        			if (Batch_IE_CallExtWebServices.crash_syncIeCloudUnits_TestByResponseStatusCode) {
	        				response.setStatusCode(0); //set the response status code to something other than 200
	        			}
	        			else {
	        				response.setStatusCode(200);
	        				response.setBody(JSON.serialize(Units));
	        			}
	        		}
	        	}

               if(response.getStatusCode() == 200)
                { 
                    //iterate over the response checking for errors maybe we just return the body
                    if(Test.isRunningTest())
                        jsonPutResponse = JSON.serialize(Units);//for testing purposes since we can't make a call-out
                    else
                        jsonPutResponse = response.getBody();
                        
                    UnitsPutResponse = (IE_IntegrationObjects.IE_UnitResetListResponse )JSON.deserialize(jsonPutResponse, IE_IntegrationObjects.IE_UnitResetListResponse.class);
                    System.debug('syncIeCloudUnitReset PUT UNITS RESPONSE: '+UnitsPutResponse);
                }
                else{ 
                    //log the error
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'Transmission Error ['+response.getStatusCode()+']'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(UnitsPut) ));
                    hasErrors = true;
                    errorMsg = errorMsg + ' | ' + 'Put Transmission Error ['+response.getStatusCode()+']';
                }
           }
       	}
       	catch(Exception e)
       	{
            //log the error
            System.debug('syncIeCloudUnitReset PUT CALLOUT EXCEPTION: '+ e);
            integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = 'CALLOUT_EXCEPTION'
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = e.getMessage() ));
            hasErrors = true;
			if ((e.getMessage() == 'Read timed out') || (e.getMessage() == 'Exceeded maximum time allotted for callout (120000 ms)')) hasIETimeout = true;

            errorMsg = errorMsg + ' | ' + 'Put CALLOUT_EXCEPTION ' + e.getMessage();
       	}*/
       
       	if (!hasErrors)
       	{
           if(UnitsPostResponse.Units != null && UnitsPostResponse.Units.size() > 0)
                processIeUnitResetResponse(UnitsPostResponse, unitAsset, assetMap, addressMap, integrationErrorList);
           /*if(UnitsPutResponse.Units != null && UnitsPutResponse.Units.size() > 0)
                processIeUnitResetResponse(UnitsPutResponse, unitAsset, assetMap, addressMap, integrationErrorList);*/
			
			System.debug('syncIeCloudUnitReset: assetMap 2' + assetMap);
        }

        if (hasErrors && !hasIETimeout) throw new syncIeCloudUnitResetException(errorMsg); // Only Rethrow a new exception if there wasn't an IE Timeout exception thrown

	}


	public static void processIeUnitResetResponse(IE_IntegrationObjects.IE_UnitResetListResponse Units, Asset unitAsset, 
                                map<Id, Asset> assetMap, map<Id, Address__c> addressMap, list<Integration_Error__c> integrationErrorList)
    {
    	//Parse the response for errors
        // retrieve the IE IDs and update the base as well as the child objects if they are null
        // update the status to Processed
       
        //log errors
        //update the status to Error
        for(IE_IntegrationObjects.IE_UnitReset unit : Units.Units)
        {
            if(unit.errors != null && unit.errors.size() > 0)
            {
                //assetMap.get(unit.SFDCId).IE_Sync_Status__c = 'Error';
				assetMap.get(unitAsset.Id).IE_Sync_Status__c = 'Error';

                integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                , Error_Description__c = String.ValueOf(unit.errors)
                                                                , Integration_Object__c = 'Asset'
                                                                , Integration_Object_Id__c = unitAsset.Id   //unit.SFDCId
                                                                , Integration_Point__c = 'IE'
                                                                , Request_Data__c = JSON.serialize(unit) ));
            }
            else
            {
                //assetMap.get(unit.SFDCId).IE_Sync_Status__c = 'Processed';
                //assetMap.get(unit.SFDCId).IE_Id__c = unit.IEId;
				System.debug('processIeUnitResetResponse: unitAsset.Id' + unitAsset.Id);
				System.debug('processIeUnitResetResponse: unit.IEId' + unit.IEId);
				assetMap.get(unitAsset.Id).IE_Sync_Status__c = 'Processed';
				if (String.isNotEmpty(unit.IEId))
					assetMap.get(unitAsset.Id).IE_Id__c = unit.IEId;
            }
            
            if(unit.UnitAddress != null && addressMap.containsKey(unit.UnitAddress.SFDCId))
            {
                if(unit.UnitAddress.errors != null && unit.UnitAddress.errors.size() > 0)
                {
                    if(addressMap.containsKey(unit.UnitAddress.SFDCId))
                      addressMap.get(unit.UnitAddress.SFDCId).IE_Sync_Status__c = 'Error';
                        
                    integrationErrorList.add(new Integration_Error__c(Direction__c = 'Outbound'
                                                                    , Error_Description__c = String.ValueOf(unit.UnitAddress.errors)
                                                                    , Integration_Object__c = 'Address'
                                                                    , Integration_Object_Id__c = unit.UnitAddress.SFDCId
                                                                    , Integration_Point__c = 'IE'
                                                                    , Request_Data__c = JSON.serialize(unit) ));
                }
                else
                {
                    if(addressMap.containsKey(unit.UnitAddress.SFDCId))
                    {
                        addressMap.get(unit.UnitAddress.SFDCId).IE_Sync_Status__c = 'Processed';

						if (String.isNotEmpty(unit.UnitAddress.IEId))
							addressMap.get(unit.UnitAddress.SFDCId).IE_Id__c = unit.UnitAddress.IEId;

						addressMap.get(unit.UnitAddress.SFDCId).IE_Address__c = true;  // set this to true in case it wasn't set earlier
                    }
                }
            }
        }
    }




    public static list<String> getCodeStringValues(string codeString)
    {
        list<String> codeStringValues = new list<String>();
        try{
        	if (String.isNotEmpty(codeString))
        	{
	            JSONParser parser = JSON.createParser(codeString);
	            string label = '';
	            string value = '';
	            while (parser.nextToken() != null) {
	            // Start at the array of invoices.
	                if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
	                    while (parser.nextToken() != null) {
	                        // Advance to the start object marker to
	                        //  find next invoice statement object.
	                        if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
	                            // Read entire invoice object, including its array of line items.
	                             CodeStringViewerController.CodeStringRec codeRec 
	                                = (CodeStringViewerController.CodeStringRec)parser.readValueAs(CodeStringViewerController.CodeStringRec.class);
	                             System.Debug(':::>'+codeRec);
	                             codeStringValues.add(codeRec.code_value);
	                        }
	                    }
	                }
	            }
        	}
        }
        catch(Exception e)
        {
            System.Debug('ERROR: '+e);
        }
        
        return codeStringValues;
    }


	/*public static String GetIntlPlan(String domesticPlan) {
		String intlPlan = null;

		//intlPlan = 'DataXoom – 0kB Plan';
		
		if (domesticPlan == 'Daikin Applied - 50MB Plan')
			intlPlan = 'Daikin Applied - 50MB US_CAN_MEX Plan';
		else if (domesticPlan == 'Daikin Applied - 100MB Plan')
			intlPlan = 'Daikin Applied - 100MB US_CAN_MEX Plan';
		else if (domesticPlan == 'Daikin Applied - 10MB Plan')
			intlPlan = 'Daikin Applied - 10MB US_CAN_MEX Plan';
		else if (domesticPlan == 'Daikin Applied - 150MB Plan')
			intlPlan = 'Daikin Applied - 150MB Intl Plan';
		else if (domesticPlan == 'Daikin Applied - 1GB Plan')
			intlPlan = 'Daikin Applied - 1GB US_CAN_MEX Plan';
		else if (domesticPlan == 'Daikin Applied - 20MB Plan')
			intlPlan = 'Daikin Applied - 20MB US_CAN_MEX Plan';
		else if (domesticPlan == 'Daikin Applied - 500MB Plan')
			intlPlan = 'Daikin Applied - 500MB US_CAN_MEX Plan';

		return intlPlan;
	}*/


	/*public static String GetDomesticPlan(String intlPlan) {
		String domesticPlan = null;

		//domesticPlan = 'DataXoom – 0kB Plan';
		
		if (intlPlan == 'Daikin Applied - 50MB US_CAN_MEX Plan')
			domesticPlan = 'Daikin Applied - 50MB Plan';
		else if (intlPlan == 'Daikin Applied - 100MB US_CAN_MEX Plan')
			domesticPlan = 'Daikin Applied - 100MB Plan';
		else if (intlPlan == 'Daikin Applied - 10MB US_CAN_MEX Plan')
			domesticPlan = 'Daikin Applied - 10MB Plan';
		else if (intlPlan == 'Daikin Applied - 150MB Intl Plan')
			domesticPlan = 'Daikin Applied - 150MB Plan';
		else if (intlPlan == 'Daikin Applied - 1GB US_CAN_MEX Plan')
			domesticPlan = 'Daikin Applied - 1GB Plan';
		else if (intlPlan == 'Daikin Applied - 20MB US_CAN_MEX Plan')
			domesticPlan = 'Daikin Applied - 20MB Plan';
		else if (intlPlan == 'Daikin Applied - 500MB US_CAN_MEX Plan')
			domesticPlan = 'Daikin Applied - 500MB Plan';

		return domesticPlan;
	}*/



	public static void resetAPIFlags(list<Subscription__c> subscriptions)
	{
		TriggerUtility.limitIntegrationBatch = true; // set this to true since subscriptions may be updated which will invoke the SubscriptionTriggerHandler

		// Reset the API flag to false for each subscription record only after successful processing

		for (Subscription__c s : subscriptions)
		{
			if (s.TriggerInvokedByAPI__c == true)
			{
				s.TriggerInvokedByAPI__c = false;
			}
		}
	}



	/* AT&T CC Web REST API Response schemas */
    public class DeviceDetailsResponse
    {
		public String iccid;
		public String imsi;
		public String msisdn;
		public String imei;
		public String status;
		public String ratePlan;
		public String communicationPlan;
		public String customer;
		public String endConsumerId;
		public String dateActivated;
		public String dateAdded;
		public String dateUpdated;
		public String dateShipped;
		public String accountId;
		public String fixedIPAddress;
		public String operatorCustom1;
		public String operatorCustom2;
		public String operatorCustom3;
		public String operatorCustom4;
		public String operatorCustom5;
		public String accountCustom1;
		public String accountCustom2;
		public String accountCustom3;
		public String accountCustom4;
		public String accountCustom5;
		public String accountCustom6;
		public String accountCustom7;
		public String accountCustom8;
		public String accountCustom9;
		public String accountCustom10;
		public String customerCustom1;
		public String customerCustom2;
		public String customerCustom3;
		public String customerCustom4;
		public String customerCustom5;
		public String simNotes;
		public String deviceID;
		public String modemID;
		public String globalSimType;
    }


    // Create custom exceptions to throw back to caller if there are any errors
    public class processIESubscriptionOrderException extends Exception {}
	public class updateSimCardObjectCellularInfoException extends Exception {}
    public class syncIeCloudIndividualsException extends Exception {}
    public class syncIeCloudOrganizationsException extends Exception {}
    public class syncIeCloudSubscriptionsException extends Exception {}
    public class syncIeCloudSIMCardActiveStatusException extends Exception {}
    public class syncIeCloudUnitsException extends Exception {}
	public class syncIeCloudUnitResetException extends Exception {}
	public class generalException extends Exception {}
}
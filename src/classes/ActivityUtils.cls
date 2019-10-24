/**************************************************************************************
 Author       :   Amarendar Junuthula
 Created Date :   December 08, 2015
 Description  :   This Utility class will be called by Task Trigger and Event Trigger.

This utility class calculates number of Open Activities and Clsoed Activities on the following objects
Account
Contact
Opportunity
Lead
Case

To meet the requirement, I have created the following fields on each of the above mentioned object.
Field Label						API Name							Data Type
Number of Open Activities		Number_of_Open_Activities__c		Number(5, 0)
Number of Closed Activities		Number_of_Closed_Activities__c		Number(5, 0)
Number of Activities			Number_of_Activities__c				Formula (Number(5, 0))

These Fields should be read only on page layouts as these will get updated by the Apex logic.
***************************************************************************************/

public class ActivityUtils {
	 //config
    String NumberofOpenActivities = 'Number_of_Open_Activities__c'; //this field must be added to each object we're updating
    String NumberofClosedActivities = 'Number_of_Closed_Activities__c'; //this field must be added to each object we're updating
 
    //set to capture the unique Ids
    set<id> accountIds;
    set<id> contactIds;
    set<id> opportunityIds;
    set<id> leadIds;
    set<id> caseIds;
    set<id> ChangeRequestIds;
   
    public ActivityUtils(sObject[] records) {
        accountIds = new set<id>();
        contactIds = new set<id>();
        opportunityIds = new set<id>();
        leadIds = new set<id>();
        caseIds = new set<id>();
        ChangeRequestIds = new set<id>();
        captureWhatAndWhoIds(records);		//WhatId for Account, Opportunity and Case. WhoId for Lead and Contact.
        addAccountIdsFromRlatedObjects();	//Contacts, Opportunities and Cases are related to an Account.
    }
 	
    //Method to find Open and Closed activities on Account(This includes activities from child objects like Contacts, Opportunities and Cases)
    public void updateAccountActivityCount() {
        if(accountIds.size() == 0 || accountIds == NULL) return;
        updateNumberofOpenActivities('Account','WhatId', getStringFromIdSet(accountIds));
        updateNumberofClosedActivities('Account','WhatId', getStringFromIdSet(accountIds));
    }
    
    //Method to find Open and Closed activities on Contact
    public void updateContactActivityCount() {
        if(contactIds.size() == 0) return;
        updateNumberofOpenActivities('Contact','WhoId', getStringFromIdSet(contactIds));
        updateNumberofClosedActivities('Contact','WhoId', getStringFromIdSet(contactIds));
    }
    
    //Method to find Open and Closed activities on Opportunity
    public void updateOpportunityActivityCount() {
        if(opportunityIds.size() == 0) return;
        updateNumberofOpenActivities('Opportunity','WhatId', getStringFromIdSet(opportunityIds));
        updateNumberofClosedActivities('Opportunity','WhatId', getStringFromIdSet(opportunityIds));
    }
    
    //Method to find Open and Closed activities on Lead
    public void updateLeadActivityCount() {
        if(leadIds.size() == 0) return;
        updateNumberofOpenActivities('Lead','WhoId', getStringFromIdSet(leadIds));
        updateNumberofClosedActivities('Lead','WhoId', getStringFromIdSet(leadIds));
    }
    
    //Method to find Open and Closed activities on Case
    public void updateCaseActivityCount() {
        if(caseIds.size() == 0) return;
        updateNumberofOpenActivities('Case','WhatId', getStringFromIdSet(caseIds));
        updateNumberofClosedActivities('Case','WhatId', getStringFromIdSet(caseIds));
    }
    
    //Method to find Open and Closed activities on Case
    public void updateChangeRequestActivityCount() {
        if(ChangeRequestIds.size() == 0) return;
        updateNumberofOpenActivities('Change_Request__c','WhatId', getStringFromIdSet(ChangeRequestIds));
        updateNumberofClosedActivities('Change_Request__c','WhatId', getStringFromIdSet(ChangeRequestIds));
    }
    
    //Method to update Number of Open Activities on passed object
    private void updateNumberofOpenActivities(String objToUpdate, String queryFld, String updateIds) {
        
        string strQuery = 'SELECT Id, (SELECT Id FROM OpenActivities) FROM ' + objToUpdate + ' WHERE Id IN (' + updateIds + ')';
        sObject[] sobjects = new list<sobject>();
        for(sObject so : database.query(strQuery)) {
            //OpenActivity[] oActivities = so.getSObjects('OpenActivities');
            //Integer openActivityCount = oActivities == null ? 0 : oActivities.size();
            Integer openActivityCount =0;
            for(sObject oA: so.getSObjects('OpenActivities')){
                if(oA == null){
                	openActivityCount = 0;
            	} else {
                
                	openActivityCount++;
                
            	}
            }
            sObject obj = createObject(objToUpdate, so.Id);
            obj.put(NumberofOpenActivities, openActivityCount);
            sobjects.add(obj);
            system.debug('openActivityCount: ' + openActivityCount);
        }
        if(sobjects != NULL )
            update sobjects;
    }
    
    //Method to update Number of Closed Activities on passed object
    private void updateNumberofClosedActivities(String objToUpdate, String queryFld, String updateIds) {
        string strQuery = 'SELECT Id, (SELECT Id FROM ActivityHistories) FROM ' + objToUpdate + ' WHERE Id IN (' + updateIds + ')';
        sObject[] sobjects = new list<sobject>();
        for(sObject so : database.query(strQuery)) {
            //ActivityHistory[] cActivities = so.getSObjects('ActivityHistories');
            //Integer closedActivityCount = cActivities == null ? 0 : cActivities.size();
            Integer closedActivityCount =0;
            for(sObject ah: so.getSObjects('ActivityHistories')){
                if(ah == null){
                closedActivityCount = 0;
            } else {
                
                closedActivityCount++;
                
            }
        }
            
            
            
            sObject obj = createObject(objToUpdate, so.Id);
            obj.put(NumberofClosedActivities, closedActivityCount);
            sobjects.add(obj);
            system.debug('closedActivityCount: ' + closedActivityCount);
        }
        if(sobjects != NULL )
        update sobjects;
        
    }
	
    //Method to capture WhatId for Accounts, Opportunities & Cases and WhoId for Contacts and Leads. 
    private void captureWhatAndWhoIds(sObject[] objects) {
        for(sObject o : objects) {
            Id whatId = (Id)o.get('WhatId');
            Id whoId = (Id)o.get('WhoId');
            if(whatId != null) {
                String objectName = getObjectNameFromId(whatId);
                if(objectName == 'account') accountIds.add(whatId);
                if(objectName == 'opportunity') opportunityIds.add(whatId);
                if(objectName == 'case') caseIds.add(whatId);
                if(objectName == 'Change_Request__c') ChangeRequestIds.add(whatId);
            }
            if(whoId != null) {
                String objectName = getObjectNameFromId(whoId);
                if(objectName == 'contact') contactIds.add(whoId);
                if(objectName == 'lead') leadIds.add(whoId);
            }
        }
    }
    
    //This method adds the related  Account Ids to the set: AccountIds. (This is required because everytime a task is created on Contact or Opportunty or Case then the task will also be shown under the Account)
    private void addAccountIdsFromRlatedObjects() {
        for(Opportunity o : [SELECT AccountId FROM Opportunity WHERE Id IN :opportunityIds])
            if(o.Accountid != Null)
            	accountIds.add(o.AccountId);
        for(Contact c : [SELECT AccountId FROM Contact WHERE Id IN :contactIds])
            if(c.Accountid != Null)
            	accountIds.add(c.AccountId);
        for(case cs : [SELECT AccountId FROM Case WHERE Id IN :caseIds])
            if(cs.Accountid != Null)
            	accountIds.add(cs.AccountId);
    }
    
	//This method is used to figure out Object name based on the first three characters of the Id.
    private String getObjectNameFromId(Id objId) {
        String preFix = String.valueOf(objId).left(3).toLowercase();
        if(prefix == '001') return 'account';
        if(prefix == '003') return 'contact';
        if(prefix == '500') return 'case';
        if(prefix == '006') return 'opportunity';
        if(prefix == '00q') return 'lead';
        if(prefix == 'a17') return 'Change_Request__c';         return '';
    }
	
    //This method will convert the Id to a string(This is required to look at the prefix of the Id)
    private String getStringFromIdSet(set<id> idSet) {
        string idString = '';
        for(Id i : idSet) idString+= '\'' + i + '\',';
        return idString == '' ? idString : idString.left(idString.length()-1); //If idString contains some ids we want to ensure we strip out the last comma
    }
 
    //The main part of the method below was taken from //Taken from http://www.salesforce.com/us/developer/docs/apexcode/Content/apex_dynamic_dml.htm
    //However we've modified this to accept an object id
    private sObject createObject(String typeName, Id objId) {
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);
        if (targetType == null) {
            // throw an exception
        }
 
        // Instantiate an sObject with the type passed in as an argument
        //  at run time.
        return targetType.newSObject(objId);
    }
    
}
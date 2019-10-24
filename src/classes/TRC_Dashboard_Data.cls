public class TRC_Dashboard_Data {
        
    //Data holding class
    class TRCDashboardData {
        public Integer openCaseCount = 0;
        public Integer createdCaseCount = 0;
        public Integer closedCaseCount = 0;
        public Integer reopenedCaseCount = 0;
    }
    
    public void getTRCResults() {
        map<string,TRCDashboardData> resultsMap = new map<string,TRCDashboardData>();
        List<Case_Snapshot__c> cs = new List<Case_Snapshot__c>();        
       
        for(AggregateResult openCases : [SELECT RecordType.Name Name,OwnerId Id, count(Id) Result, Status FROM Case WHERE Status != 'Closed' AND RecordType.Name IN('TRC', 'TRC - AAH', 'TRC - Chillers','TRC - ATS','TRC - Controls',  'Rep Help Desk', 'Salesforce Help', 'TRC - PQR') AND OwnerID NOT IN('00GC0000002VcJx', '00GC0000002VcK2', '00GC0000002VcK7', '00GC0000002VcKC', '00G1A000002bqRe', '00GC0000002YF2m')  group by RecordType.Name, OwnerId, Status]) {
            resultsMap.put(openCases.get('Name') + ',' + openCases.get('Id') , new TRCDashboardData());
            resultsMap.get(openCases.get('Name') + ',' + openCases.get('Id')).openCaseCount = (Integer)openCases.get('Result');
			System.debug(openCases);
        }        
		System.debug(resultsMap);

        //need to update query criteria
        for(AggregateResult createdCases : [SELECT RecordType.Name Name, OwnerId Id, count(Id) Result FROM Case WHERE RecordType.Name IN('TRC', 'TRC - AAH', 'TRC - Chillers','TRC - ATS','TRC - Controls', 'Rep Help Desk', 'Salesforce Help', 'TRC - PQR') AND OwnerID NOT IN('00GC0000002VcJx', '00GC0000002VcK2', '00GC0000002VcK7', '00GC0000002VcKC', '00G1A000002bqRe', '00GC0000002YF2m') AND CreatedDate = YESTERDAY group by RecordType.Name, OwnerId]) {
            if(resultsMap.get(createdCases.get('Name') + ',' + createdCases.get('Id')) == NULL) {
                resultsMap.put(createdCases.get('Name') + ',' + createdCases.get('Id'), new TRCDashboardData());
                resultsMap.get(createdCases.get('Name') + ',' + createdCases.get('Id')).createdCaseCount = (Integer)createdCases.get('Result');
                
            } 
			else resultsMap.get(createdCases.get('Name') + ',' + createdCases.get('Id')).createdCaseCount = (Integer)createdCases.get('Result');     

        }
        
        //need to update query criteria
        for(AggregateResult closedCases : [SELECT RecordType.Name Name,OwnerId Id, count(Id) Result FROM Case WHERE RecordType.Name IN('TRC', 'TRC - AAH', 'TRC - Chillers','TRC - ATS','TRC - Controls', 'Rep Help Desk', 'Salesforce Help', 'TRC - PQR') AND OwnerID NOT IN('00GC0000002VcJx', '00GC0000002VcK2', '00GC0000002VcK7', '00GC0000002VcKC', '00G1A000002bqRe', '00GC0000002YF2m') AND ClosedDate = YESTERDAY group by RecordType.Name, OwnerId]) {
            if(resultsMap.get(closedCases.get('Name') + ',' + closedCases.get('Id')) == NULL) {
                resultsMap.put(closedCases.get('Name') + ',' + closedCases.get('Id'), new TRCDashboardData());
                resultsMap.get(closedCases.get('Name') + ',' + closedCases.get('Id')).closedCaseCount = (Integer)closedCases.get('Result');
                
            }
			else resultsMap.get(closedCases.get('Name') + ',' + closedCases.get('Id')).closedCaseCount = (Integer)closedCases.get('Result');     

        }
                
        //need to update query criteria
        for(AggregateResult reopenedCases : [SELECT RecordType.Name Name, OwnerId Id, count(Id) Result FROM Case WHERE RecordType.Name IN('TRC', 'TRC - AAH', 'TRC - Chillers','TRC - ATS','TRC - Controls', 'Rep Help Desk', 'Salesforce Help', 'TRC - PQR') AND OwnerID NOT IN('00GC0000002VcJx', '00GC0000002VcK2', '00GC0000002VcK7', '00GC0000002VcKC', '00G1A000002bqRe', '00GC0000002YF2m') AND Date_Time_Re_Opened__c = YESTERDAY group by RecordType.Name, OwnerId]) {
			System.debug(reopenedCases);
            if(resultsMap.get(reopenedCases.get('Name') + ',' + reopenedCases.get('Id')) == NULL) 
			{
                resultsMap.put(reopenedCases.get('Name') + ',' + reopenedCases.get('Id'), new TRCDashboardData());
                resultsMap.get(reopenedCases.get('Name') + ',' + reopenedCases.get('Id')).reopenedCaseCount = (Integer)reopenedCases.get('Result');
                
            }
			else resultsMap.get(reopenedCases.get('Name') + ',' + reopenedCases.get('Id')).reopenedCaseCount = (Integer)reopenedCases.get('Result');
        }
		System.debug(resultsMap);
        
  
        for(String keys : resultsMap.keySet()) {
            String [] arry;
            Case_Snapshot__c c = new Case_Snapshot__c();
            c.SnapShot_Date__c = Date.Today() - 1;
            c.Open_Cases__c = resultsMap.get(keys).openCaseCount;
            c.Created_Cases__c = resultsMap.get(keys).createdCaseCount;
            c.Closed_Cases__c = resultsMap.get(keys).closedCaseCount;
            c.Reopened_Cases__c = resultsMap.get(keys).reopenedCaseCount;
            
            arry = keys.split(',');
            system.debug('Group key is:' + arry[0]);
            c.TRC_Group__c = arry[0];
            //c.TRC_Group__c = getTRCGroupNameFromRecordTypeId(arry[0]);
            
            system.debug('Userkey is:' + arry[1]);
            c.User__c = (Id)arry[1];
            
            cs.add(c);
            system.debug('create case snapshot');
        }
        
        
        if(cs.size()>0) {
            system.debug('insert case records:' +cs);
            insert cs;
		}
    }
    
    
    
    /*string getTRCGroupNameFromRecordTypeId(String recordTypeId){
        string result = '';
            
        if (recordTypeId == '012C0000000Hqlk'){
            result = 'TRC';
        } else if (recordTypeId == '012C0000000HoMR'){
            result = 'TRC - AAH';
        } else if (recordTypeId == '012C0000000HoMS'){
            result = 'TRC - ATS';
        } else if (recordTypeId == '012C0000000HoMT'){
            result = 'TRC - Chillers';
        } else {
            result = 'TRC - Controls';
        }
        
        return result;
    }*/
}
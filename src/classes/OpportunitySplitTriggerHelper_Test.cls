@isTest
private class OpportunitySplitTriggerHelper_Test
{
	//Initial Test Data
	static void SetUp(){
		test.StartTest();
	}
	//Tear Down 
	//Add Logic to delete data that has been created
	static void TearDown(){
		test.StopTest();
	}
	
	// Test Method: handleAfterInsert
	public static testmethod void Test_handleAfterInsert(){
		SetUp();
		list<OpportunitySplit> newopportunitysplitlist = new list<OpportunitySplit>();
		// TODO : Add extra code to validate the method call
		OpportunitySplitTriggerHelper.handleAfterInsert(newopportunitysplitlist);
		TearDown();
	}
	// Test Method: handleAfterUpdate
	public static testmethod void Test_handleAfterUpdate(){
		SetUp();
		list<OpportunitySplit> newopportunitysplitlist = new list<OpportunitySplit>();
		Map<Id, OpportunitySplit> oldopportunitysplitmap = new Map<Id,OpportunitySplit>();
		// TODO : Add extra code to validate the method call
		OpportunitySplitTriggerHelper.handleAfterUpdate(newopportunitysplitlist, oldopportunitysplitmap);
		TearDown();
	}
	// Test Method: handleAfterDelete
	public static testmethod void Test_handleAfterDelete(){
		SetUp();
		Map<Id, OpportunitySplit> oldopportunitysplitmap = new Map<Id,OpportunitySplit>();
		// TODO : Add extra code to validate the method call
		OpportunitySplitTriggerHelper.handleAfterDelete(oldopportunitysplitmap);
        /* List<OpportunitySplit> oppSplits = new List<OpportunitySplit>();
        for(OpportunitySplit s :oldOpportunitySplitMap.values()){
        	oppSplits.add(s);    
        }
       // OpportunitySplitServices.updateOpportunities(oppSplits);*/
        TearDown();
    }
		
	
	// Test Method: handleBeforeUpdate
	public static testmethod void Test_handleBeforeUpdate(){
		SetUp();
		list<OpportunitySplit> opportunitysplitlist = new list<OpportunitySplit>();
		// TODO : Add extra code to validate the method call
		OpportunitySplitTriggerHelper.handleBeforeUpdate(opportunitysplitlist);
		TearDown();
	}
	// Test Method: handleBeforeInsert
	public static testmethod void Test_handleBeforeInsert(){
		SetUp();
		list<OpportunitySplit> opportunitysplitlist = new list<OpportunitySplit>();
		// TODO : Add extra code to validate the method call
		OpportunitySplitTriggerHelper.handleBeforeInsert(opportunitysplitlist);
		TearDown();
	}
}
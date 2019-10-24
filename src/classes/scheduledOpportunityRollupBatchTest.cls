@isTest
public class scheduledOpportunityRollupBatchTest {
    
public static testMethod void testschedule() {

Test.StartTest();
 scheduledOpportunityRollupBatch sh1 = new scheduledOpportunityRollupBatch();

String sch = '0 0 * * * ?';
system.schedule('Test', sch, sh1);  	
        Test.stopTest();   
}   
}
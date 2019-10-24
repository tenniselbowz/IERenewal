/*
    Trigger Written by Apttus Support 
    Case : 00209292
    Date : 20-04-2017
    Desc : To convert wf and process builder to trigger to avoid apex cpu time limit error
*/
trigger APTS_LineItemTrigger on Apttus_Config2__LineItem__c (before insert,before update) {
    if(trigger.isBEfore) {
        if(trigger.isInsert) {
            APTS_LineItemServices.updatePrice(trigger.new);
        }
        else if(trigger.isUpdate) {
            APTS_LineItemServices.updatePrice(trigger.new);
        }
    }

}
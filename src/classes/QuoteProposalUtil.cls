public class QuoteProposalUtil {
	@InvocableMethod
    public static List<Boolean> submitForCreditPreApproval(List<Id> quoteIds) {
        List<Boolean> processRequests = new List<Boolean>();
        for(Id quoteId : quoteIds) {
            Approval.ProcessSubmitRequest req = new Approval.ProcessSubmitRequest();
            req.setObjectId(quoteId);
            Approval.ProcessResult result = Approval.process(req);
            if(!result.isSuccess()) {
                //shouldnt happen unless the approval process is setup incorrectly
                // - Joo Kang
                throw new TestException(result.getErrors()[0].getMessage());
                processRequests.add(false);
            }
            Approval.unlock(quoteId);
            processRequests.add(true);
        }
        return processRequests;
    }
    
    public class TestException extends Exception {}
}
public with sharing class  GetAccountDetails {
    // Used by Flow Screen
    @InvocableMethod(
      callout=true
      label='GetAccountDetails'
      description='Get a contact given a Chat Transcript Id'
    )
    public static List<AccountDetails> getAccounts(List<String> ids) {
      String id = ids[0];
      AccountDetails ai = GetAccountDetails.getInfo(id);
      List<AccountDetails> result = new List<AccountDetails>();
      result.add(ai);
      return result;
    }
  
    // Used by LWC
    // Given a transcript Id, look up the Customer code then pass to query the API
    @AuraEnabled
    public static AccountDetails getInfoByTranscriptId(Id recordId) {
      return GetAccountDetails.getInfo(recordId);
    }
  
    public static AccountDetails getInfo(String recordId) {
      String customerCode;
      Id recId;
      try {
        recId = (Id) recordId;
      } catch (Exception e) {
        System.debug('getInfoException');
        throw new AuraHandledException(e.getMessage());
      }
      List<LiveChatTranscript> lcts = [
        SELECT Id, Receivable_Acct_Number__c
        FROM LiveChatTranscript
        WHERE Id = :recId 
        WITH SECURITY_ENFORCED
      ];
      if (lcts?.size() > 0) {
        customerCode = lcts[0].Receivable_Acct_Number__c;
      }
      //remove after updating API
      customerCode =  '60691143'; 

      // Call the API with account code and return the value
      Http h = new Http();
      HttpRequest req = new HttpRequest();
      // For real API, send a list of accountIds
      req.setEndpoint(
        'callout:ApigeeFord/fccrmsalesforce/api/accountlookupservice/accounts?coBusCd=1&rcvblAcctNb=' +
        customerCode
      );
      req.setMethod('GET');
      HttpResponse res = h.send(req);
      String json = res.getBody();
      AccountDetails ai = AccountDetails.parse(json);
      return ai;
    }
  }
  
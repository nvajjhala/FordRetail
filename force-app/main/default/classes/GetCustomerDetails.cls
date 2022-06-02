public with sharing class  GetCustomerDetails {
  // Used by Flow Screen
  @InvocableMethod(
    callout=true
    label='GetCustomerDetails'
    description='Get a contact given a Chat Transcript Id'
  )
  public static List<CustomerDetails> getCustomers(List<String> ids) {
    String id = ids[0];
    CustomerDetails ci = GetCustomerDetails.getInfo(id);
    List<CustomerDetails> result = new List<CustomerDetails>();
    result.add(ci);
    return result;
  }

  // Used by LWC
  // Given a transcript Id, look up the customer code then pass to query the API
  @AuraEnabled
  public static CustomerDetails getInfoByTranscriptId(Id recordId) {
    return GetCustomerDetails.getInfo(recordId);
  }

  public static CustomerDetails getInfo(String recordId) {
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
    // Call the API with customer code and return the value
    Http h = new Http();
    HttpRequest req = new HttpRequest();
    // For real API, send a list of customerIds
    req.setEndpoint(
      'callout:ApigeeFord/fccrmsalesforce/api/v1/cim/customer?coBusCd=1&rcvblAcctNb=' +
      customerCode
    );
    req.setMethod('GET');
    HttpResponse res = h.send(req);
    String json = res.getBody();
    CustomerDetails ci = CustomerDetails.parse(json);
    return ci;
  }
}

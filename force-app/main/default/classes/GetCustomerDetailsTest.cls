@isTest
private with sharing class GetCustomerDetailsTest {
  @TestSetup
  static void makeData() {
    LiveChatVisitor lcv = new LiveChatVisitor();
    insert lcv;

    LiveChatTranscript lct = new LiveChatTranscript();
    lct.LiveChatVisitorId = lcv.id;
    lct.Receivable_Acct_Number__c = '12345';
    insert lct;
  }

  @isTest
  static void testCustomerDetailsClass() {
    string jsonSkaggs = '{"name":"MOMMA SKAGGS", "email":"mommaskaggs@mailinator.com", "phone":"2125551212", "postalCode":"10101"}';
    CustomerDetails ci = CustomerDetails.parse(jsonSkaggs);
    System.assertEquals(ci.name, 'MOMMA SKAGGS');
  }

  @isTest
  static void testCallout() {
    LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new GetCustomerDetailsMockGenerator());
    // Test LWC call
    CustomerDetails ciResult = GetCustomerDetails.getInfoByTranscriptId(lct.Id);
    System.assertEquals(ciResult.name, 'MOMMA SKAGGS');

    // Test Flow call
    List<Id> ids = new List<id>();
    ids.add(lct.Id);
    List<CustomerDetails> custs = GetCustomerDetails.getCustomers(ids);
    System.assertEquals(custs[0].name, 'MOMMA SKAGGS');

    // Force error to cover catch
    try {
      CustomerDetails ciFail = GetCustomerDetails.getInfo('NOT ID');
      System.debug('good');
    } catch (Exception e) {
      System.debug('exception ' + e);
      System.assertEquals(e.getTypeName(), 'System.AuraHandledException');
    }

    CustomerDetails ciPass = GetCustomerDetails.getInfo(lct.Id);
    System.assertEquals(ciPass.name, 'MOMMA SKAGGS');

    Test.stopTest();
  }
}

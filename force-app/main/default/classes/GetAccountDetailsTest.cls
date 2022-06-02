@isTest
private with sharing class GetAccountDetailsTest {
  @TestSetup
  static void makeData() {
    LiveChatVisitor lcv = new LiveChatVisitor();
    insert lcv;

    LiveChatTranscript lct = new LiveChatTranscript();
    lct.LiveChatVisitorId = lcv.id;
    lct.Receivable_Acct_Number__c = '52139639';
    insert lct;
  }

  @isTest
  static void testAccountDetailsClass() {
    string jsonSkaggs = '{"receivableAccountNumber":"52139639", "productType":"Lease", "scheduledPaymentAmount":"412.33", "contractTermInMonths":"24",  "lastPaymentDate":"8-10-2023", "currentScheduledTerminationDate":"8-11-2023"}';
    AccountDetails ai = AccountDetails.parse(jsonSkaggs);
    System.assertEquals(ai.contractTermInMonths, '24');
  }

  @isTest
  static void testCallout() {
    LiveChatTranscript lct = [SELECT Id FROM LiveChatTranscript LIMIT 1];

    Test.startTest();
    Test.setMock(HttpCalloutMock.class, new GetAccountDetailsMockGenerator());
    // Test LWC call
    AccountDetails aiResult = GetAccountDetails.getInfoByTranscriptId(lct.Id);
    System.assertEquals(aiResult.contractTermInMonths, '24');

    // Test Flow call
    List<Id> ids = new List<id>();
    ids.add(lct.Id);
    List<AccountDetails> accs = GetAccountDetails.getAccounts(ids);
    System.assertEquals(accs[0].contractTermInMonths, '24');

    // Force error to cover catch
    try {
      AccountDetails aiFail = GetAccountDetails.getInfo('NOT ID');
      System.debug('good');
    } catch (Exception e) {
      System.debug('exception ' + e);
      System.assertEquals(e.getTypeName(), 'System.AuraHandledException');
    }

    AccountDetails aiPass = GetAccountDetails.getInfo(lct.Id);
    System.assertEquals(aiPass.contractTermInMonths, '24');

    Test.stopTest();
  }
}

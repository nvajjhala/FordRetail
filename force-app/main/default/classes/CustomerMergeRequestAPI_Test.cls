/* @group: Test class
 * @description: Test class for CustomerMergeRequestAPI
 */
@isTest
public class CustomerMergeRequestAPI_Test {

    /* @description: Test setup method
    */
    @testSetup
    static void dataSetup() {
        Id prsnAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        List<Account> accountInsertList = TestFactory.createAccounts(4, prsnAccountRecTypeId);
        accountInsertList[0].ExternalId__c = '11299977766';
        accountInsertList[1].ExternalId__c = '11211100066';
        accountInsertList[2].ExternalId__c = '11255500066';
        accountInsertList[3].ExternalId__c = '11255566666';
        insert accountInsertList;
    }

    /*
     * @description: Postitive test method to check if the  accounts are merged and
     * customer merge request records are created
     */
    @isTest public static void cmrJSONReqShouldCreateCMRAndMergeRecords() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();
		List< CustomerMergeRequestAPI.customerRequestWrapper> wrapperlist =
            new List< CustomerMergeRequestAPI.customerRequestWrapper>();
        CustomerMergeRequestAPI.customerRequestWrapper wrapper
            = new CustomerMergeRequestAPI.customerRequestWrapper();
        wrapper.winner = '11299977766';
        wrapper.loser = '11211100066';
        wrapper.mergedDateTime = system.now();
        wrapperlist.add(wrapper);
        CustomerMergeRequestAPI.customerRequestWrapper wrapper2
            = new CustomerMergeRequestAPI.customerRequestWrapper();
        wrapper2.winner = '11299977766';
        wrapper2.loser = '11255566666';
        wrapper2.mergedDateTime = system.now();
        wrapperlist.add(wrapper2);
        CustomerMergeRequestAPI.customerRequestWrapper wrapper3
            = new CustomerMergeRequestAPI.customerRequestWrapper();
        wrapper3.winner = '11299977766';
        wrapper3.loser = '11255500066';
        wrapper3.mergedDateTime = system.now();
        wrapperlist.add(wrapper3);
        req.requestURI = '/services/apexrest/custmerge';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(wrapperlist));

        RestContext.request = req;
   	    RestContext.response= res;

        Test.startTest();
        CustomerMergeRequestAPI.doPost();
        Test.stopTest();
         CustMergeReq__c cmrObj = [SELECT Id, Processedtime__c, Merged__c
                                   FROM CustMergeReq__c
                                   WHERE loser__c = '11255500066'];
        system.assertEquals(true, cmrObj.Merged__c,'Test Method failed, Expected: true, Actual:'+cmrObj.Merged__c);
    }

    /*
     * @description: Negetive test case to check if the winner id is not present in the system,
     * the accounts will not be merged and the customer merge request records will be created and marked as failed
     */
     @isTest public static void cmrJSONReqShouldCreateFailedCMRNotMergeRecords() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        CustomerMergeRequestAPI.customerRequestWrapper wrapper
            = new CustomerMergeRequestAPI.customerRequestWrapper();
        wrapper.winner = '11299900066';
        wrapper.loser = '11111100066';
        wrapper.mergedDateTime = system.now();

        req.requestURI = '/services/apexrest/custmerge';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(new List< CustomerMergeRequestAPI.customerRequestWrapper>{wrapper}));

        RestContext.request = req;
   		RestContext.response= res;

        Test.startTest();
        CustomerMergeRequestAPI.doPost();
        Test.stopTest();
        CustMergeReq__c cmrObj = [SELECT Id, Failed__c, Error__c
                                   FROM CustMergeReq__c
                                   WHERE loser__c = '11111100066'];
         system.assertEquals(true, cmrObj.Failed__c,'Test Method failed, Expected: true, Actual:'+cmrObj.Failed__c);
    }

    /*
     * @description: Negetive test case to check the JSON structure exception
     */
     @isTest public static void cmrJSONReqShouldTheowErrorOnInvalidJSON() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        CustomerMergeRequestAPI.customerRequestWrapper wrapper
            = new CustomerMergeRequestAPI.customerRequestWrapper();
        wrapper.winner = '11299900066';
        wrapper.loser = '11111100066';
        wrapper.mergedDateTime = system.now();

        req.requestURI = '/services/apexrest/custmerge';
        req.httpMethod = 'POST';
        req.requestBody = Blob.valueOf(JSON.serializePretty(wrapper));

        RestContext.request = req;
   		RestContext.response= res;

        Test.startTest();
        String errorStr = CustomerMergeRequestAPI.doPost();
        Test.stopTest();
        system.assertEquals(true, !String.isBlank(errorStr),'Test Method failed, Expected: true, Actual:'+!String.isBlank(errorStr));
    } 
}
/*
 * @description: Test class for PostDeploymentService
 * @group: Test class
*/
@isTest
public class PostDeploymentService_Test {

    /*
    * @description: Test setup method
    */
    @testSetup
    static void dataSetup() {
        List<User> userList = new List<User>();
        Id profileId = [SELECT Id FROM Profile WHERE Name = 'Tester'].Id;
        system.runAs(new User(Id= userInfo.getUserId())){
        UserRole usrRole = new UserRole(Name = 'Test Ford Advisor');
        insert usrRole;
        userList.add(TestFactory.createUser(profileId,usrRole.Id,'Test Post Dep', 'Batch_Test'));
        userList.add(TestFactory.createUser(profileId,usrRole.Id,'Test Refreshal', 'Batch_Test'));
        insert userList;
        }


        Id prsnAccountRecTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        List<Account> accountInsertList = TestFactory.createAccounts(4, prsnAccountRecTypeId);
        insert accountInsertList;

        List<Contact> contactList = testFactory.createContacts(4);
        insert contactList;

    }

    /*
     * @description: Postitive test method to check if the  accounts,Contacts, users are getting updated
     */
    @isTest public static void testRecordMasking() {
        Test.startTest();
        Test.testSandboxPostCopyScript(
            new PostDeploymentService(), UserInfo.getOrganizationId(),
                UserInfo.getOrganizationId(), UserInfo.getOrganizationName());
        Test.stopTest();
        Account accObj = [SELECT PersonEmail, Sync_To_MC__c FROM Account LIMIT 1];
        system.assertEquals(false, accObj.Sync_To_MC__c, 'Test method failed');
    }

}
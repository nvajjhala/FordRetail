/* @group: Test factory
 * @description: Generic class to setup data in test class
 */
@isTest
public class TestFactory {

    /*@description: Create Accounts for test class.
     */
    public static List<Account> createAccounts( Integer numberOfAccounts, String recordTypeId) {
        List<Account> accountList = new List<Account>();
        for ( Integer i = 0 ; i < numberOfAccounts ; i++ ) {
            Account account = new Account( firstname = 'Test' + Math.random(), lastname = 'Account',RecordTypeID=recordTypeId,
                                         InactiveMerged__c = False, DealerPrimaryPAAccountCode__c = '1234ABC', 
                                         DealerPrimarySalesCode__c = 'EFDR33');
            accountList.add(account);
        }
        return accountList;
    }

    /*@description: Create Customer Merge Request records for Customer Profile Merge.
     */
    public static List<CustMergeReq__c> createMergeReq(Integer numberOfCustMerge, List<String> winner, List<String> loser) {
        List<CustMergeReq__c> cmrList = new List<CustMergeReq__c>();
        for ( Integer i = 0 ; i < numberOfCustMerge ; i++ ) {
            CustMergeReq__c mergeRequest = new CustMergeReq__c(loser__c = loser[i],winner__c = winner[i],Merged__c = False );
            cmrList.add( mergeRequest);
        }
        return cmrList;
    }

    /*
     *@description: Create Contact records.
     */
    public static List<Contact> createContacts(Integer numberOfContact){
        List<Contact> contactList = new List<Contact>();
        for ( Integer i = 0 ; i < numberOfContact ; i++ ) {
            Contact conObj = new Contact(LastName = 'Test',
                                         Email='test@example.com',
                                         Phone='1234567891',
                                         Sync_To_MC__c = false);
            contactList.add( conObj);
        }
        return contactList;

    }

    /*
     *@description: Create user records
     */
    public static User createUser(Id profileId, Id userRoleId, String firstname, String lastName){
        String orgId = UserInfo.getOrganizationId();
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId  + randomInt;
        User usrObj = new User(  firstname = firstname,
                                lastName = lastName,
                                email = uniqueName + '@test' + '.org',
                                Username = uniqueName + '@test' + '.org',
                                EmailEncodingKey = 'ISO-8859-1',
                                Alias = uniqueName.substring(18, 23),
                                TimeZoneSidKey = 'America/Los_Angeles',
                                LocaleSidKey = 'en_US',
                                LanguageLocaleKey = 'en_US',
                                ProfileId = profileId,
                                UserRoleId = userRoleId);
        return usrObj;
    }
}
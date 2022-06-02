/* @description: Test class for CustomerMergeRequestBatch
 */
@isTest
public class CustomerMergeRequestBatch_Test {
    
     /*
     * @description: This method prepares the test datas well as covers the positive and negative scenario.
     */
    @isTest
     public static void testCustomerMerge(){
        
        String formatedDt = System.now().addHours(-1).formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        CustMergeCS__c cus = new CustMergeCS__c();
        cus.Name = 'Merge Batch Run Time';
        cus.Last_Batch_Run_Time__c = formatedDt;
        insert cus;
        
        String recordTypeId  = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        List<String> extList = new list<String> { '11299885521' , '11256478219', '11299885777', '11256478999' };
   
        List<Account> insertAccList = TestFactory.createAccounts(4,recordTypeId);
        
        for( Integer i = 0 ; i < 4 ; i++ ){
            insertAccList[i].ExternalId__c = extList[i];
            
        }
        Insert insertAccList;
        
        List<CustMergeReq__c> cmrList = new List<CustMergeReq__c>();
        List<String> wList = new list<String> { '11299885521','132465', '11299885521', '11299885521'};
        List<String> lList = new list<String> { '11256478219','987654', '11299885777', '11256478999'};
        
        List<CustMergeReq__c> mergeList = TestFactory.createMergeReq(4,wList,lList); 
 		cmrList.addAll(mergeList); 
        Insert cmrList;
         
        Test.startTest();
        CustomerMergeRequest_Batch req = new CustomerMergeRequest_Batch();
		database.executeBatch(req);
        Test.stopTest();
        
        CustMergeReq__c cmrpositive = [SELECT Id, Processedtime__c, Merged__c 
                                   FROM CustMergeReq__c 
                                   WHERE loser__c = '11256478219'];
        
        system.debug('cmrpositive=>'+ cmrpositive);
        system.assertEquals(True,cmrpositive.Merged__c,'Merged');
        
        CustMergeReq__c cmrnegative = [SELECT Id, Processedtime__c, Merged__c,Failed__c 
                                   FROM CustMergeReq__c 
                                   WHERE loser__c = '987654'];
        
        system.debug('cmrnegative=>'+ cmrnegative);
        system.assertEquals(True,cmrnegative.Failed__c,'Falied CMR Scenario');
        
    }
    /*
	* @description: This method tests the scheduler method of the Batch Class.
	*/
     @isTest
    public static void scheduleBatch(){

        CustomerMergeRequest_Batch sched = new CustomerMergeRequest_Batch();
        String sch = '0 0 0 1 * ? *';
        String jobID = system.schedule('Merge Job', sch, sched);
        system.assertNotEquals(Null, jobID,'Schedule job');

    }
    
}
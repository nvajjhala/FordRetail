public class CustomerMergeRequest_Batch implements Database.Batchable<sObject>, Schedulable,Database.Stateful{
    public Datetime currentExecutionTime = System.now().addHours(-8);

 /****************************************************************************************************************
* @Description: Start method will fetch all the Customer Merge Request records created or updated in the system.
* @param :      Standard parameter where id = \'a0T8G0000006zUHUAY\' where Merged__c = False
* @Returns:
*****************************************************************************************************************/
    public Database.QueryLocator  start(Database.BatchableContext bc){
        String lastBatchExecutionTime = UtilityClass.fetchMergeBatchexecutionTime();
        String query = '';
        query = 'select ID,winner__c,loser__c,Merged__c,merged_date_time__c,Processedtime__c from CustMergeReq__c '+
            'where Merged__c = False AND LastModifiedDate >='+lastBatchExecutionTime ;
            System.debug('query=> ' + query);
        try{
            return Database.getQueryLocator(query);
        }catch(Exception e){
            return null;
        }
    }

/****************************************************************************************************************
* @Description: Execute method will get the Customer Merge Request records from the start method and iterate on them to perform
				merge operation on them.
* @param :      Customer Merge Request
* @Returns:
*****************************************************************************************************************/
    public void execute(System.SchedulableContext st){
        Database.executeBatch(new CustomerMergeRequest_Batch(),120);
    }

    public void execute (Database.BatchableContext bc, List<CustMergeReq__c> mergeReqs){
        Map<String,CustMergeReq__c> loserCMRMap = new Map<String,CustMergeReq__c>();
        Set<String> loserSet = new Set<String> ();
        Set<String> winSet = new Set<String> ();
        for(CustMergeReq__c cusMerge : mergeReqs){
            if(!String.isBlank(cusMerge.winner__c) ){
                winSet.add(cusMerge.winner__c);
            }
            if(!String.isBlank(cusMerge.loser__c) ){
                loserSet.add(cusMerge.loser__c);
            }
            loserCMRMap.put(cusMerge.loser__c,cusMerge);
        }
        AccountMergeService.handleAccountMerge(winSet, loserSet, loserCMRMap);
    }

/****************************************************************************************************************
* @Description:
* @param :      Database.BatchableContext bc
* @Returns:     NA
*****************************************************************************************************************/
    public void finish(Database.BatchableContext bc){
        UtilityClass.updateBatchTime(currentExecutionTime);
    }
}
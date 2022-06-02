/* @group: Service class
 * @description: Service class to merge the account records and create or update
 * CustMergeReq__c records
 */

public without sharing class AccountMergeService {
    public static final String MERGE_FAILED_ERROR_MESSAGE = 'Merge failed. The winner/loser id is not present in system as of ';
	public static final String STATUS_INACTIVE = 'Inactive';
    public static Map<Id,Account> accountMap;

    /*  @description: Method will merge the account and upsert CustMergeReq__c records
     *  @param: Set<String> winnerIdSet
     *  @param: Set<String>loserIdSet
     *  @param: Map<String,CustMergeReq__c>custMergeReqMap
    */
    public static void handleAccountMerge(Set<String> winnerIdSet, Set<String>loserIdSet, Map<String,CustMergeReq__c>custMergeReqMap){
        Map<String,Account> winnerMap = new Map<String,Account>();
        Map<String,Account> loserMap = new Map<String,Account>();
        List<Account> accountUpdateList = new List<Account>();
        Map<String,List<Account>> loserAccMapByWinId = new Map<String,List<Account>>();
        List<CustMergeReq__c> updateMergeReqList = new List<CustMergeReq__c>();
        accountMap = new Map<Id,Account>();
        Savepoint sp;
        //query on account to get records to merge
        accountMap = queryOnAcc(winnerIdSet,loserIdSet);
        buildWinloserMap(winnerIdSet, loserIdSet,winnerMap, loserMap);
        Integer counter = 0;
        for(CustMergeReq__c cusMerge : custMergeReqMap.values()){
             String uniqueWinnerId = cusMerge.winner__c + '|' + counter;
             // Adding error message on CMR records if the loser/winner account is not present in the database
            if(!loserMap.containsKey(cusMerge.loser__c) || !winnerMap.containsKey(cusMerge.winner__c)){
                cusMerge.Failed__c = true;
                cusMerge.Error__c = MERGE_FAILED_ERROR_MESSAGE + system.now();
                cusMerge.Merge_Type__c = system.isBatch() ? 'Batch' : 'API';
                updateMergeReqList.add(cusMerge);
            } else {
                /* building Map<String, List<Account>> where key is a unique combination of winnerId
                and counter seperated by '|' and value will include loserAccounts in a list with size 2*/
                Account loserAcc = new Account(Id = loserMap.get(cusMerge.loser__c).Id);
                if(loserAccMapByWinId.containsKey(uniqueWinnerId)
                    && loserAccMapByWinId.get(uniqueWinnerId).size()<2){
                    loserAccMapByWinId.get(uniqueWinnerId).add(loserAcc);
                } else if(loserAccMapByWinId.containsKey(uniqueWinnerId)
                        && loserAccMapByWinId.get(uniqueWinnerId).size()>=2){
                    counter++;
                    uniqueWinnerId = cusMerge.winner__c + '|' + counter;
                    loserAccMapByWinId.put(uniqueWinnerId,new List<Account>{loserAcc});
                } else{
                    counter = 0;
                    uniqueWinnerId = cusMerge.winner__c + '|' + counter;
                    loserAccMapByWinId.put(uniqueWinnerId,new List<Account>{loserAcc});
                }
            }
        }
        List<MergeResultWrapper> mergeResWrapperList = new List<MergeResultWrapper>();
        List<Id> mergedIds = new List<Id>();
        sp = Database.setSavepoint();
        // for loop runs over loserAccMapByWinId and gets winnwer account and list of loser accounts
        for(String key : loserAccMapByWinId.keySet()){
                String winId = key.SubStringBefore('|');
                List<Account> loserMergeList = loserAccMapByWinId.get(key);
                Account winnerAcc = new Account(Id = winnerMap.get(winId).Id);
                // Account Merge operation with 2 loser accounts and 1 winner account
                Database.MergeResult[] results = Database.merge(winnerAcc, loserMergeList, false);
            for (Database.MergeResult res : results) {
                MergeResultWrapper wrap;
                if (res.isSuccess()) {
                    wrap = new MergeResultWrapper(loserMergeList,'', true,winnerAcc);
                    mergedIds.addAll(res.getMergedRecordIds());
                } else {
                    handleMergeFailure(res.getErrors(),loserMergeList, wrap);
                    Database.RollBack(sp);
                }
                mergeResWrapperList.add(wrap);
            }
        }
        undeleteAccRecords(mergedIds);
        handleMergeResults(mergeResWrapperList, accountUpdateList, updateMergeReqList,custMergeReqMap);
        updateAccRecords(accountUpdateList);
        updateCMRRecords(updateMergeReqList);
    }

    /*  @description: Method will create a winner and loser maps which contains External Id as key
     *  and Account as the value
     *  @param: Set<String> winnerIdSet
     *  @param: Set<String>loserIdSet
     *  @param: Map<String,Account> winnerMap
     *  @param: Map<String,Account> loserMap
    */
    public static void buildWinloserMap(Set<String> winnerIdSet, Set<String>loserIdSet,
    Map<String,Account> winnerMap,Map<String,Account> loserMap){
        for(Account accObj : accountMap.values()) {
            if(winnerIdSet.contains(accObj.ExternalId__c)){
                winnerMap.put(accObj.ExternalId__c,accObj);
            } else if(loserIdSet.contains(accObj.ExternalId__c)){
                loserMap.put(accObj.ExternalId__c,accObj);
            }
        }
    }

    /*  @description: Method is used to handle Account merge failures, the failed accounts are added
     *  to the MergeResultWrapper wrapper
     *  @param: List<Database.Error> errorList
     *  @param: List<Account> loserMergeList
     *  @param: MergeResultWrapper wrap
    */
    public static void handleMergeFailure(List<Database.Error> errorList,
                                    List<Account> loserMergeList, MergeResultWrapper wrap){
        for (Database.Error err : errorList) {
            wrap = new MergeResultWrapper(loserMergeList, err.getMessage(), false, null);
        }
    }

    /*  @description: Method is used to perform update DML on Account records
     *  @param: List<Account> accountUpdateList
    */
    public static void updateAccRecords(List<Account> accountUpdateList){
        List<Database.SaveResult> accountSaveResult = database.update(accountUpdateList, false);
        for (Database.SaveResult accRes : accountSaveResult) {
            if(!accRes.isSuccess()){
                system.debug('error in accountSaveResult--'+accRes.getErrors());
            }
        }
    }

    /*  @description: Method is used to perform undelete DML on Account records
     *  @param: List<Id> mergedIds
    */
    public static void undeleteAccRecords(List<Id> mergedIds){
        List<Account> accUndeleteList = [SELECT Id
                                             FROM Account
                                             WHERE Id IN: mergedIds AND isDeleted = true
                                             WITH SECURITY_ENFORCED ALL ROWS];
        List<Database.UndeleteResult> undeleteResult = Database.undelete(accUndeleteList,false);
        for (Database.UndeleteResult undeleteRes : undeleteResult) {
            if(!undeleteRes.isSuccess()){
                system.debug('error in undeleteResult--'+undeleteRes.getErrors());
            }
        }
    }

    /*  @description: Method is used to perform update DML on CustMergeReq__c records
     *  @param: List<CustMergeReq__c>updateMergeReqList
    */
    public static void updateCMRRecords(List<CustMergeReq__c>updateMergeReqList){
        List<Database.SaveResult> cmrSaveResult;
        if(System.isBatch()){
            cmrSaveResult = database.update(updateMergeReqList, false);
        }else{
            cmrSaveResult = database.insert(updateMergeReqList, false);
        }
        for (Database.SaveResult cmrRes : cmrSaveResult) {
            if(!cmrRes.isSuccess()){
                system.debug('error in cmrSaveResult--'+cmrRes.getErrors());
            }
        }
    }

    /*  @description: Method does a dynamic query on account to fetch the person account records
     *  @param: Set<String> winnerIdSet
     *  @param: Set<String> loserIdSet
    */
    public static Map<Id,Account> queryOnAcc(Set<String> winnerIdSet, Set<String> loserIdSet){
        String queryString = 'SELECT ';
        for(Schema.FieldSetMember fld : SObjectType.Account.FieldSets.Customer_Merge_Field_Set.getFields()) {
            queryString += String.escapeSingleQuotes(fld.getFieldPath() +', ');
         }
         queryString += 'Id, ExternalId__c,MergedDateTime__c,Winner_Customer__c,createddate FROM Account WHERE isPersonAccount = true AND (ExternalId__c IN: winnerIdSet OR ExternalId__c IN: loserIdSet) WITH SECURITY_ENFORCED';
         try{
            Map<Id, Account> accountMap = new Map<Id, Account>((List<Account>)Database.query(queryString));
            return accountMap;
         }
         catch(QueryException queryExe){
            system.debug('Query execption:'+queryExe);
            return null;
        }
    }

    /*  @description: Method to handle merge results and add them in accountlist and cmrList
     *  @param: List<MergeResultWrapper> mergeResWrapperList
     *  @param: List<Account>accountUpdateList
     *  @param: List<CustMergeReq__c>updateMergeReqList
     *  @param: Map<String,CustMergeReq__c>custMergeReqMap
    */
    public static void handleMergeResults(List<MergeResultWrapper> mergeResWrapperList,
                                        List<Account>accountUpdateList,
                                        List<CustMergeReq__c>updateMergeReqList,
                                        Map<String,CustMergeReq__c>custMergeReqMap){
        Set<Id> dupCheckAccountId = new Set<Id>();
        for(MergeResultWrapper eachWrap : mergeResWrapperList){
            if(eachWrap.isSuccess && !dupCheckAccountId.contains(eachWrap.winnerAccount.Id)){
                //Code to Populate the Winner account fields with loser account data if they are blank.
                //Calls Utility Class method.
                eachWrap.winnerAccount = UtilityClass.populateWinnerField(eachWrap.winnerAccount, eachWrap.accountList,accountMap);
                eachWrap.winnerAccount.MergedDateTime__c = system.now();
                dupCheckAccountId.add(eachWrap.winnerAccount.Id);
                accountUpdateList.add(eachWrap.winnerAccount);
            }
            for(Account accObj : eachWrap.accountList){
                Account loserAcc = accountMap.get(accObj.Id);
                    CustMergeReq__c cmrObj = custMergeReqMap.get(loserAcc.ExternalId__c);
                    cmrObj.Merge_Type__c = system.isBatch() ? 'Batch' : 'API';
                    cmrObj.Error__c = eachWrap.errorMessage;
                    cmrObj.Failed__c = true;
                    if(eachWrap.isSuccess){
                        cmrObj.Merged__c = true;
                        cmrObj.Processedtime__c = System.now();
                        cmrObj.Error__c = '';
                        cmrObj.Failed__c = false;

                        loserAcc.MergedDateTime__c = system.now();
                        loserAcc.Winner_Customer__c = eachWrap.winnerAccount.Id;
                        loserAcc.InactiveMerged__c = True;
                        accountUpdateList.add(loserAcc);
                    }
                    updateMergeReqList.add(cmrObj);
            }
        }
    }

    /*
     * @group: Wrapper class
     * @description: This is used to handle error/success and create/update CMR records
    */
    public class MergeResultWrapper{
        public List<Account> accountList{get;set;}
        public String errorMessage{get;set;}
        public Boolean isSuccess{get;set;}
        public Account winnerAccount {get;set;}
        public MergeResultWrapper(List<Account> accountList, String errorMessage,
                                    Boolean isSuccess,Account winnerAccount){
            this.accountList = accountList;
            this.errorMessage = errorMessage;
            this.isSuccess = isSuccess;
            this.winnerAccount = winnerAccount;
        }
    }
}
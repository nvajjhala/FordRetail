/****************************************************************************************************************
* @Date:        [26/04/2022]
* @Description: [Use this class to write common utility methods that can be used across all classes
for example: methods to read custom setting, custom metadata, calculations etc.]
*****************************************************************************************************************/
public without sharing class UtilityClass {
    /****************************************************************************************************************
* @Description: Get the DateTime value from Custom setting                                                      *
* @param :                                                                                                      *
* @Returns:                                                                                                     *
****************************************************************************************************************/
    public static String fetchMergeBatchexecutionTime() {

        CustMergeCS__c configTime =  CustMergeCS__c.getInstance('Merge Batch Run Time');
        String executionTime = configTime.Last_Batch_Run_Time__c ;

        return executionTime;
    }
/****************************************************************************************************************
* @Description: Update Custom setting record after batch execution                                              *
* @param :                                                                                                      *
* @Returns:                                                                                                     *
****************************************************************************************************************/
    public static void updateBatchTime(Datetime currentExecutionTime) {
        //Datetime currentExecutionTime = System.now().addHours(-1);
        String formatedDt = currentExecutionTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
        system.debug('time=>'+ currentExecutionTime);
        CustMergeCS__c configTime =  CustMergeCS__c.getInstance('Merge Batch Run Time');
        configTime.Last_Batch_Run_Time__c = formatedDt;

        if (!Schema.sObjectType.CustMergeCS__c.fields.Last_Batch_Run_Time__c.isUpdateable()) {
            system.debug('error in updateBatchTime--');
        }
        else{
            Update configTime;
        }

       //Update configTime;
    }
/****************************************************************************************************************
* @Description: Populate the Winner account fields with loser account data if they are blank                    *
* @param : Account winAcc, List<Account> loserList                                                              *
* @Returns: Account Record                                                                                      *
****************************************************************************************************************/
    public static Account populateWinnerField(Account winAccount, List<Account> loserLists, Map<Id,Account> accountMap){

        Account winAcc  = accountMap.get(winAccount.Id);
        system.debug('winAcc=>' + winAcc);

        List<Account> loserList = new List<Account>();

        system.debug('loserLists=>' + loserLists);
        /*
        String queryString = 'SELECT Id,createddate';

        for(Schema.FieldSetMember fld :SObjectType.Account.FieldSets.Customer_Merge_Field_Set.getFields()) {
            //queryString += ', ' + fld.getFieldPath();
            queryString += String.escapeSingleQuotes(', ' + fld.getFieldPath());
        }
        queryString += ' FROM Account WHERE Id IN: loserLists';
        system.debug('queryString=>'+ queryString);

        loserList = Database.query(queryString);
        */

        String fieldName = '';
        Account loser;

        if(loserLists.size()> 1){
            system.debug('Ifstart=>');
            loserList.add(accountMap.get(loserLists[0].id));
            loserList.add(accountMap.get(loserLists[1].id));
			system.debug('loserList=>' + loserList);

            if(loserList[0].createddate < loserList[1].createddate){
                system.debug('Ifcreateddate=>');
                loser = loserList[0];
            }
            else{
                system.debug('Elsecreateddate=>');
                loser = loserList[1];

            }
        }
        else{
             loser = accountMap.get(loserLists[0].id);
            //loser = loserList[0];
        }
        system.debug('Loser=>' + loser);
        system.debug('loserList=>' + loserList);

        for(Schema.FieldSetMember fld :SObjectType.Account.FieldSets.Customer_Merge_Field_Set.getFields()) {
            fieldName = (String)fld.getFieldPath();
            String winValue = '';
            String loserValue = '';
            winValue = (String)winAcc.get(fld.getFieldPath());
            loserValue = (String)loser.get(fld.getFieldPath());
            system.debug('fieldname=>' + fieldName);
            system.debug('testwinner=>' + winValue);
            system.debug('testloser=>' + loserValue);
            if(String.isBlank(winValue) && !String.isBlank(loserValue)){
                system.debug('IfFor=>' + fieldName);

                winAcc.put(fieldName,loserValue );
            }
        }
        system.debug('winner=>' + winAcc);

        return winAcc;
    }


}
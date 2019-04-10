//  Flow component to attach a file to a record.
//  
//  The code checks to make sure that only one record is entered at a time.  To provide updates to multiple
//  cases, place this component inside a loop in flow builder.
//  
//  Returns a status string of either 'SUCCESS' or 'FAILURE'.  In case of FAILURE, a more detailed message
//  detailing the reason for failure is provided.
//
//  This code is provided AS IS, with no warranty or guarantee of suitability for use.
//  Contact: john.meyer@salesforce.com

global without sharing class AttachFileToRecord {
    
    private static final String SUCCESS = 'SUCCESS';
    private static final String FAILURE = 'FAILURE';
    
    global class Requests {
        @InvocableVariable
        global Id recordId;                 // The ID of the record
        
        @InvocableVariable
        global String fileTitle;            // The title of the file to assign
    }
    
    global class Results {
        @InvocableVariable
        global String status;               // Either 'SUCCESS' or 'FAILURE'
        
        @InvocableVariable
        global String message;              // In the case of FAILURE, a more detailed message
    }    
    
    @InvocableMethod(label='Attach File to Record' description='Attaches a file to a record.')
    
    public static List<Results> attachFileToRecord (List<Requests> records) {
        
        List<Results> resultList = new List<Results>();
        Results result = new Results();
        
        if (records.size() != 1) {
            result.status = FAILURE;
            result.message = 'You must supply exactly one record to use this action.';
            System.debug(result.message);
        } else {
            List<ContentDocument> docs = [SELECT Id FROM ContentDocument WHERE Title = :records[0].fileTitle LIMIT 1];            
            if (docs.size() != 1) {
                result.status = FAILURE;
                result.message = 'No files titled "' + records[0].fileTitle + '" were found.';
                System.debug(result.message);
            } else 
                try {
                    ContentDocumentLink link = new ContentDocumentLink(
                        ContentDocumentId = docs[0].Id,
                        LinkedEntityId = records[0].recordId,
                        ShareType = 'I',
                        Visibility = 'AllUsers'
                    );
                    insert link;
                    result.status = SUCCESS;
                } catch (DMLException e) {
                    result.status = FAILURE;
                    result.message = 'Could not attach file "' + records[0].fileTitle + '" to record ' + records[0].recordId + ': ' + e.getMessage();
                    System.debug(result.message);
                }
        }
        
        resultList.add(result);
        return resultList;
    }
    
}
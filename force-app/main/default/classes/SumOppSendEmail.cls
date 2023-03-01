public class SumOppSendEmail implements Database.Batchable<sObject> {
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //this query returns all accounts, all of their opportunities created/edited this month and all the contacts available to be emailed
        return Database.getQueryLocator('SELECT Id, Name, (SELECT Id, Email, AccountId FROM Contacts WHERE Is_Primary_Contact__c = true AND Email != null), (SELECT Amount, StageName FROM Opportunities WHERE CreatedDate = THIS_MONTH OR LastModifiedDate = THIS_MONTH) FROM Account');
    }

    public void execute(Database.BatchableContext bc, List<Account> scope) {
        //Set to identify stages to be added to open
        Set<String> openStages = new Set<String>{'Prospecting', 'Qualification', 'Needs Analysis', 'Value Proposition', 'Id. Decision Makers', 'Perception Analysis', 'Proposal/Price Quote', 'Negotiation/Review'};

        //map for all accounts and opportunities
        Map<Id, Map<String, Integer>> results = new Map<Id, Map<String, Integer>>();

        //list for primary contacts available to be emailed
        List<Contact> primaryContacts = new List<Contact>();
        
        //map for account names to the ids
        Map<Id, String> accNames = new Map<Id, String>();

        //add all accounts to the map.
        for (Account acc : scope) {
            results.put(acc.Id, new Map<String, Integer>{'Closed Won' => 0, 'Closed Lost' => 0, 'Open' => 0});
        }
    
        //loop over the scope to put the data to related collections.
        for (Account acct : scope) {
            //loop over the opportunities for each account.
            for (Opportunity opp : acct.Opportunities) {
                //if the stage is one of the open stages
                if (openStages.contains(opp.StageName)) {
                    //add the amount to the 'Open' key's value
                    results.get(acct.Id).put('Open', results.get(acct.Id).get('Open') + Integer.valueOf(opp.Amount));
                //if the stage isn't one of the open stages
                } else {
                    //add the amount to StageName key's value.
                    results.get(acct.Id).put(opp.StageName, results.get(acct.Id).get(opp.StageName) + Integer.valueOf(opp.Amount));
                }
            }

            //put all the primary contacts to the list
            for (Contact c : acct.Contacts) {
                primaryContacts.add(c);
            }

            //map all the account ids with their names
            accNames.put(acct.Id, acct.Name);
        }
    
        //create list of singeEmails
        List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
    
        for (Contact con : primaryContacts) {
            //create new email object
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        
            //add the email address
            String[] toAddresses = new String[]{con.Email};
            mail.setToAddresses(toAddresses);
        
            //add subject to the email
            mail.setSubject('Summary of This Month\'s Opportunities');
    
            //generate the body;
            String body = '';
            body = '<p>Below is a table of opportunities related to the account: ' + accNames.get(con.AccountId) + '</p><br/><br/>' + 
            '<table border="1">' + 
            '<tr><th>Account</th><th>Stage</th><th>Amount</th></tr>';
    
            //get the stage values as strings.
            for (String key : results.get(con.AccountId).keySet()) {
                String sum = '';
    
                if (results.get(con.AccountId).get(key) != 0) {
                    sum = String.valueOf(results.get(con.AccountId).get(key));
                } else {
                    sum = ' ';
                }
    
                body += '<tr><td>' + accNames.get(con.AccountId) +
                '</td><td>' + key + 
                '</td><td>' + sum + '</td></tr>';
            }
    
            body += '</table>';
    
            //set the body
            mail.setHtmlBody(body);
    
            //add the mail to the list
            mails.add(mail);
        }
    
        if (mails.size() > 0) {
            SendAndLogEmails.sendAndLog(mails);
        }
    }

    public void finish(Database.BatchableContext bc) {}
}
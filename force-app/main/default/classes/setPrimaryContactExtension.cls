public with sharing class setPrimaryContactExtension {
    public Account acct{get; set;}

    Public Integer size{get;set;} 
    Public Integer offset{get; set;}
    Public Integer noOfRecords{get; set;}
    Public Integer page{get; set;}

    Public String inputText{get; set;}
    Public String nameInput{get{
        if (nameInput == null) {
            nameInput = '%';
        }
        return nameInput;
    } set;}

    public List<SelectOption> paginationSizeOptions{get;set;}

    public setPrimaryContactExtension(ApexPages.StandardController sc) {
        this.acct = (Account)sc.getRecord();
        size = 10;
        offset = 0;
        page = 1;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('25','25'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
        noOfRecords = [SELECT Count()
                       FROM Contact
                       WHERE AccountId = :acct.Id
                       AND Name LIKE :nameInput];
    }

    public boolean getHasNext() {
        if (offset + size < noOfRecords) {
            return true;
        } else {
            return false;
        }
    }

    public boolean getHasPrev() {
        if (offset > 0) {
            return true;
        } else {
            return false;
        }
    }

    public PageReference refreshPageSize() {
        this.size = size;
        return null;
   }

    public PageReference nextPage() {
        page += 1;
        offset += size;
        return null;
    }

    public PageReference prevPage() {
        page -= 1;
        offset -= size;
        return null;
    }

    public PageReference firstPage() {
        page = 1;
        offset = 0;
        return null;
    }

    public PageReference lastPage() {
        page = noOfRecords / size;
        offset = noOfRecords - Math.mod(noOfRecords, size);
        return null;
    }

    public PageReference refreshNameInput() {
        this.nameInput = inputText + '%';
        return null;
    }
    
    public List<Contact> getContacts() {
        List<Contact> results = [
            SELECT Id, Name, Title, Phone, Is_Primary_Contact__c
            FROM Contact
            WHERE AccountId = :acct.Id
            AND Name LIKE :nameInput
            ORDER BY Name, Is_Primary_Contact__c 
            LIMIT :size
            OFFSET :offset
            ];
        return results;
    }
}

// SELECT Id, Name, Title, Phone, Is_Primary_Contact__c FROM Contact WHERE AccountId = 'd00000Tbw2sAABAND' AND Name LIKE '%' ORDER BY Name, Is_Primary_contact__c LIMIT 25 OFFSET 0

// 'AND Name LIKE ' + nameInput + 
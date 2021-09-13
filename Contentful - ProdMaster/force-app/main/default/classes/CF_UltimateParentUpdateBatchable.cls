/*
Version        : 2.0
Company        : Websolo inc. 
Date           : 11/2013
Description    : This batchable class calculates Ultimate Parent for Account with Hierarchy of parent Accounts to 5 levels up.

*/ 
global class CF_UltimateParentUpdateBatchable implements Database.Batchable<SObject>, Database.Stateful 
{
    global Database.QueryLocator start(Database.BatchableContext bc) 
    {
        return  Database.getQueryLocator([select id, Name, ParentId, Parent.ParentId, Parent.Parent.ParentId, Parent.Parent.Parent.ParentId, Parent.Parent.Parent.Parent.ParentId from Account]);
    }
    global void execute(Database.BatchableContext bc, List<SObject> batch)      
    {               
        list<Account> ListAcc = new list<Account>();
        set<id> idAcc = new set<id>();  
        for (Account a : (List<Account>) batch) 
        {
           if(a.ParentId != null)
           {
              ListAcc.add(a);
              idAcc.add(a.id);            
           }                
        }
        List<Account> AccUltP = new List<Account>();

                            AccUltP = [select id, Name,
                                             ParentId,
                                             Parent.ParentId,
                                             Parent.Parent.ParentId,
                                             Parent.Parent.Parent.ParentId,
                                             Parent.Parent.Parent.Parent.ParentId                                     
                                             from 
                                                Account
                                             where 
                                                ParentId != null
                                                and
                                                id IN: idAcc]; 
        
       if(AccUltP.size() > 0)
       {                                                                        
           for(Account a: ListAcc)
           {
            for(Account b: AccUltP)
            {           
                if(a.id == b.id)
                {
                    if(b.Parent.Parent.Parent.Parent.ParentId != null)
                    {
                        a.Ultimate_Parent__c = b.Parent.Parent.Parent.Parent.ParentId;
                    }           
                    else
                    {
                        if(b.Parent.Parent.Parent.ParentId != null)
                        {
                            a.Ultimate_Parent__c = b.Parent.Parent.Parent.ParentId;
                        }       
                        else
                        {
                            if(b.Parent.Parent.ParentId != null)
                            {
                                a.Ultimate_Parent__c = b.Parent.Parent.ParentId;
                            }       
                            else
                            {
                                if(b.Parent.ParentId != null)
                                {
                                    a.Ultimate_Parent__c = b.Parent.ParentId;
                                }       
                                else
                                {
                                    if(b.ParentId != null)
                                    {
                                        a.Ultimate_Parent__c = b.ParentId;
                                    }
                                    else
                                    {
                                        a.Ultimate_Parent__c = b.id;
                                    }                               
                                }                   
                            }               
                        }           
                    }                   
                }
             }
          }
          update ListAcc;
       }                    
    }
    global void finish(Database.BatchableContext bc) 
    {
        
    }
   
}
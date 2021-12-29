//  Copyright (c) 2012, Odhrán Lenaghan, Sales Support Engineer, Salesforce.com Inc.
//  All rights reserved.
//
//  Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
//  Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
//  Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
//  Neither the name of the salesforce.com nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission. 

//  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
//  INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//  DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
//  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
//  LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN 
//  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, 
//  EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

public with sharing class ChatterIdLookup {

    public string currentChatterId {get;set;} //intialise storage for current Chatter Group Id
    
    public Chatter_Marquee__c chatterStorage {get; set;} //initialise the Chatter_Marquee__c custom setting where the id will be stored permanently
    
    public List<CollaborationGroup> chatterGroups{get; set;} //initialise List to store Chatter Group Ids
    
    public ChatterIdLookup(){
        chatterStorage = Chatter_Marquee__c.getOrgDefaults(); //get the current Chatter_Marquee__c settings
        currentChatterId = chatterStorage.ChatterId__c; //assign stored Chatter Group Id to currentChatterId which is used as the entityId in <chatter:feed>       
    }
    
    //get all Chatter Group names and ids, store in drop down list
    public List<SelectOption> getGroups() {
        List<SelectOption> options = new List<SelectOption>();
        
        chatterGroups = [SELECT name, id from CollaborationGroup];
        options.add(new SelectOption('','Select a Chatter Group'));   
        
        for(CollaborationGroup cg:  chatterGroups) {
            options.add(new SelectOption(cg.Id,cg.Name));
        }
        return options;
    }
    
    //upsert the selected group id to the custom setting Chatter_Marquee__c to store permanently  
    public PageReference setSelectedId(){
        chatterStorage.ChatterId__c = currentChatterId ;
        upsert chatterStorage;
        return null;
    }
    
    //upsert null to the custom setting Chatter_Marquee__c to allow the user to select a new Chatter Group to display
    public PageReference edit(){
    
        chatterStorage.ChatterId__c = null;
        upsert chatterStorage;
        
        PageReference thisPage = ApexPages.currentPage();
        thisPage.setRedirect(true);
        return thisPage;
    }
}
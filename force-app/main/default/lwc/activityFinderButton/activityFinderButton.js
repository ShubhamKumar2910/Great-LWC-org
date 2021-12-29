import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import eventQuickSearchBtnLbl from '@salesforce/label/c.Event_Quick_Search';

export default class ActivityFinderButton extends NavigationMixin(LightningElement) 
{
    //Labels
    eventQuickSearchBtnLabel = eventQuickSearchBtnLbl;

    @api recordId;
    @api objectApiName;

    quickSearchActivities()
    {
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: 'c__activityFinderAura'
            },
            state: {
                c__recordId: this.recordId,
                c__objectApiName: this.objectApiName
            }
        });

        /*if(this.objectApiName === 'Account')
        {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__activityFinderAura'
                },
                state: {
                    c__accountId: this.recordId
                }
            });
        }
        else if(this.objectApiName === 'Contact') 
        {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__activityFinderAura'
                },
                state: {
                    c__contactId: this.recordId
                }
            });
        }
        else if(this.objectApiName === 'User')
        {
            this[NavigationMixin.Navigate]({
                type: 'standard__component',
                attributes: {
                    componentName: 'c__activityFinderAura'
                },
                state: {
                    c__userId: this.recordId
                }
            });
        }*/
        
    }    

}
/* eslint-disable no-console */
import { LightningElement, wire, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import waveAnalyticsDashboards from '@salesforce/label/c.Wave_Analytics_Dashboards';
import mgmtReportsLbl from '@salesforce/label/c.Mgmt_Reports';
import electronicTradingReportsLbl from '@salesforce/label/c.Electronic_Trading_Reports';
// import dashboardCrossSellTracker from '@salesforce/label/c.Cross_Sell_Tracker_Dashboard';
// import dashboardUserAdoption from '@salesforce/label/c.User_Adoption_Dashboard';
// import dashboardSalesROI from '@salesforce/label/c.Sales_ROI_Dashboard';
// import dashboardResearchROI from '@salesforce/label/c.Research_ROI_Dashboard';
// import dashboardResearchMonetization from '@salesforce/label/c.Research_Monetization';
import { NavigationMixin, CurrentPageReference  } from 'lightning/navigation';
import { registerListener, unregisterAllListeners, fireEvent } from 'c/pubsub';
import getExternalReportsForUserId from '@salesforce/apex/AUDController.getExternalReportsForUserId';
import getInternalReports from '@salesforce/apex/AUDController.getInternallReports';
import Id from '@salesforce/user/Id';

export default class WaveNavigationMenu extends NavigationMixin(LightningElement)  {
    @track powerBiReports;
    @track tableauReports;
    userIdValue = Id;
    menuItems = [];
    
    handleLoad() {
        // console.log('In handleLoad');
        getInternalReports()
            .then(result => {
                this.record = result;
                this.menuItems = this.record.map(row => ({
                    ...row,
                    id: row.report.Id,
                    folderName: row.report.Folder_Name__c,
                    dashboardLabel: row.report.Dashboard_Label__c,
                    dashboardName: row.report.Dashboard_Name__c
                  }));
                //   console.log('got results. size = '+ this.menuItems.length);
                  this.state.renderMenu = false;
                  this.menuItems.forEach(element => {
                    //   console.log('folder name '+ element.folderName);
                      if(this.state.userFolderPermissions.includes(element.folderName)) {
                          this.state.renderMenu = true;
                      }
                  });
                //   console.log('render menue '+ this.state.renderMenu)
          
            })
            .catch(error => {
                // console.log('did not get results');
                this.menuItems = undefined;
                const event = new ShowToastEvent ({
                    'title': 'Error Getting Einstein Analytic Dashboard names',
                    'message': error.body.message
                    });
                    this.dispatchEvent(event);
                });
    }
    // @wire(getInternalReports)
    // allEinsteinReportsToSurface({error, data}) {
    //     if (data) {
    //         this.record = data;
    //         this.menuItems = this.record.map(row => ({
    //             ...row,
    //             id: row.report.Id,
    //             folderName: row.report.Folder_Name__c,
    //             dashboardLabel: row.report.Dashboard_Label__c,
    //             dashboardName: row.report.Dashboard_Name__c
    //           }));
    //     } else if (error) {
    //         this.menuItems = undefined;
    //         const event = new ShowToastEvent({
    //             'title': 'Error Getting Einstein Analytic Dashboard names',
    //             'message': error.body.message
    //         });
    //         this.dispatchEvent(event);
    //     }
    // }

    @wire(CurrentPageReference) pageRef; // Required by pubsub
    analyticsLabel = waveAnalyticsDashboards;
    electronicTradingReportsLabel = electronicTradingReportsLbl;
    mgmtReportsLabel = mgmtReportsLbl;
    
    @track state = {};

    @wire(getExternalReportsForUserId,{userId: '$userIdValue', systemNameValue: 'Power BI'})
    wiredPowerBiReports({error, data}) {
        if (data) {
            this.powerBiReports = data;
        } else if (error) {
            this.powerBiReports = undefined;
            const event = new ShowToastEvent({
                'title': 'Error Getting External Report Links for Power BI',
                'message': error.body.message
            });
            this.dispatchEvent(event);
        }
    }

    @wire(getExternalReportsForUserId,{userId: '$userIdValue', systemNameValue: 'Tableau'})
    wiredTableauReports({error, data}) {
        if (data) {
            this.tableauReports = data;
        } else if (error) {
            this.tableauReports = undefined;
            const event = new ShowToastEvent({
                'title': 'Error Getting External Report Links for Tableau',
                'message': error.body.message
            });
            this.dispatchEvent(event);
        }
    }

    toggleWaveMenu(event) {
        this.toggleWaveMenuOnly(event);
        fireEvent(this.pageRef, 'navMenuToggleEvent', this);
    }

    toggleWaveMenuOnly(event) {
        var menus = this.template.querySelectorAll ('.slds-is-open');
        var i;
        // toggle currnet clicked menu
        //if the toggle event is coming from outside this virtual dom (say from a event we subscribe to)
        //then the current target will be undefined.
        if (typeof event.currentTarget !== 'undefined') {
            event.currentTarget.classList.toggle('slds-is-open');
        }
        // close all menus except currnely clicked
        for(i=0; i<menus.length; i++) {
            menus[i].classList.remove('slds-is-open');
        }

    }

    connectedCallback() {
        // subscribe to inputChangeEvent event
        registerListener('waveFolderSearchEvent', this.handleFolderSearchEvent, this);
        registerListener('waveNavMenuToggleEvent', this.toggleWaveMenuOnly, this);
    }

    disconnectedCallback() {
        // unsubscribe from inputChangeEvent event
        unregisterAllListeners(this);
    }

    handleFolderSearchEvent(inpVal) {
        this.state.userFolderPermissions = Array.from(inpVal);
        this.handleLoad();
        // this.state.renderMenu = false;
        // this.menuItems.forEach(element => {
        //     if(this.state.userFolderPermissions.includes(element.report.folderName)) {
        //         this.state.renderMenu = true;
        //     }
        // });
    }

    openWebPage(event)
    {
        var webPageURL = event.target.dataset.webpageurl;
        
        this[NavigationMixin.Navigate]({
            type: 'standard__webPage',
            attributes: {
                url: webPageURL
            }
        });
    }
    // navigateToTabPage(event) {
    //     // Navigate to a specific CustomTab.
    //     var customTab = event.target.dataset.customtab;
    //     console.log('tab name '+ customTab);
    //     this[NavigationMixin.Navigate]({
    //         type: 'standard__navItemPage',
    //         attributes: {
    //             // CustomTabs from managed packages are identified by their
    //             // namespace prefix followed by two underscores followed by the
    //             // developer name. E.g. 'namespace__TabName'
    //             apiName: customTab
    //         }
    //     });
    // }
    get renderMenu() {
        return this.state.renderMenu || (this.powerBiReports && this.powerBiReports.length>0) || (this.tableauReports && this.tableauReports.length>0);
    }

    get renderWaveMenu() {
        return this.state.renderMenu;
    }

    get renderPowerBIMenuItem() {
        return this.powerBiReports && this.powerBiReports.length>0;
    }

    get renderTableauMenuItem() {
        return this.tableauReports && this.tableauReports.length>0;
    }
    get userFolderPermissions() {
        return this.state.userFolderPermissions
    }

    get powerBIUrl() {
        return this.powerBIHost.data;
    }
}
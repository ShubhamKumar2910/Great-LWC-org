/* eslint-disable no-console */
import { LightningElement, api, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class WaveNavigationMenuItem extends NavigationMixin(LightningElement) {
    @api itemLabel;
    @api dashboardName;

    @track state = {};

    @api
    get folderName() {
        return this.state.folderName;
    }

    set folderName(value) {
        this.state.folderName = value;
        //check to see if userFolderPermissions has been updated and then fire method that controls visibility
        if (this.state.userFolderPermissions && !this.permissionsAreSet) {
            this.setItemVisibility();
            this.permissionsAreSet = true;
        }
    }

    @api 
    get userFolderPermissions() {
        return this.state.userFolderPermissions;
    }

    set userFolderPermissions(value) {
        this.state.userFolderPermissions = Array.from(value);
        if (!this.state.folderName) {
            this.permissionsAreSet = false;
            return;
        }
        this.setItemVisibility();
    }

    get renderItem() {
        return this.state.renderItem;
    }
    setItemVisibility() {
        this.state.renderItem = this.state.userFolderPermissions.includes(this.state.folderName);
    }

    openWaveComponent() {
        console.log("navigating to "+ this.dashboardName);
        this[NavigationMixin.Navigate]({
            type: 'standard__component',
            attributes: {
                componentName: "c__AnalyticsDisplay",
            },
            state: {
                "c__DashboardName": this.dashboardName
            }
        });
    }


}
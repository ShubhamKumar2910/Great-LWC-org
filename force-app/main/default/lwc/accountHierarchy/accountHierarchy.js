/* eslint-disable no-console */
import { LightningElement, track, wire, api } from 'lwc';
import HIERARCHY_NODE from '@salesforce/resourceUrl/HierarchyNode';
//import HIERARCHY_NODES from '@salesforce/resourceUrl/hierarchyNodes';

//import getRMAccountParentHierarchy from '@salesforce/apex/AccountHierarchyController.getRMAccountParentHierarchy';
import searchParentHierarchy from '@salesforce/apex/AccountHierarchyController.searchParentHierarchy';

export default class AccountHierarchy extends LightningElement {
    hierarchyNodeImg = HIERARCHY_NODE;
    //hierarchyNodeImg = HIERARCHY_NODES+'/images/node.png';
    //hierarchyEndNodeImg = HIERARCHY_NODES+'/images/endnode.png';

    // public properties
    @api height = 300;
    @api width = 300;

    @api rgAccCanExpand = false;
    
    //@api rgEntityName = null;
    rgEntitySrchStr = null;
    @api
    get rgEntityName() {
        return this.rgEntitySrchStr;
    }
    set rgEntityName(value) {
        this.isLoaded = false;
        this.rgEntitySrchStr = value;
    }
    @api rgEntityIdList = [];
    //@api rsEntityName = null;
    rsEntitySrchStr = null;
    @api
    get rsEntityName() {
        return this.rsEntitySrchStr;//this.rsEntityName === undefined ? null : this.rsEntityName;
    }
    set rsEntityName(value) {
        this.isLoaded = false;
        this.rsEntitySrchStr = value;
    }
    @api rsEntityNameOperator = 'AND';
    @api rsEntityIdList = [];
    @api includeInActive = false;

    
    @api
    resetRSHierarchySelection() {
        console.log('#### resetRSHierarchySelection : ');
        this.currentSelRSAccIndex = parseInt(this.currentSelRSAccIndex, 10);
        if(this.currentSelRSAccIndex !== -1) {
            this.setSelectionHelper('RS_ACC', this.currentSelRSAccIndex, -1); 
        }
    }

    @api
    resetRGHierarchySelection() {
        console.log('#### resetRGHierarchySelection : ');
        this.currentSelRGAccIndex = parseInt(this.currentSelRGAccIndex, 10);
        if(this.currentSelRGAccIndex !== -1) {
            this.currentSelRSAccIndex = parseInt(this.currentSelRSAccIndex, 10);
            this.setSelectionHelper('RG_ACC', this.currentSelRSAccIndex, this.currentSelRGAccIndex); 
        }
    }
        
    get sizeStyle() {
        return 'width:'+this.width+'px; height:'+this.height+'px;';
    }

    get innerSizeStyle() {
        return 'width:'+(parseInt(this.width, 10)+100)+'px; height:'+(parseInt(this.height, 10)+100)+'px;';
    }

    @track accData = [];
    currentSelRSAccIndex = -1;
    currentSelRGAccIndex = -1;
    currentSelRMAccIndex = -1;

    initializedFirstTime = false;
    @api 
    get initialRsAccId() {
        return this.currentSelRSAccId;
    }
    set initialRsAccId(value) {
        this.currentSelRSAccId = value;
        console.log('initialRsAccId : this.currentSelRSAccId : ',this.currentSelRSAccId);
        if(this.currentSelRSAccId) {
            this.initializedFirstTime = true;
        }
    }

    @api 
    get initialRgAccId() {
        return this.currentSelRGAccId;
    }
    set initialRgAccId(value) {
        this.currentSelRGAccId = value;
        console.log('initialRgAccId : this.currentSelRGAccId : ',this.currentSelRGAccId);
        if(this.currentSelRGAccIdcurrentSelRSAccId) {
            this.initializedFirstTime = true;
        }
    }

    currentSelRSAccId = null;
    currentSelRGAccId = null;

    @track isLoaded = false;
    get loaded() {
        return this.isLoaded;
    }

    get isDataEmpty() {
        return this.accData===null || this.accData===undefined || this.accData.length===0;
    }

    handleClick(event) {
        console.log('event : ',event);
    }

    handleRSAccExpColp(event) {
        console.log('#### handleRSAccExpColp()'); 
        const rsIndex = parseInt(event.currentTarget.dataset.rsaccIndex, 10);
        this.accData[rsIndex].isExpanded = !this.accData[rsIndex].isExpanded;
        this.accData[rsIndex].expColpBtnIcon = this.accData[rsIndex].isExpanded ? 'utility:dash' : 'utility:add'; 
    }

    handleSelectRSAccClick(event) {
        const rsIndex = parseInt(event.currentTarget.dataset.rsaccIndex, 10);
        this.setSelectionHelper('RS_ACC', rsIndex, -1); 
    }

    handleRGAccExpColp(event) {
        const rsIndex = parseInt(event.currentTarget.dataset.rsaccIndex, 10);
        const rgIndex = parseInt(event.currentTarget.dataset.rgaccIndex, 10);

        this.accData[rsIndex].childRGAccList[rgIndex].isExpanded = !this.accData[rsIndex].childRGAccList[rgIndex].isExpanded;
        this.accData[rsIndex].childRGAccList[rgIndex].expColpBtnIcon = this.accData[rsIndex].childRGAccList[rgIndex].isExpanded ? 
                'utility:dash' : 'utility:add'; 
    }

    handleSelectRGAccClick(event) {
        const rsIndex = parseInt(event.currentTarget.dataset.rsaccIndex, 10);
        const rgIndex = parseInt(event.currentTarget.dataset.rgaccIndex, 10);
        this.setSelectionHelper('RG_ACC', rsIndex, rgIndex/*, -1*/);
    }

    setSelectionHelper(accTypeSelToggled, rsIndex, rgIndex/*, rmIndex*/) {
        console.log('#### setSelectionHelper()');
        console.log('details: ',accTypeSelToggled, ' - ', rsIndex, ' , ',rgIndex);
        console.log('this.currentSelRSAccIndex : ', this.currentSelRSAccIndex);
        console.log('this.currentSelRGAccIndex : ', this.currentSelRGAccIndex);
        this.currentSelRSAccIndex = parseInt(this.currentSelRSAccIndex, 10);
        this.currentSelRGAccIndex = parseInt(this.currentSelRGAccIndex, 10);
        console.log('this.currentSelRSAccIndex : ', this.currentSelRSAccIndex);
        console.log('this.currentSelRGAccIndex : ', this.currentSelRGAccIndex);
        console.log('this.accData : ',this.accData);
        console.log('rsIndex===this.currentSelRSAccIndex : ',rsIndex===this.currentSelRSAccIndex);
        if(accTypeSelToggled==='RS_ACC') {
            console.log('RS_ACC match');
            console.log('this.accData[rsIndex].isSelected : ',this.accData[rsIndex].isSelected);
            this.accData[rsIndex].isSelected = !this.accData[rsIndex].isSelected;
            this.accData[rsIndex].selectedBtnIcon = this.accData[rsIndex].isSelected ? 'utility:check' : '';
            console.log('this.accData[rsIndex].isSelected : ',this.accData[rsIndex].isSelected);
            if(this.accData[rsIndex].isSelected) {
                console.log('seleted');
                if(this.currentSelRSAccIndex !== -1) {
                    console.log('current selected');
                    this.accData[this.currentSelRSAccIndex].isSelected = false;
                    this.accData[this.currentSelRSAccIndex].selectedBtnIcon = '';
                    // if previously RS was selcted then RG may or may not be selected
                    if(this.currentSelRGAccIndex !== -1) {
                        console.log('current rg indx sel');
                        this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].isSelected = false;
                        this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].selectedBtnIcon = '';
                    }
                }
                console.log('exiting rs cond');
                this.currentSelRSAccIndex = rsIndex;
            } else if(rsIndex===this.currentSelRSAccIndex) {
                console.log('rs acc to be unchecked');
                if(this.currentSelRGAccIndex !== -1) {
                    console.log('rg under it is selected');
                    this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].isSelected = false;
                    this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].selectedBtnIcon = '';
                }
                this.currentSelRSAccIndex = -1;
            }
            console.log('after current rs check');
            this.currentSelRGAccIndex = -1;
        } else if(accTypeSelToggled==='RG_ACC') {
            console.log('rg account condition');
            // set the RG level flags
            this.accData[rsIndex].childRGAccList[rgIndex].isSelected = 
                    !this.accData[rsIndex].childRGAccList[rgIndex].isSelected;
            this.accData[rsIndex].childRGAccList[rgIndex].selectedBtnIcon = 
                    this.accData[rsIndex].childRGAccList[rgIndex].isSelected ? 'utility:check' : '';

            if(this.accData[rsIndex].childRGAccList[rgIndex].isSelected) {
                console.log('rg already selected');
                this.accData[rsIndex].isSelected = true;
                this.accData[rsIndex].selectedBtnIcon = 'utility:check';
                if(this.currentSelRSAccIndex !== -1 && this.currentSelRSAccIndex !== rsIndex && 
                            this.accData[rsIndex].rsAccId !== this.accData[this.currentSelRSAccIndex].rsAccId) {
                    console.log('uncheck previous rg');
                    this.accData[this.currentSelRSAccIndex].isSelected = false;
                    this.accData[this.currentSelRSAccIndex].selectedBtnIcon = '';
                } // else indicates that different RG undetr same RS has been selected
                if(this.currentSelRGAccIndex !== -1 && 
                        this.accData[rsIndex].childRGAccList[rgIndex].rgAccId !== this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].rgAccId) {
                    console.log('uncheck if same rg unselected');
                    this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].isSelected = false;
                    this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].selectedBtnIcon = '';
                }

                console.log('exiting rg cond');
                this.currentSelRSAccIndex = rsIndex;
                this.currentSelRGAccIndex = rgIndex;
            } else if(rsIndex=== this.currentSelRSAccIndex && rgIndex===this.currentSelRGAccIndex){
                // To Do: - uncheck the RM - selection 
                console.log('if some other rg selected');
                this.currentSelRGAccIndex = -1;
            }
            
            
        }

        console.log('Before : ',this.currentSelRSAccId, '-',this.currentSelRGAccId);
        this.currentSelRSAccId = this.currentSelRSAccIndex !==-1 ? this.accData[this.currentSelRSAccIndex].rsAccId : null;
        this.currentSelRGAccId = this.currentSelRGAccIndex !==-1 ? 
                this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].rgAccId : null; 
        console.log('After : ',this.currentSelRSAccId, '-',this.currentSelRGAccId);
        //if(this.currentSelRSAccIndex === -1) {
        //    this.currentSelRSAccId = null;
        //}
        //if(this.currentSelRGAccIndex === -1) {
        //    this.currentSelRGAccId = null;
        //}

        console.log('exit: ',accTypeSelToggled, ' - ', rsIndex, ' - ',rgIndex);
        console.log('this.currentSelRSAccIndex : ', this.currentSelRSAccIndex);
        console.log('this.currentSelRGAccIndex : ', this.currentSelRGAccIndex);

        this.fireUpdateSelectedHierarchy();
    }

    fireUpdateSelectedHierarchy() {
         // Creates the event with the entity Ids.
         console.log('fireUpdateSelectedHierarchy');
         const updateHierarchyEvent = new CustomEvent('updatehierarchy', { detail: Object.assign(
                    { 
                        rsAccId: this.currentSelRSAccId, 
                        rsAccName: this.currentSelRSAccIndex !== -1 ? this.accData[this.currentSelRSAccIndex].rsAccObj.Name : null,
                        rgAccId: this.currentSelRGAccId,
                        rgAccName: this.currentSelRGAccIndex !== -1 ? 
                            this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].rgAccObj.Name : null
                    } 
                ) }
            );

         // Dispatches the event.
         this.dispatchEvent(updateHierarchyEvent);
        
    }

    @wire(searchParentHierarchy, { rgEntityName: '$rgEntityName', RGEntityIdList: '$rgEntityIdList', rsEntityName: '$rsEntityName', 
            rsEntityNameOperator: '$rsEntityNameOperator', RSEntityIdList: '$rsEntityIdList', includeInActive: '$includeInActive' })
        wiredSearchParentHierarchy({ error, data }) {
            if(data) { 
                console.log('#### wiredSearchParentHierarchy');

                let previouslySelected = (this.currentSelRSAccIndex !== -1 || this.currentSelRGAccIndex !== -1 || this.initializedFirstTime);
                console.log('previouslySelected : ',previouslySelected);
                this.initializedFirstTime = false;
                /*if(this.currentSelRSAccIndex !== -1) {
                    if(this.currentSelRGAccIndex!==-1) {
                        this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].isSelected = false;
                        this.accData[this.currentSelRSAccIndex].childRGAccList[this.currentSelRGAccIndex].selectedBtnIcon = '';
                    }
                    this.accData[this.currentSelRSAccIndex].isSelected = false;
                    this.accData[this.currentSelRSAccIndex].selectedBtnIcon = '';
                }*/

                this.currentSelRSAccIndex = -1;
                this.currentSelRGAccIndex = -1;
                this.currentSelRMAccIndex = -1;
                let isRSSelected = false, rsIdFound = false, isRGSelected = false, rgIdFound = false;
                this.accData = data.map(
                    (oRSAcc, rsIndex) => {
                        isRSSelected = false;
                        if(previouslySelected && !rsIdFound && this.currentSelRSAccId && this.currentSelRSAccId === oRSAcc.Id) {
                            isRSSelected = true;
                            this.currentSelRSAccIndex = rsIndex;
                            rsIdFound = true;
                            console.log('found : RS Account');
                            console.log('isRSSelected : ',isRSSelected);
                        }
                        return Object.assign(
                            {
                                rsAccId: oRSAcc.Id,
                                rsAccURL: '/' + oRSAcc.Id,
                                isExpanded: true,
                                expColpBtnIcon: 'utility:dash',
                                isSelected: isRSSelected,
                                selectedBtnIcon: isRSSelected ? 'utility:check' : '',
                                rsAccObj: {
                                    Id: oRSAcc.Id,
                                    Name: oRSAcc.Name,
                                    Active__c: oRSAcc.Active__c
                                },
                                childRGAccList: ( (oRSAcc.ChildAccounts === undefined || oRSAcc.ChildAccounts === null) ? [] :
                                    oRSAcc.ChildAccounts.map(
                                        (oRGAcc, rgIndex) => {
                                            isRGSelected = false;
                                            if(previouslySelected && rsIdFound && !rgIdFound && this.currentSelRGAccId && this.currentSelRGAccId === oRGAcc.Id) {
                                                isRGSelected = true;
                                                this.currentSelRGAccIndex = rgIndex;
                                                rgIdFound = true;
                                                console.log('found : RG Account');
                                            }
                                            return Object.assign(
                                                {
                                                    rgAccId: oRGAcc.Id,
                                                    rgAccURL: '/' + oRGAcc.Id,
                                                    canRgAccExpand: this.rgAccCanExpand,
                                                    isExpanded: false,
                                                    expColpBtnIcon: 'utility:add',
                                                    isSelected: isRGSelected,
                                                    selectedBtnIcon: isRGSelected ? 'utility:check' : '',
                                                    rgAccObj: {
                                                        Id: oRGAcc.Id,
                                                        Name: oRGAcc.Name,
                                                        Active__c: oRGAcc.Active__c
                                                    }
                                                },
                                                oRGAcc
                                            )
                                        }
                                    )
                                )
                            },
                            oRSAcc
                        )
                    }
                );

                
                let notifyUpdate = false;
                if(previouslySelected && this.currentSelRSAccIndex === -1) {
                    this.currentSelRSAccId = null;
                    notifyUpdate = true;
                }
                if(previouslySelected && this.currentSelRGAccIndex === -1) {
                    this.currentSelRGAccId = null;
                    notifyUpdate = true;
                }
                console.log('Exit -> wiredSearchParentHierarchythis : currentSelRSAccIndex : ',this.currentSelRSAccIndex);
                console.log('Exit -> wiredSearchParentHierarchythis : currentSelRGAccIndex : ',this.currentSelRGAccIndex);
                
                //this.currentSelRGAccIndex = -1;
                if(notifyUpdate) {
                    this.fireUpdateSelectedHierarchy();
                }
                // To-Do : if previously any of current RS or RG Id was non-null and now it is null then fire the cange event for parent component
            } else if (error) {
                console.log('error : ',error);
            }
            this.isLoaded = true;
            this.dispatchEvent(new CustomEvent('loadcomplete'));
            console.log('this.accData : ',this.accData);
        }


/* 
        @wire(searchParentHierarchy, { rgEntityName: '$rgEntityName', RGEntityIdList: '$rgEntityIdList', rsEntityName: '$rsEntityName', RSEntityIdList: '$rsEntityIdList', includeInActive: '$includeInActive' })
        wiredSearchParentHierarchy({ error, data }) {
            if(data) { 
                console.log('#### wiredSearchParentHierarchy');
                console.log('returned data : ',data);
                this.currentSelRSAccIndex = null;
                this.currentSelRGAccIndex = null;
                this.currentSelRMAccIndex = null;
                this.accData = data.map(
                    oRSAcc => Object.assign(
                        {
                            rsAccId: oRSAcc.Id,
                            rsAccURL: '/' + oRSAcc.Id,
                            isExpanded: true,
                            expColpBtnIcon: 'utility:dash',
                            isSelected: false,
                            selectedBtnIcon: '', 
                            rsAccObj: {
                                Id: oRSAcc.Id,
                                Name: oRSAcc.Name,
                                Active__c: oRSAcc.Active__c
                            },
                            childRGAccList: ( (oRSAcc.ChildAccounts === undefined || oRSAcc.ChildAccounts === null) ? [] :
                                oRSAcc.ChildAccounts.map(
                                    oRGAcc => Object.assign(
                                        {
                                            rgAccId: oRGAcc.Id,
                                            rgAccURL: '/' + oRGAcc.Id,
                                            canRgAccExpand: this.rgAccCanExpand,
                                            isExpanded: false,
                                            expColpBtnIcon: 'utility:add',
                                            isSelected: false,
                                            rgAccObj: {
                                                Id: oRGAcc.Id,
                                                Name: oRGAcc.Name,
                                                Active__c: oRGAcc.Active__c
                                            }
                                        },
                                        oRGAcc
                                    )
                                )
                            )
                        },
                        oRSAcc
                    )
                );
            } else if (error) {
                console.log('error : ',error);
            }
            console.log('this.accData : ',this.accData);
            this.isLoaded = true;
            this.dispatchEvent(new CustomEvent('loadcomplete'));
        }
*/


    /*@wire(getRMAccountParentHierarchy, { rmEntityName: null, RMEntityIdList: '$defaultRmAccList', includeActive: true})
    wiredRMAccountParentHierarchy({ error, data }) {    
        console.log('#### wiredRMAccountParentHierarchy');
        if (data) { 
            console.log('returned data : ',data);
            this.accData = data.map(
                oRSAcc => Object.assign(
                    {
                        rsAccId: oRSAcc.Id,
                        rsAccURL: '/' + oRSAcc.Id,
                        isExpanded: true,
                        expColpBtnIcon: 'utility:dash',
                        isSelected: false,
                        selectedBtnIcon: '', 
                        rsAccObj: {
                            Id: oRSAcc.Id,
                            Name: oRSAcc.Name,
                            Active__c: oRSAcc.Active__c
                        },
                        childRGAccList: oRSAcc.ChildAccounts.map(
                            oRGAcc => Object.assign(
                                {
                                    rgAccId: oRGAcc.Id,
                                    rgAccURL: '/' + oRGAcc.Id,
                                    canRgAccExpand: this.rgAccCanExpand,
                                    isExpanded: false,
                                    expColpBtnIcon: 'utility:add',
                                    isSelected: false,
                                    rgAccObj: {
                                        Id: oRGAcc.Id,
                                        Name: oRGAcc.Name,
                                        Active__c: oRGAcc.Active__c
                                    }
                                },
                                oRGAcc
                            )
                        )
                    },
                    oRSAcc
                )
            );
        } else if (error) {
            console.log('error : ',error);
        }
        console.log('this.accData : ',this.accData);
        this.isLoaded = true;
    }*/
}

/*
const accData = [
    {
        rsAccId: '001dsffsfsfsdfdsf',
        isExpanded: true,
        expColpBtnIcon: 'utility:dash',
        isSelected: false,
        selectedBtnIcon: '',
        rsAccObj: {
            Name: 'BLACKROCK (S)'
        },
        childRGAccList: [
            {
                rgAccId: '001fsdfdsfdsfds',
                canRGAccExpand: true,
                isExpanded: false,
                expColpBtnIcon: 'utility:add',
                isSelected: false,
                rgAccObj: {
                    Name: 'BLACKROCK (G)'
                },
                childRMAccList: [
                    {
                        rgAccId: '001aadadaeefff',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK UK'
                        }
                    },
                    {
                        rgAccId: '001aadadaeefed',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK US'
                        }
                    },
                    {
                        rgAccId: '001aadadaeefsx',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK JPN'
                        }
                    }
                ]
            },
            {
                rgAccId: '001fsdfdsfdsscvh',
                canRGAccExpand: true,
                isExpanded: true,
                expColpBtnIcon: 'utility:dash',
                isSelected: false,
                rgAccObj: {
                    Name: 'BLACKROCK 2 (G)'
                },
                childRMAccList: [
                    {
                        rgAccId: '001aadadaeefff',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK UK'
                        }
                    },
                    {
                        rgAccId: '001aadadaeefed',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK US'
                        }
                    },
                    {
                        rgAccId: '001aadadaeefsx',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK JPN'
                        }
                    }
                ]
            }
        ]
    },






    {
        rsAccId: '001dsffsfsfsdssxksss',
        isExpanded: true,
        expColpBtnIcon: 'utility:dash',
        isSelected: false,
        selectedBtnIcon: '',
        rsAccObj: {
            Name: 'BLACKROCK (S)'
        },
        childRGAccList: [
            {
                rgAccId: '001fsdfdsfdsfds',
                canRGAccExpand: true,
                isExpanded: false,
                expColpBtnIcon: 'utility:add',
                isSelected: false,
                rgAccObj: {
                    Name: 'BLACKROCK (G)'
                },
                childRMAccList: [
                    {
                        rgAccId: '001aadadaeefff',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK UK'
                        }
                    },
                    {
                        rgAccId: '001aadadaeefed',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK US'
                        }
                    },
                    {
                        rgAccId: '001aadadaeefsx',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK JPN'
                        }
                    }
                ]
            },
            {
                rgAccId: '001fsdfdsfdsscvh',
                canRGAccExpand: true,
                isExpanded: true,
                expColpBtnIcon: 'utility:dash',
                isSelected: false,
                rgAccObj: {
                    Name: 'BLACKROCK 2 (G)'
                },
                childRMAccList: [
                    {
                        rgAccId: '001aadadaeefff',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK UK'
                        }
                    },
                    {
                        rgAccId: '001aadadaeefed',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK US'
                        }
                    },
                    {
                        rgAccId: '001aadadaeefsx',
                        isSelected: false,
                        selectedBtnIcon: 'utility:check',
                        rmAccObj: {
                            Name: 'BLACKROCK JPN'
                        }
                    }
                ]
            }
        ]
    }
];
*/
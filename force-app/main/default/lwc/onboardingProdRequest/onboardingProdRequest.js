/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';

import loadOnbReqWithOnbProds from '@salesforce/apex/OnboardingReqAndProdController.loadOnbReqWithOnbProds';

const existingProdStatusCols = [
    { label: 'Product Catagory', fieldName: 'prodCatagory', iconName: 'standard:product', initialWidth: 270},
    { label: 'Product Type', fieldName: 'prodType', iconName: 'standard:product_item', initialWidth: 270},
    { label: 'Nomura Entity', fieldName: 'nomuraEntity', iconName: 'standard:entity', initialWidth: 450},
    { label: 'Status', fieldName: 'status', type: 'text', cellAttributes: { iconName: { fieldName: 'icon' }  , iconAlternativeText: { fieldName: 'iconAltTxt' }}, initialWidth: 160} 
];

const newOnbProdReqCols = [
    { label: 'Product Catagory', fieldName: 'prodCatagory', iconName: 'standard:product', initialWidth: 270},
    { label: 'Product Type', fieldName: 'prodType', iconName: 'standard:product_item', initialWidth: 270},
    { label: 'Nomura Entity', fieldName: 'nomuraEntity', iconName: 'standard:entity', initialWidth: 450},
    { label: 'Priority', fieldName: 'priority', type: 'text', initialWidth: 160} 
];

export default class OnboardingProdRequest extends LightningElement {

    @api rmAccId = '';
    @api reqId = '';

    @track existingProdStatusCols = existingProdStatusCols;
    @track existingProdStatusData = [];

    @track newOnbProdReqCols = newOnbProdReqCols;
    @track newOnbProdReqData = [];

    @track showObProdForm = false;

    handleAddClick() {
        console.log('#### handleAddClick()');
        this.showObProdForm = true;
    } 

    closeProductForm() {
        console.log('#### handleAddClick()');
        this.showObProdForm = false;
    }

    @wire(loadOnbReqWithOnbProds, { rmAccId: '$rmAccId', reqId: '$reqId'})
    wiredLoadOnbReqWithOnbProds({ error, data }) {
        console.log('#### wiredLoadOnbReqWithOnbProds() : ', this.rmAccId,',',this.reqId);
        console.log(this.onbProdCols);
        console.log(this.onbProdData);
        if (data) { 
            console.log('data: ',data);
            this.existingProdStatusData = [];
            let row1 = {
                Id: '1',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA INTERNATIONAL (HONG KONG) LIMITED (NIHK)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            };
            this.existingProdStatusData.push(row1);

            let row2 = {
                Id: '2',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'COMPLETED',
                icon : 'utility:check',
                iconAltTxt : 'COMPLETED'
            };
            this.existingProdStatusData.push(row2);

            let row3 = {
                Id: '3',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA INVESTMENT SINGAPORE PTE LIMITED (NISP)',
                status : 'CANCELLED',
                icon : 'utility:error',
                iconAltTxt : 'CANCELLED'
            };
            this.existingProdStatusData.push(row3);

            let row4 = {
                Id: '4',
                prodCatagory : 'Cash',
                prodType : 'Fixed Income Cash',
                nomuraEntity : 'NOMURA SPECIAL INVESTMENTS SINGAPORE PTE LIMITED (NSIS)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            };
            this.existingProdStatusData.push(row4);

            let row5 = {
                Id: '5',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            };
            this.existingProdStatusData.push(row5);

            this.existingProdStatusData.push({
                Id: '6',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            this.existingProdStatusData.push({
                Id: '7',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            this.existingProdStatusData.push({
                Id: '8',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            this.existingProdStatusData.push({
                Id: '9',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            this.existingProdStatusData.push({
                Id: '10',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            this.existingProdStatusData.push({
                Id: '11',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            this.existingProdStatusData.push({
                Id: '12',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            this.existingProdStatusData.push({
                Id: '13',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });
            this.existingProdStatusData.push({
                Id: '14',
                prodCatagory : 'Credit Default Swap (CDS) Derivatives',
                prodType : 'Index CDS (Broad-based & cash-settled)',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                status : 'IN PROGRESS',
                icon : 'utility:macros',
                iconAltTxt : 'IN PROGRESS'
            });



            this.newOnbProdReqData = [];
            this.newOnbProdReqData.push({
                Id: '1',
                prodCatagory : 'Loans',
                prodType : 'Primary Loan',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                priority : 'Urgent - Imminent and materially significant trade'
            });

            this.newOnbProdReqData.push({
                Id: '2',
                prodCatagory : 'Securitized Products',
                prodType : 'Specified Pool Transactions',
                nomuraEntity : 'NOMURA INTERNATIONAL FUNDING PTE LIMITED (NIF)',
                priority : 'Urgent - Imminent and materially significant trade'
            });

            this.newOnbProdReqData.push({
                Id: '3',
                prodCatagory : 'Securitized Products',
                prodType : 'Specified Pool Transactions',
                nomuraEntity : 'NOMURA SINGAPORE LIMITED (NSL)',
                priority : 'Urgent - Imminent and materially significant trade'
            });

            this.newOnbProdReqData.push({
                Id: '4',
                prodCatagory : 'India Offshore Derivative Instruments (ODI)',
                prodType : 'P-Note',
                nomuraEntity : 'NOMURA ALTERNATIVE INVESTMENT MANAGEMENT FRANCE S.A.S. (NAIMF)',
                priority : 'BAU'
            });

            this.newOnbProdReqData.push({
                Id: '5',
                prodCatagory : 'India Offshore Derivative Instruments (ODI)',
                prodType : 'P-Note',
                nomuraEntity : 'NOMURA EUROPE FINANCE NV (NEF)',
                priority : 'BAU'
            });

            this.newOnbProdReqData.push({
                Id: '6',
                prodCatagory : 'India Offshore Derivative Instruments (ODI)',
                prodType : 'P-Note',
                nomuraEntity : 'NOMURA AMERICAS RE LIMITED (NARL)',
                priority : 'BAU'
            });
            
        } else if (error) {
            console.log('error : ',error);
        }
        //this.showSearching = false;
        this.showSearchingRmEntityInRDM = false;
    }
}
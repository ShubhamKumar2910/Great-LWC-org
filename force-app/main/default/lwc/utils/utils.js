import pendingRGCoverageRequest from '@salesforce/apex/CoverageControllerLWC.pendingRGCoverageRequest';
import pendingRMCoverageRequest from '@salesforce/apex/CoverageControllerLWC.pendingRMCoverageRequest';
import approvedCoverageRequest from '@salesforce/apex/CoverageControllerLWC.approvedCoverageRequest';
import fetchPODsParentApprovedCvgReq from '@salesforce/apex/CoverageControllerLWC.fetchPODsParentApprovedCvgReq';
import fetchPODsParentPendingCvgReq from '@salesforce/apex/CoverageControllerLWC.fetchPODsParentPendingCvgReq';
import fetchRMAccountByPOD from '@salesforce/apex/CoverageControllerLWC.fetchRMAccountByPOD';
import fetchRGAccount from '@salesforce/apex/CoverageControllerLWC.fetchRGAccount';
import fetchRMAccount from '@salesforce/apex/CoverageControllerLWC.fetchRMAccount';

//Labels
import pendingRelatedAccOnPODRequest from '@salesforce/label/c.Related_Account_pending_for_approval_on_POD_request';
import coverRelatedAccOnPODRequest from '@salesforce/label/c.Cover_related_account_on_POD_request';
import approvedCvgPresent from '@salesforce/label/c.You_already_have_the_requested_coverage';
import pendingCvgPresent from '@salesforce/label/c.Your_requested_coverage_is_pending_for_approval';
import cannotAddInstinetSalescodeRequest from '@salesforce/label/c.Cannot_add_Instinet_salescode_request';

let productsWithRegionsToIncludeForInstinet = ['content - asia', 'futures - asia', 'content - japan', 'futures - japan', 'nes - cash - asia', 'nes - ets - asia', 'nes - pt - asia', 'nes - cash - japan', 'nes - ets - japan', 'nes - pt - japan', 'prime finance - usa', 'prime finance - europe', 'prime finance - asia', 'prime finance - japan'];

export async function coverageServerSideValidation(data, rgAccountIdList, rmAccountIdList, salespersonIdList, groupBy){
    //groupBy - from UI only one type of GroupBy request can be sent to server side validation on click of apply.so groupBy from UI at any point in time will have only 1 value..but what about from BULK upload. It can fail
    let productName_key = '';
    let productGroup_key = '';
    let productRegion_key = '';
    let pending_coverages = new Set();
    let existing_coverages = new Set();
    let pendingParent_coverages = new Set();
    let existingParent_coverages = new Set();
    let hierarchyMaintenance = new Map();
    let podAccountIdList = [];
    let pod_rgAccountIdList = [];
    let dataTemp_rmMaintenance = [];
    let dataTemp_rgMaintenance = [];

    console.log('rgAccountIdList: ' + rgAccountIdList);
    console.log('rmAccountIdList: ' + rmAccountIdList);
    console.log('salespersonIdList: ' + salespersonIdList);
    console.log('groupBy: ' + groupBy);

    //fetch pending data from RG_Coverage_Request__c and coverage_Access_Request__c
    //TODO: Check if rgAccountIdList != '' and then query | else if empty query is called - no use
    if(groupBy.toLowerCase() !== 'pod'){
        await new Promise(async (resolve) => {
            let results = await pendingRGCoverageRequest({ rgAccountIds: rgAccountIdList, salesTeamCodeIds: salespersonIdList, status: 'Pending Approval' });
            resolve(results);
        }).then(function (results) {
            console.log('Pending RG Coverage result data length: ' + results.length);
            if (results.length > 0) {
                results.forEach(request => {

                    let rgkey = '';
                    let product = '';
                    let productGrp = '';
                    let productRegion = '';

                    if (request.Product__c !== null && request.Product__c !== undefined) {
                        product = request.Product__c.substring(0, request.Product__c.lastIndexOf('-')).trim();
                        productRegion = request.Product__c.substring(request.Product__c.lastIndexOf('-') + 1).trim();
                    }
                    if (request.Product_Group__c !== null && request.Product_Group__c !== undefined) {
                        productGrp = request.Product_Group__c.trim();
                    }

                    if (product !== '' && productRegion !== '' && productGrp !== '') {
                        rgkey = request.RG_Account__c + '#' + request.Sales_Team_for_Coverage__c + '#' + productRegion + '#' + productGrp + '#' + product;
                    } else {
                        rgkey = request.RG_Account__c + '#' + request.Sales_Team_for_Coverage__c;
                    }
                    pending_coverages.add(rgkey);
                    hierarchyMaintenance.set(rgkey, request.Group_By__c);
                })
                console.log('Pending RG Coverage results: ' + JSON.stringify(results));
            }
        })
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            })
    }

    await new Promise(async (resolve) => {
        let results = await pendingRMCoverageRequest({ rmAccountIds: rmAccountIdList, salesTeamCodeIds: salespersonIdList, status: 'Pending Approval' })
        resolve(results);
    }).then(function (results) {
        console.log('Pending RM Coverage result data length: ' + results.length);
        if (results.length > 0) {
            results.forEach(request => {

                let rmkey = '';
                let rgkey = '';
                let product = '';
                let productGrp = '';
                let productRegion = '';

                if (request.Product__c !== null && request.Product__c !== undefined) {
                    product = request.Product__c.substring(0, request.Product__c.lastIndexOf('-')).trim();
                    productRegion = request.Product__c.substring(request.Product__c.lastIndexOf('-') + 1).trim();
                }
                if (request.Product_Group__c !== null && request.Product_Group__c !== undefined) {
                    productGrp = request.Product_Group__c.trim();
                }

                if (product !== '' && productRegion !== '' && productGrp !== '') {
                    rmkey = request.Account__c + '#' + request.Sales_Team_for_Coverage__c + '#' + productRegion + '#' + productGrp + '#' + product;
                    if(!request.Account__r.Restricted_Flag__c){
                        rgkey = request.Account__r.ParentId + '#' + request.Sales_Team_for_Coverage__c + '#' + productRegion + '#' + productGrp + '#' + product;
                        hierarchyMaintenance.set(rgkey, request.Group_By__c);
                    }
                } else {
                    rmkey = request.Account__c + '#' + request.Sales_Team_for_Coverage__c;
                }
                pending_coverages.add(rmkey);
                pending_coverages.add(rgkey);
            })
            console.log('Pending RM Coverage results: ' + JSON.stringify(results));
        }
    })
        .catch(error => {
            console.log('Error: ' + JSON.stringify(error));
        })

    console.log('pending_Coverages Size: ' + pending_coverages.size);
    console.log('hierarchyMaintenance size: ' + hierarchyMaintenance.size);

    await new Promise(async (resolve) => {
        let results = await approvedCoverageRequest({ rmAccountIds: rmAccountIdList, salesTeamCodeIds: salespersonIdList })
        resolve(results);
    }).then(function (results) {
        console.log('Approved Coverage result data length: ' + results.length);
        if (results.length > 0) {
            results.forEach(request => {

                let rmkey = '';
                let rgkey = ''
                let product = '';
                let productGrp = '';
                let productRegion = '';

                if (request.Product2__c !== null && request.Product2__c !== undefined)
                    product = request.Product2__c.trim();
                if (request.Product_Group__c != null && request.Product_Group__c !== undefined)
                    productGrp = request.Product_Group__c.trim();
                if (request.Product_Region__c != null && request.Product_Region__c !== undefined)
                    productRegion = request.Product_Region__c.trim();

                //if(request.Account__r.Restricted_Flag__c){
                //setting all key with respect to RM for all the record irrespective of the Restrcited Account
                //because when toggle is at RG and SP maintains at RM level then with current current key is set with RG account for unrestricted but here we wanted key with RM account
                //so as both restricted and unrestricted need key at RM level we made it come and inserted one key with RG acccount when toggle and SP both are rg
                if (product !== '' && productGrp !== '' && productRegion !== '') {
                    rmkey = request.Account__c + '#' + request.Sales_Team_for_Coverage__c + '#' + productRegion + '#' + productGrp + '#' + product;
                    if (!request.Account__r.Restricted_Flag__c) {
                        rgkey = request.Account__r.ParentId + '#' + request.Sales_Team_for_Coverage__c + '#' + productRegion + '#' + productGrp + '#' + product;
                    }
                } else {
                    rmkey = request.Account__c + '#' + request.Sales_Team_for_Coverage__c;
                    if (request.Group_By__c.toLowerCase() === 'rg' && !request.Account__r.Restricted_Flag__c) {
                        rgkey = request.Account__r.ParentId + '#' + request.Sales_Team_for_Coverage__c;
                    }
                }
                /*}else{
                    if (product !== '' && productGrp !== '' && productRegion !== '') {
                        key = request.Account__r.ParentId + '#' + request.Sales_Team_for_Coverage__c + '#' + productRegion + '#' + productGrp + '#' + product;
                    } else {
                        key = request.Account__r.ParentId + '#' + request.Sales_Team_for_Coverage__c;
                    }
                }*/
                existing_coverages.add(rmkey);
                existing_coverages.add(rgkey);
                hierarchyMaintenance.set(rgkey, request.Group_By__c);
            })
            console.log('Approved Coverage results: ' + JSON.stringify(results));
        }
    })
        .catch(error => {
            console.log('Error: ' + JSON.stringify(error));
        })

    console.log('existing_coverages: ' + existing_coverages.size);
    console.log('hierarchyMaintenance size: '+hierarchyMaintenance.size);

    await new Promise(async (resolve) => {
        let results = await fetchPODsParentApprovedCvgReq({ rgAccountIds: rgAccountIdList, salesTeamCodeIds: salespersonIdList })
        resolve(results);
    }).then(function (results) {
        console.log('Approved PODs Parent Coverage result data length: ' + results.length);
            if (results.length > 0) {
                results.forEach(request => {
                    existingParent_coverages.add(request);
                })
            }
        })
        .catch(error => {
            console.log('Error: ' + JSON.stringify(error));
        })

    console.log('existingParent_coverages: ' + existingParent_coverages.size);

    await new Promise(async (resolve) => {
        let results = await fetchPODsParentPendingCvgReq({ rgAccountIds: rgAccountIdList, salesTeamCodeIds: salespersonIdList })
        resolve(results);
    }).then(function (results) {
        console.log('Pending PODs Parent Coverage result data length: ' + results.length);
        if (results.length > 0) {
            results.forEach(request => {
                pendingParent_coverages.add(request);
            })
        }
    })
        .catch(error => {
            console.log('Error: ' + JSON.stringify(error));
        })

    console.log('pendingParent_coverages: ' + pendingParent_coverages.size);

    data.forEach(record => {
        if (!record.isRecordValidated){
            let error_msg = '';
            console.log('Server side validation: ' + JSON.stringify(record));

            if (record.productRegion !== null) {
                productRegion_key = record.productRegion;
            }
            if (record.productGroup !== null) {
                productGroup_key = record.productGroup;
            }
            if (record.product !== null) {
                productName_key = record.product;
            }

            if (record.salesTeamForCvgRecord.Coverage_ID__c !== null && record.salesTeamForCvgRecord.Coverage_ID__c !== '') {
                let productWithRegion = '';
                let showValidation = true;

                if (productName_key !== '' && productRegion_key !== '') {
                    productWithRegion = productName_key.toLowerCase() + ' - ' + productRegion_key.toLowerCase();
                }
                console.log('ProductWithRegion: ' + productWithRegion);

                if (productWithRegion !== '' && productsWithRegionsToIncludeForInstinet.includes(productWithRegion)) {
                    showValidation = false;
                    console.log('Instinet');
                }
                console.log('getProductWithRegionForInstinet: ' + productsWithRegionsToIncludeForInstinet.includes(productWithRegion));
                console.log(record.salesTeamForCvgRecord.Company__c + ' ' + showValidation);
                if (record.salesTeamForCvgRecord.Company__c === 'I' && showValidation) {
                    if (error_msg === '') {
                        error_msg = cannotAddInstinetSalescodeRequest;
                    } else {
                        error_msg += ', ' + cannotAddInstinetSalescodeRequest;
                    }
                }
            }

            let primaryKey = record.uniqueId;
            let primaryKeyMap = primaryKey.split('#');
            let parentPrimaryKey = primaryKey.replace(record.accountRecord.Id, record.accountRecord.ParentId);
            console.log('Account Id: '+record.accountRecord.Id);
            console.log('Account Parent Id: ' + record.accountRecord.ParentId);
            console.log('Primary Key: '+primaryKey);
            console.log('Parent Primary Key: ' + parentPrimaryKey);

            console.log('hierarchyMaintenance: **' + hierarchyMaintenance.get(primaryKey));
            console.log('pending_coverages.has(primaryKey): ' + pending_coverages.has(primaryKey));
            console.log('existing_coverages.has(primaryKey): ' + existing_coverages.has(primaryKey));

            if (existing_coverages.has(primaryKey) && (groupBy.toLowerCase() === 'rm' || groupBy.toLowerCase() === 'pod' || (groupBy.toLowerCase() === 'rg' && record.accountRecord.Restricted_Flag__c) || hierarchyMaintenance.get(primaryKey).toLowerCase() === 'rg')) {
                if (error_msg === '') {
                    error_msg = approvedCvgPresent;
                } else {
                    error_msg += ', ' + approvedCvgPresent;
                }
            } else {
                if (primaryKeyMap.length === 2) {
                    let requestKey;
                    for (requestKey of existing_coverages) {
                        if (requestKey.includes(primaryKey)) {
                            if (error_msg === '') {
                                error_msg = approvedCvgPresent;
                            } else {
                                error_msg += ', ' + approvedCvgPresent;
                            }
                            break;
                        }
                    }
                }
            }

            //when with/without product key matches exactly with respective with/without key of the new record
            if (!error_msg.includes(approvedCvgPresent) && ((pending_coverages.has(primaryKey) && (groupBy.toLowerCase() === 'rm' || groupBy.toLowerCase() === 'pod' || (groupBy.toLowerCase() === 'rg' && record.accountRecord.Restricted_Flag__c) || hierarchyMaintenance.get(primaryKey).toLowerCase() === 'rg')) || (pending_coverages.has(parentPrimaryKey) && groupBy.toLowerCase() === 'rm'))) {
                if (error_msg === '') {
                    error_msg = pendingCvgPresent;
                } else {
                    error_msg += ', ' + pendingCvgPresent;
                }
            } else {
                //when there is a record with product in DB and a new entry without product for same SP and Acc comes then show error
                //when there is a record without product in DB and a new entry with product for same SP and Acc comes then show no error....allow it to save (it will then update without product record with products)
                if (primaryKeyMap.length === 2) {
                    let requestKey;
                    for (requestKey of pending_coverages) {
                        if (!error_msg.includes(approvedCvgPresent) && (requestKey.includes(primaryKey) || (requestKey.includes(parentPrimaryKey) && groupBy.toLowerCase() === 'rm'))) {
                            if (error_msg === '') {
                                error_msg = pendingCvgPresent;
                            } else {
                                error_msg += ', ' + pendingCvgPresent;
                            }
                            break;
                        }
                    }
                }
            }

            //to check if POD Account's RG has atleast one coverage, only then allow POD to give coverage
            //show this validation only when there are no other validation for the record
            if (groupBy.toLowerCase() === 'pod') {
                if (!existingParent_coverages.has(record.accountRecord.ParentId)) {
                    //When PODs RM/RG is pending for approval, the related RM/RG are not auto added, but POD is allowed to be submmitted
                    if(pendingParent_coverages.has(record.accountRecord.ParentId)){
                        if (error_msg === '') {
                            error_msg = pendingRelatedAccOnPODRequest;
                            record.isPODCoverageError = true;
                        }
                    }else{
                        if (error_msg === '') {
                            //When there is no RM/RG pending request OR RM/RG is approved, PODs related RM/RG are auto added with POD request
                            error_msg = coverRelatedAccOnPODRequest;
                            record.isPODCoverageError = true;
                            let salespersonMaintenanceLevel = record.salesTeamForCvgRecord.Coverage_Maintenance_Level__r.Sales_Client_Hierarchy_Level__c.toLowerCase();
                            if(salespersonMaintenanceLevel === 'rm'){
                                dataTemp_rmMaintenance.push(record);
                                podAccountIdList.push(record.accountRecord.Id); // check with Set
                            }else if(salespersonMaintenanceLevel === 'rg'){
                                pod_rgAccountIdList.push(record.accountRecord.ParentId);
                                dataTemp_rgMaintenance.push(record);
                            }
                        }
                    }
                }
            }

            record.validation = error_msg;
            record.isRecordValidated = true;
        }
    })

    if (podAccountIdList.length > 0){
        //add related RM to bucket 
        let relatedRMs = [];
        await new Promise(async (resolve) => {
            let results = await fetchRMAccountByPOD({ podAccountIds: podAccountIdList })
            resolve(results);
        }).then(function (results) {
            console.log('Related RM to POD: ' + JSON.stringify(results));
            if (results) {
                dataTemp_rmMaintenance.forEach(podRecord =>{
                    let uniqueIdList = data.map(key => key.uniqueId);
                    console.log('POD Id:' + podRecord.accountRecord.Id);
                    if (results.hasOwnProperty(podRecord.accountRecord.Id)){
                        console.log('ALl related RM Account: ' + JSON.stringify(results[podRecord.accountRecord.Id]));
                        relatedRMs = results[podRecord.accountRecord.Id];
                        relatedRMs.forEach(rmAccount => {
                            console.log('Each RM: ' + JSON.stringify(rmAccount));
                            let rowId = Math.max(...data.map(key => key.id)) + 1;
                            let new_record = {...podRecord};
                            let uniqueKey = new_record.uniqueId.replace(podRecord.accountRecord.Id, rmAccount.resultData.Id);
                            new_record.groupBy = 'rm';
                            addPODsRelatedAccount(data, uniqueIdList, uniqueKey, podRecord, rowId, new_record, rmAccount.resultData);
                        })
                    }
                })
            }
        })
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            })
    }

    if (pod_rgAccountIdList.length > 0){
        //add related RG's Restricted Account to bucket
        let relatedRGs = [];
        let rgAccountList = [];

        await new Promise(async (resolve) => {
            let results = await fetchRMAccount({ accountIds: pod_rgAccountIdList, onlyRestricted: false })
            resolve(results);
        }).then(function (results) {
            console.log('Related RG\'s Restricted Account to POD: ' + JSON.stringify(results));
            if (results) {
                dataTemp_rgMaintenance.forEach(podRecord => {
                    let uniqueIdList = data.map(key => key.uniqueId);
                    console.log('POD Parent Id:' + podRecord.accountRecord.ParentId);
                    results.forEach(rmAccount => {
                        if (rmAccount.Restricted_Flag__c) {//adding only restricted account
                            if (rmAccount.ParentId === podRecord.accountRecord.ParentId) {
                                console.log('Each RM: ' + JSON.stringify(rmAccount));
                                let rowId = Math.max(...data.map(key => key.id)) + 1;
                                let new_record = { ...podRecord };
                                let uniqueKey = new_record.uniqueId.replace(podRecord.accountRecord.Id, rmAccount.Id);
                                new_record.groupBy = 'rm';//all restricted RM to have group by as RM everytime
                                addPODsRelatedAccount(data, uniqueIdList, uniqueKey, podRecord, rowId, new_record, rmAccount);
                            }
                        }else{
                            if(!rgAccountList.includes(rmAccount.ParentId)){
                                rgAccountList.push(rmAccount.ParentId);
                            }
                        }
                    })
                })
            }
        })
            .catch(error => {
                console.log('Error: ' + JSON.stringify(error));
            })

        if(rgAccountList.length > 0){
            //add related RG to bucket 
            await new Promise(async (resolve) => {
                console.log('rgAccountList: ' + rgAccountList);
                let results = await fetchRGAccount({ rgAccountIds: rgAccountList })
                resolve(results);
            }).then(function (results) {
                console.log('Related RG to POD: ' + JSON.stringify(results));
                if (results) {
                    dataTemp_rgMaintenance.forEach(podRecord => {
                        let uniqueIdList = data.map(key => key.uniqueId);
                        console.log('POD Parent Id:' + podRecord.accountRecord.ParentId);
                        if (results.hasOwnProperty(podRecord.accountRecord.ParentId)) {
                            console.log('ALl related RG Account: ' + JSON.stringify(results[podRecord.accountRecord.ParentId]));
                            relatedRGs = results[podRecord.accountRecord.ParentId];
                            relatedRGs.forEach(rgAccount => {
                                console.log('Each RG: ' + JSON.stringify(rgAccount));
                                let rowId = Math.max(...data.map(key => key.id)) + 1;
                                let new_record = { ...podRecord };
                                let uniqueKey = new_record.uniqueId.replace(podRecord.accountRecord.Id, rgAccount.resultData.Id);
                                new_record.groupBy = 'rg' ;
                                addPODsRelatedAccount(data, uniqueIdList, uniqueKey, podRecord, rowId, new_record, rgAccount.resultData);
                            })
                        }
                    })
                }
            })
                .catch(error => {
                    console.log('Error: ' + JSON.stringify(error));
                })
        }
    }
    return data;
}

function addPODsRelatedAccount(data, uniqueIdList, uniqueKey, podRecord, rowId, new_record, rmAccount){
    if (!uniqueIdList.includes(uniqueKey)) {
        new_record.uniqueId = uniqueKey
        new_record.secKey = new_record.secKey.replace(podRecord.accountRecord.Id, rmAccount.Id);
        new_record.id = rowId;
        new_record.accountName = rmAccount.Restricted_Flag__c ? '(' + rmAccount.Domicile_Country__c + '-Restricted Jurisdiction) - ' + rmAccount.Name : rmAccount.Name;
        new_record.parentAccountName = rmAccount.Parent.Name;
        new_record.countryName = rmAccount.hasOwnProperty("Domicile_Country__c") ? rmAccount.Domicile_Country__c : '';
        new_record.validation = '';
        new_record.accountRecord = rmAccount;
        new_record.isRG = rmAccount.RecordType.DeveloperName === 'RG_Account' ? true : false;
        new_record.isRecordValidated = true;
        new_record.relatedPODId = podRecord.accountRecord.Id;
        new_record.isPODCoverageError = false;
        if (podRecord.role === 'Primary' && podRecord.salesTeamForCvgRecord.Company__c === 'N' && podRecord.salesTeamForCvgRecord.Sales_Desk_Region__c === 'Europe') {
            new_record.isAttested = 'utility:check';
            new_record.isAttest = true;
        }
        delete new_record.accountRecord.RM_POD_Links__r
        data.push(new_record);
        rowId++;
    } else {
        //same uniqueId is found then check for change in date/role
        const rowIndex = data.findIndex(obj => obj.uniqueId === uniqueKey);
        if (data[rowIndex].startDate !== podRecord.startDate) {
            data[rowIndex].startDate = podRecord.startDate;
        }
        if (data[rowIndex].role !== podRecord.role) {
            data[rowIndex].role = podRecord.role;
            if (podRecord.role === 'Primary' && podRecord.salesTeamForCvgRecord.Company__c === 'N' && podRecord.salesTeamForCvgRecord.Sales_Desk_Region__c === 'Europe') {
                data[rowIndex].isAttested = 'utility:check';
                data[rowIndex].isAttest = true;
            } else {
                data[rowIndex].isAttested = '';
                data[rowIndex].isAttest = false;
            }
        }
    }
}

export function updateRelatedAccount(data,updatedRecord){
    let uniqueIdList = data.map(key => key.uniqueId);
    updatedRecord.forEach(record => {
        data.forEach(dataRecord => {
            if(dataRecord.relatedPODId === record.accountRecord.Id){
                let uniqueKey = record.uniqueId.replace(record.accountRecord.Id, dataRecord.accountRecord.Id);
                addPODsRelatedAccount(data, uniqueIdList, uniqueKey, record, null, null, null);
            }
        })
    })
}
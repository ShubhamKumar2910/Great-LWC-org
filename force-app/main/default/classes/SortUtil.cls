/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : Generic - Sort Util
**
**/

public class SortUtil {
    //public enum OBJECT_TYPE {OBJ_TYPE_SOBJECT}
    public enum SORT_ORDER {ASC_ORDER, DESC_ORDER}

    //private static Map<Integer, Map<String, SORT_ORDER>> SortOrderByFldNameMapByFldOrderMap;
    private static List<FieldSortOrder> FieldSortOrderList;

    public static List<SObject> simpleSort(List<SObject> SObjectList, List<FieldSortOrder> SortOrderList) {
        System.debug('#### SortUtil::simpleSort()');
        List<SObject> ReturnSObjectList = new List<SObject>();
        try {
            FieldSortOrderList = SortOrderList;
            System.debug('FieldSortOrderList : '+FieldSortOrderList);
            List<SObjectWrapper> SObjectWrapperList = new List<SObjectWrapper>();
            for(Object obj : SObjectList) {
                SObjectWrapperList.add(new SObjectWrapper((SObject)obj));
            }
            SObjectList.clear();
            SObjectWrapperList.sort();
            for(SObjectWrapper sObjWrapper : SObjectWrapperList) {
                ReturnSObjectList.add(sObjWrapper.getSObject());
            }
        } catch (Exception ex) {
            System.debug('SortUtil::simpleSort() : ERROR : '+ex.getMessage());
            System.debug('SortUtil::simpleSort() : ERROR StackTrace : '+ex.getStackTraceString());
            throw new SortUtilException('Error Occured in  : SortUtil::simpleSort() : '+ex.getMessage());
        }
        return ReturnSObjectList;
    }

    public static void complexSort(List<ObjectWrapper> ObjectWrapperList, List<FieldSortOrder> SortOrderList) {
        System.debug('#### SortUtil::complexSort()');
        try {
            FieldSortOrderList = SortOrderList;
            System.debug('FieldSortOrderList : '+FieldSortOrderList);
            ObjectWrapperList.sort();
        } catch (Exception ex) {
            System.debug('SortUtil::complexSort() : ERROR : '+ex.getMessage());
            System.debug('SortUtil::complexSort() : ERROR StackTrace : '+ex.getStackTraceString());
            throw new SortUtilException('Error Occured in  : SortUtil::complexSort() : '+ex.getMessage());
        }
    }

    public class SObjectWrapper implements Comparable{
        private SObject oObj;
        SObjectWrapper(SObject oObj) {
            this.oObj = oObj;
        }

        public SObject getSObject() {
            return oObj;
        }

        public Integer compareTo(Object compToObj) {
            Integer retVal = 0;
            SObjectWrapper compareToSObjWrapper = (SObjectWrapper)compToObj;
            for(FieldSortOrder FldOrder : FieldSortOrderList) {
                String lhsVal = String.valueOf(this.oObj.get(FldOrder.fieldName));
                String rhsVal = String.valueOf(compareToSObjWrapper.oObj.get(FldOrder.fieldName));
                if(FldOrder.isAlreadySorted) {
                    if(lhsVal!=rhsVal) {
                        break;
                    }
                } else {
                    if(FldOrder.sortOrder == SORT_ORDER.ASC_ORDER) {
                        if(lhsVal < rhsVal) {
                            retVal=-1;
                        } else if (lhsVal > rhsVal) {
                            retVal=1;
                        }
                    } else if(FldOrder.sortOrder == SORT_ORDER.DESC_ORDER) {
                        if(lhsVal < rhsVal) {
                            retVal=1;
                        } else if (lhsVal > rhsVal) {
                            retVal=-1;
                        }
                    }

                    if(retVal!=0) {
                        break;
                    }
                } 
            }
            return retVal;
        }
    }

    public class ObjectWrapper implements Comparable{
        public String recId; 
        public List<Object> ObjectValueList;
        public ObjectWrapper(String recId, List<Object> ObjectValueList) {
            this.recId = recId;
            this.ObjectValueList = ObjectValueList;
        }

        public Integer compareTo(Object compToObj) {
            Integer retVal = 0;
            ObjectWrapper compareToObjWrapper = (ObjectWrapper)compToObj;
            Integer valIndx = 0;
            for(FieldSortOrder FldOrder : FieldSortOrderList) {
                String lhsVal = String.valueOf(ObjectValueList.get(valIndx));
                String rhsVal = String.valueOf(compareToObjWrapper.ObjectValueList.get(valIndx));
                if(FldOrder.isAlreadySorted) {
                    if(lhsVal!=rhsVal) {
                        //System.debug('As the field is already sorted and lhsVal != rhsVal indicates that the sub-group has ended');
                        break;
                    }
                } else {
                    if(FldOrder.sortOrder == SORT_ORDER.ASC_ORDER) {
                        if(lhsVal < rhsVal) {
                            retVal=-1;
                        } else if (lhsVal > rhsVal) {
                            retVal=1;
                        }
                    } else if(FldOrder.sortOrder == SORT_ORDER.DESC_ORDER) {
                        if(lhsVal < rhsVal) {
                            retVal=1;
                        } else if (lhsVal > rhsVal) {
                            retVal=-1;
                        }
                    }

                    if(retVal!=0) {
                        break;
                    }
                }
                ++valIndx;
            }
            return retVal;
        }
    }


    public class FieldSortOrder {
        public string fieldName;
        public SORT_ORDER sortOrder;
        public Boolean isAlreadySorted;

        public FieldSortOrder(string fieldName, SORT_ORDER sortOrder, Boolean isAlreadySorted) {
            this.fieldName = fieldName;
            this.sortOrder = sortOrder;
            this.isAlreadySorted = isAlreadySorted;
        }
    }

    public class SortUtilException extends Exception {}
}
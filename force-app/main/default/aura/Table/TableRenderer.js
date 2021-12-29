({
    afterRender : function( component, helper ) {

        this.superAfterRender();
        var pDiv = document.getElementById(component.get("v.parentId")+"parentDiv");
        
        var didScroll = false;
        pDiv.onscroll = function() {
            didScroll = true;
        };
        
        var scrollCheckIntervalId = setInterval( $A.getCallback( function() {
            // since this function is called asynchronously outside the component's lifecycle
            // we need to check if the component still exists before trying to do anything else
            if ( didScroll && component.isValid() ) {
                didScroll = false;
                console.log('scroll scrollTop: '+pDiv.scrollTop);
                console.log('scroll scrollHeight: '+pDiv.scrollHeight);
                console.log('scroll offsetHeight: '+pDiv.offsetHeight);
                var scrollpoint = pDiv.scrollHeight / 2;
                if( pDiv.scrollTop > (pDiv.scrollHeight / 2))
                {
                    console.log('Scroll Data');
                    if(!component.get("v.isWrapper"))
                    helper.getNextPage( component );    
                    else
                    {
                        component.showSpinner();
                        window.setTimeout($A.getCallback(function() {
                            helper.getScrollNext(component,false,pDiv,scrollpoint); 
                        }), 50);
                        
                    }
                }
                
            }
            
        }), 1000 );
        component.set( 'v.scrollCheckIntervalId', scrollCheckIntervalId );
    },
	
    unrender : function( component, helper ) {

        this.superUnrender();

        var scrollCheckIntervalId = component.get( 'v.scrollCheckIntervalId' );

        if ( !$A.util.isUndefinedOrNull( scrollCheckIntervalId ) ) {
            window.clearInterval( scrollCheckIntervalId );
        }

    },
    
    rerender : function(cmp, helper){
         this.superRerender();

       /* if(cmp.get("v.isJqueryLoaded") && cmp.get("v.needToProcessReRenderLogic")) {
            //your logics
            try {
                $("#fixTable").tableHeadFixer({'foot' : true,'head' : false, 'z-index' : 0,'left':0,'right' : 0});
                //Finally set the needToProcessReRenderLogic to false, since rerender will be called multiple times
            	cmp.set("v.needToProcessReRenderLogic",false); // this will not fire rerender again
            }
            catch(err) {
                
            }
            
        }*/
    }
})
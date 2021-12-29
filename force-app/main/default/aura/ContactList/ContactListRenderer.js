({ 
     afterRender : function(component, helper) { 
 
         this.superAfterRender(); 
          // this is done in renderer because we don't get 
         // access to the window element in the helper js. 
 
 
         var tableDiv = document.getElementById("contactListTableDiv");         
         var didScroll = false;          
         var prevLeft = 0;
         var previousPosition = tableDiv.pageYOffset || tableDiv.scrollTop;
         var scrolledDown = true;
         
         tableDiv.onscroll = function() { 
             //Added below code because we dont want to perform any action on horizontal scrollbar
             var currentLeft = tableDiv.scrollLeft;
             if(prevLeft === currentLeft){
                 didScroll = true;
             }
             else {
                 prevLeft = currentLeft;
             }
             
             var currentPosition = tableDiv.pageYOffset || tableDiv.scrollTop;                
             if (currentPosition < previousPosition  ) {
                 scrolledDown = false;
             }     
             else{
                 scrolledDown = true;
             }
             previousPosition = currentPosition;
         };
 
         /*window.onscroll = function() { 
             didScroll = true; 
         };*/ 
 
 
         // periodically attach the scroll event listener 
         // so that we aren't taking action for all events 
         var scrollCheckIntervalId = setInterval( $A.getCallback( function() { 
             // since this function is called asynchronously outside the component's lifecycle 
             // we need to check if the component still exists before trying to do anything else 
             if ( didScroll && component.isValid() ) { 
                 didScroll = false; 
                 /*if ( window['scrollY'] >= document.body['scrollHeight'] - window['outerHeight'] - 100 ) { 
                     component.getNextPage();
                 }*/ 
                 //+ 17 Include as we introduced Horizontal Scrollbar                
                 console.log(tableDiv.scrollHeight - (tableDiv.offsetHeight + (tableDiv.scrollTop / 4)) + 17  );
                 if((tableDiv.scrollTop ) > ((tableDiv.scrollHeight - (tableDiv.offsetHeight + (tableDiv.scrollTop / 4))) + 17) && scrolledDown){
                     
                     component.getNextPage();
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
     }
    
})
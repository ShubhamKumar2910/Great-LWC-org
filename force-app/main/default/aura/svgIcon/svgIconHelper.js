({
  renderIcon: function(component) {
      
    var prefix = "slds-";
    var svgns = "http://www.w3.org/2000/svg";
    var xlinkns = "http://www.w3.org/1999/xlink";
    var size = component.get("v.size");
    var classname = component.get("v.class");
    var containerclass = component.get("v.containerClass");
     
    var containerClassName = containerclass;
    component.set("v.containerClass", containerClassName);
      console.log('final containerClassName-- '+ containerClassName);		
      
    var svgroot = document.createElementNS(svgns, "svg");
     var iconClassName = classname + " slds-icon_" + size;
    svgroot.setAttribute("aria-hidden", "true");
    svgroot.setAttribute("class", iconClassName);
    svgroot.setAttribute("name", name);

      console.log('iconClassName-- '+ iconClassName);
      
      
    // Add an "href" attribute (using the "xlink" namespace)
    var shape = document.createElementNS(svgns, "use");
    shape.setAttributeNS(xlinkns, "href", component.get("v.svgPath"));
    svgroot.appendChild(shape);
	var container = component.find("container").getElement();
    
      console.log('shape-- '+ svgroot.appendChild(shape));
      console.log('component.-- '+ component.get("v.svgPath"));
      
    container.insertBefore(svgroot, container.firstChild);
  }
})
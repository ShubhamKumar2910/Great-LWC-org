/**
**	Author 		: Pravin Kundal
**	Company 	: Nomura
**	Description : This is the generic implementation of Stack - LIFO (Last In First Out) data-Structure.  
**
**/
public class GenericStack {
	// Stack buffer is comprised of generic type - Object
	private List<Object> buffer;
		
	// Contructor
	public GenericStack() {
		buffer = new List<Object>();
	}

	/**
	  * Description : check whether the there are elements in Stack.	
	  *
	  * @return Boolean - true  : if Stack is empty, 
	  *					  false : if there are elements in stack 
	**/ 
	public Boolean empty() {
		return buffer.isEmpty();
	}

	/**
	  * Description : remove and returns the top last element pushed on Stack. Throws an exception if
	  *				  this operation is performed on an empty stack. 	
	  *
	  * @return Object - most recent element pushed on Stack  
	**/
	public Object pop() {
		return buffer.remove(buffer.size()-1);
	}

	/**
	  * Description : pushes a Object type on Stack and increases its size by 1 	
	  *
	  *	@param Object token - element that needs to be pushed on to the Stack
	  * @return void  
	**/
	public void push(Object token) {
		buffer.add(token);
	}

	/**
	  * Description : returns the top element on a Stack, without removing it from the stack. This is
	  *				  just to check the top element on Stack. 	
	  *
	  * @return Object - most recent element pushed on Stack  
	**/
	public Object top() {
		return buffer[buffer.size()-1];
	}
}
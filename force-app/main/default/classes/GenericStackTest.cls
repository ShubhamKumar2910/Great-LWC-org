/**
 *	Author 		: Pravin Kundal
 *	Company 	: Nomura
 *  Description : This class contains unit tests for validating the behavior of Apex class - GenericStack
 *
 */
@isTest
private class GenericStackTest {
	static testMethod void testGenericStack() {
		GenericStack stack = new GenericStack();
		stack.push('a');
		stack.push('b');
		System.assertEquals(stack.top(), 'b');
		System.assertEquals(stack.empty(), false);
		String token = (String)stack.pop();
		System.assertEquals(token, 'b');
		System.assertEquals(stack.empty(), false);
		token = (String)stack.pop();
		System.assertEquals(token, 'a');
		System.assertEquals(stack.empty(), true);
	}
}
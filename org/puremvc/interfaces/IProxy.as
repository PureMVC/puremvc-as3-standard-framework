/*
 PureMVC - Copyright(c) 2006, 2007 FutureScale, Inc., Some rights reserved.
 Your reuse is governed by the Creative Commons Attribution 3.0 United States License
*/
package org.puremvc.interfaces
{
	
	/**
	 * The interface definition for a PureMVC Proxy.
	 *
	 * <P>
	 * In PureMVC, <code>IProxy</code> implementors assume these responsibilities:</P>
	 * <UL>
	 * <LI>Implement a common method which returns the name of the Proxy.</LI>
	 * </UL>
	 * <P>
	 * Additionally, <code>IProxy</code>s typically:</P>
	 * <UL>
	 * <LI>Maintain references to one or more pieces of model data.</LI>
	 * <LI>Provide methods for manipulating that data.</LI>
	 * <LI>Generate <code>INotifications</code> when their model data changes.</LI>
	 * <LI>Expose their name as a <code>public static const</code> called <code>NAME</code>.</LI>
	 * <LI>Encapsulate interaction with local or remote services used to fetch and persist model data.</LI>
	 * </UL>
	 */
	public interface IProxy
	{
		
		/**
		 * Get the Proxy name
		 * 
		 * @return the Proxy instance name
		 */
		function getProxyName():String;
		
	}
}
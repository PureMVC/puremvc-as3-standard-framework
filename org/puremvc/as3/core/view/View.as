/*
 PureMVC - Copyright(c) 2006-08 Futurescale, Inc., Some rights reserved.
 Your reuse is governed by the Creative Commons Attribution 3.0 United States License
*/
package org.puremvc.as3.core.view
{

	import org.puremvc.as3.interfaces.*;
	import org.puremvc.as3.patterns.observer.Observer;

	/**
	 * A Singleton <code>IView</code> implementation.
	 * 
	 * <P>
	 * In PureMVC, the <code>View</code> class assumes these responsibilities:
	 * <UL>
	 * <LI>Maintain a cache of <code>IMediator</code> instances.</LI>
	 * <LI>Provide methods for registering, retrieving, and removing <code>IMediators</code>.</LI>
	 * <LI>Managing the observer lists for each <code>INotification</code> in the application.</LI>
	 * <LI>Providing a method for attaching <code>IObservers</code> to an <code>INotification</code>'s observer list.</LI>
	 * <LI>Providing a method for broadcasting an <code>INotification</code>.</LI>
	 * <LI>Notifying the <code>IObservers</code> of a given <code>INotification</code> when it broadcast.</LI>
	 * </UL>
	 * 
	 * @see org.puremvc.as3.patterns.mediator.Mediator Mediator
	 * @see org.puremvc.as3.patterns.observer.Observer Observer
	 * @see org.puremvc.as3.patterns.observer.Notification Notification
	 */
	public class View implements IView
	{
		
		/**
		 * Constructor. 
		 * 
		 * <P>
		 * This <code>IView</code> implementation is a Singleton, 
		 * so you should not call the constructor 
		 * directly, but instead call the static Singleton 
		 * Factory method <code>View.getInstance()</code>
		 * 
		 * @throws Error Error if Singleton instance has already been constructed
		 * 
		 */
		public function View( )
		{
			if (instance != null) throw Error(SINGLETON_MSG);
			instance = this;
			mediatorMap = new Array();
			observerMap = new Array();	
			initializeView();	
		}
		
		/**
		 * Initialize the Singleton View instance.
		 * 
		 * <P>
		 * Called automatically by the constructor, this
		 * is your opportunity to initialize the Singleton
		 * instance in your subclass without overriding the
		 * constructor.</P>
		 * 
		 * @return void
		 */
		protected function initializeView(  ) : void 
		{
		}
	
		/**
		 * View Singleton Factory method.
		 * 
		 * @return the Singleton instance of <code>View</code>
		 */
		public static function getInstance() : IView 
		{
			if ( instance == null ) instance = new View( );
			return instance;
		}
				
		/**
		 * Register an <code>IObserver</code> to be notified
		 * of <code>INotifications</code> with a given name.
		 * 
		 * @param notificationName the name of the <code>INotifications</code> to notify this <code>IObserver</code> of
		 * @param observer the <code>IObserver</code> to register
		 */
		public function registerObserver ( notificationName:String, observer:IObserver ) : void
		{
			if( observerMap[ notificationName ] != null ) {
				observerMap[ notificationName ].push( observer );
			} else {
				observerMap[ notificationName ] = [ observer ];	
			}
		}


		/**
		 * Notify the <code>IObservers</code> for a particular <code>INotification</code>.
		 * 
		 * <P>
		 * All previously attached <code>IObservers</code> for this <code>INotification</code>'s
		 * list are notified and are passed a reference to the <code>INotification</code> in 
		 * the order in which they were registered.</P>
		 * 
		 * @param notification the <code>INotification</code> to notify <code>IObservers</code> of.
		 */
		public function notifyObservers( notification:INotification ) : void
		{
			if( observerMap[ notification.getName() ] != null ) {
				var observers:Array = observerMap[ notification.getName() ] as Array;
				for (var i:Number = 0; i < observers.length; i++) {
					var observer:IObserver = observers[ i ] as IObserver;
					observer.notifyObserver( notification );
				}
			}
		}
						
		/**
		 * Register an <code>IMediator</code> instance with the <code>View</code>.
		 * 
		 * <P>
		 * Registers the <code>IMediator</code> so that it can be retrieved by name,
		 * and further interrogates the <code>IMediator</code> for its 
		 * <code>INotification</code> interests.</P>
		 * <P>
		 * If the <code>IMediator</code> returns any <code>INotification</code> 
		 * names to be notified about, an <code>Observer</code> is created encapsulating 
		 * the <code>IMediator</code> instance's <code>handleNotification</code> method 
		 * and registering it as an <code>Observer</code> for all <code>INotifications</code> the 
		 * <code>IMediator</code> is interested in.</p>
		 * 
		 * @param mediatorName the name to associate with this <code>IMediator</code> instance
		 * @param mediator a reference to the <code>IMediator</code> instance
		 */
		public function registerMediator( mediator:IMediator ) : void
		{
			// Register the Mediator for retrieval by name
			mediatorMap[ mediator.getMediatorName() ] = mediator;
			
			// Get Notification interests, if any.
			var interests:Array = mediator.listNotificationInterests();
			if ( interests.length == 0) return;
			
			// Create Observer
			var observer:Observer = new Observer( mediator.handleNotification, mediator );
			
			// Register Mediator as Observer for its list of Notification interests
			for ( var i:Number=0;  i<interests.length; i++ ) {
				registerObserver( interests[i],  observer );
			}			
		}

		/**
		 * Retrieve an <code>IMediator</code> from the <code>View</code>.
		 * 
		 * @param mediatorName the name of the <code>IMediator</code> instance to retrieve.
		 * @return the <code>IMediator</code> instance previously registered with the given <code>mediatorName</code>.
		 */
		public function retrieveMediator( mediatorName:String ) : IMediator
		{
			return mediatorMap[ mediatorName ];
		}

		/**
		 * Remove an <code>IMediator</code> from the <code>View</code>.
		 * 
		 * @param mediatorName name of the <code>IMediator</code> instance to be removed.
		 * @return the <code>IMediator</code> that was removed from the <code>View</code>
		 */
		public function removeMediator( mediatorName:String ) : IMediator
		{
			// Go through the observer list for each notification 
			// in the observer map and remove all Observers with a 
			// reference to the Mediator being removed.
			for ( var notificationName:String in observerMap ) {
				// the observer list for the notification under inspection
				var observers:Array = observerMap[ notificationName ];
				// First, collect the indices of the observers to be removed 
				var removalTargets:Array = new Array();
				for ( var i:int=0;  i< observers.length; i++ ) {
					if ( Observer(observers[i]).compareNotifyContext( retrieveMediator( mediatorName ) ) == true ) {
						removalTargets.push(i);
					}
				}
				// now the removalTargets array has an ascending 
				// list of indices to be removed from the observers array
				// so pop them off the array, effectively going from 
				// highest index value to lowest, and splice each
				// from the observers array. since we're going backwards,
				// the collapsing of the array elements to fill the spliced
				// out element's space does not affect the position of the
				// lower numbered indices we've yet to remove
				var target:int;
				while ( removalTargets.length > 0 ) 
				{
					target = removalTargets.pop();
					observers.splice(target,1);
				}
				// Also, when an notification's observer list length falls to 
				// zero, delete the notification key from the observer map
				if ( observers.length == 0 ) {
					delete observerMap[ notificationName ];		
				}
			}			
			// Remove the to the Mediator from the mediator map and return it
			var mediator:IMediator = mediatorMap[ mediatorName ] as IMediator;
			delete mediatorMap[ mediatorName ];
			return mediator;
		}
						
		/**
		 * Check if a Mediator is registered or not
		 * 
		 * @param mediatorName
		 * @return whether a Mediator is registered with the given <code>mediatorName</code>.
		 */
		public function hasMediator( mediatorName:String ) : Boolean
		{
			return mediatorMap[ mediatorName ] != null;
		}

		// Mapping of Mediator names to Mediator instances
		protected var mediatorMap : Array;

		// Mapping of Notification names to Observer lists
		protected var observerMap	: Array;
		
		// Singleton instance
		protected static var instance	: IView;

		// Message Constants
		protected const SINGLETON_MSG	: String = "View Singleton already constructed!";
	}
}
/**
 * Cloud Explorer, lightweight frontend component for file browsing with cloud storage services.
 * @see https://github.com/silexlabs/cloud-explorer
 *
 * Cloud Explorer works as a frontend interface for the unifile node.js module:
 * @see https://github.com/silexlabs/unifile
 *
 * @author Thomas Fétiveau, http://www.tokom.fr  &  Alexandre Hoyau, http://lexoyo.me
 * Copyrights SilexLabs 2013 - http://www.silexlabs.org/ -
 * License MIT
 */
package ce.core.ctrl;

import ce.core.view.Application;

import ce.core.model.State;
import ce.core.model.CEError;
import ce.core.model.unifile.UnifileError;

class ErrorCtrl {

	public function new(parent : Controller, state : State, application : Application) {

		this.parent = parent;
		this.state = state;
		this.application = application;
	}

	var state : State;

	var application : Application;

	var parent : Controller;

	///
	// API
	//

	public function manageListSrvError(msg : String) : Void {

		switch (state.currentMode) {

			case SingleFileSelection(_), SingleFileExport(_) :

				setError(msg);

			case IsLoggedIn(_, onError, _) :

				onError(new CEError(500)); // FIXME

			case RequestAuthorize(_, onError, _) :

				onError(new CEError(500)); // FIXME
				
				state.displayState = false;
		}
	}	

	public function manageConnectError(msg : String) : Void {

		switch (state.currentMode) {

			case SingleFileSelection(_), SingleFileExport(_) :

				setError(msg);

			case RequestAuthorize(_, onError, _) :

				onError(new CEError(500)); // FIXME
				
				state.displayState = false;

			case IsLoggedIn(_) :

				throw "unexpected mode " + state.currentMode;
		}
	}

	public function manageLoginError(msg : String) : Void {

		switch (state.currentMode) {

			case SingleFileSelection(_), SingleFileExport(_) :

				setError(msg);

			case RequestAuthorize(_, onError, _) :

				onError(new CEError(500)); // FIXME

				state.displayState = false;

			case IsLoggedIn(_) :

				throw "unexpected mode " + state.currentMode;
		}
	}

	/**
	 * FIXME UnifileError should probably be converted to a generic error in service layer
	 */
	public function setUnifileError(err : UnifileError) : Void {

		if (err.code == CEError.CODE_UNAUTHORIZED) {

			var srv = state.currentLocation.service;

			state.serviceList.get(srv).isLoggedIn = false;

			parent.connect(srv);
		
		} else {

			setError(err.message);
		}
	}


	public function setError(msg : String) : Void {

		application.setLoaderDisplayed(false); // FIXME should this be there ?

		application.alertPopup.setMsg(msg, 0, [{ msg: "Continue", cb: function() { application.setAlertPopupDisplayed(false); }}]);

		application.setAlertPopupDisplayed(true);
	}
}
using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Application as App;

class CrystalView extends Ui.WatchFace {

	function initialize() {
		WatchFace.initialize();
	}

	// Load your resources here
	function onLayout(dc) {
		setLayout(Rez.Layouts.WatchFace(dc));
	}

	// Called when this View is brought to the foreground. Restore
	// the state of this View and prepare it to be shown. This includes
	// loading resources into memory.
	function onShow() {
	}

	// Update the view
	function onUpdate(dc) {
		System.println("onUpdate()");

		// Call the parent onUpdate function to redraw the layout
		View.onUpdate(dc);
	}

	// Set clipping region to previously-displayed seconds text only.
	// Clear background, clear clipping region, then draw new seconds.
	function onPartialUpdate(dc) {
		System.println("onPartialUpdate()");
	
		var time = View.findDrawableById("Time");
		time.drawSeconds(dc, /* isPartialUpdate */ true);
	}

	// Called when this View is removed from the screen. Save the
	// state of this View here. This includes freeing resources from
	// memory.
	function onHide() {
	}

	// The user has just looked at their watch. Timers and animations may be started here.
	function onExitSleep() {
	}

	// Terminate any active timers and prepare for slow updates.
	function onEnterSleep() {
	}

}

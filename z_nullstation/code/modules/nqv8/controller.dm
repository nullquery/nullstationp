// Pass the delay of the master controller over to the v8 controller.
/datum/controller/master/calculate_gcd()
	. = ..()

	// Wrapped in a try/catch block, because despite the sanity check
	// this still triggers a runtime error.
	try
		if (v8) v8.SetProcessorDelay(.)
	catch ()

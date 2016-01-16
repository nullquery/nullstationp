// Pass the delay of the master controller over to the v8 controller.
/datum/controller/master/calculate_gcd()
	. = ..()

	if (v8) v8.SetProcessorDelay(.);

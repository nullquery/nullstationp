var/datum/nqv8/v8/v8						= new/datum/nqv8/v8();

/datum/nqv8/v8/var/processor_delay;
/datum/nqv8/v8/var/processor_id				= 0;
/datum/nqv8/v8/var/list/processing			= new/list();

/datum/nqv8/v8/New()
{
	. = ..();

	src.processor_delay						= world.tick_lag * 2;

	Call("initialize");
}

/datum/nqv8/v8/proc/SetProcessorDelay(delay)
{
	src.processor_delay						= delay;
}

/datum/nqv8/v8/proc/Call(name, ...)
{
	var/list/L								= args.Copy(2)

	return call(world.system_type == MS_WINDOWS ? "./libnqv8.dll" : "./libnqv8.so", name)(arglist(L));
}

/datum/nqv8/v8/proc/AllocateProcessor()
{
	return new/datum/nqv8/processor(arglist(args));
}

/datum/nqv8/processor/var/tmp/id;
/datum/nqv8/processor/var/tmp/processing	= null;

/datum/nqv8/processor/New(callbackObject, callbackFunction)
{
	. = ..();

	if (v8.processing.len > 2048)			{ CRASH("Maximum number of v8 instances reached. Only 2048 instances are permitted."); }

	src.id									= "\ref[src]";
	v8.processing[src.id]					= null;

	v8.Call("allocateProcessor", src.id);

	spawn (0)
		var/id								= src.id;
		src									= null;

		v8.ProcessMessages(id, callbackObject, callbackFunction);
}

/datum/nqv8/processor/Del()
{
	src.Dispose();

	return ..()
}

/datum/nqv8/processor/proc/Dispose()
{
	while (v8.processing[src.id] == null)		{ sleep(v8.processor_delay); }

	v8.processing[src.id]						= FALSE;

	v8.Call("destroyProcessor", src.id);
}

/datum/nqv8/v8/proc/ProcessMessages(id, callbackObject, callbackFunction)
{
	src.processing[id]						= TRUE;

	var/list/messages;

	while (src.processing[id])
	{
		try
		{
			.								= v8.Call("getMessages", id)

			if (. != "\[\]")
			{
				messages					= json_decode("{\"m\":[.]}");
				messages					= messages["m"];

				for (var/object in messages)
				{
					call(callbackObject, callbackFunction)(object)
				}
			}
		}
		catch (var/ex)
		{
			world.log << "ERROR: [ex]"
		}

		sleep(max(world.tick_lag, v8.processor_delay))
	}

	v8.processing.Remove(id);
}

/datum/nqv8/processor/proc/EvaluateText(text)
{
	v8.Call("evaluate", src.id, "[text]")
}

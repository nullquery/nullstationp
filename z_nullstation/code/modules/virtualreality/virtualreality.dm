// Javascript code to run before initialization of the virtual reality environment.
// Sandboxing takes place here.
/datum/virtualreality/environment/var/global/INIT_JS = {"

var vr = {};

(function()
{
	// Override the send functionality to prevent raw messages from being sent.
	var rawSend = send;
	send = null;

	vr.initialize = function(width, height)
	{
		rawSend({ "type": "init", "width": width, "height": height });
	};
})();

"}

var/datum/virtualreality/environment/testenv
/mob/verb/test()
	set category = "Test"
	testenv = new(file2text("test.js"))

/datum/virtualreality/environment
	var/global/list/allocated_z_levels
	var/global/list/allocated_blocks
	var/global/viewport_x = Ceiling(15 / 2) // based off world.view
	var/global/viewport_y = Ceiling(15 / 2) // based off world.view

	var/datum/virtualreality/block/block
	var/datum/nqv8/processor/processor

/datum/virtualreality/environment/New(code)
	. = ..()

	src.processor = v8.AllocateProcessor(src, "onV8Message")
	src.processor.EvaluateText(INIT_JS)
	src.processor.EvaluateText(code) // user input!
	src.processor.EvaluateText("onInit();")

/datum/virtualreality/environment/proc/onV8Message(object)
	if (istype(object, /list))
		world.log << "Received message: [list2params(object)]"

		switch (object["type"])
			if ("init")
				var/width = object["width"]
				var/height = object["height"]

				src.block = src.AllocateBlock(width, height)
				world.log << "Allocated block of [width]x[height] -> [src.block.x1],[src.block.y1],[src.block.z] to [src.block.x2],[src.block.y2],[src.block.z]"

/datum/virtualreality/environment/Del()
	if (src.processor) src.processor.Dispose()
	if (src.block) deallocateBlock(src.block)

	return ..()

/datum/virtualreality/environment/proc/AllocateBlock(width, height)
	if (src.allocated_z_levels == null) src.allocated_z_levels = new/list()
	if (!allocated_blocks) src.allocated_blocks = new/list()

	var/maxx = world.maxx - viewport_x - 1
	var/maxy = world.maxy - viewport_y - 1

	var/datum/virtualreality/block/block

	var/x1 = viewport_x + 1
	var/y1 = viewport_y + 1
	var/z
	var/z_index = 1

	if (allocated_z_levels.len) z = allocated_z_levels[1]
	else
		z = ++world.maxz
		allocated_z_levels.Add(z)

	do
		block = null

		for (block in src.allocated_blocks)
			if (block.z == z && (block.x1 >= x1 && block.x2 <= x1) && (block.y1 >= y1 && block.y2 <= y1))
				break

		if (block != null)
			x1 = x1 + width + viewport_x + 1

			if (x1 > maxx)
				x1 = viewport_x + 1
				y1 = y1 + height + viewport_y + 1

				if (y1 > maxy)
					x1 = viewport_x + 1
					y1 = viewport_y + 1
					z++

					if (z > world.maxz)
						z_index++
						if (allocated_z_levels.len >= z_index)
							z = allocated_z_levels[z_index]
						else
							z = ++world.maxz
							allocated_z_levels.Add(z)

	while (block != null)

	block = new(locate(x1, y1, z), locate(x1 + width, y1 + height, z))

	src.allocated_blocks.Add(block)

	return block

/datum/virtualreality/environment/proc/deallocateBlock(datum/virtualreality/block/block)
	for (var/turf/T in block(locate(block.x1, block.y1, block.z), locate(block.x2, block.y2, block.z)))
		for (var/atom/movable/A in T.contents)
			qdel(A)

		new/turf/space(T)

	src.allocated_blocks.Remove(block)
	// block can now be collected by the garbage collector

/datum/virtualreality/block
	var/x1
	var/x2
	var/y1
	var/y2
	var/z

/datum/virtualreality/block/New(turf/lowerLeft, turf/upperRight)
	. = ..()

	ASSERT(lowerLeft.z == upperRight.z)

	src.x1 = lowerLeft.x
	src.y1 = lowerLeft.y
	src.x2 = upperRight.x
	src.y2 = upperRight.y

	src.z = lowerLeft.z
package org.fipro.service.command;

import java.util.HashMap;
import java.util.Map;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.event.Event;
import org.osgi.service.event.EventAdmin;

@Component(
	property =	{
		"osgi.command.scope=fipro",
		"osgi.command.function=consume"
	},
	service = StringConsumerCommand.class
)
public class StringConsumerCommand {

	@Reference
	private EventAdmin eventAdmin;
	
	public void consume(String input) {
		Map<String, String> map = new HashMap<>();
		map.put("value", input);
		Event event = new Event("org/fipro/service/consume", map);
		eventAdmin.sendEvent(event);
	}

}

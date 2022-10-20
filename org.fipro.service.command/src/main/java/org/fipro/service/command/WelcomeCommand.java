package org.fipro.service.command;

import java.util.Map;

import org.fipro.service.configurable.ConfigurableService;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

@Component(
	property =	{
		"osgi.command.scope=fipro",
		"osgi.command.function=welcome"
	},
	service = WelcomeCommand.class
)
public class WelcomeCommand {

	@Reference
	private ConfigurableService service;
	
	public void updatedConfigurable(ConfigurableService service, Map<String, Object> properties) {
		System.out.print("ConfigurableService updated\n\r");
	}
	
	public void welcome() {
		System.out.print(service.execute() + "\n\r");
	}
}

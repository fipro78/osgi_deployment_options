package org.fipro.service.command;

import java.io.IOException;
import java.util.Hashtable;

import org.osgi.service.cm.Configuration;
import org.osgi.service.cm.ConfigurationAdmin;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

@Component(
	property =	{
		"osgi.command.scope=fipro",
		"osgi.command.function=configure"
	},
	service = ConfigurationCommand.class
)
public class ConfigurationCommand {

	@Reference
	private ConfigurationAdmin cm;
	
	public void configure(String input) throws IOException {
		Configuration config = cm.getConfiguration("org.fipro.service.configurable.ConfigurableService", null);
		Hashtable<String, Object> props = new Hashtable<>();
		props.put("msg", input);
		config.update(props);
	}
}

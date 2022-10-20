package org.fipro.service.command;

import java.util.List;

import org.fipro.service.modifier.StringModifier;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;

@Component(
	property =	{
		"osgi.command.scope=fipro",
		"osgi.command.function=modify"
	},
	service = StringModifierCommand.class
)
public class StringModifierCommand {

	@Reference
	private List<StringModifier> modifier;
	
	public void modify(String input) {
		modifier.forEach(m -> System.out.print(m.modify(input) + "\n\r"));
	}
}

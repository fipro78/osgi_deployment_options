package org.fipro.service.modifier.impl;

import org.fipro.service.modifier.StringModifier;
import org.osgi.service.component.annotations.Component;

@Component
public class CamelCaseModifier implements StringModifier {

	@Override
	public String modify(String input) {
		StringBuilder builder = new StringBuilder();
		if (input != null) {
			for (int i = 0; i < input.length(); i++) {
				char currentChar = input.charAt(i);
				if (i % 2 == 0) {
					builder.append(Character.toUpperCase(currentChar));
				} else {
					builder.append(Character.toLowerCase(currentChar));
				}
			} 
		}
		else {
			builder.append("No input given");
		}
		return builder.toString();
	}
}

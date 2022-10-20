package org.fipro.service.modifier.impl;

import java.util.Locale;

import org.fipro.service.modifier.StringModifier;
import org.osgi.service.component.annotations.Component;

@Component
public class UppercaseModifier implements StringModifier {

    @Override
    public String modify(String input) {
        return (input != null)
        	? input.toUpperCase(Locale.getDefault())
        	: "No input given";
    }
}
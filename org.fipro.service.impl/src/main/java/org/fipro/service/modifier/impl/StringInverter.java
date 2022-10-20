package org.fipro.service.modifier.impl;

import org.fipro.service.modifier.StringModifier;
import org.osgi.service.component.annotations.Component;

@Component
public class StringInverter implements StringModifier {

    @Override
    public String modify(String input) {
        return (input != null) 
        	? new StringBuilder(input).reverse().toString()
        	: "No input given";
    }
}
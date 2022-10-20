package org.fipro.service.eventhandler;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.event.Event;
import org.osgi.service.event.EventHandler;

@Component(property="event.topics=org/fipro/service/consume")
public class ConsumeEventHandler implements EventHandler {

    @Override
    public void handleEvent(Event event) {
        System.out.print("Aahh that was good. Gimme more " + event.getProperty("value") + "\n\r");
    }

}
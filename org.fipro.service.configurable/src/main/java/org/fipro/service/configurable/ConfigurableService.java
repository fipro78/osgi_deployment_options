package org.fipro.service.configurable;
import java.util.Map;

import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Deactivate;
import org.osgi.service.component.annotations.Modified;

@Component(service=ConfigurableService.class)
public class ConfigurableService {

	private String message;
	
	@Activate
	public void activate(Map<String, Object> params) {
		System.out.print("Activate configurable\n\r");
		message = (String) params.get("msg");
	}

	@Modified
	public void modified(Map<String, Object> params) {
		System.out.print("Modify configurable\\n\\r");
		message = (String) params.get("msg");
	}
	
	@Deactivate
	public void deactivate(Map<String, Object> params) {
		System.out.print("Deactivate configurable\\n\\r");
		message = (String) params.get("msg");
	}
	
	public String execute() {
		return "Service says: " + message;
	}
}

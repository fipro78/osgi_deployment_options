package org.fipro.osgi.benchmark.service;

import javax.ws.rs.FormParam;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;

import org.osgi.service.component.annotations.Component;
import org.osgi.service.component.annotations.Reference;
import org.osgi.service.jaxrs.whiteboard.propertytypes.JSONRequired;
import org.osgi.service.jaxrs.whiteboard.propertytypes.JaxrsResource;

@Component(service=BenchmarkService.class)
@JaxrsResource
@Produces(MediaType.TEXT_HTML)
@JSONRequired
public class BenchmarkService {

	@Reference
	BenchmarkStorage storage;
	
	@POST
	@Path("benchmark/start/{variant}/{id}/{timestamp}")
	public Response registerAppStart(@PathParam("variant") String appVariant, @PathParam("id") String runId, @PathParam("timestamp") String start) {
		try {
			this.storage.registerAppStart(appVariant, runId, Long.valueOf(start));
			return Response.ok().build();
		} catch (Exception e) {
			return Response.status(Status.BAD_REQUEST).build();
		}
	}
	
	@POST
	@Path("benchmark/end/{variant}/{id}/{timestamp}")
	public Response registerAppEnd(@PathParam("variant") String appVariant, @PathParam("id") String runId, @PathParam("timestamp") String end) {
		try {
			this.storage.registerAppEnd(appVariant, runId, Long.valueOf(end));
			return Response.ok().build();
		} catch (Exception e) {
			return Response.status(Status.BAD_REQUEST).build();
		}
	}
	
	@POST
	@Path("benchmark/registerstartup")
	public Response registerAppStartup(@FormParam("variant") String appVariant, @FormParam("id") String runId, @FormParam("start") String start, @FormParam("end") String end) {
		try {
			this.storage.registerAppStartup(appVariant, runId, Long.valueOf(start), Long.valueOf(end));
			return Response.ok().build();
		} catch (Exception e) {
			return Response.status(Status.BAD_REQUEST).build();
		}
	}
	
	@GET
	@Path("benchmark/details")
	public Response getDetails() {
		StringBuilder builder = new StringBuilder("<table>");
		this.storage.getAppVariants().forEach((variant, avg) -> 
			builder
				.append("<tr><td>")
				.append("<a href='/benchmark/details/").append(variant).append("'>").append(variant).append("</a>")
				.append("</td><td>")
				.append(avg)
				.append(" ms</td></tr>"));
		builder.append("</table>");
		return Response.ok(builder.toString()).build();
	}
	
	@GET
	@Path("benchmark/details/{variant}")
	public Response getDetails(@PathParam("variant") String appVariant) {
		StringBuilder builder = new StringBuilder();
		this.storage.getDataForAppVariant(appVariant).forEach(data -> builder.append(data.runId).append(": duration = ").append((data.end - data.start)).append(" ms<br>"));
		return Response.ok(builder.toString()).build();
	}
}

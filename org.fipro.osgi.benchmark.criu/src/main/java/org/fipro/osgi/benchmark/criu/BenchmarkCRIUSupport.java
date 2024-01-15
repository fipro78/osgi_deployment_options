package org.fipro.osgi.benchmark.criu;

import java.io.FileInputStream;
import java.io.FileWriter;
import java.io.IOException;
import java.net.InetAddress;
import java.net.URI;
import java.net.URLEncoder;
import java.net.UnknownHostException;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Properties;

import org.eclipse.openj9.criu.CRIUSupport;
import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;

@Component
public class BenchmarkCRIUSupport {

    @Activate
    void activate() {
        try {
            String containerInit = System.getProperty("container.init");
            if (Boolean.valueOf(containerInit)) {
                // create the checkpoint
                if (CRIUSupport.isCRIUSupportEnabled()) {

                    try {
                        Thread.sleep(2000);
                    } catch (InterruptedException e) {
                        Thread.currentThread().interrupt();
                    }

                    new CRIUSupport(Paths.get("checkpointData"))
                            .setLeaveRunning(false)
                            .setShellJob(true)
                            .setFileLocks(true)
                            .setLogLevel(4)
                            .setLogFile("logs")
                            .setUnprivileged(true)
                            .setTCPEstablished(true)
                            .checkpointJVM();
                } else {
                    System.err.println("CRIU is not enabled: " + CRIUSupport.getErrorMessage());
                }
            }

            long current = System.currentTimeMillis();

            // It is currently not possible to change or pass new environment variables or command line parameters to a restored process.
            // We therefore use a properties file as workaround.
            Properties benchmarkProps = new Properties();
            benchmarkProps.load(new FileInputStream("/app/benchmark.properties"));

            String appid = benchmarkProps.getProperty("benchmark.appid");
            String executionid = benchmarkProps.getProperty("benchmark.executionid");
            String start = benchmarkProps.getProperty("benchmark.starttime");

            String serviceHost = benchmarkProps.getProperty("benchmark.host", "localhost");

            if (appid != null && executionid != null && start != null) {
                List<String> logs = new ArrayList<>();
                
                HttpClient httpClient = HttpClient.newBuilder()
                    .connectTimeout(Duration.ofSeconds(5))
                    .version(HttpClient.Version.HTTP_2)
                    .build();
                
                
                String formDataString = buildFormDataString(appid, executionid, start, "" + current);
                logs.add("Send request: " + formDataString);

                HttpRequest request = HttpRequest
                        .newBuilder(URI.create("http://" + resolveHostname(serviceHost) + ":8080/benchmark/registerstartup/"))
                        .POST(HttpRequest.BodyPublishers
                                .ofString(formDataString))
                        .build();

                try {
                    HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
                    logs.add("Status: " + response.statusCode());
                } catch (IOException | InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                } finally {

                    try (FileWriter logWriter = new FileWriter("/app/benchmark.log")) {
                        for (String log : logs) {
                            logWriter.write(log);
                            logWriter.write(System.lineSeparator());
                        }
                    }

                    System.exit(0);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private String resolveHostname(String hostname) {
		InetAddress benchmarkServiceAddress;
		try {
			benchmarkServiceAddress = InetAddress.getByName(hostname);
		} catch (UnknownHostException e) {
			// fallback to localhost if the configured hostname is not available
			// only needed for local testing scenarios, probably not a good design for production cases
			throw new IllegalStateException("Address of benchmark service server can not be resolved", e);
		}
		return benchmarkServiceAddress.getHostAddress();
	}

    private String buildFormDataString(String appid, String executionid, String start, String end) {
        var builder = new StringBuilder();

        builder.append(URLEncoder.encode("variant", StandardCharsets.UTF_8));
        builder.append("=");
        builder.append(URLEncoder.encode(appid, StandardCharsets.UTF_8));
        builder.append("&");

        builder.append(URLEncoder.encode("id", StandardCharsets.UTF_8));
        builder.append("=");
        builder.append(URLEncoder.encode(executionid, StandardCharsets.UTF_8));
        builder.append("&");

        builder.append(URLEncoder.encode("start", StandardCharsets.UTF_8));
        builder.append("=");
        builder.append(URLEncoder.encode(start, StandardCharsets.UTF_8));
        builder.append("&");

        builder.append(URLEncoder.encode("end", StandardCharsets.UTF_8));
        builder.append("=");
        builder.append(URLEncoder.encode(end, StandardCharsets.UTF_8));

        return builder.toString();
    }

}

package org.fipro.osgi.benchmark.criu;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.nio.file.Paths;
import java.time.Duration;

import org.eclipse.openj9.criu.CRIUSupport;
import org.osgi.service.component.annotations.Activate;
import org.osgi.service.component.annotations.Component;

@Component
public class BenchmarkCRUISupport {

    @Activate
    void activate() {
        try {
            String containerInit = System.getProperty("container.init");
            if (Boolean.valueOf(containerInit)) {
                // TODO create the checkpoint
                if (CRIUSupport.isCRIUSupportEnabled()) {
                    new CRIUSupport(Paths.get("checkpointData"))
                            .setLeaveRunning(false)
                            .setShellJob(true)
                            .setFileLocks(true)
                            .setLogLevel(4)
                            .setLogFile("logs")
                            .checkpointJVM();
                } else {
                    System.err.println("CRIU is not enabled: " + CRIUSupport.getErrorMessage());
                }

                // perform a graceful shutdown to get the bundle cache created correctly
                System.exit(0);
            }

            long current = System.currentTimeMillis();
            String appid = System.getProperty("benchmark.appid");
            String executionid = System.getProperty("benchmark.executionid");
            String start = System.getProperty("benchmark.starttime");

            String serviceHost = System.getProperty("benchmark.host", "localhost");

            if (appid != null && executionid != null && start != null) {
                HttpClient httpClient = HttpClient.newBuilder()
                        .connectTimeout(Duration.ofSeconds(5))
                        .version(HttpClient.Version.HTTP_2)
                        .build();

                HttpRequest request = HttpRequest
                        .newBuilder(URI.create("http://" + serviceHost + ":8080/benchmark/registerstartup/"))
                        .POST(HttpRequest.BodyPublishers
                                .ofString(buildFormDataString(appid, executionid, start, "" + current)))
                        .build();

                try {
                    HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString());
                    System.out.println("Status: " + response.statusCode());
                } catch (IOException | InterruptedException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                } finally {
                    System.exit(0);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
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

        System.out.println(builder.toString());

        return builder.toString();
    }

}

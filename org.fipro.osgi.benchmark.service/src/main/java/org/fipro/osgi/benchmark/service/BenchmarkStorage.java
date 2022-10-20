package org.fipro.osgi.benchmark.service;

import java.util.Collection;
import java.util.HashMap;
import java.util.Map;
import java.util.TreeMap;
import java.util.concurrent.ConcurrentHashMap;

import org.osgi.service.component.annotations.Component;

@Component(service = BenchmarkStorage.class)
public class BenchmarkStorage {

	Map<String, Map<String, BenchmarkExecutionData>> storage = new ConcurrentHashMap<>();
	
	public void registerAppStart(String appVariant, String runId, long start) {
		Map<String, BenchmarkExecutionData> variantMap = this.storage.computeIfAbsent(appVariant, variant -> new ConcurrentHashMap<>());
		BenchmarkExecutionData tuple = new BenchmarkExecutionData();
		tuple.runId = runId;
		tuple.start = start;
		variantMap.put(runId, tuple);
	}
	
	public void registerAppEnd(String appVariant, String runId, long end) {
		Map<String, BenchmarkExecutionData> variantMap = this.storage.computeIfAbsent(appVariant, variant -> new ConcurrentHashMap<>());
		BenchmarkExecutionData tuple = variantMap.get(runId);
		if (tuple != null) {
			tuple.end = end;
		}
	}
	
	public void registerAppStartup(String appVariant, String runId, long start, long end) {
		Map<String, BenchmarkExecutionData> variantMap = this.storage.computeIfAbsent(appVariant, variant -> new ConcurrentHashMap<>());
		BenchmarkExecutionData tuple = new BenchmarkExecutionData();
		tuple.runId = runId;
		tuple.start = start;
		tuple.end = end;
		variantMap.put(runId, tuple);
	}
	
	public Map<String, Long> getAppVariants() {
		TreeMap<String, Long> result = new TreeMap<>();
		
		this.storage.entrySet().forEach(entry -> {
			long sum = entry.getValue().values().stream().mapToLong(data -> (data.end - data.start)).sum();
			result.put(entry.getKey(), sum / entry.getValue().values().size());
		});
		
		return result;
	}
	
	public Collection<BenchmarkExecutionData> getDataForAppVariant(String appVariant) {
		return this.storage.getOrDefault(appVariant, new HashMap<>()).values();
	}
}

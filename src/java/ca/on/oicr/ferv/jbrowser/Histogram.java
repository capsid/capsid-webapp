package ca.on.oicr.ferv.jbrowser;

import java.util.ArrayList;
import java.util.List;

public class Histogram {
	
	private final int binSize;
	
	private List<Bin> bins = new ArrayList<Bin>();
	
	private int max = 0;
	
	public Histogram(int binSize) {
		this.binSize = binSize;
	}	
	
	public void count(int start) {
		int binIndex = start / binSize;
		while(bins.size() <= binIndex) {
			bins.add(new Bin());
		}
		Bin b = bins.get(binIndex);
		b.freq++;
		max = Math.max(max, b.freq);
	}
	
	public int binSize() {
		return binSize;
	}
	public int binCount() {
		return bins.size();
	}
	public int max() {
		return max;
	}
	
	public double mean() {
		if(bins.size() == 0) return 0;
		int sum = 0;
		for(Bin b : bins) {
			sum += b.freq;
		}
		return sum / (double)bins.size();
	}

	private class Bin {
		int freq;
	}
}

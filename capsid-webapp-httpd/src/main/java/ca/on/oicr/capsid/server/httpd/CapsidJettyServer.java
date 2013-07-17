package ca.on.oicr.capsid.server.httpd;

import java.net.URL;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.util.resource.FileResource;
import org.eclipse.jetty.util.resource.Resource;
import org.eclipse.jetty.xml.XmlConfiguration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class CapsidJettyServer {

	private static final Logger log = LoggerFactory.getLogger(CapsidJettyServer.class);

	private final Server jettyServer;

	public static void main(String[] args) throws Exception {
		CapsidJettyServer server = new CapsidJettyServer();
		server.start();
		server.stop();
	}

	public CapsidJettyServer() throws Exception {
		
		String config = System.getProperty("CAPSID_CONFIG");
		if (config == null) {
			config = System.getProperty("CAPSID_HOME");
			if (config == null) {
				config = System.getProperty("user.dir");
			}
			config = config + "/capsid.xml";
		}
		
		URL configXMLURL = new URL("file", "", config);
		System.err.println("Configuring web server from: " + configXMLURL);
		Resource configXML = new FileResource(configXMLURL);
	
	    XmlConfiguration configuration = new XmlConfiguration(configXML.getInputStream());
	    Server server = (Server)configuration.configure();
	    
	    this.jettyServer = server;
	}

	public boolean isRunning() {
		return this.jettyServer.isRunning();
	}

	public void start() {
		try {
			log.info("Starting CaPSID server on port {}", this.jettyServer.getConnectors()[0].getPort());
			this.jettyServer.start();
			this.jettyServer.join();
		} catch (Exception e) {
			log.error("Error starting Jetty", e);
			throw new RuntimeException(e);
		}
	}

	public void stop() {
		try {
			this.jettyServer.stop();
		} catch (Exception e) {
			// log and ignore
			log.warn("Exception during CaPSID server shutdown", e);
		}

	}

}
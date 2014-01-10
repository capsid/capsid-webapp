package ca.on.oicr.capsid.server.httpd;

import java.net.URL;

import org.eclipse.jetty.server.Server;
import org.eclipse.jetty.util.resource.FileResource;
import org.eclipse.jetty.util.resource.Resource;
import org.eclipse.jetty.xml.XmlConfiguration;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Wrapper class to provide CaPSID's web server using an embedded Jetty. This class uses
 * system properties to direct the web server to an externalized configuration file that
 * configures the system. 
 */
public class CapsidJettyServer {

	/** A logger. */
	private static final Logger log = LoggerFactory.getLogger(CapsidJettyServer.class);

	/** The encapsulated Jetty server instance. */
	private final Server jettyServer;

	/**
	 * Main method for running starts the server, and handles stopping the server 
	 * on exit. 
	 *
	 * @param args command line arguments, which are all entirely ignored.
	 */
	public static void main(String[] args) throws Exception {
		CapsidJettyServer server = new CapsidJettyServer();
		server.start();
		server.stop();
	}

	/**
	 * Primary constructor. Initializes the Jetty server using the files 
	 * pointed to either by the CAPSID_CONFIG system property, or called
	 * "capsid.xml" in the "conf" directory within the location pointed to
	 * by the CAPSID_HOME system property. Once located, this XML file is 
	 * used to configure Jetty in the usual way. 
	 */
	public CapsidJettyServer() throws Exception {
		
		String config = System.getProperty("CAPSID_CONFIG");
		if (config == null) {
			config = System.getProperty("CAPSID_HOME") + "/conf";
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

	/**
	 * Public method to determine whether Jetty is running.
	 *
	 * @return true if Jetty is running
	 */
	public boolean isRunning() {
		return this.jettyServer.isRunning();
	}

	/**
	 * Starts the embedded Jetty server.
	 */
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

	/**
	 * Stops the embedded Jetty server.
	 */
	public void stop() {
		try {
			this.jettyServer.stop();
		} catch (Exception e) {
			// log and ignore
			log.warn("Exception during CaPSID server shutdown", e);
		}
	}
}